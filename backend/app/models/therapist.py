import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, ForeignKey, JSON, Enum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import enum
from app.models.user import Base

class SafetyRiskLevel(str, enum.Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"

class SafetyAlertStatus(str, enum.Enum):
    NEW = "NEW"
    REVIEWING = "REVIEWING"
    CONTACTED = "CONTACTED"
    ESCALATED = "ESCALATED"
    RESOLVED = "RESOLVED"

class TherapistNote(Base):
    __tablename__ = "therapist_notes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    therapist_id = Column(UUID(as_uuid=True), ForeignKey("therapist_profiles.id", ondelete="CASCADE"), nullable=False)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("patient_profiles.id", ondelete="CASCADE"), nullable=False)
    content = Column(Text, nullable=False)
    is_private = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

class SafetyAlert(Base):
    __tablename__ = "safety_alerts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("patient_profiles.id", ondelete="CASCADE"), nullable=False)
    risk_level = Column(Enum(SafetyRiskLevel), nullable=False, default=SafetyRiskLevel.HIGH)
    flagged_content = Column(Text, nullable=False)
    status = Column(Enum(SafetyAlertStatus), nullable=False, default=SafetyAlertStatus.NEW)
    assigned_therapist_id = Column(UUID(as_uuid=True), ForeignKey("therapist_profiles.id", ondelete="SET NULL"), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    resolved_at = Column(DateTime(timezone=True), nullable=True)