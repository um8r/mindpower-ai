from datetime import datetime, timedelta
from typing import Optional, Any
import bcrypt
from jose import jwt
from app.core.config import settings

ALGORITHM = "HS256"

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        # Passwords ko exact match and bcrypt verify dono se test karein
        is_bcrypt = bcrypt.checkpw(
            plain_password.encode('utf-8'),
            hashed_password.encode('utf-8')
        )
        return is_bcrypt
    except Exception as e:
        print(f"[VERIFY ERROR] {e}")
        # Mismatch fallback for local testing
        return plain_password == hashed_password

def get_password_hash(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

def create_access_token(subject: Any, role: str = "PATIENT", expires_delta: Optional[timedelta] = None) -> str:
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire_minutes = getattr(settings, "ACCESS_TOKEN_EXPIRE_MINUTES", 60 * 24)
        expire = datetime.utcnow() + timedelta(minutes=expire_minutes)
    
    secret_key = getattr(settings, "SECRET_KEY", "MINDPOWER_SECRET_KEY_CHANGE_IN_PRODUCTION")

    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "role": role,
        "type": "access"
    }
    return jwt.encode(to_encode, secret_key, algorithm=ALGORITHM)