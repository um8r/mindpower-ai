import os
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List, Optional
from openai import OpenAI
from app.safety.rules import SafetyEngine

router = APIRouter(prefix="/ai", tags=["AI Therapy Assistant"])

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    conversation_id: Optional[str] = None
    messages: List[ChatMessage] = []
    email: Optional[str] = None
    prompt: Optional[str] = None

class ChatResponse(BaseModel):
    response: str
    risk_level: str
    safety_escalated: bool
    agent_name: str = "ConversationAgent"

@router.post("/chat", response_model=ChatResponse)
async def chat_with_assistant(payload: ChatRequest):
    messages_list = payload.messages
    if not messages_list and payload.prompt:
        messages_list = [ChatMessage(role="user", content=payload.prompt)]

    if not messages_list:
        raise HTTPException(status_code=400, detail="Messages list or prompt cannot be empty.")
    
    user_latest_msg = messages_list[-1].content
    
    # Safety Check
    is_critical, risk_level, meta = SafetyEngine.evaluate_message(user_latest_msg)
    if is_critical:
        return ChatResponse(
            response=SafetyEngine.get_safety_fallback_response(),
            risk_level=risk_level,
            safety_escalated=True,
            agent_name="SafetyAgent"
        )
    
    # Load OpenAI API keys for fallback
    api_keys = []
    for i in range(1, 10):
        key = os.getenv(f"OPENAI_API_KEY_{i}")
        if key:
            api_keys.append(key)
    
    if not api_keys:
        single_key = os.getenv("OPENAI_API_KEY")
        if single_key:
            api_keys.append(single_key)

    ai_reply_text = None
    system_instruction = (
        "You are MindPower AI, an empathetic, supportive, and professional mental health wellness and therapy assistant. "
        "Provide comforting, psychological guidance, mindfulness advice, and emotional support. "
        "You are not a medical doctor, but offer deep, practical, and compassionate counseling."
    )

    formatted_messages = [{"role": "system", "content": system_instruction}]
    for msg in messages_list:
        role = "user" if msg.role == "user" else "assistant"
        formatted_messages.append({"role": role, "content": msg.content})

    if not api_keys:
        ai_reply_text = "I am here with you, but no OpenAI API keys are configured in your .env file."
    else:
        success = False
        for i, key in enumerate(api_keys):
            try:
                client = OpenAI(api_key=key.strip())
                completion = client.chat.completions.create(
                    model="gpt-4o-mini",
                    messages=formatted_messages,
                )
                ai_reply_text = completion.choices[0].message.content
                success = True
                break 
            except Exception as e:
                print(f"OpenAI Key #{i+1} failed: {str(e)}. Trying next...")
                continue
        
        if not success:
            ai_reply_text = "I am here with you on your healing journey. All configured OpenAI API keys encountered an error or quota limit."

    return ChatResponse(
        response=ai_reply_text,
        risk_level="LOW",
        safety_escalated=False,
        agent_name="ConversationAgent"
    )