---
title: "Trag dich in die Teamwand ein (@{{login}})"
labels: [eintrag]
---

Füge deinen eigenen Eintrag in `team.js` hinzu.

## Aufgabe

1. Branch anlegen: `feat/<issue-nummer>-teamwand-{{login}}`
2. In `team.js` **eine** Zeile ergänzen – an der alphabetisch richtigen Stelle (nach Login, Groß-/Kleinschreibung egal):
   ```js
   { login: "{{login}}", name: "Vorname Nachname", emoji: "🚀", motto: "Dein Motto (max. 120 Zeichen)" },
   ```
3. `index.html` im Browser öffnen und prüfen, dass deine Karte erscheint.
4. Commit, Push, Pull Request mit `gh pr create`.
   - PR-Titel nach Conventional Commits, z. B. `feat: add {{login}} to the team wall`
   - Im PR-Text: `Closes #<issue-nummer>`
5. KI-Review lesen und Kommentare beantworten. Dann Review anfordern – dein Reviewer ist **@{{reviewer}}**:
   `gh pr edit --add-reviewer {{reviewer}}`
6. Nach Approval: **Squash and merge** – und auf GitHub Pages nachsehen.

## Fertig, wenn

- [ ] CI ist grün (`gh pr checks`)
- [ ] ein Mensch hat approved
- [ ] deine Karte ist auf https://meko-christian.github.io/workshop-teamwand/ zu sehen
