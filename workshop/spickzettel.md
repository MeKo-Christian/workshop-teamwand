# Spickzettel: Git & GitHub

Repo: <https://github.com/MeKo-Christian/workshop-teamwand> · Seite:
<https://meko-christian.github.io/workshop-teamwand/> (nach jedem Merge; ein
Release zeigt die neue Version im Footer)

Jede Etappe zeigt die Befehle zum Selbertippen und daneben den Satz für einen
KI-Assistenten, falls ihr einen nutzt. Prüfen müsst ihr in beiden Fällen
selbst. Beispiele für Issue 7 und Login `anna`.

## Einmalig vorab

```sh
git --version                                    # Git ist installiert
git config --global user.name "Anna Muster"
git config --global user.email "eure@mail.de"
```

Beim ersten `git push` fragt Git im Browser nach dem GitHub-Login.

## Der Ablauf

```
Klonen → Branch & Commit → Push & Pull Request → Checks → Review
       → Merge → Deployment (Seite) → Release-PR → neue Version
```

In echten Projekten gibt es meist zwei Umgebungen: Staging nach jedem Merge,
Prod erst mit dem Release. Die Teamwand hat eine Seite für beides.

## Etappe für Etappe

### 1 · Klonen

```sh
git clone https://github.com/MeKo-Christian/workshop-teamwand
cd workshop-teamwand
git log --oneline -5
```

Auf GitHub unter **Issues**: Welches Issue ist euch zugewiesen?
KI-Assistent: „Klone MeKo-Christian/workshop-teamwand in meinen Projektordner.“
· „Welche Issues sind mir auf GitHub zugewiesen?“
**Prüfen:** `index.html` im Browser öffnen.

### 2 · Branch & Commit

```sh
git switch -c feat/7-teamwand-anna
# team.js im Editor: eure Zeile an der alphabetischen Stelle einfügen
git add team.js
git commit -m "feat: add anna to the team wall"
```

KI-Assistent: „Leg einen Branch nach AGENTS.md an, trag mich in team.js ein
und committe. Noch nicht hochladen.“
**Prüfen:** Karte lokal sichtbar? `git status` sauber? Branch auf GitHub? (Noch
nicht.)

### 3 · Push & Pull Request

```sh
git push -u origin feat/7-teamwand-anna
```

Auf GitHub **Compare & pull request** → Titel
`feat: add anna to the team wall`, Text `Closes #7` → **Create pull request**.
KI-Assistent: „Lade meinen Branch hoch und öffne einen Pull Request mit
Conventional-Commit-Titel, der mein Issue schließt. Zeig mir Titel und Text
vorher.“
**Prüfen:** Unter **Files changed** nur eure eine Zeile?

### 4 · Checks

Im PR die Checks abwarten. Rot: **Details** öffnen, Log lesen, korrigieren:

```sh
git commit -am "fix: sort my entry"
git push
```

Kommentare beantworten, dann **Resolve conversation**.
KI-Assistent: „Sind die Checks grün? Falls rot: Lies das Log und behebe den
Fehler, ohne Regeln abzuschalten.“ · „Fass die Kommentare in meinem PR
zusammen. Was ist berechtigt?“
**Prüfen:** Alles grün, jeder Kommentar beantwortet und aufgelöst.

### 5 · Review

Im eigenen PR bei **Reviewers** die Person aus eurem Issue eintragen. Den
fremden PR unter **Files changed** lesen, gern lokal ausprobieren:

```sh
git fetch
git switch feat/8-teamwand-ben
```

Dann **Review changes** → **Approve** oder **Request changes**.
KI-Assistent: „Fordere ein Review von der Person an, die in meinem Issue
steht.“ · „Hol mir PR #8 auf den Rechner und fass zusammen: Passt er zum Issue
und zu AGENTS.md?“
**Prüfen:** Freigeben klickt ihr _selbst_ im Browser.

### 6 · Merge & Deployment

Im PR **Squash and merge**, einer nach dem anderen. Dann lokal:

```sh
git switch main
git pull
git branch -D feat/7-teamwand-anna   # -D, weil Squash-Merge
```

KI-Assistent: „Ist mein PR freigegeben und grün? Dann merge ihn.“ · „Hol den
neuesten Stand von main und lösch meinen alten Branch.“
**Prüfen:** Nach ein paar Minuten zeigt die Seite eure Karte.

### 7 · Release

Den Release-PR `chore(main): release …` öffnen, Changelog lesen, gemeinsam
freigeben und mergen. Unter **Actions** und **Releases** nachsehen.
KI-Assistent: „Zeig mir den offenen Release-PR und fass den Changelog
zusammen.“
**Prüfen:** Die Seite zeigt die neue Version im Footer.

## Wenn's hakt

- `git status` zeigt, wo ihr steht.
- Konflikt: im PR **Resolve conflicts**, beide Einträge behalten, **Mark as
  resolved**, **Commit merge**. KI-Assistent: „Mein PR hat einen Konflikt mit
  main. Löse ihn so, dass beide Einträge erhalten bleiben, und erklär mir, was
  du gemacht hast.“
- Branch hinter `main`: im PR **Update branch**.
- KI-Assistent: „Erklär mir, was du gerade gemacht hast und warum.“

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
- Wer reviewt, schaut wirklich hin. Ein KI-Review ersetzt euch nicht.
- Rote CI wird im selben Branch repariert, nicht weggeschaltet.
