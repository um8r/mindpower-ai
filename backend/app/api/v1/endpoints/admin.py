from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

router = APIRouter(prefix="/admin", tags=["Admin Web Dashboard & System Governance"])

class TherapistApprovalRequest(BaseModel):
    therapist_id: str
    approve: bool

class UserStatusUpdate(BaseModel):
    user_id: str
    is_active: bool

@router.get("/metrics")
async def get_system_metrics():
    return {
        "total_patients": 142,
        "total_therapists": 18,
        "pending_therapist_approvals": 3,
        "active_safety_alerts": 1,
        "ai_conversations_today": 320,
        "system_status": "Healthy"
    }

@router.post("/therapists/approve")
async def approve_therapist(payload: TherapistApprovalRequest):
    status_str = "approved" if payload.approve else "rejected"
    return {
        "message": f"Therapist account {payload.therapist_id} has been {status_str}.",
        "therapist_id": payload.therapist_id,
        "approved": payload.approve,
        "updated_at": datetime.utcnow().isoformat()
    }

@router.get("/audit-logs")
async def get_audit_logs():
    return [
        {
            "id": "audit-001",
            "action": "SAFETY_ALERT_TRIGGERED",
            "resource_type": "SafetyAlert",
            "resource_id": "alert-1",
            "details": {"risk_level": "HIGH", "patient": "Ali Khan"},
            "timestamp": datetime.utcnow().isoformat()
        },
        {
            "id": "audit-002",
            "action": "THERAPIST_APPROVAL",
            "resource_type": "TherapistProfile",
            "resource_id": "th-55",
            "details": {"approved_by": "admin@mindpowerartists.com"},
            "timestamp": datetime.utcnow().isoformat()
        }
    ]