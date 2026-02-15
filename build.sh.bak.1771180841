#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST="$ROOT/dist"

rm -rf "$DIST"
mkdir -p "$DIST/static"

# copy CSS to dist
if [ -f "$ROOT/static/app.css" ]; then
  cp "$ROOT/static/app.css" "$DIST/static/app.css"
else
  echo "ERROR: static/app.css not found"
  exit 1
fi

# Cloudflare Pages redirect rules (optional but handy)
cat > "$DIST/_redirects" <<'TXT'
/student/dashboard  /student/dashboard/  301
/student/chat       /student/chat/       301
/student/speaking   /student/speaking/   301
/student/settings   /student/settings/   301
/teacher/dashboard  /teacher/dashboard/  301
/teacher/students   /teacher/students/   301
/teacher/students/new /teacher/students/new/ 301
TXT

layout() {
  local title="$1"
  local body="$2"
  cat <<HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
  <title>${title}</title>
  <link rel="stylesheet" href="/static/app.css?v=1"/>
</head>
<body>
  <div class="bg-glow"></div>

  <header class="topbar">
    <div class="topbar-inner">
      <a class="brand" href="/">Peak English</a>
      <nav class="nav">
        <a class="nav-link" href="/student/dashboard/">Dashboard</a>
        <a class="nav-link" href="/student/speaking/">Speaking</a>
        <a class="nav-link" href="/student/chat/">Chat</a>
        <a class="nav-link" href="/student/settings/">Settings</a>
        <a class="nav-pill" href="/" title="Demo logout">Logout</a>
      </nav>
    </div>
  </header>

  <main class="page">
    <div class="wrap">
      ${body}
    </div>
  </main>
</body>
</html>
HTML
}

write_page() {
  local out="$1"
  local title="$2"
  local body="$3"
  mkdir -p "$(dirname "$out")"
  layout "$title" "$body" > "$out"
}

# ---------- LOGIN (/) ----------
cat > "$DIST/index.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
  <title>Peak English — Demo</title>
  <link rel="stylesheet" href="/static/app.css?v=1"/>
</head>
<body>
  <div class="bg-glow"></div>

  <header class="topbar">
    <div class="topbar-inner">
      <a class="brand" href="/">Peak English</a>
      <nav class="nav">
        <a class="nav-link" href="/student/dashboard/">Student</a>
        <a class="nav-link" href="/teacher/dashboard/">Teacher</a>
      </nav>
    </div>
  </header>

  <main class="page">
    <div class="wrap">
      <section class="hero">
        <div class="hero-card">
          <div class="hero-badge">Demo • Static build (Cloudflare Pages)</div>
          <h1 class="hero-title">Sign in</h1>
          <p class="hero-sub">Static demo: no real server login. Redirects locally.</p>

          <form class="form" id="loginForm">
            <label class="lbl">Username</label>
            <input class="input" name="username" autocomplete="username" required>

            <label class="lbl">Password</label>
            <input class="input" type="password" name="password" autocomplete="current-password" required>

            <button class="btn primary full" type="submit">Login</button>
          </form>

          <div class="hint">
            Demo accounts:
            <div class="chips">
              <span class="chip">teacher / teacher123</span>
              <span class="chip">student / student123</span>
            </div>
          </div>
        </div>
      </section>
    </div>
  </main>

<script>
(function(){
  const form = document.getElementById("loginForm");
  form.addEventListener("submit", (e)=>{
    e.preventDefault();
    const fd = new FormData(form);
    const u = String(fd.get("username") || "").trim().toLowerCase();
    if (u === "teacher") location.href = "/teacher/dashboard/";
    else location.href = "/student/dashboard/";
  });
})();
</script>
</body>
</html>
HTML

# ---------- STUDENT DASHBOARD ----------
write_page "$DIST/student/dashboard/index.html" "Peak English — Student" '
<section class="section">
  <div class="section-head">
    <div class="row" style="justify-content:space-between; align-items:flex-end;">
      <div>
        <h1 class="h1">Student</h1>
        <p class="sub">Quick access. Wide. Touch-friendly.</p>
      </div>
      <div class="row" style="gap:10px; align-items:center;">
        <div class="avatar avatar-fallback">A</div>
      </div>
    </div>
  </div>

  <div class="tiles">
    <a class="tile" href="/student/speaking/">
      <div class="tile-title">Speaking</div>
      <div class="tile-sub">Mic demo, transcript, feedback</div>
      <div class="mini-row">
        <span class="pill">~60 sec</span>
        <span class="pill">B/W UI</span>
      </div>
    </a>

    <a class="tile" href="/student/chat/">
      <div class="tile-title">Chat</div>
      <div class="tile-sub">Dialog trainer, corrections, prompts</div>
      <div class="mini-row">
        <span class="pill">fast</span>
        <span class="pill">task-based</span>
      </div>
    </a>

    <a class="tile" href="/student/settings/">
      <div class="tile-title">Settings</div>
      <div class="tile-sub">Goal, level, avatar (demo)</div>
      <div class="mini-row">
        <span class="pill">profile</span>
        <span class="pill">demo</span>
      </div>
    </a>

    <div class="tile tile-static">
      <div class="tile-title">Daily word</div>
      <div class="tile-sub">Demo card for the pitch</div>
      <div class="mini-card">
        <div class="mini-top">resilient</div>
        <div class="mini-sub">able to recover quickly from difficulties</div>
        <div class="mini-ex">She stayed resilient despite the setbacks.</div>
      </div>
    </div>
  </div>
</section>
'

# ---------- STUDENT SPEAKING ----------
write_page "$DIST/student/speaking/index.html" "Peak English — Speaking" '
<section class="section section-wide">
  <div class="section-head head-row">
    <div>
      <h1 class="h1">Speaking</h1>
      <p class="sub">Demo UI: mic, timer, transcript, feedback. (No backend audio yet)</p>
    </div>
    <span class="badge">Demo</span>
  </div>

  <div class="grid">
    <div class="col-8">
      <div class="panel">
        <div class="label">Prompt</div>
        <div class="prompt">Describe your last weekend in 45–60 seconds.</div>
        <div class="muted small">Use: past simple + 1–2 linking words (first, because, however).</div>

        <div class="divider"></div>

        <div class="row" style="justify-content:space-between;">
          <button class="btn primary mic" id="micBtn">🎙 Hold to talk</button>
          <div class="row" style="gap:10px;">
            <span class="pill" id="timer">00:47</span>
            <span class="pill">EN</span>
            <span class="pill">Speed: normal</span>
          </div>
        </div>

        <div class="wave" aria-hidden="true">
          <span></span><span></span><span></span><span></span><span></span>
          <span></span><span></span><span></span><span></span><span></span>
        </div>

        <div class="divider"></div>

        <div class="label">Transcript (demo)</div>
        <div class="bubble wide">
          “Last weekend I visited my friends. We had dinner at home and watched a movie.
          I was tired, but it was relaxing and I enjoyed it.”
        </div>

        <div class="divider"></div>

        <div class="label">Feedback (demo)</div>
        <div class="mini-row">
          <span class="pill">Pronunciation: Good</span>
          <span class="pill">Grammar: Minor issues</span>
          <span class="pill">Fluency: Improving</span>
        </div>
        <div class="muted small" style="margin-top:8px;">
          Tip: add 1 detail + 1 reason. Example: “because it helped me rest after work”.
        </div>
      </div>
    </div>

    <div class="col-4">
      <div class="panel">
        <div class="label">Quick stats</div>
        <div class="kpi-num">7</div>
        <div class="muted small">day streak</div>
        <div class="divider"></div>
        <a class="btn primary full" href="/student/chat/">Continue in Chat</a>
      </div>
    </div>
  </div>

  <script>
  (function(){
    const btn = document.getElementById("micBtn");
    const timer = document.getElementById("timer");
    let down = false;
    let t = 47;

    function fmt(n){ return String(n).padStart(2,'0'); }
    function render(){
      const m = Math.floor(t/60), s = t%60;
      timer.textContent = `${fmt(m)}:${fmt(s)}`;
    }
    function tick(){
      if(!down) return;
      t = Math.max(0, t-1);
      render();
      if(t>0) setTimeout(tick, 1000);
    }

    btn.addEventListener("pointerdown", ()=>{
      down = true;
      btn.classList.add("is-down");
      tick();
    });
    function up(){
      down = false;
      btn.classList.remove("is-down");
    }
    btn.addEventListener("pointerup", up);
    btn.addEventListener("pointercancel", up);
    btn.addEventListener("pointerleave", up);

    render();
  })();
  </script>
</section>
'

# ---------- STUDENT CHAT ----------
write_page "$DIST/student/chat/index.html" "Peak English — Chat" '
<section class="section section-wide">
  <div class="section-head">
    <h1 class="h1">Chat</h1>
    <p class="sub">Full-width chat (MVP UI). Fake reply now, backend later.</p>
  </div>

  <div class="chat-shell">
    <div class="chat-messages" id="chatMessages">
      <div class="msg ai">
        <div class="bubble">Hi! Tell me what you did today — I will correct you.</div>
      </div>
    </div>

    <form class="chat-bar" id="chatForm">
      <input class="chat-input" id="chatInput" placeholder="Type here…" autocomplete="off" />
      <button class="btn primary chat-send" type="submit">Send</button>
    </form>
  </div>

  <script>
  (function(){
    const box = document.getElementById("chatMessages");
    const form = document.getElementById("chatForm");
    const input = document.getElementById("chatInput");

    function add(role, text){
      const row = document.createElement("div");
      row.className = "msg " + role;
      const b = document.createElement("div");
      b.className = "bubble";
      b.textContent = text;
      row.appendChild(b);
      box.appendChild(row);
      box.scrollTop = box.scrollHeight;
    }

    form.addEventListener("submit", (e)=>{
      e.preventDefault();
      const t = (input.value || "").trim();
      if(!t) return;
      add("me", t);
      input.value = "";
      setTimeout(()=> add("ai", "Nice! Try: “I did … today.”"), 250);
    });
  })();
  </script>
</section>
'

# ---------- STUDENT SETTINGS (static demo) ----------
write_page "$DIST/student/settings/index.html" "Peak English — Settings" '
<section class="section section-wide">
  <div class="section-head head-row">
    <div>
      <h1 class="h1">Settings</h1>
      <p class="sub">Static demo (no server). Avatar upload is UI-only.</p>
    </div>
    <span class="badge">Demo</span>
  </div>

  <div class="grid">
    <div class="col-5">
      <div class="panel">
        <div class="label">Avatar</div>
        <div class="muted small">Demo preview only.</div>
        <div class="divider"></div>

        <div class="row" style="justify-content:flex-start; gap:12px;">
          <div class="avatar avatar-lg avatar-fallback" id="avatarFallback">A</div>
          <img class="avatar avatar-lg" id="avatarImg" alt="avatar" style="display:none;">
          <div>
            <div class="label" id="displayNameLabel">Student</div>
            <div class="muted small">@student</div>
          </div>
        </div>
      </div>
    </div>

    <div class="col-7">
      <div class="panel">
        <form class="form" id="settingsForm">
          <label class="lbl">Display name</label>
          <input class="input" name="display_name" placeholder="Student">

          <label class="lbl">Goal</label>
          <select class="input" name="goal">
            <option>General English</option>
            <option>IELTS</option>
            <option>Business</option>
          </select>

          <label class="lbl">Upload avatar</label>
          <input class="input" type="file" id="avatarFile" accept="image/png,image/jpeg,image/webp">

          <button class="btn primary full" type="submit">Save (demo)</button>
        </form>

        <div class="hint" id="savedHint" style="display:none;">
          <div class="chips"><span class="chip">Saved (demo)</span></div>
        </div>
      </div>
    </div>
  </div>
</section>

<script>
(function(){
  const form = document.getElementById("settingsForm");
  const file = document.getElementById("avatarFile");
  const img = document.getElementById("avatarImg");
  const fb = document.getElementById("avatarFallback");
  const nameLbl = document.getElementById("displayNameLabel");
  const saved = document.getElementById("savedHint");

  file.addEventListener("change", ()=>{
    const f = file.files && file.files[0];
    if(!f) return;
    const url = URL.createObjectURL(f);
    img.src = url;
    img.style.display = "block";
    fb.style.display = "none";
  });

  form.addEventListener("submit", (e)=>{
    e.preventDefault();
    const fd = new FormData(form);
    const dn = String(fd.get("display_name") || "").trim();
    nameLbl.textContent = dn || "Student";
    saved.style.display = "block";
    setTimeout(()=> saved.style.display = "none", 1400);
  });
})();
</script>
'

# ---------- TEACHER DEMO PAGES ----------
write_page "$DIST/teacher/dashboard/index.html" "Peak English — Teacher" '
<section class="section">
  <div class="section-head">
    <h1 class="h1">Teacher</h1>
    <p class="sub">Static demo dashboard.</p>
  </div>

  <div class="kpis">
    <div class="kpi">
      <div class="kpi-num">12</div>
      <div class="kpi-label">Students (demo)</div>
    </div>

    <a class="kpi kpi-link" href="/teacher/students/">
      <div class="kpi-num">→</div>
      <div class="kpi-label">Open students</div>
    </a>

    <a class="kpi kpi-link" href="/teacher/students/new/">
      <div class="kpi-num">+</div>
      <div class="kpi-label">Create student</div>
    </a>
  </div>
</section>
'

write_page "$DIST/teacher/students/index.html" "Peak English — Students" '
<section class="section section-wide">
  <div class="section-head head-row">
    <div>
      <h1 class="h1">Students</h1>
      <p class="sub">Static demo list.</p>
    </div>
    <a class="btn primary" href="/teacher/students/new/">+ New student</a>
  </div>

  <div class="table">
    <div class="trow thead">
      <div>ID</div><div>Username</div><div>Name</div><div>Created</div>
    </div>
    <div class="trow">
      <div class="mono">1</div><div class="mono">student</div><div>Student</div><div class="mono muted">demo</div>
    </div>
    <div class="trow">
      <div class="mono">2</div><div class="mono">john</div><div>John</div><div class="mono muted">demo</div>
    </div>
  </div>
</section>
'

write_page "$DIST/teacher/students/new/index.html" "Peak English — Create Student" '
<section class="section">
  <div class="section-head">
    <h1 class="h1">Create student</h1>
    <p class="sub">Static demo form (no backend).</p>
  </div>

  <div class="panel">
    <form class="form" id="newStudentForm">
      <label class="lbl">Username</label>
      <input class="input" name="username" placeholder="e.g., john" required>

      <label class="lbl">Password</label>
      <input class="input" name="password" placeholder="e.g., john123" required>

      <label class="lbl">Display name (optional)</label>
      <input class="input" name="display_name" placeholder="John">

      <button class="btn primary full" type="submit">Create (demo)</button>
      <a class="btn full" href="/teacher/students/">Back</a>
    </form>

    <div class="hint" id="createdHint" style="display:none;">
      <div class="chips"><span class="chip">Created (demo)</span></div>
    </div>
  </div>
</section>

<script>
(function(){
  const f = document.getElementById("newStudentForm");
  const h = document.getElementById("createdHint");
  f.addEventListener("submit", (e)=>{
    e.preventDefault();
    h.style.display="block";
    setTimeout(()=> h.style.display="none", 1400);
  });
})();
</script>
'

echo "✅ dist built (static, no Jinja)"
