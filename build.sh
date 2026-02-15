#!/usr/bin/env bash
set -euo pipefail

rm -rf dist
mkdir -p dist/static

# 1) CSS
cp -f static/app.css dist/static/app.css

# 2) Redirect rules for Cloudflare Pages (fix 404 without trailing slash)
cat > dist/_redirects <<'TXT'
/student/dashboard   /student/dashboard/   301
/student/chat        /student/chat/        301
/student/speaking    /student/speaking/    301
/student/settings    /student/settings/    301
/teacher/dashboard   /teacher/dashboard/   301
/teacher/students    /teacher/students/    301
/teacher/students/new /teacher/students/new/ 301
TXT

write_page () {
  local out="$1"
  local title="$2"
  shift 2
  mkdir -p "$(dirname "$out")"

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
      <nav class="nav" id="nav"></nav>
    </div>
  </header>

  <main class="page">
    <div class="wrap">
      $*
    </div>
  </main>

  <script>
  (function(){
    const role = localStorage.getItem("pe_role") || "";
    const nav = document.getElementById("nav");
    function a(h, t, cls){
      const x=document.createElement("a");
      x.href=h; x.textContent=t; x.className=cls||"nav-link";
      return x;
    }
    if(role==="student"){
      nav.appendChild(a("/student/dashboard/","Dashboard"));
      nav.appendChild(a("/student/speaking/","Speaking"));
      nav.appendChild(a("/student/chat/","Chat"));
      nav.appendChild(a("/student/settings/","Settings"));
    } else if(role==="teacher"){
      nav.appendChild(a("/teacher/dashboard/","Dashboard"));
      nav.appendChild(a("/teacher/students/","Students"));
    }
    if(role){
      const lo = a("#","Logout","nav-pill");
      lo.addEventListener("click", (e)=>{
        e.preventDefault();
        localStorage.removeItem("pe_role");
        localStorage.removeItem("pe_name");
        localStorage.removeItem("pe_avatar");
        localStorage.removeItem("pe_disp");
        location.href="/";
      });
      nav.appendChild(lo);
    }
  })();
  </script>
</body>
</html>
HTML
}

write_page "dist/index.html" "Peak English — Demo" '
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
    const role = (u === "teacher") ? "teacher" : "student";
    localStorage.setItem("pe_role", role);
    localStorage.setItem("pe_name", u || (role==="teacher"?"teacher":"student"));
    location.href = role==="teacher" ? "/teacher/dashboard/" : "/student/dashboard/";
  });
})();
</script>
'

write_page "dist/student/dashboard/index.html" "Peak English — Student" '
<section class="section">
  <div class="section-head">
    <div class="row" style="justify-content:space-between; align-items:flex-end;">
      <div>
        <h1 class="h1">Student</h1>
        <p class="sub">Quick access. Wide. Touch-friendly.</p>
      </div>
      <div class="row" style="gap:10px; align-items:center;">
        <img class="avatar" id="avatarImg" alt="avatar" style="display:none">
        <div class="avatar avatar-fallback" id="avatarFallback">A</div>
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
  if(localStorage.getItem("pe_role")!=="student") location.href="/";
  const av = localStorage.getItem("pe_avatar") || "";
  const img = document.getElementById("avatarImg");
  const fb = document.getElementById("avatarFallback");
  if(av){
    img.src = av;
    img.style.display="block";
    fb.style.display="none";
  }
})();
</script>
'

write_page "dist/student/chat/index.html" "Peak English — Chat" '
<section class="section section-wide">
  <div class="section-head">
    <h1 class="h1">Chat</h1>
    <p class="sub">Full-width chat (MVP UI). Replace fake reply with /api later.</p>
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
    if(localStorage.getItem("pe_role")!=="student") location.href="/";
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

write_page "dist/student/speaking/index.html" "Peak English — Speaking" '
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
    if(localStorage.getItem("pe_role")!=="student") location.href="/";
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
      down = true; btn.classList.add("is-down"); tick();
    });
    function up(){ down=false; btn.classList.remove("is-down"); }
    btn.addEventListener("pointerup", up);
    btn.addEventListener("pointercancel", up);
    btn.addEventListener("pointerleave", up);
    render();
  })();
  </script>
</section>
'

write_page "dist/student/settings/index.html" "Peak English — Settings" '
<section class="section section-wide">
  <div class="section-head head-row">
    <div>
      <h1 class="h1">Settings</h1>
      <p class="sub">Static demo: name + avatar stored in localStorage.</p>
    </div>
    <span class="badge" id="savedBadge" style="display:none;">Saved</span>
  </div>

  <div class="grid">
    <div class="col-5">
      <div class="panel">
        <div class="label">Avatar</div>
        <div class="muted small">Stored locally (demo).</div>
        <div class="divider"></div>

        <div class="row" style="justify-content:flex-start; gap:12px;">
          <img class="avatar avatar-lg" id="avatarPreview" style="display:none" alt="avatar">
          <div class="avatar avatar-lg avatar-fallback" id="avatarFallback">A</div>
          <div>
            <div class="label" id="dispName">Student</div>
            <div class="muted small" id="uname">@student</div>
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

          <label class="lbl">Avatar (demo)</label>
          <input class="input" type="file" name="avatar" accept="image/png,image/jpeg,image/webp">

          <button class="btn primary full" type="submit">Save</button>
        </form>
      </div>
    </div>
  </div>
</section>

<script>
(async function(){
  if(localStorage.getItem("pe_role")!=="student") location.href="/";

  const saved = document.getElementById("savedBadge");
  const form = document.getElementById("settingsForm");
  const dn = document.getElementById("dispName");
  const un = document.getElementById("uname");
  const avp = document.getElementById("avatarPreview");
  const avf = document.getElementById("avatarFallback");

  function render(){
    const name = localStorage.getItem("pe_name") || "student";
    const disp = localStorage.getItem("pe_disp") || "Student";
    const av = localStorage.getItem("pe_avatar") || "";
    dn.textContent = disp;
    un.textContent = "@" + name;
    if(av){
      avp.src = av; avp.style.display="block"; avf.style.display="none";
    } else {
      avp.style.display="none"; avf.style.display="flex";
    }
  }
  render();

  form.addEventListener("submit", async (e)=>{
    e.preventDefault();
    saved.style.display="none";
    const fd = new FormData(form);
    const disp = String(fd.get("display_name")||"").trim();
    if(disp) localStorage.setItem("pe_disp", disp);

    const file = fd.get("avatar");
    if(file && file instanceof File && file.size){
      const buf = await file.arrayBuffer();
      const b64 = btoa(String.fromCharCode(...new Uint8Array(buf)));
      const mime = file.type || "image/png";
      localStorage.setItem("pe_avatar", `data:${mime};base64,${b64}`);
    }
    saved.style.display="inline-flex";
    render();
  });
})();
</script>
'

write_page "dist/teacher/dashboard/index.html" "Peak English — Teacher" '
<section class="section">
  <div class="section-head">
    <h1 class="h1">Teacher</h1>
    <p class="sub">Static demo: no DB.</p>
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

    <a class="kpi kpi-link" href="/teacher/students/new/">
      <div class="kpi-num">+</div>
      <div class="kpi-label">Create student</div>
    </a>
  </div>
</section>

<script>
(function(){
  if(localStorage.getItem("pe_role")!=="teacher") location.href="/";
})();
</script>
'

write_page "dist/teacher/students/index.html" "Peak English — Students" '
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
  </div>
</section>

<script>
(function(){
  if(localStorage.getItem("pe_role")!=="teacher") location.href="/";
})();
</script>
'

write_page "dist/teacher/students/new/index.html" "Peak English — New student" '
<section class="section">
  <div class="section-head">
    <h1 class="h1">Create student</h1>
    <p class="sub">Static demo (no real create).</p>
  </div>

  <div class="panel">
    <form class="form" onsubmit="event.preventDefault(); alert(\"Demo only\");">
      <label class="lbl">Username</label>
      <input class="input" placeholder="e.g., john" required>
      <label class="lbl">Password</label>
      <input class="input" placeholder="e.g., john123" required>
      <button class="btn primary full" type="submit">Create</button>
      <a class="btn full" href="/teacher/students/">Back</a>
    </form>
  </div>
</section>

<script>
(function(){
  if(localStorage.getItem("pe_role")!=="teacher") location.href="/";
})();
</script>
'

echo "✅ dist built (static, no jinja)"
