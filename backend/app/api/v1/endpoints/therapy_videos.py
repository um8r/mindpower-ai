from fastapi import APIRouter
from pydantic import BaseModel
from typing import List

router = APIRouter()

class ResourceItem(BaseModel):
    id: int
    title: str
    description: str
    category: str
    duration: str
    video_url: str
    audio_url: str
    thumbnail_url: str

THERAPY_RESOURCES_DATABASE: List[ResourceItem] = [
    ResourceItem(
        id=1,
        title="Silva 10X Alpha Level Guided Meditation",
        description="Master Alpha brainwave induction for deep mental clarity, subconscious programming, and stress relief.",
        category="MIND CONTROL & FOCUS",
        duration="10 mins",
        video_url="https://www.youtube.com/watch?v=3sxdVXIqu7M",
        audio_url="https://www.youtube.com/watch?v=3sxdVXIqu7M",
        thumbnail_url="https://img.youtube.com/vi/3sxdVXIqu7M/hqdefault.jpg"
    ),
    ResourceItem(
        id=2,
        title="Sufi Heart Meditation (Muraqaba Guide)",
        description="Learn the ancient practice of heart presence and silent breathwork to release anxiety and overthinking.",
        category="SPIRITUAL & EMOTIONAL CALM",
        duration="15 mins",
        video_url="https://www.youtube.com/watch?v=By_J8vojcKs",
        audio_url="https://www.youtube.com/watch?v=By_J8vojcKs",
        thumbnail_url="https://img.youtube.com/vi/By_J8vojcKs/hqdefault.jpg"
    ),
    ResourceItem(
        id=3,
        title="How to Become a Professional Hypnotherapist",
        description="Understanding subconscious mind techniques, emotional release, and therapeutic hypnotherapy.",
        category="HYPNOTHERAPY & SUBCONSCIOUS",
        duration="12 mins",
        video_url="https://www.youtube.com/watch?v=FZ8su4D-t5w",
        audio_url="https://www.youtube.com/watch?v=FZ8su4D-t5w",
        thumbnail_url="https://img.youtube.com/vi/FZ8su4D-t5w/hqdefault.jpg"
    ),
    ResourceItem(
        id=4,
        title="Guided Meditation for Anxiety | The Hourglass",
        description="A gentle grounding exercise designed to instantly relieve physical panic and racing thoughts.",
        category="ANXIETY RELIEF",
        duration="8 mins",
        video_url="https://www.youtube.com/watch?v=pU80BEm43JM",
        audio_url="https://www.youtube.com/watch?v=pU80BEm43JM",
        thumbnail_url="https://img.youtube.com/vi/pU80BEm43JM/hqdefault.jpg"
    ),
    ResourceItem(
        id=5,
        title="Relieving Rumination & Overthinking",
        description="10-minute CBT-based mindfulness meditation to quiet an overactive and restless mind.",
        category="CBT & MINDFULNESS",
        duration="10 mins",
        video_url="https://www.youtube.com/watch?v=4vpQNYthrIc",
        audio_url="https://www.youtube.com/watch?v=4vpQNYthrIc",
        thumbnail_url="https://img.youtube.com/vi/4vpQNYthrIc/hqdefault.jpg"
    ),
    ResourceItem(
        id=6,
        title="Surrender Session: Releasing Deep Stress",
        description="Deep muscle relaxation and mental letting-go techniques for heavy stress and burnout.",
        category="STRESS RELIEF",
        duration="19 mins",
        video_url="https://www.youtube.com/watch?v=6arfMc9Aj4k",
        audio_url="https://www.youtube.com/watch?v=6arfMc9Aj4k",
        thumbnail_url="https://img.youtube.com/vi/6arfMc9Aj4k/hqdefault.jpg"
    ),
    ResourceItem(
        id=7,
        title="Managing Panic Attacks Grounding Session",
        description="Quick breathing control and sensory awareness to stop sudden anxiety spikes.",
        category="PANIC RELIEF",
        duration="9 mins",
        video_url="https://www.youtube.com/watch?v=P3uFPd7eDTs",
        audio_url="https://www.youtube.com/watch?v=P3uFPd7eDTs",
        thumbnail_url="https://img.youtube.com/vi/P3uFPd7eDTs/hqdefault.jpg"
    ),
    ResourceItem(
        id=8,
        title="Quick 4-Minute Calmness Reset",
        description="Fast breathing reset when you need immediate composure during a busy day.",
        category="QUICK CALM",
        duration="4 mins",
        video_url="https://www.youtube.com/watch?v=wuO6nZhD5bo",
        audio_url="https://www.youtube.com/watch?v=wuO6nZhD5bo",
        thumbnail_url="https://img.youtube.com/vi/wuO6nZhD5bo/hqdefault.jpg"
    )
]

@router.get("/videos", response_model=List[ResourceItem])
async def get_therapy_videos():
    return THERAPY_RESOURCES_DATABASE