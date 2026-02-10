from __future__ import annotations

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from starlette.middleware.sessions import SessionMiddleware

from app.db import init_db
from app.routes import auth, student, teacher

app = FastAPI()

# sessions
app.add_middleware(SessionMiddleware, secret_key="dev-secret-change-me")

# static
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.on_event("startup")
def _startup():
    init_db()

# routers
app.include_router(auth.router)
app.include_router(student.router, prefix="/student", tags=["student"])
app.include_router(teacher.router, prefix="/teacher", tags=["teacher"])
