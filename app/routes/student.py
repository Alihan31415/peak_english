from __future__ import annotations

import re
from pathlib import Path

from fastapi import APIRouter, Request, UploadFile, File, Form
from fastapi.responses import RedirectResponse
from fastapi.templating import Jinja2Templates

from app.db import get_conn

router = APIRouter()
templates = Jinja2Templates(directory="templates")

AVATAR_DIR = Path("static/uploads/avatars")

def _require_student(request: Request):
    if request.session.get("role") != "student":
        return RedirectResponse("/login", status_code=303)
    return None

def _get_me(request: Request):
    uid = request.session.get("uid")
    if not uid:
        return None
    conn = get_conn()
    row = conn.execute(
        "SELECT id, username, display_name, avatar_path FROM users WHERE id=?",
        (int(uid),),
    ).fetchone()
    conn.close()
    return row

@router.get("/dashboard")
def dashboard(request: Request):
    r = _require_student(request)
    if r: return r
    me = _get_me(request)
    return templates.TemplateResponse("student/dashboard.html", {"request": request, "me": me})

@router.get("/chat")
def chat(request: Request):
    r = _require_student(request)
    if r: return r
    me = _get_me(request)
    return templates.TemplateResponse("student/chat.html", {"request": request, "me": me})

@router.get("/speaking")
def speaking(request: Request):
    r = _require_student(request)
    if r: return r
    me = _get_me(request)
    return templates.TemplateResponse("student/speaking.html", {"request": request, "me": me})

@router.get("/settings")
def settings(request: Request):
    r = _require_student(request)
    if r: return r
    me = _get_me(request)
    return templates.TemplateResponse("student/settings.html", {"request": request, "me": me, "saved": False, "error": ""})

@router.post("/settings")
async def settings_post(
    request: Request,
    display_name: str = Form(""),
    goal: str = Form("General English"),
    avatar: UploadFile | None = File(None),
):
    r = _require_student(request)
    if r: return r

    uid = int(request.session["uid"])
    display_name = (display_name or "").strip()

    avatar_path = None
    if avatar and avatar.filename:
        # allow only images
        fn = avatar.filename.lower()
        if not re.search(r"\.(png|jpg|jpeg|webp)$", fn):
            me = _get_me(request)
            return templates.TemplateResponse(
                "student/settings.html",
                {"request": request, "me": me, "saved": False, "error": "Avatar must be PNG/JPG/WEBP."},
                status_code=400,
            )

        AVATAR_DIR.mkdir(parents=True, exist_ok=True)
        ext = fn.split(".")[-1]
        out = AVATAR_DIR / f"user-{uid}.{ext}"

        data = await avatar.read()
        # keep it small-ish for demo
        if len(data) > 2_500_000:
            me = _get_me(request)
            return templates.TemplateResponse(
                "student/settings.html",
                {"request": request, "me": me, "saved": False, "error": "Avatar too large (max ~2.5MB)."},
                status_code=400,
            )
        out.write_bytes(data)
        avatar_path = f"/static/uploads/avatars/{out.name}"

    conn = get_conn()
    if avatar_path is not None:
        conn.execute("UPDATE users SET display_name=?, avatar_path=? WHERE id=?",
                     (display_name, avatar_path, uid))
    else:
        conn.execute("UPDATE users SET display_name=? WHERE id=?",
                     (display_name, uid))
    conn.commit()
    conn.close()

    me = _get_me(request)
    return templates.TemplateResponse("student/settings.html", {"request": request, "me": me, "saved": True, "error": ""})
