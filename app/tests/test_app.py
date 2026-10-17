import pytest
import json
from app import app, APP_VERSION


@pytest.fixture
def client():
    """Create a test client for the app."""
    with app.test_client() as client:
        yield client


def test_index_route(client):
    """Test the main page returns 200 and contains expected content."""
    response = client.get("/")
    assert response.status_code == 200
    assert b"DevOps IA-3" in response.data
    assert b"Automated CI/CD on Azure" in response.data
    # Version from APP_VERSION env var (or default) should appear in the page
    assert APP_VERSION.encode() in response.data


def test_health_route(client):
    """Test the health endpoint returns JSON with status ok and version."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.content_type == "application/json"

    data = json.loads(response.data)
    assert data["status"] == "ok"
    assert "version" in data
    assert isinstance(data["version"], str)
    assert len(data["version"]) > 0


def test_health_version_matches_app_version(client):
    """Test that health endpoint version matches the app's APP_VERSION."""
    response = client.get("/health")
    data = json.loads(response.data)
    # APP_VERSION is read from env at import time; health must return the same value
    assert data["version"] == APP_VERSION
