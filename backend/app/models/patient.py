import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Numeric, DateTime, Text, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import relationship
from app.models.user import Base

class MoodEntry(Base):
    __tablename__ = "mood_entries"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("patient_profiles.id", ondelete="CASCADE"), nullable=False)
    mood_score = Column(Integer, nullable=False)  # 1 to 10 scale
    stress_level = Column(Integer, nullable=False)  # 1 to 10 scale
    energy_level = Column(Integer, nullable=False)  # 1 to 10 scale
    sleep_hours = Column(Numeric(3, 1), nullable=True)
    journal_note = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)


class TherapyProgram(Base):
    __tablename__ = "therapy_programs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    category = Column(String(100), nullable=False, index=True)
    description = Column(Text, nullable=False)
    duration_weeks = Column(Integer, default=4)
    difficulty_level = Column(String(50), default="Beginner")
    steps = Column(JSON, nullable=True)  # Program steps & guided modules
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)