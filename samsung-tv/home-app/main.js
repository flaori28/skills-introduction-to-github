(function () {
  "use strict";
  var hasTizen = typeof tizen !== "undefined";
  var dock = document.getElementById("dock");
  var tiles = [], focusIndex = 0, idleTimer = null, installed = [];

  /* ---------- Horloge ---------- */
  function pad(n) { return (n < 10 ? "0" : "") + n; }
  var DAYS = ["dimanche","lundi","mardi","mercredi","jeudi","vendredi","samedi"];
  var MONTHS = ["janvier","février","mars","avril","mai","juin","juillet","août",
                "septembre","octobre","novembre","décembre"];
  function tick() {
    var d = new Date();
    document.getElementById("time").textContent = pad(d.getHours()) + ":" + pad(d.getMinutes());
    document.getElementById("date").textContent =
      DAYS[d.getDay()] + " " + d.getDate() + " " + MONTHS[d.getMonth()];
  }
  tick(); setInterval(tick, 10000);

  /* ---------- Fonds d'écran ---------- */
  var layers = [document.getElementById("bg-a"), document.getElementById("bg-b")];
  var wp = Math.floor(Math.random() * WALLPAPERS.length), front = 0;
  function showWallpaper() {
    var next = layers[1 - front], url = WALLPAPERS[wp];
    var img = new Image();
    img.onload = function () {
      next.style.backgroundImage = "url('" + url + "')";
      next.classList.remove("on"); void next.offsetWidth; next.classList.add("on");
      layers[front].classList.remove("on");
      front = 1 - front;
    };
    img.src = url;
    wp = (wp + 1) % WALLPAPERS.length;
  }
  showWallpaper(); setInterval(showWallpaper, WALLPAPER_SECONDS * 1000);
  document.getElementById("credit").textContent = "Photos : Wikimedia Commons (CC BY / CC BY-SA)";

  /* ---------- Dock ---------- */
  DOCK_APPS.forEach(function (app, i) {
    var t = document.createElement("div");
    t.className = "tile";
    t.style.background = app.color;
    t.style.setProperty("--accent", app.accent);
    t.textContent = app.label;
    t.addEventListener("click", function () { setFocus(i); launch(app); });
    dock.appendChild(t); tiles.push(t);
  });
  function setFocus(i) {
    focusIndex = (i + tiles.length) % tiles.length;
    tiles.forEach(function (t, j) { t.classList.toggle("focus", j === focusIndex); });
  }
  setFocus(0);

  function wake() {
    dock.classList.remove("idle");
    clearTimeout(idleTimer);
    idleTimer = setTimeout(function () { dock.classList.add("idle"); }, DOCK_IDLE_SECONDS * 1000);
  }
  wake();

  function toast(msg) {
    var el = document.getElementById("toast");
    el.textContent = msg; el.classList.add("show");
    setTimeout(function () { el.classList.remove("show"); }, 4000);
  }

  /* ---------- Lancement des applis ---------- */
  if (hasTizen) {
    try {
      tizen.application.getAppsInfo(function (list) { installed = list; }, function () {});
    } catch (e) {}
  }
  function candidates(app) {
    var ids = [];
    installed.forEach(function (info) {
      var name = (info.name || "").toLowerCase();
      app.match.forEach(function (m) {
        if (name.indexOf(m) !== -1 && ids.indexOf(info.id) === -1) ids.push(info.id);
      });
    });
    app.ids.forEach(function (id) { if (ids.indexOf(id) === -1) ids.push(id); });
    return ids;
  }
  function launch(app) {
    if (!hasTizen) { toast("Aperçu navigateur : lancement de " + app.label); return; }
    var ids = candidates(app), k = 0;
    (function tryNext() {
      if (k >= ids.length) { toast(app.label + " introuvable sur cette télé"); return; }
      var id = ids[k++];
      try { tizen.application.launch(id, function () {}, tryNext); }
      catch (e) { tryNext(); }
    })();
  }

  /* ---------- Télécommande ---------- */
  if (hasTizen) {
    try { tizen.tvinputdevice.registerKey("Exit"); } catch (e) {}
  }
  document.addEventListener("keydown", function (e) {
    var wasIdle = dock.classList.contains("idle");
    wake();
    if (wasIdle && e.keyCode !== 13) return;   // premier appui : réveille juste le dock
    switch (e.keyCode) {
      case 37: setFocus(focusIndex - 1); break;              // gauche
      case 39: setFocus(focusIndex + 1); break;              // droite
      case 13: launch(DOCK_APPS[focusIndex]); break;         // OK
      case 10009:                                            // Retour
      case 10182:                                            // Exit
        if (hasTizen) tizen.application.getCurrentApplication().exit();
        break;
    }
  });
})();
