from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel
from app.db.database import get_db
from app.db.models import User
from app.core.security import get_password_hash, verify_password, create_access_token

router = APIRouter()

class SignupRequest(BaseModel):
    full_name: str
    email: str
    password: str
    role: str = "PATIENT"

class LoginRequest(BaseModel):
    email: str
    password: str

@router.post("/signup")
async def signup(request: SignupRequest, db: AsyncSession = Depends(get_db)):
    clean_email = request.email.strip().lower()
    clean_password = request.password.strip()

    result = await db.execute(select(User).where(func.lower(User.email) == clean_email))
    if result.scalars().first():
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        full_name=request.full_name.strip(),
        email=clean_email,
        hashed_password=get_password_hash(clean_password),
        role=request.role
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)

    token = create_access_token(subject=new_user.email, role=new_user.role)
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": new_user.id,
            "full_name": new_user.full_name,
            "email": new_user.email,
            "role": new_user.role
        }
    }

@router.post("/login")
async def login(request: LoginRequest, db: AsyncSession = Depends(get_db)):
    clean_email = request.email.strip().lower()
    clean_password = request.password.strip()

    # Fast direct-match lookup with case fallback
    result = await db.execute(select(User).where(User.email == clean_email))
    user = result.scalars().first()

    if not user:
        result = await db.execute(select(User).where(func.lower(User.email) == clean_email))
        user = result.scalars().first()

    if not user:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if not verify_password(clean_password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token(subject=user.email, role=user.role)
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "role": user.role
        }
    }