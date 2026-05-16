"""Shared rate limiter instance."""
from slowapi import Limiter
from slowapi.util import get_remote_address

from app.config import RATE_LIMIT_GLOBAL


limiter = Limiter(key_func=get_remote_address, default_limits=[f"{RATE_LIMIT_GLOBAL}/minute"])
