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
4. Commit und Push (`git add team.js`, `git commit`, `git push -u origin <branch>`), dann auf GitHub **Compare & pull request**.
   - PR-Titel nach Conventional Commits, z. B. `feat: add {{login}} to the team wall`
   - Im PR-Text: `Closes #<issue-nummer>`
5. Checks abwarten, Kommentare lesen und beantworten. Dann rechts bei **Reviewers** ein Review anfordern – dein Reviewer ist **@{{reviewer}}**.
6. Nach Approval: **Squash and merge** – und auf GitHub Pages nachsehen.

## Fertig, wenn

- [ ] die Checks im PR sind grün
- [ ] ein Mensch hat approved
- [ ] deine Karte ist auf https://meko-christian.github.io/workshop-teamwand/ zu sehen
