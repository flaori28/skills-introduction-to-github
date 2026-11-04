/*
 * Applis du dock. Modifie cette liste pour changer le dock.
 *  - match : mots cherchés dans le nom des applis installées (insensible à la casse)
 *  - ids   : identifiants Tizen connus, essayés si la recherche par nom échoue
 * Les identifiants varient selon l'année et la région ; la recherche par nom
 * est donc tentée en premier.
 */
var DOCK_APPS = [
  { label: "Netflix",     color: "#141414", accent: "#e50914",
    match: ["netflix"],               ids: ["RN1MCdNq8t.Netflix", "3201907018807", "11101200001"] },
  { label: "YouTube",     color: "#1a1a1a", accent: "#ff0033",
    match: ["youtube"],               ids: ["9Ur5IzDKqV.TizenYouTube", "111299001912"] },
  { label: "Prime Video", color: "#0f171e", accent: "#00a8e1",
    match: ["prime video", "amazon"], ids: ["evKhCgZelL.AmazonIgnitionLauncher2", "3201910019365", "3201512006785"] },
  { label: "Disney+",     color: "#0b1a3a", accent: "#2ad1ff",
    match: ["disney"],                ids: ["MCmYXNxgcu.DisneyPlus", "3201901017640"] },
  { label: "Free TV",     color: "#1b1b1b", accent: "#cd1e25",
    match: ["free tv", "freetv", "oqee"], ids: [] },
  { label: "PlayStation", color: "#00439c", accent: "#ffffff",
    match: ["playstation"],           ids: [] }
];

var WALLPAPERS = [
  "img/nature1.jpg", "img/nature2.jpg", "img/nature3.jpg",
  "img/nature4.jpg", "img/nature5.jpg", "img/nature6.jpg"
];
var WALLPAPER_SECONDS = 45;   // durée d'affichage de chaque fond
var DOCK_IDLE_SECONDS = 12;   // le dock s'estompe après ce délai sans touche
