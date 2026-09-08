import re

CRISIS_KEYWORDS = [
    r"end it all", r"suicide", r"kill myself", r"want to die", 
    r"hopeless", r"hurt myself", r"no reason to live"
]

class SafetyAgent:
    def evaluate(self, message: str) -> dict:
        text_lower = message.lower()
        
        # Check crisis keywords
        for pattern in CRISIS_KEYWORDS:
            if re.search(pattern, text_lower):
                return {
                    "is_crisis": True,
                    "risk_level": "CRITICAL",
                    "response": (
                        "I hear how much pain you're in right now, but you don't have to carry this alone. "
                        "Please reach out immediately to a trusted professional or a suicide prevention helpline:\n\n"
                        "• National Crisis Helpline: Call or text 988 (USA/Canada)\n"
                        "• Umang Helpline (Pakistan): 0311-7786264\n"
                        "• Emergency Services: Call 911 / 1122\n\n"
                        "Your life matters, and support is available 24/7."
                    )
                }
                
        return {"is_crisis": False, "risk_level": "LOW", "response": None}