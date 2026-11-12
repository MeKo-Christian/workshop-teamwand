---
title: "Strengere Prüfung: Motto max. 80 Zeichen, Emoji genau ein Zeichen"
labels: [bonus, feature]
---

Die Wand sieht unruhig aus, wenn Mottos zu lang sind oder jemand drei Emojis einträgt. `validateEntry` in `lib.js` soll strenger werden:

- Motto höchstens **80** Zeichen (bisher 120)
- Emoji genau **ein** sichtbares Zeichen. Tipp: `[...new Intl.Segmenter().segment(emoji)].length === 1` – ein Emoji wie 👩‍💻 besteht aus mehreren Code Points!

## Hinweise

- Tests in `test/lib.test.js` anpassen und ergänzen (auch 👩‍💻 und 🇩🇪 als gültig).
- Achtung: `test/team.test.js` prüft die echten Einträge. Wenn jemand schon ein zu langes Motto hat, wird CI rot – dann im selben PR kürzen und die Person im PR erwähnen (`@login`), damit sie zustimmt.
- Das ist ein Verhaltenswechsel: überlegt, ob `feat:` oder `fix:` der richtige PR-Typ ist.

## Fertig, wenn

- [ ] Tests angepasst, CI grün
- [ ] alle bestehenden Einträge erfüllen die neue Regel
