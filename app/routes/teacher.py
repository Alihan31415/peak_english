from __future__ import annotations

from fastapi import APIRouter, Request, Form
from fastapi.responses import RedirectResponse
from fastapi.templating import Jinja2Templates

from app.db import get_conn
from app.security import hash_pw

router = APIRouter()
templates = Jinja2Templates(directory="templates")

def _require_teacher(request: Request):
    if request.session.get("role") != "teacher":
        return RedirectResponse("/login", status_code=303)
    return None

@router.get("/dashboard")
def dashboard(request: Request):
    r = _require_teacher(request)
    if r: return r

    conn = get_conn()
    total_students = conn.execute("SELECT COUNT(*) AS n FROM users WHERE role='student'").fetchone()["n"]
    conn.close()

    return templates.TemplateResponse(
        "teacher/dashboard.html",
        {"request": request, "total_students": total_students},
    )

@router.get("/students")
def students(request: Request):
    r = _require_teacher(request)
    if r: return r

    conn = get_conn()
    rows = conn.execute(
        "SELECT id, username, display_name, created_at FROM users WHERE role='student' ORDER BY id DESC"
    ).fetchall()
    conn.close()

    return templates.TemplateResponse("teacher/students.html", {"request": request, "students": rows})

@router.get("/students/new")
def students_new(request: Request):
    r = _require_teacher(request)
    if r: return r
    return templates.TemplateResponse("teacher/student_new.html", {"request": request, "error": ""})

@router.post("/students/new")
def students_new_post(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    display_name: str = Form(""),
):
    r = _require_teacher(request)
    if r: return r

    username = username.strip()
    display_name = display_name.strip()

    if len(username) < 3 or len(password) < 4:
        return templates.TemplateResponse(
            "teacher/student_new.html",
            {"request": request, "error": "Username >= 3 chars, password >= 4 chars."},
            status_code=400,
        )

    conn = get_conn()
    try:
        conn.execute(
            "INSERT INTO users(username, password_hash, role, display_name) VALUES (?, ?, 'student', ?)",
            (username, hash_pw(password), display_name),
        )
        conn.commit()
    except Exception:
        conn.close()
        return templates.TemplateResponse(
            "teacher/student_new.html",
            {"request": request, "error": "Username already exists (or DB error)."},
            status_code=400,
        )
    conn.close()

    return RedirectResponse("/teacher/students", status_code=303)
