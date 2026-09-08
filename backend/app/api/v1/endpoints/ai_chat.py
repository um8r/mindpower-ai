import os
from pathlib import Path
from dotenv import load_dotenv
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from openai import OpenAI

# Load environment variables
load_dotenv()
load_dotenv(dotenv_path=Path(__file__).resolve().parents[4] / ".env")

router = APIRouter()

class ChatRequest(BaseModel):
    user_id: int = 1
    message: str

SYSTEM_PROMPT = (
    "You are MindPower AI, a compassionate, empathetic, and professional mental health "
    "and therapy assistant. Listen carefully to the user's emotional state, offer validating "
    "and comforting responses, and suggest gentle mindfulness, CBT techniques, or Silva/Sufi "
    "relaxation exercises when applicable. Always maintain a calm, supportive tone."
)

@router.post("/chat")
async def chat_with_patient(request: ChatRequest):
    user_msg = request.message.strip()
    if not user_msg:
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    # Collect all OpenAI API keys dynamically for fallback from .env
    api_keys = []
    for i in range(1, 10):
        key = os.getenv(f"OPENAI_API_KEY_{i}")
        if key:
            api_keys.append(key.strip())
    
    if not api_keys:
        single_key = os.getenv("OPENAI_API_KEY")
        if single_key:
            api_keys.append(single_key.strip())

    ai_reply = None

    # Try keys sequentially (Fallback mechanism)
    if not api_keys:
        ai_reply = "I am here with you, but no OpenAI API keys are configured in your .env file."
    else:
        success = False
        for i, key in enumerate(api_keys):
            try:
                client = OpenAI(api_key=key)
                completion = client.chat.completions.create(
                    model="gpt-4o-mini",
                    messages=[
                        {"role": "system", "content": SYSTEM_PROMPT},
                        {"role": "user", "content": user_msg}
                    ],
                    timeout=10
                )
                ai_reply = completion.choices[0].message.content
                print(f"[SUCCESS] Responded using OpenAI Key #{i+1} (gpt-4o-mini)")
                success = True
                break
            except Exception as e:
                print(f"[OPENAI FAILOVER] Key #{i+1} failed: {e}")
                continue
        
        if not success or not ai_reply:
            ai_reply = "I am here with you on your healing journey. All configured OpenAI API keys encountered an error or quota limit."

    # Non-blocking Database Logging
    try:
        from app.db.session import SessionLocal
        from app.models.chat_log import ChatLog
        
        db = SessionLocal()
        log_entry = ChatLog(
            user_id=request.user_id,
            user_message=user_msg,
            bot_response=ai_reply
        )
        db.add(log_entry)
        db.commit()
        db.close()
        print("[DATABASE] Chat log saved successfully.")
    except Exception as db_err:
        print(f"[DATABASE NOTICE] DB save skipped: {db_err}")

    return {"response": ai_reply}


@router.get("/history/{user_id}")
async def get_chat_history(user_id: int):
    try:
        from app.db.session import SessionLocal
        from app.models.chat_log import ChatLog
        
        db = SessionLocal()
        logs = (
            db.query(ChatLog)
            .filter(ChatLog.user_id == user_id)
            .order_by(ChatLog.id.asc())
            .limit(50)
            .all()
        )
        db.close()

        history = []
        for log in logs:
            history.append({"sender": "user", "message": log.user_message})
            history.append({"sender": "bot", "message": log.bot_response})

        return {"history": history}
    except Exception as e:
        print(f"[HISTORY FETCH ERROR]: {e}")
        return {"history": [], "error": str(e)}