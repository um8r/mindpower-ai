import enum
import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, Enum, ForeignKey, Integer, Text, JSON, Numeric, Date
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class UserRole(str, enum.Enum):
    PATIENT = "PATIENT"
    THERAPIST = "THERAPIST"
    ADMIN = "ADMIN"
    SUPER_ADMIN = "SUPER_ADMIN"

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    phone_number = Column(String(50), nullable=True)
    role = Column(Enum(UserRole), nullable=False, default=UserRole.PATIENT)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    profile = relationship("UserProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    patient_profile = relationship("PatientProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    therapist_profile = relationship("TherapistProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")

class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    avatar_url = Column(Text, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    gender = Column(String(50), nullable=True)
    timezone = Column(String(50), default="UTC")
    preferred_language = Column(String(10), default="en")
    emergency_contact = Column(JSON, nullable=True)

    user = relationship("User", back_populates="profile")

class TherapistProfile(Base):
    __tablename__ = "therapist_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    title = Column(String(100), nullable=False)
    qualifications = Column(ARRAY(String), nullable=False, default=[])
    specializations = Column(ARRAY(String), nullable=False, default=[])
    years_experience = Column(Integer, default=0)
    bio = Column(Text, nullable=True)
    hourly_rate = Column(Numeric(10, 2), nullable=True)
    is_approved = Column(Boolean, default=False)
    availability_schedule = Column(JSON, nullable=True)

    user = relationship("User", back_populates="therapist_profile")

class PatientProfile(Base):
    __tablename__ = "patient_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    assigned_therapist_id = Column(UUID(as_uuid=True), ForeignKey("therapist_profiles.id", ondelete="SET NULL"), nullable=True)
    primary_goals = Column(ARRAY(String), nullable=True)
    current_risk_status = Column(String(20), default="LOW")

    user = relationship("User", back_populates="patient_profile")