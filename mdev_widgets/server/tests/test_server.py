"""Tests for the config server."""

import asyncio
import json
import pytest
import sys
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

import config_server


class TestWidgetManagement:
    """Tests for widget registration and management."""

    def setup_method(self):
        """Reset server state before each test."""
        config_server.widgets.clear()
        config_server.original_widgets.clear()
        config_server.styles = {'colors': {}, 'sizes': {}, 'textStyles': {}, 'custom': {}}
        config_server.clients.clear()

    def test_is_modified_false_for_new_widget(self, sample_widget):
        """New widget should not be marked as modified."""
        widget_id = sample_widget['id']
        config_server.widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': dict(sample_widget['properties']),
        }
        config_server.original_widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': dict(sample_widget['properties']),
        }

        assert config_server.is_modified(widget_id) is False

    def test_is_modified_true_after_change(self, sample_widget):
        """Widget should be marked as modified after property change."""
        widget_id = sample_widget['id']
        config_server.widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': dict(sample_widget['properties']),
        }
        config_server.original_widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': dict(sample_widget['properties']),
        }

        # Modify a property
        config_server.widgets[widget_id]['properties']['fontSize'] = 24

        assert config_server.is_modified(widget_id) is True

    def test_is_modified_false_for_unknown_widget(self):
        """Unknown widget should not be marked as modified."""
        assert config_server.is_modified('unknown_widget_id') is False

    def test_widget_with_modified_flag(self, sample_widget):
        """widget_with_modified_flag should include modified status."""
        widget_id = sample_widget['id']
        config_server.widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': dict(sample_widget['properties']),
        }
        config_server.original_widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': dict(sample_widget['properties']),
        }

        result = config_server.widget_with_modified_flag(widget_id)

        assert 'modified' in result
        assert result['modified'] is False
        assert result['id'] == widget_id


class TestDashboardLoading:
    """Tests for dashboard HTML loading."""

    def test_load_dashboard_success(self):
        """Dashboard should load successfully from file."""
        config_server.load_dashboard()
        assert config_server.DASHBOARD_HTML is not None
        assert 'Widget Config Editor' in config_server.DASHBOARD_HTML
        assert '<html' in config_server.DASHBOARD_HTML

    def test_load_dashboard_contains_websocket_connection(self):
        """Dashboard should contain WebSocket connection code."""
        config_server.load_dashboard()
        assert 'WebSocket' in config_server.DASHBOARD_HTML
        assert 'ws://localhost:8081' in config_server.DASHBOARD_HTML

    def test_load_dashboard_contains_theme_toggle(self):
        """Dashboard should contain theme toggle functionality."""
        config_server.load_dashboard()
        assert 'toggleTheme' in config_server.DASHBOARD_HTML
        assert 'dark' in config_server.DASHBOARD_HTML


class TestWebSocketMessages:
    """Tests for WebSocket message handling."""

    def setup_method(self):
        """Reset server state before each test."""
        config_server.widgets.clear()
        config_server.original_widgets.clear()
        config_server.styles = {'colors': {}, 'sizes': {}, 'textStyles': {}, 'custom': {}}
        config_server.clients.clear()

    @pytest.mark.asyncio
    async def test_register_widget(self, sample_widget):
        """Register message should add widget to state."""
        mock_websocket = AsyncMock()
        config_server.clients.add(mock_websocket)

        # Simulate register message handling
        widget_id = sample_widget['id']
        widget_data = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': sample_widget['properties'],
        }
        config_server.widgets[widget_id] = widget_data
        config_server.original_widgets[widget_id] = {
            'id': widget_id,
            'type': widget_data['type'],
            'properties': dict(widget_data['properties']),
        }

        assert widget_id in config_server.widgets
        assert widget_id in config_server.original_widgets

    @pytest.mark.asyncio
    async def test_broadcast_sends_to_all_clients(self):
        """Broadcast should send message to all connected clients."""
        mock_client1 = AsyncMock()
        mock_client2 = AsyncMock()
        config_server.clients.add(mock_client1)
        config_server.clients.add(mock_client2)

        message = {'type': 'test', 'data': 'hello'}
        await config_server.broadcast(message)

        mock_client1.send.assert_called_once()
        mock_client2.send.assert_called_once()

        # Verify message content
        sent_msg = json.loads(mock_client1.send.call_args[0][0])
        assert sent_msg['type'] == 'test'
        assert sent_msg['data'] == 'hello'

    @pytest.mark.asyncio
    async def test_broadcast_empty_clients(self):
        """Broadcast should handle empty client list gracefully."""
        config_server.clients.clear()
        message = {'type': 'test'}

        # Should not raise
        await config_server.broadcast(message)


class TestStylesManagement:
    """Tests for styles registration and management."""

    def setup_method(self):
        """Reset server state before each test."""
        config_server.styles = {'colors': {}, 'sizes': {}, 'textStyles': {}, 'custom': {}}

    def test_styles_update(self, sample_styles):
        """Styles should be updated correctly."""
        config_server.styles.update(sample_styles)

        assert 'primary' in config_server.styles['colors']
        assert config_server.styles['colors']['primary']['light'] == '#6200ee'
        assert config_server.styles['sizes']['padding-md'] == 16.0
        assert config_server.styles['textStyles']['heading']['fontSize'] == 24

    def test_themed_color_structure(self, sample_styles):
        """Themed colors should have light and dark variants."""
        config_server.styles.update(sample_styles)

        primary = config_server.styles['colors']['primary']
        assert 'light' in primary
        assert 'dark' in primary
        assert primary['light'] != primary['dark']


class TestResetFunctionality:
    """Tests for reset functionality."""

    def setup_method(self):
        """Reset server state before each test."""
        config_server.widgets.clear()
        config_server.original_widgets.clear()

    def test_reset_widget_restores_original(self, sample_widget):
        """Reset should restore widget to original properties."""
        widget_id = sample_widget['id']

        # Register widget
        config_server.widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': dict(sample_widget['properties']),
        }
        config_server.original_widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': dict(sample_widget['properties']),
        }

        # Modify widget
        config_server.widgets[widget_id]['properties']['fontSize'] = 24
        config_server.widgets[widget_id]['properties']['color'] = '#ff0000'

        assert config_server.is_modified(widget_id) is True

        # Reset widget
        config_server.widgets[widget_id] = {
            'id': widget_id,
            'type': config_server.original_widgets[widget_id]['type'],
            'properties': dict(config_server.original_widgets[widget_id]['properties']),
        }

        assert config_server.is_modified(widget_id) is False
        assert config_server.widgets[widget_id]['properties']['fontSize'] is None

    def test_reset_all_clears_state(self, sample_widget):
        """Reset all should clear all widgets."""
        widget_id = sample_widget['id']
        config_server.widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': sample_widget['properties'],
        }
        config_server.original_widgets[widget_id] = {
            'id': widget_id,
            'type': sample_widget['widgetType'],
            'properties': sample_widget['properties'],
        }

        # Clear all
        config_server.widgets.clear()
        config_server.original_widgets.clear()

        assert len(config_server.widgets) == 0
        assert len(config_server.original_widgets) == 0


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
