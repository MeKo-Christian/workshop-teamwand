---
title: "Button „Wer ist dran?“ hebt eine zufällige Person hervor"
labels: [bonus, feature]
---

Ein Button unter der Überschrift wählt zufällig eine Karte aus und hebt sie hervor (z. B. grüner Rahmen). Ein zweiter Klick wählt neu.

## Hinweise

- Neue reine Funktion `pickRandom(team, random = Math.random)` in `lib.js`. Der Parameter `random` macht sie testbar: im Test eine feste Funktion übergeben, z. B. `() => 0.99`.
- Tests: leere Liste → `undefined`; `() => 0` → erster Eintrag; `() => 0.99` → letzter Eintrag.
- CSS-Klasse für die Hervorhebung in `style.css`.

## Fertig, wenn

- [ ] Tests für `pickRandom` vorhanden, CI grün
- [ ] auf GitHub Pages funktioniert der Button
