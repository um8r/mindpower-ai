from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

router = APIRouter(prefix="/therapist", tags=["Therapist Portal & Safety Alerts"])

class ClinicalNoteRequest(BaseModel):
    patient_id: str
    content: str
    is_private: bool = True

class SafetyAlertUpdate(BaseModel):
    alert_id: str
    status: str

@router.get("/patients")
async def get_assigned_patients():
    return [
        {
            "id": "pat-101",
            "name": "Sarah Ahmed",
            "status": "Active",
            "risk_status": "LOW",
            "last_active": "Today, 10:30 AM",
            "current_program": "Mind-Focused Deep Hypnotherapy",
            "next_session": "Tomorrow, 3:00 PM"
        },
        {
            "id": "pat-102",
            "name": "Ali Khan",
            "status": "Needs Review",
            "risk_status": "HIGH",
            "last_active": "Yesterday, 8:15 PM",
            "current_program": "Stress & Anxiety Relief",
            "next_session": "Sep 5, 2026"
        }
    ]

@router.get("/safety-alerts")
async def get_safety_alerts():
    return [
        {
            "id": "alert-1",
            "patient_name": "Ali Khan",
            "risk_level": "HIGH",
            "flagged_content": "I feel so hopeless and stressed out about everything.",
            "status": "NEW",
            "triggered_at": datetime.utcnow().isoformat()
        }
    ]

@router.post("/notes", status_code=status.HTTP_201_CREATED)
async def create_clinical_note(payload: ClinicalNoteRequest):
    return {
        "message": "Clinical note saved securely.",
        "patient_id": payload.patient_id,
        "created_at": datetime.utcnow().isoformat()
    }