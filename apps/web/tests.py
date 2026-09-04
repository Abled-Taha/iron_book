from django.urls import reverse

# -----------------------------------------------------------------------------
# Fixtures
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------
def test_health_check_returns_200(client):
    """Ensure health check returns HTTP 200 OK."""
    url = reverse("health_check")
    response = client.get(url)

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
