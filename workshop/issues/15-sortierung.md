---
title: "Sortierung umschaltbar: nach Login oder nach Name"
labels: [bonus, feature]
---

Ein Auswahlfeld über der Wand: „nach Login“ (wie bisher) oder „nach Name“.

## Hinweise

- Neue reine Funktion `sortTeam(team, key)` in `lib.js`, die eine **neue** Liste zurückgibt (das Original bleibt unverändert – auch das testen).
- `app.js`: `render()` nutzt `sortTeam`, das Auswahlfeld ruft bei `change` neu `render()` auf.
- Das Feld braucht ein `<label>`.

## Fertig, wenn

- [ ] Tests für `sortTeam` vorhanden, CI grün
- [ ] auf GitHub Pages funktioniert die Umschaltung
