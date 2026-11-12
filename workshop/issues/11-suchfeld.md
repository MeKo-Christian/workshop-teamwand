---
title: "Suchfeld: Teamwand nach Name, Login oder Motto filtern"
labels: [bonus, feature]
---

Über der Wand soll ein Suchfeld stehen. Während man tippt, bleiben nur die Karten stehen, deren Name, Login oder Motto den Suchbegriff enthält (Groß-/Kleinschreibung egal).

## Hinweise

- Neue reine Funktion `filterTeam(team, query)` in `lib.js`, mit Tests in `test/lib.test.js` (leerer Suchbegriff → alle; Treffer in jedem der drei Felder; kein Treffer → leere Liste).
- `app.js`: `render()` nutzt `filterTeam`, das Suchfeld ruft bei `input` neu `render()` auf.
- Barrierefreiheit: das Feld braucht ein `<label>` (html-validate prüft das).

## Fertig, wenn

- [ ] Tests für `filterTeam` vorhanden, CI grün
- [ ] auf GitHub Pages funktioniert die Suche
