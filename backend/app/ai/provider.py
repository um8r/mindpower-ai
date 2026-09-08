import os
from typing import AsyncGenerator, Dict, Any, List
from openai import OpenAI
from abc import ABC, abstractmethod

class BaseAIProvider(ABC):
    @abstractmethod
    async def generate_response(
        self, 
        messages: List[Dict[str, str]], 
        system_prompt: str,
        temperature: float = 0.7
    ) -> str:
        pass

    @abstractmethod
    async def stream_response(
        self, 
        messages: List[Dict[str, str]], 
        system_prompt: str,
        temperature: float = 0.7
    ) -> AsyncGenerator[str, None]:
        pass

class OpenAIProvider(BaseAIProvider):
    """Production-ready OpenAI Provider with Multi-Key Fallback Mechanism"""
    
    def _get_client(self):
        # Dynamically fetch multiple keys from environment variables
        api_keys = []
        for i in range(1, 10):
            key = os.getenv(f"OPENAI_API_KEY_{i}")
            if key:
                api_keys.append(key.strip())
        
        if not api_keys:
            single_key = os.getenv("OPENAI_API_KEY")
            if single_key:
                api_keys.append(single_key.strip())
                
        return api_keys

    async def generate_response(
        self, 
        messages: List[Dict[str, str]], 
        system_prompt: str,
        temperature: float = 0.7
    ) -> str:
        api_keys = self._get_client()
        if not api_keys:
            return "I am here with you, but no OpenAI API keys are configured in your .env file."

        formatted_messages = [{"role": "system", "content": system_prompt}]
        for msg in messages:
            role = msg.get("role", "user")
            if role not in ["user", "assistant", "system"]:
                role = "user"
            formatted_messages.append({"role": role, "content": msg.get("content", "")})

        # Try keys sequentially (Fallback)
        for i, key in enumerate(api_keys):
            try:
                client = OpenAI(api_key=key)
                completion = client.chat.completions.create(
                    model="gpt-4o-mini",
                    messages=formatted_messages,
                    temperature=temperature,
                    timeout=15
                )
                return completion.choices[0].message.content
            except Exception as e:
                print(f"[OpenAI Provider] Key #{i+1} failed: {e}. Trying next...")
                continue

        return "I am here with you on your healing journey. All configured OpenAI API keys encountered an error or quota limit."

    async def stream_response(
        self, 
        messages: List[Dict[str, str]], 
        system_prompt: str,
        temperature: float = 0.7
    ) -> AsyncGenerator[str, None]:
        response = await self.generate_response(messages, system_prompt, temperature)
        words = response.split(" ")
        for word in words:
            yield word + " "