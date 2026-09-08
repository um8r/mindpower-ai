import enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime
from app.db.database import Base

class UserRole(str, enum.Enum):
    PATIENT = "PATIENT"
    THERAPIST = "THERAPIST"
    ADMIN = "ADMIN"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, default="PATIENT")
    created_at = Column(DateTime, default=datetime.utcnow)

class ChatLog(Base):
    __tablename__ = "chat_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, index=True, nullable=False)
    user_message = Column(Text, nullable=False)
    bot_response = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

class EmergencyEscalation(Base):
    __tablename__ = "emergency_escalations"

    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, index=True, nullable=False)
    trigger_message = Column(Text, nullable=False)
    risk_level = Column(String, default="HIGH")
    created_at = Column(DateTime, default=datetime.utcnow)

class ThoughtJournal(Base):
    __tablename__ = "thought_journals"

    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, index=True, nullable=False)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    mood = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)