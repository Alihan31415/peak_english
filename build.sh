#!/usr/bin/env bash
set -euo pipefail

rm -rf dist
mkdir -p dist

python - <<'PY'
from pathlib import Path
from jinja2 import Environment, FileSystemLoader, select_autoescape

env = Environment(
    loader=FileSystemLoader("templates"),
    autoescape=select_autoescape(["html", "xml"]),
)

# Fake minimal context so templates render without FastAPI request/session
class FakeSession(dict): pass
class FakeRequest:
    def __init__(self, role=None):
        self.session = FakeSession()
        if role:
            self.session["role"] = role
            self.session["uid"] = 1
            self.session["username"] = "student"

def render(tpl, out_path, ctx):
    html = env.get_template(tpl).render(**ctx)
    p = Path(out_path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(html, encoding="utf-8")

# pages
render("login.html", "dist/index.html", {"request": FakeRequest(None), "error": ""})
# student
render("student/dashboard.html", "dist/student/dashboard/index.html", {"request": FakeRequest("student"), "me": {"display_name":"Student","username":"student","avatar_path":""}})
render("student/speaking.html",  "dist/student/speaking/index.html",  {"request": FakeRequest("student"), "me": {"display_name":"Student","username":"student","avatar_path":""}})
render("student/chat.html",      "dist/student/chat/index.html",      {"request": FakeRequest("student"), "me": {"display_name":"Student","username":"student","avatar_path":""}})
render("student/settings.html",  "dist/student/settings/index.html",  {"request": FakeRequest("student"), "me": {"display_name":"Student","username":"student","avatar_path":""}, "saved": False, "error": ""})
# teacher (optional)
render("teacher/dashboard.html", "dist/teacher/dashboard/index.html", {"request": FakeRequest("teacher"), "total_students": 12})
render("teacher/students.html",  "dist/teacher/students/index.html",  {"request": FakeRequest("teacher"), "students": []})
render("teacher/student_new.html","dist/teacher/students/new/index.html", {"request": FakeRequest("teacher"), "error": ""})
PY

# copy static to dist/static
mkdir -p dist/static
cp -r static/* dist/static/ 2>/dev/null || true

# Cloudflare Pages SPA-style routing fallback (so /student/chat works)
cat > dist/_redirects <<'TXT'
/student/*  /student/dashboard/  200
/teacher/*  /teacher/dashboard/  200
/*          /index.html          200
TXT

echo "OK: dist generated"
