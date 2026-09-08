from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from typing import List
from app.db.database import get_db
from app.db.models import ThoughtJournal

router = APIRouter()

class JournalCreateRequest(BaseModel):
    user_email: str
    mood: str
    situation: str
    negative_thought: str
    rational_thought: str

@router.post("/entry")
async def create_journal_entry(request: JournalCreateRequest, db: AsyncSession = Depends(get_db)):
    entry = ThoughtJournal(
        user_email=request.user_email.strip().lower(),
        mood=request.mood,
        situation=request.situation,
        negative_thought=request.negative_thought,
        rational_thought=request.rational_thought
    )
    db.add(entry)
    await db.commit()
    await db.refresh(entry)
    return {"message": "Journal entry saved successfully", "id": entry.id}

@router.get("/user/{email}")
async def get_user_journals(email: str, db: AsyncSession = Depends(get_db)):
    clean_email = email.strip().lower()
    result = await db.execute(
        select(ThoughtJournal)
        .where(ThoughtJournal.user_email == clean_email)
        .order_by(ThoughtJournal.created_at.desc())
    )
    entries = result.scalars().all()
    return {"journals": entries}