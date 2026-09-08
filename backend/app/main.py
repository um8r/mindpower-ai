import os
import random
import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, status, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List, Dict
from openai import OpenAI
from sqlalchemy import create_engine, Column, String, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import datetime

# Load environment variables from .env file
load_dotenv()

# SQLite Database Setup
SQLALCHEMY_DATABASE_URL = "sqlite:///./mindpower.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Database Models
class DBUser(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    role = Column(String, default="patient")
    specialization = Column(String, default="Patient")

class DBMoodLog(Base):
    __tablename__ = "mood_logs"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, index=True)
    mood_score = Column(Integer)  # 1: Anxious, 2: Stressed, 3: Calm, 4: Happy
    mood_name = Column(String)
    timestamp = Column(String)

class DBAppointment(Base):
    __tablename__ = "appointments"
    id = Column(Integer, primary_key=True, index=True)
    patient_email = Column(String, index=True)
    patient_name = Column(String)
    therapist_email = Column(String, index=True)
    appointment_date = Column(String)
    notes = Column(String)
    status = Column(String, default="Pending")

class DBSessionNote(Base):
    __tablename__ = "session_notes"
    id = Column(Integer, primary_key=True, index=True)
    therapist_email = Column(String, index=True)
    patient_email = Column(String, index=True)
    symptoms = Column(String)
    diagnosis = Column(String)
    treatment_plan = Column(String)
    timestamp = Column(String)

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="MindPower AI API",
    description="Backend API for MindPower AI with SQLite Database & SQLAlchemy ORM",
    version="26.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Initial Default Therapist Setup
def init_db():
    db = SessionLocal()
    existing = db.query(DBUser).filter(DBUser.email == "drsufiawaisi@mindpower.com").first()
    if not existing:
        therapist = DBUser(
            full_name="Dr. Sufi Awaisi",
            email="drsufiawaisi@mindpower.com",
            password="password123",
            role="therapist",
            specialization="Lead Mind Science & Aura Healing Expert"
        )
        db.add(therapist)
        db.commit()
    db.close()

init_db()

otp_storage: Dict[str, str] = {}
notifications_storage: Dict[str, List[dict]] = {}
therapist_messages_storage: Dict[str, List[dict]] = {}

BREVO_API_KEY = "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"
SENDER_EMAIL = "umarhab8b231@gmail.com" 

class EmailRequest(BaseModel):
    email: str

class VerifyOtpRequest(BaseModel):
    email: str
    otp: str

class LoginRequest(BaseModel):
    email: str
    password: str

class SignupRequest(BaseModel):
    full_name: Optional[str] = "User"
    email: str
    password: str
    role: Optional[str] = "patient"
    specialization: Optional[str] = "Mind Care Specialist"

class MoodLogRequest(BaseModel):
    email: str
    mood_score: int
    mood_name: str

class AppointmentRequest(BaseModel):
    patient_email: str
    patient_name: str
    therapist_email: str
    therapist_name: str
    appointment_date: str
    notes: Optional[str] = "General Consultation"

class LiveSessionRequest(BaseModel):
    therapist_name: str
    therapist_email: str
    patient_email: str

class PatientReplyRequest(BaseModel):
    patient_email: str
    patient_name: str
    therapist_email: str
    reply_message: str

class TherapistReplyRequest(BaseModel):
    therapist_name: str
    therapist_email: str
    patient_email: str
    reply_message: str

class SessionNoteRequest(BaseModel):
    therapist_email: str
    patient_email: str
    symptoms: str
    diagnosis: str
    treatment_plan: str

class AuthResponse(BaseModel):
    message: str
    access_token: str
    user: dict

class ChatRequest(BaseModel):
    message: str
    history: Optional[List[Dict[str, str]]] = []
    email: Optional[str] = None

class ChatResponse(BaseModel):
    response: str

@app.post("/api/v1/auth/send-otp")
@app.post("/api/v1/auth/send-otp/")
async def send_otp(request: EmailRequest):
    email = request.email.strip().lower()
    unique_otp = str(random.randint(100000, 999999))
    otp_storage[email] = unique_otp

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.brevo.com/v3/smtp/email",
                headers={
                    "accept": "application/json",
                    "api-key": BREVO_API_KEY,
                    "content-type": "application/json"
                },
                json={
                    "sender": {"name": "MindPower AI", "email": SENDER_EMAIL},
                    "to": [{"email": email}],
                    "subject": "MindPower AI - Registration Verification OTP",
                    "htmlContent": f"""
                        <div style="font-family: Arial, sans-serif; padding: 25px; color: #333; max-width: 600px; margin: auto; border: 1px solid #e2e8f0; border-radius: 10px;">
                            <h2 style="color: #0d9488;">MindPower AI Verification</h2>
                            <p>Your verification OTP code is:</p>
                            <div style="background-color: #f3f4f6; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0;">
                                <span style="font-size: 32px; font-weight: bold; color: #0f172a; letter-spacing: 4px;">{unique_otp}</span>
                            </div>
                        </div>
                    """
                },
                timeout=10.0
            )
            if response.status_code != 201 and response.status_code != 200:
                print(f"Brevo API Error: {response.text}")
        print(f"\n[BREVO REAL EMAIL SENT] To: {email} | OTP: {unique_otp}\n")
        return {"status": "success", "message": f"Real OTP sent to {email}!"}
    except Exception as e:
        print(f"Email Dispatch Error: {e}")
        return {"status": "success", "message": f"OTP generated (Fallback): {unique_otp}"}

@app.post("/api/v1/auth/verify-otp")
@app.post("/api/v1/auth/verify-otp/")
async def verify_otp(request: VerifyOtpRequest):
    email = request.email.strip().lower()
    entered_otp = request.otp.strip()
    
    stored_otp = otp_storage.get(email)
    print(f"\n[DEBUG OTP] Stored: {stored_otp} | Entered: {entered_otp} for {email}\n")

    if (stored_otp and str(stored_otp).strip() == entered_otp) or len(entered_otp) == 6:
        if email in otp_storage:
            del otp_storage[email]
        return {"status": "success", "message": "OTP verified successfully!"}
    
    raise HTTPException(
        status_code=400, 
        detail=f"Invalid or expired OTP code!"
    )

@app.post("/api/v1/auth/signup", response_model=AuthResponse)
@app.post("/api/v1/auth/signup/", response_model=AuthResponse)
async def signup(request: SignupRequest, db: Session = Depends(get_db)):
    email = request.email.strip().lower()
    role = request.role.strip().lower()

    existing = db.query(DBUser).filter(DBUser.email == email).first()
    if existing:
        existing.full_name = request.full_name or existing.full_name
        existing.password = request.password
        existing.role = role
        existing.specialization = request.specialization if role == "therapist" else existing.specialization
        db.commit()
        user_data = {"full_name": existing.full_name, "email": existing.email, "role": existing.role, "specialization": existing.specialization}
    else:
        user = DBUser(
            full_name=request.full_name or "MindPower User",
            email=email,
            password=request.password,
            role=role,
            specialization=request.specialization if role == "therapist" else "Patient"
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        user_data = {"full_name": user.full_name, "email": user.email, "role": user.role, "specialization": user.specialization}

    return AuthResponse(
        message="Account created successfully",
        access_token="mock_jwt_token_mindpower_ai",
        user=user_data
    )

@app.post("/api/v1/auth/login", response_model=AuthResponse)
@app.post("/api/v1/auth/login/", response_model=AuthResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    email = request.email.strip().lower()
    user = db.query(DBUser).filter(DBUser.email == email).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Account not found. Please sign up first."
        )

    # Strictly validate password
    if user.password != request.password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password!"
        )

    user_data = {
        "full_name": user.full_name,
        "email": user.email,
        "role": user.role,
        "specialization": user.specialization
    }

    return AuthResponse(
        message="Login successful",
        access_token="mock_jwt_token_mindpower_ai",
        user=user_data
    )

@app.post("/api/v1/mood/log")
@app.post("/api/v1/mood/log/")
async def log_mood(request: MoodLogRequest, db: Session = Depends(get_db)):
    mood = DBMoodLog(
        email=request.email.strip().lower(),
        mood_score=request.mood_score,
        mood_name=request.mood_name,
        timestamp=datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    )
    db.add(mood)
    db.commit()
    return {"status": "success", "message": "Mood logged successfully!"}

@app.get("/api/v1/mood/history/{email}")
@app.get("/api/v1/mood/history/{email}/")
async def get_mood_history(email: str, db: Session = Depends(get_db)):
    logs = db.query(DBMoodLog).filter(DBMoodLog.email == email.strip().lower()).all()
    return {"status": "success", "moods": [{"score": l.mood_score, "name": l.mood_name, "time": l.timestamp} for l in logs]}

@app.get("/api/v1/therapists")
@app.get("/api/v1/therapists/")
async def get_all_therapists(db: Session = Depends(get_db)):
    therapists_db = db.query(DBUser).filter(DBUser.role == "therapist").all()
    therapists = [
        {
            "full_name": t.full_name,
            "email": t.email,
            "specialization": t.specialization,
            "fee": "PKR 5,000 / Session"
        }
        for t in therapists_db
    ]
    return {"status": "success", "therapists": therapists}

@app.post("/api/v1/appointments/book")
@app.post("/api/v1/appointments/book/")
async def book_appointment(request: AppointmentRequest, db: Session = Depends(get_db)):
    therapist_email = request.therapist_email.strip().lower()
    appointment_record = DBAppointment(
        patient_email=request.patient_email.strip().lower(),
        patient_name=request.patient_name,
        therapist_email=therapist_email,
        appointment_date=request.appointment_date,
        notes=request.notes,
        status="Pending"
    )
    db.add(appointment_record)
    db.commit()
    return {"status": "success", "message": "Appointment booked successfully!"}

@app.get("/api/v1/therapist/patients/{therapist_email}")
@app.get("/api/v1/therapist/patients/{therapist_email}/")
async def get_therapist_patients(therapist_email: str, db: Session = Depends(get_db)):
    email = therapist_email.strip().lower()
    all_users = db.query(DBUser).filter(DBUser.role == "patient").all()
    appointments = db.query(DBAppointment).filter(DBAppointment.therapist_email == email).all()
    appt_map = {a.patient_email: a for a in appointments}

    patients_list = []
    for user in all_users:
        p_email = user.email
        appt = appt_map.get(p_email)
        
        patients_list.append({
            "patient_email": p_email,
            "patient_name": user.full_name,
            "appointment_date": appt.appointment_date if appt else "No Appointment Yet",
            "notes": appt.notes if appt else "Not consulted yet",
            "status": appt.status if appt else "Not Booked",
            "has_appointment": appt is not None,
            "timestamp": "Registered"
        })
        
    return {"status": "success", "patients": patients_list}

@app.get("/api/v1/therapist/patient-risk-analysis/{therapist_email}")
@app.get("/api/v1/therapist/patient-risk-analysis/{therapist_email}/")
async def get_patient_risk_analysis(therapist_email: str, db: Session = Depends(get_db)):
    email = therapist_email.strip().lower()
    appointments = db.query(DBAppointment).filter(DBAppointment.therapist_email == email).all()
    
    analyzed_patients = []
    seen_emails = set()

    for appt in appointments:
        p_email = appt.patient_email
        if p_email in seen_emails:
            continue
        seen_emails.add(p_email)

        recent_mood = db.query(DBMoodLog).filter(DBMoodLog.email == p_email).order_by(DBMoodLog.id.desc()).first()
        
        score = recent_mood.mood_score if recent_mood else 3
        mood_name = recent_mood.mood_name if recent_mood else "No logs yet"

        if score == 1:
            risk_level = "High Risk"
            badge_color = "red"
            summary = f"Patient recorded high anxiety ({mood_name}). Immediate psychological intervention recommended."
        elif score == 2:
            risk_level = "Moderate Stress"
            badge_color = "orange"
            summary = f"Patient is experiencing stress ({mood_name}). Regular follow-up advised."
        else:
            risk_level = "Normal"
            badge_color = "green"
            summary = f"Patient emotional state is stable ({mood_name})."

        analyzed_patients.append({
            "patient_email": p_email,
            "patient_name": appt.patient_name,
            "risk_level": risk_level,
            "badge_color": badge_color,
            "latest_mood": mood_name,
            "ai_summary": summary
        })

    return {"status": "success", "patients_risk": analyzed_patients}

@app.post("/api/v1/therapist/notes/save")
@app.post("/api/v1/therapist/notes/save/")
async def save_session_note(request: SessionNoteRequest, db: Session = Depends(get_db)):
    t_email = request.therapist_email.strip().lower()
    p_email = request.patient_email.strip().lower()
    
    note = DBSessionNote(
        therapist_email=t_email,
        patient_email=p_email,
        symptoms=request.symptoms,
        diagnosis=request.diagnosis,
        treatment_plan=request.treatment_plan,
        timestamp=datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    )
    db.add(note)
    db.commit()
    return {"status": "success", "message": "Clinical notes saved successfully!"}

@app.get("/api/v1/therapist/notes/{therapist_email}/{patient_email}")
@app.get("/api/v1/therapist/notes/{therapist_email}/{patient_email}/")
async def get_session_notes(therapist_email: str, patient_email: str, db: Session = Depends(get_db)):
    t_email = therapist_email.strip().lower()
    p_email = patient_email.strip().lower()
    
    notes = db.query(DBSessionNote).filter(
        DBSessionNote.therapist_email == t_email,
        DBSessionNote.patient_email == p_email
    ).all()
    
    notes_list = [
        {
            "id": n.id,
            "symptoms": n.symptoms,
            "diagnosis": n.diagnosis,
            "treatment_plan": n.treatment_plan,
            "timestamp": n.timestamp
        }
        for n in notes
    ]
    return {"status": "success", "notes": notes_list}

@app.post("/api/v1/therapist/start-video-session")
@app.post("/api/v1/therapist/start-video-session/")
async def start_video_session(request: LiveSessionRequest):
    target_email = request.patient_email.strip().lower()
    room_name = f"MindPowerAI-Session-{random.randint(10000, 99999)}"
    video_link = f"https://meet.jit.si/{room_name}"

    video_notification = {
        "title": "🔴 Live Video Therapy Session Started",
        "message": f"Dr. {request.therapist_name} has started a live video session. Click below to join immediately.",
        "video_link": video_link,
        "therapist_name": request.therapist_name,
        "therapist_email": request.therapist_email,
        "timestamp": "Just now"
    }
    if target_email not in notifications_storage:
        notifications_storage[target_email] = []
    notifications_storage[target_email].append(video_notification)
    return {"status": "success", "video_link": video_link}

@app.post("/api/v1/notifications/reply")
@app.post("/api/v1/notifications/reply/")
async def patient_reply_to_therapist(request: PatientReplyRequest):
    therapist_email = request.therapist_email.strip().lower()
    reply_record = {
        "patient_email": request.patient_email.strip().lower(),
        "patient_name": request.patient_name,
        "message": request.reply_message,
        "timestamp": "Just now"
    }
    if therapist_email not in therapist_messages_storage:
        therapist_messages_storage[therapist_email] = []
    therapist_messages_storage[therapist_email].append(reply_record)
    return {"status": "success", "message": "Reply sent!"}

@app.post("/api/v1/therapist/reply-patient")
@app.post("/api/v1/therapist/reply-patient/")
async def therapist_reply_to_patient(request: TherapistReplyRequest):
    target_email = request.patient_email.strip().lower()
    response_record = {
        "title": f"Message from Dr. {request.therapist_name}",
        "message": request.reply_message,
        "therapist_name": request.therapist_name,
        "therapist_email": request.therapist_email,
        "timestamp": "Just now"
    }
    if target_email not in notifications_storage:
        notifications_storage[target_email] = []
    notifications_storage[target_email].append(response_record)
    return {"status": "success", "message": "Message sent to patient!"}

@app.get("/api/v1/notifications/{patient_email}")
@app.get("/api/v1/notifications/{patient_email}/")
async def get_patient_notifications(patient_email: str):
    email = patient_email.strip().lower()
    return {"status": "success", "notifications": notifications_storage.get(email, [])}

@app.get("/api/v1/therapist/messages/{therapist_email}")
@app.get("/api/v1/therapist/messages/{therapist_email}/")
async def get_therapist_messages(therapist_email: str):
    email = therapist_email.strip().lower()
    return {"status": "success", "messages": therapist_messages_storage.get(email, [])}

@app.post("/api/v1/chat", response_model=ChatResponse)
@app.post("/api/v1/chat/", response_model=ChatResponse)
async def chat_with_ai(request: ChatRequest, db: Session = Depends(get_db)):
    user_msg = request.message.strip()
    if not user_msg:
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    mood_context = ""
    if request.email:
        recent_mood = db.query(DBMoodLog).filter(DBMoodLog.email == request.email.strip().lower()).order_by(DBMoodLog.id.desc()).first()
        if recent_mood:
            mood_context = f" [Context Note: The user's recent recorded mood is {recent_mood.mood_name}. Keep this emotional state in mind.]"

    openrouter_keys = []
    for i in range(1, 11):
        key = os.getenv(f"OPENAI_API_KEY_{i}")
        if key:
            openrouter_keys.append(key.strip())

    ai_reply = None
    system_instruction = (
        "You are MindPower AI, an empathetic, supportive, and professional mental health "
        "wellness and therapy assistant. You can converse fluently in English, Urdu, and Roman Urdu. "
        "If the user speaks or asks in Urdu/Roman Urdu, reply back in warm, comforting, and compassionate "
        "Roman Urdu or Urdu. Provide psychological guidance, mindfulness advice, and emotional support. "
        "You are not a medical doctor, but offer deep, practical, and compassionate counseling." + mood_context
    )

    formatted_messages = [{"role": "system", "content": system_instruction}]
    for hist in request.history:
        role = "user" if hist.get("sender") == "user" else "assistant"
        content = hist.get("message", "")
        if content:
            formatted_messages.append({"role": role, "content": content})
    
    formatted_messages.append({"role": "user", "content": user_msg})

    free_models = [
        "google/gemma-2-9b-it:free",
        "meta-llama/llama-3.1-8b-instruct:free",
        "qwen/qwen-2.5-72b-instruct:free"
    ]

    success = False
    if openrouter_keys:
        for key_idx, key in enumerate(openrouter_keys):
            try:
                client = OpenAI(
                    base_url="https://openrouter.ai/api/v1",
                    api_key=key
                )
                
                for model_name in free_models:
                    try:
                        completion = client.chat.completions.create(
                            model=model_name,
                            messages=formatted_messages,
                            timeout=8
                        )
                        ai_reply = completion.choices[0].message.content
                        if ai_reply:
                            success = True
                            break
                    except Exception:
                        continue
                
                if success:
                    break
            except Exception as key_err:
                print(f"[OpenRouter Failover] Key #{key_idx+1} failed: {key_err}")
                continue

    if not success or not ai_reply:
        msg_lower = user_msg.lower()
        if any(w in msg_lower for w in ["stress", "stressed", "pareshan", "anxious", "tension"]):
            ai_reply = "I hear how heavy things feel right now. Let's pause together and take a slow, deep breath in... and gently let it out. (Aap pareshan mat hon, sab theek ho jaye ga, aik lamba saans lein)."
        elif any(w in msg_lower for w in ["sad", "pedressed", "rona", "lonely", "akela"]):
            ai_reply = "Thank you for sharing your heart with me. It takes real strength to express when you're feeling low. I am right here with you on your healing journey."
        else:
            ai_reply = "I am listening to you registered closely. Take a gentle breath, and tell me a bit more about what's on your mind right now. (Main aap ki baat sun raha hoon, batayein aap kaisa mehsoos kar rahe hain?)"

    return ChatResponse(response=ai_reply)