// Participant handout for the Git & GitHub workshop: the take-aways only.
// Standalone A4 document (not slides); build with `just build-git-workshop-handout`.

#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let meko_green = rgb(0, 136, 133)
#let meko_grey = rgb("#4b4c53")
#let meko_body = rgb("#595959")
#let warn_bg = rgb("#fff8e1")
#let warn_line = rgb("#e0b73a")
#let bad_bg = rgb("#fff3f3")
#let bad_line = rgb("#cc3333")

#set page(
  paper: "a4",
  margin: (x: 1.6cm, top: 1.4cm, bottom: 1.6cm),
  footer: {
    set text(size: 8pt, fill: meko_body)
    [Git & GitHub Workshop · Webanwendungen & Schnittstellen (EWWS)]
    h(1fr)
    context counter(page).display("1 / 1", both: true)
  },
)
#set text(
  font: ("Calibri", "Fira Sans", "Noto Sans"),
  size: 10.5pt,
  weight: "light",
  fill: meko_body,
  lang: "de",
)
#set par(leading: 0.58em, spacing: 0.8em)
#set list(spacing: 0.55em, indent: 0.2em, body-indent: 0.4em)
#show raw: set text(font: "Fira Mono", size: 9.5pt)
#show strong: set text(fill: meko_grey, weight: "bold")
#show heading: set text(
  font: ("Proxima Nova Rg", "Proxima Nova"),
  fill: meko_green,
  weight: "bold",
)
#show heading.where(level: 1): set text(size: 21pt)
#show heading.where(level: 2): it => block(above: 1.3em, below: 0.7em)[
  #set text(size: 13.5pt, fill: meko_green)
  #it.body
]

#let card(title, body, kind: "neutral") = {
  let (bg, border) = if kind == "good" {
    (meko_green.lighten(90%), meko_green.lighten(30%))
  } else if kind == "bad" {
    (bad_bg, bad_line)
  } else if kind == "warn" {
    (warn_bg, warn_line)
  } else {
    (luma(245), luma(200))
  }
  block(
    width: 100%,
    fill: bg,
    stroke: 0.6pt + border,
    radius: 5pt,
    inset: (x: 10pt, y: 8pt),
    breakable: false,
  )[
    #if title != none [#text(weight: "bold", fill: meko_grey)[#title] #v(0.2em)]
    #body
  ]
}

#let flow(label, kind: "neutral") = card(none, kind: kind)[
  #align(center, text(size: 9pt, weight: "bold", fill: meko_grey)[#label])
]
#let arrow = align(center + horizon, text(fill: meko_green, weight: "bold")[→])
#let prompt(body) = text(fill: meko_green, weight: "bold")[„#body“]
#let rule(body) = text(fill: meko_green, weight: "bold")[#body]
#let cols(..a) = grid(columns: (1fr,) * a.pos().len(), gutter: 14pt, ..a)

// Diagram helpers: a commit dot and a labelled box.
#let dot(pos, fill: meko_grey, label: none) = node(
  pos,
  if label != none { text(size: 8pt, weight: "bold", fill: white)[#label] },
  shape: circle,
  radius: 8pt,
  fill: fill,
  stroke: none,
)
#let tag(pos, body, color: meko_grey) = node(
  pos,
  text(size: 9pt, weight: "bold", fill: color)[#body],
  stroke: none,
)
#let box-node(pos, body, bg: luma(245), line: luma(190)) = node(
  pos,
  text(size: 9.5pt, weight: "bold", fill: meko_grey)[#body],
  fill: bg,
  stroke: 0.8pt + line,
  corner-radius: 5pt,
  inset: 8pt,
)
#let green-line = 1.6pt + meko_green
#let grey-line = 1.6pt + meko_grey
#let dashed-green = (paint: meko_green, thickness: 1.6pt, dash: "dashed")

// ───────────────────────── Page 1 ─────────────────────────

= Git & GitHub bei MeKo — die Take-aways

Repo `MeKo-Christian/workshop-teamwand` · Seite `meko-christian.github.io/workshop-teamwand` (nach jedem Merge, Version im Footer)

== Der Weg einer Änderung

#grid(
  columns: (1fr, 0.9em, 1fr, 0.9em, 1fr, 0.9em, 1fr, 0.9em, 1fr),
  row-gutter: 5pt,
  align: horizon,
  flow[Klonen], arrow, flow[Branch & Commit], arrow, flow[Pull Request], arrow,
  flow[Checks (CI + KI)], arrow, flow([Review], kind: "good"),
  grid.cell(colspan: 9, align(right, text(size: 9pt)[↓ Merge in `main`])),
  flow([Staging], kind: "warn"), arrow, flow[Release-PR], arrow,
  flow([Merge → neue Version], kind: "good"), arrow, flow([Prod], kind: "warn"),
  [], [],
)

#rule[Niemand ändert `main` direkt — nicht ihr, nicht der Agent, nicht die Admins.]
Jede Änderung nimmt diesen Weg, auch die kleinste. Der Agent tippt die Befehle; ihr sagt ihm, was er tun soll, und *prüft das Ergebnis*.

== Zwei Kopien: euer Rechner und GitHub

#align(center, diagram(
  spacing: (150pt, 40pt),
  node(
    (0, 0),
    width: 150pt,
    fill: meko_green.lighten(90%),
    stroke: 0.8pt + meko_green.lighten(30%),
    corner-radius: 6pt,
    inset: 9pt,
  )[
    #set text(size: 9.5pt)
    *Euer Rechner*\
    Arbeitsordner + `.git` mit der ganzen History\
    #text(size: 8.5pt)[Commits entstehen hier — auch offline]
  ],
  node(
    (1, 0),
    width: 150pt,
    fill: warn_bg,
    stroke: 0.8pt + warn_line,
    corner-radius: 6pt,
    inset: 9pt,
  )[
    #set text(size: 9.5pt)
    *GitHub („origin“)*\
    Das Original, für alle erreichbar\
    #text(size: 8.5pt)[*Nur hier:* Issues, PRs, Reviews, CI]
  ],
  edge((1, 0), (0, 0), "-|>", bend: 28deg, stroke: green-line, label: text(size: 9pt)[*clone* (einmal) · *pull*]),
  edge((0, 0), (1, 0), "-|>", bend: 28deg, stroke: green-line, label: text(size: 9pt)[*push*]),
))

#cols(
  [
    - Nichts gleicht sich von selbst ab: *ihr ändert* → GitHub sieht es erst nach dem *push*. *Andere ändern* → ihr seht es erst nach dem *pull*.
    - *Push abgelehnt?* GitHub hat auf dem Branch Commits, die ihr nicht habt → erst *pull*.
  ],
  [
    - *Ordner gelöscht?* GitHub bleibt unverändert, neu klonen. Verloren ist nur, was nie gepusht wurde.
    - Ein Merge in `main` blockiert euren Push nicht; `main` holt ihr eigens in euren Branch.
  ],
)
#rule[Faustregel: vor der Arbeit pull, nach dem Commit push.]

== `main` und Branch

#align(center, diagram(
  spacing: (46pt, 34pt),
  edge-stroke: grey-line,
  tag((-0.9, 0), [`main`]),
  ..range(6).map(x => dot((x, 0))),
  ..range(5).map(x => edge((x, 0), (x + 1, 0))),
  dot((2, 1), fill: meko_green),
  dot((3, 1), fill: meko_green),
  edge((1, 0), (2, 1), stroke: green-line, label: text(size: 8.5pt)[abzweigen], label-side: right),
  edge((2, 1), (3, 1), stroke: green-line),
  edge((3, 1), (4, 0), "-|>", stroke: dashed-green, label: text(size: 8.5pt)[PR → Merge], label-side: right),
  tag((-0.9, 1), [`feat/ada`], color: meko_green),
  edge((5, 0), (6.4, 0), "-|>", stroke: dashed-green),
  box-node((6.9, 0), [Staging], bg: warn_bg, line: warn_line),
))

#cols(
  [
    - `main` = der *abgestimmte Stand*, den ihr beim Klonen bekommt. Der Name ist frei wählbar (früher meist `master`).
    - *Unsere Entscheidung:* jeder Merge in `main` geht automatisch auf Staging.
    - Neue Arbeit startet immer vom neuesten `main` → erst pull.
  ],
  [
    - *Ein Issue = ein Branch = ein PR:* klein, gut zu reviewen.
    - Name: Typ + Kurzbeschreibung, z. B. `feat/ada`.
    - Ein Branch kostet nichts (nur ein Name), entsteht lokal, wird nach dem Merge gelöscht. Schiefgegangen? Wegwerfen.
  ],
)

#pagebreak()

// ───────────────────────── Page 2 ─────────────────────────

== Der PR-Titel wird zum Changelog

Beim Merge wird der PR-Titel *wörtlich* der Commit auf `main` und landet in den Release-Notes. Darum hat er eine feste Form, und die CI prüft sie:

#align(center, text(size: 14pt)[`typ: was sich ändert`])

#cols(
  card([Gut], kind: "good")[
    `feat: add anna to the team wall`\
    `fix: keep long mottos inside the card`
  ],
  card([Fällt durch die CI], kind: "bad")[
    `Update team.js`\
    `fix stuff`
  ],
  card([Formal ok, sagt nichts], kind: "warn")[
    `feat: changes`
  ],
)

#v(0.3em)
#table(
  columns: (auto, 1fr, auto, 1fr),
  stroke: none,
  inset: (x: 6pt, y: 4pt),
  fill: (_, y) => if calc.odd(y) { luma(245) } else { none },
  [`feat`], [neue Funktion], [`docs`], [nur Dokumentation],
  [`fix`], [Fehler behoben], [`refactor`], [Umbau ohne neues Verhalten],
  [`test`], [nur Tests], [`chore`], [Sonstiges (Abhängigkeiten, Aufräumen)],
)

== Checks und KI-Review

#align(center, diagram(
  spacing: (62pt, 30pt),
  edge-stroke: green-line,
  box-node((0, 0), [Pull Request]),
  box-node((1, -0.6), [CI: Format, Lint,\ Tests, PR-Titel]),
  box-node((1, 0.6), [KI-Review\ (nach `AGENTS.md`)], bg: warn_bg, line: warn_line),
  box-node((2, -0.6), [grün ✅], bg: meko_green.lighten(85%), line: meko_green),
  box-node((2, 0.6), [Kommentare], bg: warn_bg, line: warn_line),
  box-node((3, 0), [bereit fürs\ Review], bg: meko_green.lighten(85%), line: meko_green),
  edge((0, 0), (1, -0.6), "-|>"),
  edge((0, 0), (1, 0.6), "-|>"),
  edge((1, -0.6), (2, -0.6), "-|>"),
  edge((1, 0.6), (2, 0.6), "-|>"),
  edge((2, -0.6), (3, 0), "-|>"),
  edge((2, 0.6), (3, 0), "-|>", label: text(size: 8.5pt)[beantwortet\ + aufgelöst], label-side: right),
  edge((1, -0.6), (1, -1.35), "-|>", stroke: (paint: bad_line, thickness: 1.4pt), label: text(size: 8.5pt, fill: bad_line)[rot: im selben Branch fixen], label-side: right),
))

#v(0.2em)
#cols(
  [
    - Beides läuft *automatisch* bei jedem PR. *Rot = kein Merge.*
    - Rot wird *im selben Branch* repariert, nie werden Regeln abgeschaltet. Rot ist gut: der Fehler ist gefunden, bevor ihn jemand sieht.
  ],
  [
    - KI-Kommentare *bewerten*, nicht blind umsetzen.
    - Jeder Thread wird beantwortet und aufgelöst, sonst lässt sich nicht mergen. Der KI-Review ist beratend, die Freigabe gibt ein Mensch.
  ],
)

== Skill `/pr-fix`

Ein *Skill* ist eine Anleitung als Markdown-Datei, die der Agent Schritt für Schritt abarbeitet. `/pr-fix` erledigt die offenen Review-Kommentare eures PRs:

#grid(
  columns: (1fr, 0.9em, 1fr, 0.9em, 1.1fr, 0.9em, 1fr, 0.9em, 1.3fr),
  align: horizon,
  flow[PR finden], arrow, flow[Kommentare lesen], arrow,
  flow([Sortieren: beheben, beantworten, ablehnen], kind: "warn"), arrow,
  flow[Beheben: commit + push], arrow,
  flow([Antworten (deutsch), auflösen], kind: "good"),
)

#v(0.4em)
#cols(
  card([Eingebaute Bremsen], kind: "good")[
    - Kein offener PR → tut nichts.
    - Fragen werden beantwortet, nicht aufgelöst.
    - Erst push, dann antworten — nie umgekehrt.
    - Unklarer Kommentar → fragt euch statt zu raten.
  ],
  card([Eure Rolle], kind: "warn")[
    - Die Sortierung prüfen, *bevor* er ändert.
    - Ablehnen ist erlaubt — mit Begründung.
    - Die Antworten stehen unter *eurem Namen*: lesen!
  ],
)

== Review: Vier Augen

#cols(
  card([Ihr als Reviewer:in], kind: "good")[
    - Passt der PR zum Issue — und *nur* dazu?
    - Selbst ansehen, nicht nur dem Agenten glauben.
    - Ist der Titel ein guter Changelog-Eintrag?
    - Konkret kommentieren: *was* und *warum*. Änderungen anfordern ist nicht unhöflich.
  ],
  card([Der KI-Reviewer], kind: "warn")[
    - Findet Muster, schnell und gründlich.
    - Kennt euer Ziel nicht und kann irren.
    - *Gibt nichts frei:* Das macht immer ein Mensch, nie der Autor selbst. Approve heißt: ich stehe mit dafür ein.
  ],
)

#pagebreak()

// ───────────────────────── Page 3 ─────────────────────────

== Merge und Konflikt

#align(center, diagram(
  spacing: (46pt, 34pt),
  edge-stroke: grey-line,
  tag((-0.9, 0), [`main`]),
  ..range(4).map(x => dot((x, 0))),
  ..range(3).map(x => edge((x, 0), (x + 1, 0))),
  dot((4, 0), fill: meko_green, label: [S]),
  edge((3, 0), (4, 0), stroke: grey-line),
  tag((-0.9, 1), [`feat/ada`], color: meko_green),
  dot((1, 1), fill: luma(170)),
  dot((2, 1), fill: luma(170)),
  dot((3, 1), fill: luma(170)),
  edge((0, 0), (1, 1), stroke: (paint: luma(170), thickness: 1.4pt)),
  edge((1, 1), (2, 1), stroke: (paint: luma(170), thickness: 1.4pt)),
  edge((2, 1), (3, 1), stroke: (paint: luma(170), thickness: 1.4pt)),
  edge((3, 1), (4, 0), "-|>", stroke: dashed-green, label: text(size: 8.5pt)[Squash-Merge], label-side: right),
  tag((5.4, 0), [＝ *ein* Commit\ mit PR-Titel], color: meko_green),
))

- *Squash-Merge:* der ganze PR wird *ein* Commit `S` auf `main`, mit dem PR-Titel als Nachricht. `main` bleibt eine gerade Linie, egal wie es im Branch aussah.
- Jeder Merge ändert `main`: mergt *nacheinander*, die anderen ziehen nach. Danach lokal *pull*, sonst kennt euer Rechner den neuen Stand nicht.

#v(0.3em)
#cols(
  [
    #text(size: 10pt)[*Konflikt:* zwei PRs ändern *dieselbe Stelle*. Wer zuerst merged, gewinnt, der andere zieht nach.]
    #v(0.2em)
    ```
    <<<<<<< main
      { login: "anna", … },
    =======
      { login: "ben", … },
    >>>>>>> mein-branch
    ```
  ],
  card([Was richtig ist, wisst ihr], kind: "good")[
    Git kann nicht entscheiden, welche Zeile gilt. In der Teamwand: *beide* behalten, alphabetisch sortiert.
    #v(0.3em)
    #prompt[Löse den Konflikt so, dass beide Einträge erhalten bleiben, und erklär mir, was du gemacht hast.]
  ],
)

== Release: Versionen aus PR-Titeln

#align(center, diagram(
  spacing: (50pt, 30pt),
  edge-stroke: green-line,
  box-node((0, 0), [Merge in `main`]),
  box-node((1, 0), [Staging], bg: warn_bg, line: warn_line),
  box-node((2, 0), [Release-PR\ (offen)]),
  box-node((3, 0), [Review +\ Merge], bg: meko_green.lighten(85%), line: meko_green),
  box-node((4, 0), [Prod], bg: warn_bg, line: warn_line),
  edge((0, 0), (1, 0), "-|>", label: text(size: 8pt)[automatisch]),
  edge((1, 0), (2, 0), "-|>", label: text(size: 8pt)[sammelt]),
  edge((2, 0), (3, 0), "-|>"),
  edge((3, 0), (4, 0), "-|>", label: text(size: 8pt)[neue Version]),
))

#cols(
  [
    *release-please* hält nach jedem Merge *einen* Release-PR offen:
    - Changelog aus euren *PR-Titeln*
    - neue Versionsnummer
    - Merge des Release-PRs → *Prod*

    Prod bekommt genau den Stand, der schon auf Staging lief.
  ],
  card([chore(main): release 0.2.0])[
    #set text(size: 9.5pt)
    ```
    ## 0.2.0

    ### Features
    * add anna to the team wall
    * add ben to the team wall
    * add carla to the team wall
    ```
  ],
)

#v(0.2em)
#card([Und wenn Prod kaputt ist?], kind: "warn")[
  Kein Hotfix per Hand. Die Änderung per *Revert-PR* zurücknehmen und neu releasen — gleicher Weg, auch unter Zeitdruck.
]

== Merge oder Rebase? Euren Branch auf `main` nachziehen

Euer Branch ist hinter `main`, weil inzwischen `C` gemerged wurde. Zwei Wege:

#let nd(pos, label, fill: meko_grey, ghost: false) = node(
  pos,
  text(size: 8pt, weight: "bold", fill: if ghost { luma(150) } else { white })[#label],
  shape: circle,
  radius: 9pt,
  fill: if ghost { none } else { fill },
  stroke: if ghost { (paint: luma(160), thickness: 1pt, dash: "dashed") } else { none },
)
#cols(
  card([Merge — der sichere Standard], kind: "good")[
    #align(center, diagram(
      spacing: (30pt, 24pt),
      edge-stroke: grey-line,
      ..range(3).map(x => nd((x, 0), ([1], [2], [C]).at(x))),
      edge((0, 0), (1, 0)),
      edge((1, 0), (2, 0)),
      nd((1, 1), [A], fill: meko_green),
      nd((2, 1), [B], fill: meko_green),
      nd((3, 1), [M], fill: meko_green.darken(30%)),
      edge((0, 0), (1, 1), stroke: green-line),
      edge((1, 1), (2, 1), stroke: green-line),
      edge((2, 1), (3, 1), stroke: green-line),
      edge((2, 0), (3, 1), "-|>"),
    ))
    Ein Merge-Commit `M` verbindet beide Linien; `A` und `B` bleiben unverändert. Das macht auch „Update branch“ auf GitHub.
  ],
  card([Rebase — neu aufsetzen], kind: "warn")[
    #align(center, diagram(
      spacing: (30pt, 24pt),
      edge-stroke: grey-line,
      ..range(3).map(x => nd((x, 0), ([1], [2], [C]).at(x))),
      edge((0, 0), (1, 0)),
      edge((1, 0), (2, 0)),
      nd((1, 1), [A], ghost: true),
      nd((2, 1), [B], ghost: true),
      edge((0, 0), (1, 1), stroke: (paint: luma(160), dash: "dashed")),
      edge((1, 1), (2, 1), stroke: (paint: luma(160), dash: "dashed")),
      nd((3, 1), [A′], fill: meko_green),
      nd((4, 1), [B′], fill: meko_green),
      edge((2, 0), (3, 1), stroke: green-line),
      edge((3, 1), (4, 1), stroke: green-line),
    ))
    Eure Commits werden auf das neue `main` neu abgespielt → *neue* Commits `A′`, `B′`. Danach braucht der push `--force-with-lease`.
  ],
)

#v(0.3em)
#card([Goldene Regel], kind: "bad")[
  Nie Commits rebasen, die andere schon haben — sonst gibt es doppelte Commits. `main` ist gegen force push gesperrt. Der Code ist nach beiden Wegen derselbe, nur die History nicht.
]

#pagebreak()

// ───────────────────────── Page 4 ─────────────────────────

== Prompts, Etappe für Etappe

Ihr sagt eurem Agenten, *was* er tun soll, und prüft danach selbst:

#table(
  columns: (auto, 1fr, 0.8fr),
  stroke: (x: none, y: 0.4pt + luma(210)),
  inset: (x: 6pt, y: 6pt),
  fill: (_, y) => if y == 0 { meko_green.lighten(85%) } else { none },
  table.header[*Etappe*][*Sagt eurem Agenten*][*Selbst prüfen*],
  [1 · Klonen],
  [#prompt[Klone MeKo-Christian/workshop-teamwand in meinen Projektordner.] #prompt[Welche Issues sind mir zugewiesen?]],
  [`index.html` im Browser öffnen],
  [2 · Branch & Commit],
  [#prompt[Leg einen Branch nach AGENTS.md an, erstelle meine Karte (Name, Emoji, Motto) und committe. Noch nicht hochladen.]],
  [Karte lokal sichtbar? Branch auf GitHub? (noch nicht)],
  [3 · Push & PR],
  [#prompt[Lade meinen Branch hoch und öffne einen PR mit Conventional-Commit-Titel. Gib mir den Link.]],
  [Titel verständlich? Nur eure Zeile geändert?],
  [4 · Checks],
  [#prompt[Sind die Checks grün? Falls rot: Lies das Log und behebe den Fehler, ohne Regeln abzuschalten.] #prompt[Fass das KI-Review zusammen. Was ist berechtigt?]],
  [Kommentare beantworten und auflösen],
  [5 · Review],
  [#prompt[Fordere ein Review von der Person an, die in meinem Issue steht.] #prompt[Hol mir diesen PR und fass zusammen: Passt er zum Issue und zu AGENTS.md?]],
  [Fremden PR ansehen, *selbst* freigeben],
  [6 · Merge & Staging],
  [#prompt[Ist mein PR freigegeben und grün? Dann merge ihn.] #prompt[Hol den neuesten Stand von main und lösch meinen alten Branch lokal.]],
  [Staging zeigt eure Karte],
  [7 · Release & Prod],
  [#prompt[Zeig mir den offenen Release-PR und fass den Changelog zusammen.] #prompt[Ist die Release-Pipeline durchgelaufen?]],
  [Gemeinsam freigeben, Prod und Version prüfen],
)

#v(0.4em)
*Wenn es hakt:* #prompt[Mein PR hat einen Konflikt mit main …] · #prompt[Bring meinen Branch per Merge auf den Stand von main.] · #prompt[Erklär mir, was du gerade gemacht hast und warum.]

== Wer macht was?

#cols(
  card([Der Agent tippt], kind: "warn")[
    - Befehle ausführen: klonen, Branch, Commit, push
    - PR anlegen, Logs lesen, Fehler beheben
    - Kommentare und Changelog zusammenfassen
    - Konflikte vorschlagen aufzulösen
  ],
  card([Ihr entscheidet und prüft], kind: "good")[
    - Was geändert wird und ob es zum Issue passt
    - Titel, Text und Diff vor dem Hochladen
    - Welche KI-Kommentare berechtigt sind
    - *Die Freigabe im Browser* — nie der Agent
  ],
)

== Eure Regeln auf einen Blick

#cols(
  [
    - Niemand ändert `main` direkt.
    - Ein Issue, ein Branch, ein kleiner PR.
    - Vor der Arbeit pull, nach dem Commit push.
    - PR-Titel: `typ: was sich ändert`.
  ],
  [
    - Rote CI wird repariert, nicht abgeschaltet.
    - Jeder KI-Kommentar wird bewertet und beantwortet.
    - Das Review ist ein Mensch, nie der Autor.
    - Prod nur über den Release-PR; Rollback per Revert-PR.
  ],
)

#v(1fr)

#card(none, kind: "good")[
  #align(center)[
    #text(fill: meko_green, weight: "bold", size: 12pt)[
      Der Agent tippt. Verantwortlich seid ihr — und das Review ist eure Unterschrift.
    ]\
    #v(0.2em)
    Weiterüben: Issues mit Label `bonus` (kleine Features mit Test, gleicher Weg) · Vorlage für euer eigenes Projekt: `MeKo-Tech/go-react-template`
  ]
]
