#!/usr/bin/env bash
set -euo pipefail

rm -rf dist
mkdir -p dist/static dist/student/{dashboard,chat,speaking,settings} dist/teacher/{dashboard,students,students-new}

# copy css
mkdir -p dist/static
cp -f static/app.css dist/static/app.css

# redirects: ONLY normalize common paths, no catch-all (keeps CSS safe)
cat > dist/_redirects <<'TXT'
/student /student/ 301
/teacher /teacher/ 301
/login / 301
TXT

# tiny shared JS for "auth" + avatar/name
cat > dist/static/app.js <<'JS'
(function(){
  const store = {
    get(k, d){ try { const v = localStorage.getItem(k); return v==null? d : JSON.parse(v); } catch { return d; } },
    set(k, v){ localStorage.setItem(k, JSON.stringify(v)); }
  };

  function el(id){ return document.getElementById(id); }

  window.Peak = {
    store,
    login(role, username){
      store.set("session", { role, username, ts: Date.now() });
    },
    logout(){
      localStorage.removeItem("session");
      location.href = "/";
    },
    requireRole(role){
      const s = store.get("session", null);
      if(!s || s.role !== role){
        location.href = "/";
      }
    },
    getProfile(){
      return store.get("profile", { displayName: "", avatarDataUrl: "" });
    },
    setProfile(p){
      store.set("profile", p);
    },
    hydrateTopbar(){
      const p = Peak.getProfile();
      const avatar = el("topAvatar");
      const name = el("topName");
      if(avatar){
        if(p.avatarDataUrl){
          avatar.innerHTML = '<img class="avatar" src="'+p.avatarDataUrl+'" alt="avatar">';
        } else {
          const letter = (p.displayName || "A").trim().charAt(0).toUpperCase() || "A";
          avatar.innerHTML = '<div class="avatar avatar-fallback">'+letter+'</div>';
        }
      }
      if(name){
        name.textContent = (p.displayName || "Student").trim() || "Student";
      }
    }
  };
})();
JS

# helper to write full html pages (no templating)
page(){
  local out="$1"; shift
  local title="$1"; shift
  local nav="$1"; shift
  local body="$1"; shift

  cat > "$out" <<HTML
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
        ${nav}
      </nav>
    </div>
  </header>

  <main class="page">
    <div class="wrap">
      ${body}
    </div>
  </main>

  <script src="/static/app.js"></script>
</body>
</html>
HTML
}

# ---------- INDEX (login) ----------
page "dist/index.html" "Peak English — Demo" "" '
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

<script>
(function(){
  const form = document.getElementById("loginForm");
  form.addEventListener("submit", (e)=>{
    e.preventDefault();
    const fd = new FormData(form);
    const u = String(fd.get("username") || "").trim().toLowerCase();
    if (u === "teacher") {
      Peak.login("teacher","teacher");
      location.href = "/teacher/dashboard/";
    } else {
      Peak.login("student", u || "student");
      location.href = "/student/dashboard/";
    }
  });
})();
</script>
'

# ---------- STUDENT NAV ----------
student_nav='
<a class="nav-link" href="/student/dashboard/">Dashboard</a>
<a class="nav-link" href="/student/speaking/">Speaking</a>
<a class="nav-link" href="/student/chat/">Chat</a>
<a class="nav-link" href="/student/settings/">Settings</a>
<a class="nav-pill" href="#" onclick="Peak.logout(); return false;">Logout</a>
<span id="topAvatar"></span>
'

# ---------- TEACHER NAV ----------
teacher_nav='
<a class="nav-link" href="/teacher/dashboard/">Dashboard</a>
<a class="nav-link" href="/teacher/students/">Students</a>
<a class="nav-link" href="/teacher/students-new/">Create</a>
<a class="nav-pill" href="#" onclick="Peak.logout(); return false;">Logout</a>
'

# ---------- STUDENT: DASHBOARD ----------
page "dist/student/dashboard/index.html" "Peak English — Student" "$student_nav" '
<section class="section">
  <div class="section-head">
    <div class="row" style="justify-content:space-between; align-items:flex-end;">
      <div>
        <h1 class="h1">Student</h1>
        <p class="sub">Quick access. Wide. Touch-friendly.</p>
      </div>
      <div class="row" style="gap:10px; align-items:center;">
        <div class="pill" id="topName">Student</div>
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
      <div class="tile-sub">Goal, level, avatar</div>
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

<script>
(function(){
  Peak.requireRole("student");
  Peak.hydrateTopbar();
})();
</script>
'

# ---------- STUDENT: CHAT ----------
page "dist/student/chat/index.html" "Peak English — Chat" "$student_nav" '
<section class="section section-wide">
  <div class="section-head">
    <h1 class="h1">Chat</h1>
    <p class="sub">Full-width chat (MVP UI). Fake reply. No backend.</p>
  </div>

  <div class="chat-shell">
    <div class="chat-messages" id="chatMessages">
      <div class="msg ai"><div class="bubble">Hi! Tell me what you did today — I will correct you.</div></div>
    </div>

    <form class="chat-bar" id="chatForm">
      <input class="chat-input" id="chatInput" placeholder="Type here…" autocomplete="off" />
      <button class="btn primary chat-send" type="submit">Send</button>
    </form>
  </div>

  <script>
  (function(){
    Peak.requireRole("student");
    Peak.hydrateTopbar();

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

# ---------- STUDENT: SPEAKING ----------
page "dist/student/speaking/index.html" "Peak English — Speaking" "$student_nav" '
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
    Peak.requireRole("student");
    Peak.hydrateTopbar();

    const btn = document.getElementById("micBtn");
    const timer = document.getElementById("timer");
    let down = false;
    let t = 47;

    function fmt(n){ return String(n).padStart(2,"0"); }
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

# ---------- STUDENT: SETTINGS (localStorage) ----------
page "dist/student/settings/index.html" "Peak English — Settings" "$student_nav" '
<section class="section section-wide">
  <div class="section-head head-row">
    <div>
      <h1 class="h1">Settings</h1>
      <p class="sub">Avatar + display name (stored locally). Demo-friendly.</p>
    </div>
    <span class="badge" id="savedBadge" style="display:none;">Saved</span>
  </div>

  <div class="grid">
    <div class="col-5">
      <div class="panel">
        <div class="label">Avatar</div>
        <div class="muted small">PNG/JPG/WEBP. Stored as DataURL locally.</div>
        <div class="divider"></div>

        <div class="row" style="justify-content:flex-start; gap:12px;">
          <div id="bigAvatar"></div>
          <div>
            <div class="label" id="dispName">Student</div>
            <div class="muted small" id="userTag">@student</div>
          </div>
        </div>
      </div>
    </div>

    <div class="col-7">
      <div class="panel">
        <form class="form" id="settingsForm">
          <label class="lbl">Display name</label>
          <input class="input" name="display_name" id="displayNameInput" placeholder="Student">

          <label class="lbl">Goal</label>
          <select class="input" name="goal">
            <option>General English</option>
            <option>IELTS</option>
            <option>Business</option>
          </select>

          <label class="lbl">Upload avatar</label>
          <input class="input" type="file" id="avatarInput" accept="image/png,image/jpeg,image/webp">

          <button class="btn primary full" type="submit">Save</button>
        </form>
      </div>
    </div>
  </div>
</section>

<script>
(function(){
  Peak.requireRole("student");

  const s = Peak.store.get("session", {username:"student"});
  const profile = Peak.getProfile();

  const badge = document.getElementById("savedBadge");
  const dispName = document.getElementById("dispName");
  const userTag = document.getElementById("userTag");
  const bigAvatar = document.getElementById("bigAvatar");
  const nameInput = document.getElementById("displayNameInput");
  const avatarInput = document.getElementById("avatarInput");
  const form = document.getElementById("settingsForm");

  function render(){
    const p = Peak.getProfile();
    const nm = (p.displayName || "Student").trim() || "Student";
    dispName.textContent = nm;
    userTag.textContent = "@" + (s.username || "student");
    nameInput.value = p.displayName || "";
    if(p.avatarDataUrl){
      bigAvatar.innerHTML = '<img class="avatar avatar-lg" src="'+p.avatarDataUrl+'" alt="avatar">';
    } else {
      const letter = nm.charAt(0).toUpperCase() || "A";
      bigAvatar.innerHTML = '<div class="avatar avatar-lg avatar-fallback">'+letter+'</div>';
    }
    Peak.hydrateTopbar();
  }

  form.addEventListener("submit", async (e)=>{
    e.preventDefault();
    const p = Peak.getProfile();
    p.displayName = (nameInput.value || "").trim();

    const file = avatarInput.files && avatarInput.files[0];
    if(file){
      const ok = /image\/(png|jpeg|webp)/.test(file.type);
      if(!ok){ alert("Avatar must be PNG/JPG/WEBP"); return; }
      const dataUrl = await new Promise((res, rej)=>{
        const r = new FileReader();
        r.onload = ()=> res(String(r.result||""));
        r.onerror = rej;
        r.readAsDataURL(file);
      });
      p.avatarDataUrl = dataUrl;
    }

    Peak.setProfile(p);
    badge.style.display = "inline-flex";
    setTimeout(()=> badge.style.display="none", 1200);
    render();
  });

  render();
})();
</script>
'

# ---------- TEACHER: DASHBOARD ----------
page "dist/teacher/dashboard/index.html" "Peak English — Teacher" "$teacher_nav" '
<section class="section">
  <div class="section-head">
    <h1 class="h1">Teacher</h1>
    <p class="sub">Static demo dashboard. No DB.</p>
  </div>

  <div class="kpis">
    <div class="kpi">
      <div class="kpi-num">18</div>
      <div class="kpi-label">Students (demo)</div>
    </div>

    <a class="kpi kpi-link" href="/teacher/students/">
      <div class="kpi-num">→</div>
      <div class="kpi-label">Open students</div>
    </a>

    <a class="kpi kpi-link" href="/teacher/students-new/">
      <div class="kpi-num">+</div>
      <div class="kpi-label">Create student</div>
    </a>
  </div>
</section>

<script>
(function(){ Peak.requireRole("teacher"); })();
</script>
'

# ---------- TEACHER: STUDENTS (static list) ----------
page "dist/teacher/students/index.html" "Peak English — Students" "$teacher_nav" '
<section class="section section-wide">
  <div class="section-head head-row">
    <div>
      <h1 class="h1">Students</h1>
      <p class="sub">Static demo list.</p>
    </div>
    <a class="btn primary" href="/teacher/students-new/">+ New student</a>
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

<script>
(function(){ Peak.requireRole("teacher"); })();
</script>
'

# ---------- TEACHER: CREATE (static) ----------
page "dist/teacher/students-new/index.html" "Peak English — Create Student" "$teacher_nav" '
<section class="section">
  <div class="section-head">
    <h1 class="h1">Create student</h1>
    <p class="sub">Static demo page (no DB). For pitch only.</p>
  </div>

  <div class="panel">
    <div class="alert">
      Cloudflare Pages is static. Real creation requires a backend (Workers/Pages Functions).
      For now this is UI-only.
    </div>

    <div class="form">
      <label class="lbl">Username</label>
      <input class="input" placeholder="e.g., john" disabled>

      <label class="lbl">Password</label>
      <input class="input" placeholder="e.g., john123" disabled>

      <button class="btn primary full" disabled>Create (demo)</button>
      <a class="btn full" href="/teacher/students/">Back</a>
    </div>
  </div>
</section>

<script>
(function(){ Peak.requireRole("teacher"); })();
</script>
'

echo "✅ dist built (static, no Jinja)."
