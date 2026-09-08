import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["app"] == "MindPower AI"

def test_health_check():
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_safety_engine_crisis_detection():
    # Tests that high-risk language triggers safety escalation
    payload = {
        "messages": [
            {"role": "user", "content": "I feel like I want to end my life"}
        ]
    }
    response = client.post("/api/v1/ai/chat", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["safety_escalated"] == True
    assert data["risk_level"] == "CRITICAL"
    assert "SafetyAgent" in data["agent_name"]

def test_normal_ai_wellness_conversation():
    # Tests normal wellness conversation
    payload = {
        "messages": [
            {"role": "user", "content": "Hello, I want to learn about mindfulness breathing."}
        ]
    }
    response = client.post("/api/v1/ai/chat", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["safety_escalated"] == False
    assert data["risk_level"] == "LOW"