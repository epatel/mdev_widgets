info: menu select

# OS Detection for cross-platform compatibility
ifeq ($(OS),Windows_NT)
    OPEN_CMD = start
    PYTHON = python
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Darwin)
        OPEN_CMD = open
    else
        OPEN_CMD = xdg-open
    endif
    PYTHON = python3
endif

VENV_DIR = mdev_widgets/server/.venv
VENV_PYTHON = $(VENV_DIR)/bin/python
VENV_PIP = $(VENV_DIR)/bin/pip

menu:
	echo "1 make server             - Run the Python config server"
	echo "2 make app                - Run the counter app in Chrome"
	echo "3 make demo               - Run the widgets demo app in Chrome"
	echo "4 make all                - Run server (background) and counter app"
	echo "5 make demo-all           - Run server (background) and demo app"
	echo "6 make analyze            - Analyze all packages"
	echo "7 make test               - Run tests"
	echo "8 make build              - Build the counter app for web"
	echo "9 make clean              - Clean build artifacts"
	echo "10 make pub-get           - Get dependencies for all projects"
	echo "11 make stop-server       - Stop any running server"
	echo "12 make dashboard         - Open the config dashboard in browser"
	echo "13 make venv              - Setup Python virtual environment"
	echo "14 make test-server       - Run Python server tests only"

select:
	read -p ">>> " P ; make menu | grep "^$$P " | cut -d ' ' -f2-3 ; make menu | grep "^$$P " | cut -d ' ' -f2-3 | bash

1 2 3 4 5 6 7 8 9 10 11 12 13 14:
	make menu | grep "^$@ " | cut -d ' ' -f2-3 | bash

.SILENT:

.PHONY: info menu select server app demo all demo-all analyze test test-server build clean pub-get stop-server dashboard server-bg venv venv-check

# Setup Python virtual environment
venv:
	echo "Creating virtual environment..."
	$(PYTHON) -m venv $(VENV_DIR)
	echo "Installing dependencies..."
	$(VENV_PIP) install -r mdev_widgets/server/requirements.txt
	echo "Virtual environment ready at $(VENV_DIR)"

# Check if venv exists, create if not
venv-check:
	test -d $(VENV_DIR) || make venv

# Run the Python config server (with venv)
server: venv-check
	cd mdev_widgets/server && ../../$(VENV_PYTHON) config_server.py

# Run server in background (with venv)
server-bg: venv-check
	echo "Starting config server in background..."
	cd mdev_widgets/server && ../../$(VENV_PYTHON) config_server.py &
	sleep 2

# Run the Flutter counter app
app:
	cd mdev_widgets_counter && flutter run -d chrome

# Run the Flutter widgets demo app
demo:
	cd mdev_widgets_demo && flutter run -d chrome

# Run both server and counter app (cleanup server when app exits)
all: server-bg
	cd mdev_widgets_counter && flutter run -d chrome; \
	echo "Stopping server..."; \
	pkill -f "config_server.py" 2>/dev/null || true; \
	echo "Done."

# Run both server and demo app (cleanup server when app exits)
demo-all: server-bg
	cd mdev_widgets_demo && flutter run -d chrome; \
	echo "Stopping server..."; \
	pkill -f "config_server.py" 2>/dev/null || true; \
	echo "Done."

# Analyze code
analyze:
	echo "=== Analyzing mdev_widgets package ==="
	cd mdev_widgets && flutter analyze
	echo ""
	echo "=== Analyzing mdev_widgets_counter ==="
	cd mdev_widgets_counter && flutter analyze
	echo ""
	echo "=== Analyzing mdev_widgets_demo ==="
	cd mdev_widgets_demo && flutter analyze

# Run tests
test: venv-check
	echo "=== Running Python server tests ==="
	cd mdev_widgets/server && ../../$(VENV_PYTHON) -m pytest tests/ -v
	echo ""
	echo "=== Running Flutter tests ==="
	cd mdev_widgets && flutter test
	cd mdev_widgets_counter && flutter test
	@if [ -d mdev_widgets_demo/test ]; then cd mdev_widgets_demo && flutter test; else echo "mdev_widgets_demo: no tests"; fi

# Run only Python server tests
test-server: venv-check
	cd mdev_widgets/server && ../../$(VENV_PYTHON) -m pytest tests/ -v

# Build for web
build:
	cd mdev_widgets_counter && flutter build web

# Clean build artifacts
clean:
	cd mdev_widgets && flutter clean
	cd mdev_widgets_counter && flutter clean
	cd mdev_widgets_demo && flutter clean

# Get dependencies
pub-get:
	cd mdev_widgets && flutter pub get
	cd mdev_widgets_counter && flutter pub get
	cd mdev_widgets_demo && flutter pub get

# Stop any running server
stop-server:
	pkill -f "config_server.py" 2>/dev/null && echo "Server stopped" || echo "No server running"

# Open the config dashboard
dashboard:
	$(OPEN_CMD) http://localhost:8080
