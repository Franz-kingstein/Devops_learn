import pytest
import json
from app import app


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
    # Version should be present (from env or default)
    assert b"1.0.0-dev" in response.data or b"APP_VERSION" in response.data


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
    """Test that health endpoint version matches the app's version."""
    response = client.get("/health")
    data = json.loads(response.data)
    # The version should match what the app uses (from env or default)
    expected = app.config.get("APP_VERSION", "1.0.0-dev")
    assert data["version"] == expected or data["version"] == "1.0.0-dev"
