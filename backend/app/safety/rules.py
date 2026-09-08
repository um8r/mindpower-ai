import re
from typing import Dict, Any, Tuple

CRISIS_KEYWORDS = [
    r"\bsuicide\b", r"\bkill myself\b", r"\bend my life\b", r"\bwant to die\b",
    r"\bself-harm\b", r"\bcutting myself\b", r"\boverdose\b", r"\bno reason to live\b"
]

HIGH_RISK_PATTERNS = [re.compile(pattern, re.IGNORECASE) for pattern in CRISIS_KEYWORDS]

class SafetyEngine:
    @staticmethod
    def evaluate_message(content: str) -> Tuple[bool, str, Dict[str, Any]]:
        """
        Evaluates input text for crisis triggers.
        Returns: (is_critical, risk_level, escalation_metadata)
        """
        for pattern in HIGH_RISK_PATTERNS:
            if pattern.search(content):
                return True, "CRITICAL", {
                    "reason": "Immediate self-harm or crisis language detected",
                    "action": "TRIGGER_SAFETY_ESCALATION",
                    "emergency_helpline": "988 (USA) / Regional Emergency Services"
                }
        
        return False, "LOW", {}

    @staticmethod
    def get_safety_fallback_response() -> str:
        return (
            "I'm deeply concerned about what you're experiencing right now. "
            "Because your safety is the absolute priority, I cannot continue this as a standard chat. "
            "Please connect immediately with a licensed professional or emergency support:\n\n"
            "• National Crisis Lifeline: Call or text 988 (Available 24/7)\n"
            "• Emergency Services: Call 911 or visit the nearest hospital\n\n"
            "An alert has also been routed to your assigned therapist team."
        )