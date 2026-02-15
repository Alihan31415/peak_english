#!/usr/bin/env bash
set -euo pipefail

rm -rf dist
mkdir -p dist dist/static

# копируем статику
cp -r static/* dist/static/ 2>/dev/null || true

# копируем HTML (у тебя уже есть готовые templates/*.html)
# делаем “псевдо-страницы” как на Pages: /student/speaking -> /student/speaking/index.html
mkdir -p dist/student/{dashboard,chat,speaking,settings} dist/teacher/{dashboard,students,students/new}

cp templates/login.html dist/index.html
cp templates/student/dashboard.html dist/student/dashboard/index.html
cp templates/student/chat.html dist/student/chat/index.html
cp templates/student/speaking.html dist/student/speaking/index.html
cp templates/student/settings.html dist/student/settings/index.html
cp templates/teacher/dashboard.html dist/teacher/dashboard/index.html
cp templates/teacher/students.html dist/teacher/students/index.html
cp templates/teacher/student_new.html dist/teacher/students/new/index.html

# ВАЖНО: так как это статик, POST /login не будет.
# поэтому превращаем логин в “кнопку входа” без POST (чисто демо)
python - <<'PY'
from pathlib import Path
p = Path("dist/index.html")
s = p.read_text(encoding="utf-8", errors="ignore")
s = s.replace('method="post"', 'method="get"')
s = s.replace('action="/login"', 'action="/student/dashboard"')
p.write_text(s, encoding="utf-8")
PY

# редиректы для Pages (чтобы роуты работали)
cat > dist/_redirects <<'TXT'
/student/* /student/dashboard 200
/teacher/* /teacher/dashboard 200
TXT

echo "✅ dist built"
