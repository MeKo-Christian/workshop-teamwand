# Spickzettel: Git & GitHub bei MeKo

Repo: <https://github.com/MeKo-Christian/workshop-teamwand> · Seite:
<https://meko-christian.github.io/workshop-teamwand/> (nach jedem Merge; ein
Release zeigt die neue Version im Footer)

Euer Agent tippt die Befehle. Ihr sagt ihm, was er tun soll — und prüft das
Ergebnis selbst.

## Der Ablauf

```
Klonen → Branch & Commit → Push & Pull Request → Checks → Review
       → Merge → Staging → Release-PR → Prod
```

## Prompts, Etappe für Etappe

| Etappe              | Sagt eurem Agenten                                                                                                                                    | Selbst prüfen                                         |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| 1 · Klonen          | „Klone MeKo-Christian/workshop-teamwand in meinen Projektordner.“ · „Welche Issues sind mir auf GitHub zugewiesen?“                                   | `index.html` im Browser öffnen                        |
| 2 · Branch & Commit | „Lies mein Issue und leg dafür einen Branch nach AGENTS.md an. Trag mich in team.js ein und committe. Noch nicht hochladen.“                          | Karte lokal sichtbar? Branch auf GitHub? (noch nicht) |
| 3 · Push & PR       | „Lade meinen Branch hoch und öffne einen Pull Request mit Conventional-Commit-Titel, der mein Issue schließt. Zeig mir Titel und Text vorher.“        | PR im Browser: Titel verständlich?                    |
| 4 · Checks          | „Sind die Checks grün? Falls rot: Lies das Log und behebe den Fehler, ohne Regeln abzuschalten.“ · „Fass das KI-Review zusammen. Was ist berechtigt?“ | Kommentare beantworten und auflösen                   |
| 5 · Review          | „Fordere ein Review von der Person an, die in meinem Issue steht.“ · „Welche PRs soll ich reviewen? Fass PR #N zusammen.“                             | Fremden PR ansehen, _selbst_ freigeben                |
| 6 · Merge & Staging | „Ist mein PR freigegeben und grün? Dann merge ihn.“ · „Hol den neuesten Stand von main.“                                                              | Die Seite zeigt eure Karte                            |
| 7 · Release & Prod  | „Zeig mir den offenen Release-PR und fass den Changelog zusammen.“                                                                                    | Gemeinsam freigeben, Version im Footer prüfen         |

Wenn's hakt:

- „Mein PR hat einen Konflikt mit main. Löse ihn so, dass beide Einträge
  erhalten bleiben, und erklär mir, was du gemacht hast.“
- „Erklär mir, was du gerade gemacht hast und warum.“

## PR-Titel = Eintrag im Changelog

`typ: was sich ändert` — klein, Englisch, ohne Punkt.

| Typ        | Wann                                  |
| ---------- | ------------------------------------- |
| `feat`     | neue Funktion                         |
| `fix`      | Fehler behoben                        |
| `docs`     | nur Doku                              |
| `refactor` | Umbau ohne neues Verhalten            |
| `test`     | nur Tests                             |
| `chore`    | Sonstiges (Abhängigkeiten, Aufräumen) |

✅ `feat: add anna to the team wall` · ❌ `Update team.js` · ❌ `fix stuff`

## Regeln

- Niemand ändert `main` direkt — geht auch gar nicht.
- Ein Issue, ein Branch, ein kleiner PR.
- Zwei Kopien, unabhängig: Erst holen, dann arbeiten. Erst hochladen, dann
  sieht es GitHub.
- Wer reviewt, schaut wirklich hin. Das KI-Review ersetzt euch nicht.
- Rote CI wird im selben Branch repariert, nicht weggeschaltet.
