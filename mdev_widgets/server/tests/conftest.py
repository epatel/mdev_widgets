"""Pytest configuration and fixtures for config server tests."""

import asyncio
import json
import pytest
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))


@pytest.fixture
def event_loop():
    """Create event loop for async tests."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def sample_widget():
    """Sample widget data for testing."""
    return {
        'id': 'testWidget (test.dart:10:5)',
        'widgetType': 'Text',
        'properties': {
            'fontSize': None,
            'fontWeight': None,
            'color': None,
            'visible': True,
            'highlight': False,
        }
    }


@pytest.fixture
def sample_styles():
    """Sample styles data for testing."""
    return {
        'colors': {
            'primary': {'light': '#6200ee', 'dark': '#bb86fc'},
            'secondary': {'light': '#03dac6', 'dark': '#03dac6'},
        },
        'sizes': {
            'padding-sm': 8.0,
            'padding-md': 16.0,
            'padding-lg': 24.0,
        },
        'textStyles': {
            'heading': {
                'fontSize': 24,
                'fontWeight': 'bold',
            },
            'body': {
                'fontSize': 16,
                'fontWeight': 'normal',
            }
        }
    }
