from __future__ import annotations

from fastapi import APIRouter, Request, Form
from fastapi.responses import RedirectResponse
from fastapi.templating import Jinja2Templates

from app.db import get_conn, init_db
from app.security import hash_pw, verify_pw

router = APIRouter()
templates = Jinja2Templates(directory="templates")

def _seed_defaults():
    init_db()
    conn = get_conn()
    # teacher
    conn.execute("""
      INSERT OR IGNORE INTO users(username, password_hash, role, display_name)
      VALUES (?, ?, 'teacher', ?)
    """, ("teacher", hash_pw("teacher123"), "Teacher"))
    # demo student
    conn.execute("""
      INSERT OR IGNORE INTO users(username, password_hash, role, display_name)
      VALUES (?, ?, 'student', ?)
    """, ("student", hash_pw("student123"), "Student"))
    conn.commit()
    conn.close()

def _set_session(request: Request, uid: int, role: str, username: str):
    request.session["uid"] = uid
    request.session["role"] = role
    request.session["username"] = username

@router.get("/")
def home(request: Request):
    role = request.session.get("role")
    if role == "teacher":
        return RedirectResponse("/teacher/dashboard", status_code=303)
    if role == "student":
        return RedirectResponse("/student/dashboard", status_code=303)
    return RedirectResponse("/login", status_code=303)

@router.get("/login")
def login_page(request: Request):
    _seed_defaults()
    return templates.TemplateResponse("login.html", {"request": request, "error": ""})

@router.post("/login")
def login_post(request: Request, username: str = Form(...), password: str = Form(...)):
    _seed_defaults()
    conn = get_conn()
    row = conn.execute(
        "SELECT id, username, password_hash, role FROM users WHERE username = ?",
        (username.strip(),),
    ).fetchone()
    conn.close()

    if not row or not verify_pw(password, row["password_hash"]):
        return templates.TemplateResponse(
            "login.html",
            {"request": request, "error": "Invalid username or password."},
            status_code=401,
        )

    _set_session(request, int(row["id"]), row["role"], row["username"])
    return RedirectResponse("/teacher/dashboard" if row["role"] == "teacher" else "/student/dashboard", status_code=303)

@router.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/login", status_code=303)
