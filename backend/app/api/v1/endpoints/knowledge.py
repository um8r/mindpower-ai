from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List
from app.ai.rag_engine import RAGEngine

router = APIRouter(prefix="/knowledge", tags=["RAG Knowledge Base"])

class DocumentIngestRequest(BaseModel):
    title: str
    category: str
    content: str
    author: str = "MindPower Artists"

class DocumentIngestResponse(BaseModel):
    message: str
    chunks_created: int
    category: str

@router.post("/ingest", response_model=DocumentIngestResponse, status_code=status.HTTP_201_CREATED)
async def ingest_document(payload: DocumentIngestRequest):
    if not payload.content.strip():
        raise HTTPException(status_code=400, detail="Document content cannot be empty.")
    
    chunks = RAGEngine.chunk_text(payload.content)
    
    return DocumentIngestResponse(
        message=f"Document '{payload.title}' successfully processed and chunked.",
        chunks_created=len(chunks),
        category=payload.category
    )