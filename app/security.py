from __future__ import annotations
from passlib.hash import pbkdf2_sha256

def hash_pw(pw: str) -> str:
    return pbkdf2_sha256.hash(pw)

def verify_pw(pw: str, hashed: str) -> bool:
    try:
        return pbkdf2_sha256.verify(pw, hashed)
    except Exception:
        return False
