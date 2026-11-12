---
title: "Dark Mode nach Systemeinstellung"
labels: [bonus, feature]
---

Wenn das Betriebssystem auf dunkel steht, soll die Teamwand dunkel sein.

## Hinweise

- Nur CSS: `@media (prefers-color-scheme: dark)` überschreibt die Variablen in `:root` (`--bg`, `--card`, `--text`, …).
- Kein Test nötig – beschreibt im PR unter „Wie getestet“, wie ihr es geprüft habt (z. B. DevTools → Rendering → „prefers-color-scheme: dark“).
- Achtet auf genug Kontrast, auch beim Grün.

## Fertig, wenn

- [ ] CI grün
- [ ] auf GitHub Pages im Dark Mode lesbar
