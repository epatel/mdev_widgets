#!/usr/bin/env python3
"""
Widget Config Server

A WebSocket server for live-editing Flutter widget configurations.
Provides a web dashboard at http://localhost:8080 and WebSocket API at ws://localhost:8081.
"""

import asyncio
import json
from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import signal
import subprocess
import sys
import threading
import websockets

# Server state
widgets = {}
original_widgets = {}
schemas = {}  # Widget type -> schema (from first registration)
styles = {'colors': {}, 'sizes': {}, 'textStyles': {}, 'custom': {}}
clients = set()

# Dashboard HTML (loaded from file)
DASHBOARD_HTML = None
DASHBOARD_PATH = Path(__file__).parent / 'dashboard.html'


def load_dashboard():
    """Load dashboard HTML from file."""
    global DASHBOARD_HTML
    try:
        DASHBOARD_HTML = DASHBOARD_PATH.read_text(encoding='utf-8')
    except FileNotFoundError:
        DASHBOARD_HTML = '<html><body><h1>Error: dashboard.html not found</h1></body></html>'


def is_modified(widget_id):
    """Check if widget has been modified from its original state."""
    if widget_id not in original_widgets:
        return False
    orig = original_widgets[widget_id]
    curr = widgets[widget_id]
    return orig.get('properties') != curr.get('properties')


def widget_with_modified_flag(widget_id):
    """Return widget data with modified flag."""
    w = widgets[widget_id].copy()
    w['modified'] = is_modified(widget_id)
    return w


async def handle_websocket(websocket):
    """Handle WebSocket connections from Flutter app and dashboard."""
    clients.add(websocket)
    print(f"Client connected. Total clients: {len(clients)}")

    try:
        async for message in websocket:
            data = json.loads(message)
            msg_type = data.get('type')

            if msg_type == 'register':
                widget_id = data['id']
                widget_type = data.get('widgetType', 'unknown')
                widget_data = {
                    'id': widget_id,
                    'type': widget_type,
                    'properties': data.get('properties', {}),
                }

                # Store schema if provided (first registration for this type wins)
                if 'schema' in data and widget_type not in schemas:
                    schemas[widget_type] = data['schema']
                    print(f"Registered schema for {widget_type}: {len(data['schema'])} properties")

                # Include schema in widget data for dashboard
                if widget_type in schemas:
                    widget_data['schema'] = schemas[widget_type]

                widgets[widget_id] = widget_data
                original_widgets[widget_id] = {
                    'id': widget_id,
                    'type': widget_data['type'],
                    'properties': dict(widget_data['properties']),
                }
                print(f"Registered widget: {widget_id} ({widget_data['type']})")
                await broadcast({'type': 'update', 'data': widget_with_modified_flag(widget_id)})

            elif msg_type == 'unregister':
                widget_id = data['id']
                if widget_id in widgets:
                    del widgets[widget_id]
                    if widget_id in original_widgets:
                        del original_widgets[widget_id]
                    print(f"Unregistered widget: {widget_id}")
                    all_widgets = {wid: widget_with_modified_flag(wid) for wid in widgets}
                    await broadcast({'type': 'widgets', 'data': all_widgets})

            elif msg_type == 'get_all':
                all_widgets = {wid: widget_with_modified_flag(wid) for wid in widgets}
                await websocket.send(json.dumps({'type': 'widgets', 'data': all_widgets}))
                await websocket.send(json.dumps({'type': 'styles', 'data': styles}))
                await websocket.send(json.dumps({'type': 'schemas', 'data': schemas}))

            elif msg_type == 'styles':
                styles.update(data.get('data', {}))
                print(f"Updated styles: {list(styles.keys())}")
                await broadcast({'type': 'styles', 'data': styles})

            elif msg_type == 'update_prop':
                widget_id = data['id']
                if widget_id in widgets:
                    key = data['key']
                    value = data['value']
                    widgets[widget_id]['properties'][key] = value
                    print(f"Updated widget {widget_id}: {key} = {value}")
                    await broadcast({'type': 'update', 'data': widget_with_modified_flag(widget_id)})

            elif msg_type == 'reset':
                widget_id = data['id']
                if widget_id in widgets and widget_id in original_widgets:
                    widget_type = original_widgets[widget_id]['type']
                    widgets[widget_id] = {
                        'id': widget_id,
                        'type': widget_type,
                        'properties': dict(original_widgets[widget_id]['properties']),
                    }
                    # Re-add schema if available
                    if widget_type in schemas:
                        widgets[widget_id]['schema'] = schemas[widget_type]
                    print(f"Reset widget: {widget_id}")
                    await broadcast({'type': 'update', 'data': widget_with_modified_flag(widget_id)})

            elif msg_type == 'reset_all_changes':
                for widget_id in list(widgets.keys()):
                    if widget_id in original_widgets:
                        widget_type = original_widgets[widget_id]['type']
                        widgets[widget_id] = {
                            'id': widget_id,
                            'type': widget_type,
                            'properties': dict(original_widgets[widget_id]['properties']),
                        }
                        if widget_type in schemas:
                            widgets[widget_id]['schema'] = schemas[widget_type]
                print("Reset all widgets to original values")
                all_widgets = {wid: widget_with_modified_flag(wid) for wid in widgets}
                await broadcast({'type': 'widgets', 'data': all_widgets})

            elif msg_type == 'reset_all':
                widgets.clear()
                original_widgets.clear()
                schemas.clear()
                print("Cleared all widgets and schemas")
                await broadcast({'type': 'widgets', 'data': {}})
                await broadcast({'type': 'schemas', 'data': {}})

    except websockets.exceptions.ConnectionClosed:
        pass
    finally:
        clients.discard(websocket)
        print(f"Client disconnected. Total clients: {len(clients)}")


async def broadcast(message):
    """Broadcast message to all connected clients."""
    if clients:
        msg = json.dumps(message)
        await asyncio.gather(*[client.send(msg) for client in clients])


class ConfigHTTPHandler(SimpleHTTPRequestHandler):
    """HTTP handler for serving the dashboard."""

    def do_GET(self):
        if self.path == '/' or self.path == '/index.html':
            # Reload dashboard on each request (for development)
            load_dashboard()
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(DASHBOARD_HTML.encode())
        else:
            self.send_error(404)

    def log_message(self, format, *args):
        print(f"HTTP: {args[0]}")


def run_http_server(port=8080):
    """Run HTTP server in a thread."""
    server = HTTPServer(('', port), ConfigHTTPHandler)
    print(f"HTTP server running at http://localhost:{port}")
    server.serve_forever()


async def main():
    """Main entry point for the server."""
    load_dashboard()

    loop = asyncio.get_event_loop()
    stop = loop.create_future()

    def handle_signal():
        print("\nShutting down...")
        stop.set_result(None)

    for sig in (signal.SIGINT, signal.SIGTERM):
        try:
            loop.add_signal_handler(sig, handle_signal)
        except NotImplementedError:
            signal.signal(sig, lambda s, f: handle_signal())

    http_thread = threading.Thread(target=run_http_server, args=(8080,), daemon=True)
    http_thread.start()

    print("WebSocket server running at ws://localhost:8081")
    async with websockets.serve(handle_websocket, "localhost", 8081):
        await stop


def run_with_reload():
    """Run server with auto-reload on file changes."""
    script_path = Path(__file__).absolute()
    dashboard_path = DASHBOARD_PATH

    watch_files = [script_path, dashboard_path]
    last_mtimes = {f: f.stat().st_mtime for f in watch_files if f.exists()}

    while True:
        print("Starting server (auto-reload enabled)...")
        print(f"  Watching: {', '.join(f.name for f in watch_files)}")
        process = subprocess.Popen([sys.executable, str(script_path), '--no-reload'])

        try:
            while process.poll() is None:
                for path in watch_files:
                    if path.exists():
                        current_mtime = path.stat().st_mtime
                        if path not in last_mtimes or current_mtime != last_mtimes[path]:
                            print(f"\n>>> {path.name} changed, restarting server...\n")
                            last_mtimes[path] = current_mtime
                            process.terminate()
                            process.wait()
                            break
                else:
                    threading.Event().wait(1)
                    continue
                break  # File changed, restart
            else:
                break  # Process ended normally
        except KeyboardInterrupt:
            process.terminate()
            process.wait()
            break

    print("Server stopped.")


if __name__ == '__main__':
    if '--no-reload' in sys.argv:
        print("Starting Widget Config Server...")
        print("  - Config Editor: http://localhost:8080")
        print("  - WebSocket: ws://localhost:8081")
        print("Press Ctrl+C to stop\n")
        try:
            asyncio.run(main())
        except KeyboardInterrupt:
            pass
        print("Server stopped.")
    else:
        run_with_reload()
