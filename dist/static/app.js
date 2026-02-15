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
