import os
from typing import List, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "MindPower AI"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "DEV_SECRET_KEY_MUST_BE_CHANGED_IN_PRODUCTION_32CHAR_MIN"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 Days
    
    # Database
    POSTGRES_SERVER: str = os.getenv("POSTGRES_SERVER", "localhost")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "mindpower_user")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "mindpower_password")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "mindpower_db")
    
    @property
    def ASYNC_DATABASE_URI(self) -> str:
        return f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

    # AI Service Settings
    AI_PROVIDER: str = "OPENAI" # Options: OPENAI, GEMINI, LOCAL
    AI_API_KEY: Optional[str] = None
    
    CORS_ORIGINS: List[str] = ["*"]

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True, extra="ignore")

settings = Settings()