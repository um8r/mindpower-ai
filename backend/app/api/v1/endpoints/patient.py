from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

router = APIRouter(prefix="/patient", tags=["Patient Portal & Mood Tracking"])

class MoodLogRequest(BaseModel):
    mood_score: int = Field(..., ge=1, le=10, description="1=Very Low, 10=Excellent")
    stress_level: int = Field(..., ge=1, le=10)
    energy_level: int = Field(..., ge=1, le=10)
    sleep_hours: float = Field(..., ge=0, le=24)
    journal_note: Optional[str] = None

class MoodLogResponse(BaseModel):
    message: str
    mood_score: int
    logged_at: str

@router.post("/mood", response_model=MoodLogResponse, status_code=status.HTTP_201_CREATED)
async def log_daily_mood(payload: MoodLogRequest):
    return MoodLogResponse(
        message="Mood entry successfully recorded.",
        mood_score=payload.mood_score,
        logged_at=datetime.utcnow().isoformat()
    )

@router.get("/programs")
async def get_therapy_programs():
    # Approved MindPower Artists Therapy Categories
    return [
        {
            "id": "prog-1",
            "title": "Mind-Focused Deep Hypnotherapy",
            "category": "Behavioral & Subconscious",
            "description": "Guided relaxation and subconscious reconditioning for habit transformation and emotional alignment.",
            "duration": "4 Weeks",
            "difficulty": "All Levels"
        },
        {
            "id": "prog-2",
            "title": "Sufi Mind Control & Silva 10X Meditation",
            "category": "Mindfulness & Energy",
            "description": "Disciplined mental focus, high-energy alignment, and deep self-awareness techniques.",
            "duration": "6 Weeks",
            "difficulty": "Intermediate"
        },
        {
            "id": "prog-3",
            "title": "Stress & Anxiety Relief Therapy",
            "category": "Mental Wellness",
            "description": "Evidence-based counseling support, 4-7-8 breathing exercises, and sensory grounding.",
            "duration": "2 Weeks",
            "difficulty": "Beginner"
        }
    ]