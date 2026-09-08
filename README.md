# MindPower AI
> **AI-Powered Support. Human-Centered Care.**

MindPower AI is an enterprise-grade AI-assisted therapy, wellness, and therapist management platform.

## Architecture Highlights
- **Frontend:** Flutter (iOS/Android/Desktop) with Material 3 & Clean Architecture.
- **Backend:** FastAPI, SQLAlchemy 2.0, Pydantic v2.
- **Database:** PostgreSQL 16 with `pgvector` extension for RAG semantics.
- **AI Engine:** Provider-agnostic multi-agent system (Conversation, Safety, RAG).

## How to Run Locally

### 1. Run Backend via Python directly
```bash
cd backend
python -m uvicorn app.main:app --reload