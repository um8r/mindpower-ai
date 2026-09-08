import os
import math
from typing import List, Dict, Any
from openai import OpenAI

class RAGEngine:
    """Retrieval-Augmented Generation Service for MindPower Approved Content"""

    @staticmethod
    def chunk_text(text: str, chunk_size: int = 500, overlap: int = 50) -> List[str]:
        """Splits long clinical/program text into overlapping chunks."""
        words = text.split()
        if not words:
            return []
        
        chunks = []
        i = 0
        while i < len(words):
            chunk = " ".join(words[i : i + chunk_size])
            chunks.append(chunk)
            i += chunk_size - overlap
        return chunks

    @staticmethod
    async def generate_embedding(text: str) -> List[float]:
        """Generates real embedding using OpenAI text-embedding-3-small or fallback mock vector."""
        api_keys = []
        for i in range(1, 10):
            k = os.getenv(f"OPENAI_API_KEY_{i}")
            if k:
                api_keys.append(k.strip())
        if not api_keys and os.getenv("OPENAI_API_KEY"):
            api_keys.append(os.getenv("OPENAI_API_KEY").strip())

        if api_keys:
            try:
                client = OpenAI(api_key=api_keys[0])
                response = client.embeddings.create(
                    model="text-embedding-3-small",
                    input=text[:8000]
                )
                return response.data[0].embedding
            except Exception as e:
                print(f"[Embedding Fallback Warning]: {e}")

        # Fallback deterministic mock vector if API call fails
        seed = sum(ord(c) for c in text[:50]) if text else 1.0
        return [math.sin(seed + idx) for idx in range(1536)]

    @staticmethod
    def retrieve_relevant_context(user_query: str, top_k: int = 2) -> List[Dict[str, Any]]:
        """Retrieves top matching knowledge fragments for patient questions."""
        approved_kb = [
            {
                "category": "Hypnotherapy & Mind Relaxation",
                "content": "MindPower Artists Hypnotherapy focuses on mind-focused deep relaxation, guided self-management, and subconscious behavioral transformation."
            },
            {
                "category": "Energy & Personal Growth",
                "content": "Sufi Mind Control and Silva 10X principles emphasize disciplined focus, stress reduction, daily meditation, and self-awareness exercises."
            },
            {
                "category": "Stress & Anxiety Support",
                "content": "For acute stress management, patients are guided through 4-7-8 breathing techniques and sensory grounding activities."
            }
        ]
        
        query_lower = user_query.lower()
        matched = []
        for doc in approved_kb:
            if any(term in query_lower for term in ["stress", "relax", "hypno", "sufi", "mind", "anxiety", "depression", "sad"]):
                matched.append(doc)
        
        return matched[:top_k] if matched else [approved_kb[0]]