#import "@preview/polylux:0.4.0": *
#import "@preview/polylux:0.4.0": toolbox.pdfpc
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "lib.typ": *
#import "lib.typ" as lib

// Define slides, so we can include it in handout mode
#let slides = [
  #show: setup

  // Rounded card used throughout this deck; `kind` picks the colour scheme.
  #let card(title, body, kind: "neutral") = {
    let (bg, border) = if kind == "good" {
      (meko_green.lighten(90%), meko_green.lighten(30%))
    } else if kind == "bad" {
      (rgb("#fff3f3"), rgb("#cc3333"))
    } else if kind == "warn" {
      (rgb("#fff8e1"), rgb("#e0b73a"))
    } else {
      (luma(245), luma(200))
    }
    block(
      width: 100%,
      fill: bg,
      stroke: 0.75pt + border,
      radius: 10pt,
      inset: (x: 12pt, top: 10pt, bottom: 12pt),
    )[
      #if title != none [#text(weight: "bold")[#title] #v(0.2em)]
      #set text(size: 0.85em, fill: meko_body)
      #body
    ]
  }

  // One step of the delivery flow: a small box with a label and a sub line.
  #let step(label, sub, kind: "neutral") = card(none, kind: kind)[
    #align(center)[
      #text(size: 1.05em, weight: "bold", fill: meko_grey)[#label]\
      #text(size: 0.85em)[#sub]
    ]
  ]
  #let arrow = align(center + horizon, text(size: 1.4em, fill: meko_green)[→])

  // A prompt for the participant's agent.
  #let prompt(body) = text(fill: meko_green, weight: "bold")[„#body“]

  // Exercise slide body: the prompts for the agent, then what to check by
  // yourself. No terminal commands: the agent runs them.
  #let aufgabe(minuten, prompts, selbst) = [
    #text(
      fill: meko_green,
      weight: "bold",
    )[Sagt eurem Agenten (ca. #minuten Minuten)]
    #v(0.3em)
    #stack(
      spacing: 8pt,
      ..prompts
        .enumerate()
        .map(((i, body)) => block(
          width: 100%,
          fill: meko_green.lighten(90%),
          stroke: 0.75pt + meko_green.lighten(30%),
          radius: 10pt,
          inset: (x: 14pt, y: 10pt),
          grid(
            columns: (1.6em, 1fr),
            text(fill: meko_green, weight: "bold")[#(i + 1)], prompt(body),
          ),
        )),
    )
    #v(0.6em)
    *Selbst prüfen:* #selbst
  ]

  // The stages of the workshop. Every stage section shows this bar with the
  // current stage highlighted, so the flow stays visible as one piece.
  #let etappen-liste = (
    [Klonen],
    [Branch & Commit],
    [Push & PR],
    [Checks],
    [Review],
    [Merge & Staging],
    [Release & Prod],
  )
  #let etappen(current, on-dark: true) = {
    let fg = if on-dark { white } else { meko_grey }
    let active-fg = if on-dark { meko_green } else { white }
    let active-bg = if on-dark { white } else { meko_green }
    grid(
      columns: etappen-liste.len(),
      column-gutter: 5pt,
      ..etappen-liste
        .enumerate()
        .map(((i, name)) => {
          let active = i + 1 == current
          box(
            radius: 20pt,
            inset: (x: 7pt, y: 4pt),
            fill: if active { active-bg } else { none },
            stroke: 0.75pt + if active { active-bg } else { fg },
            text(
              size: 11pt,
              weight: if active { "bold" } else { "regular" },
              fill: if active { active-fg } else { fg },
            )[#(i + 1) · #name],
          )
        }),
    )
  }

  #let etappe(nummer, title, body, notes: none) = section-slide(
    [Etappe #nummer: #title],
    notes: notes,
  )[
    #body
    #v(1.5em)
    #etappen(nummer)
  ]

  #title-slide(
    title: [Git & GitHub Workshop],
    subtitle: [Von der Idee bis in die Produktionsumgebung],
    authors: [Webanwendungen & Schnittstellen (EWWS)],
    notes: "Begrüßung · heute keine Vorlesung · ihr macht es selbst · eine Änderung, Schritt für Schritt bis Prod",
  )

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Einstieg
  // ─────────────────────────────────────────────────────────────────────────

  #content-slide(
    [Workshop-Agenda],
    notes: "Grundlagen kennt ihr aus dem SE-Workshop · heute: echtes Repo, echte Pipeline, echtes Review · EINE Änderung pro Person · alle gehen gemeinsam Etappe für Etappe · der Agent tippt, ihr entscheidet und prüft",
  )[
    #set align(left)
    Die Grundlagen hatten wir schon: Commit, Branch, Merge, Pull Request.
    Heute spielen wir den *kompletten Ablauf* wie bei uns üblich selbst durch — an einem Beispiel-Repo „Teamwand“.

    #v(0.5em)
    *Eine Änderung pro Person:* jede:r trägt sich in die Teamwand ein.
    Wir gehen den Weg *gemeinsam, Etappe für Etappe*.

    #v(0.7em)
    #align(center, etappen(0, on-dark: false))

    #v(0.7em)
    *Euer Agent tippt die Befehle — ihr sagt ihm, was er tun soll, und prüft das Ergebnis.*
  ]

  #content-slide(
    [Der Weg einer Änderung],
    notes: "einmal komplett zeigen, dann Etappe für Etappe · obere Reihe: jeder PR · untere Reihe: Release · Staging nach jedem Merge, Prod nur über Release-PR · niemand ändert main direkt",
  )[
    #set align(left)
    *Jede Änderung* — egal wie klein — nimmt diesen Weg:

    #v(0.4em)
    #grid(
      columns: (1fr, 1.6em, 1fr, 1.6em, 1fr, 1.6em, 1fr, 1.6em, 1fr),
      align: horizon,
      step([Klonen], [Kopie holen]),
      arrow,
      step([Branch], [eigene Linie]),
      arrow,
      step([Pull Request], [Bitte um Aufnahme]),
      arrow,
      step([Checks], [CI + KI-Review]),
      arrow,
      step([Review], [ein Mensch], kind: "good"),
    )
    #v(0.3em)
    #align(right, text(
      size: 0.85em,
      fill: meko_body,
    )[↓ Merge in `main`#h(5.5em)])
    #v(0.3em)
    #grid(
      columns: (1fr, 1.6em, 1fr, 1.6em, 1fr, 1.6em, 1fr),
      align: horizon,
      step([Staging], [Testumgebung], kind: "warn"),
      arrow,
      step([Release-PR], [sammelt Änderungen]),
      arrow,
      step([Review + Merge], [neue Version], kind: "good"),
      arrow,
      step([Prod], [live], kind: "warn"),
    )

    #v(0.6em)
    #text(fill: meko_green, weight: "bold")[
      Niemand ändert main direkt — nicht ihr, nicht der Agent, nicht die Admins.
    ]
  ]

  #content-slide(
    [Die Teamwand],
    notes: "Repo im Browser zeigen · team.js eine Zeile pro Person, alphabetisch · AGENTS.md: Regeln, die der Agent und der KI-Reviewer lesen · Seite auf GitHub Pages, öffentlich",
  )[
    #set align(left)
    #grid(
      columns: (1.3fr, 1fr),
      gutter: 18pt,
      [
        *Unser Übungsprojekt:* eine Webseite mit einer Karte pro Person.

        #v(0.4em)
        - `team.js` — die Einträge, eine Zeile pro Person
        - `index.html` — die Seite, per Doppelklick öffnen
        - `AGENTS.md` — die Regeln für euch *und* euren Agenten

        #v(0.4em)
        #text(size: 0.85em)[Kein Build, kein Server — läuft direkt im Browser.]
      ],
      [
        #card([Repo])[`MeKo-Christian/workshop-teamwand`]
        #card(
          [GitHub Pages — nach jedem Merge],
          kind: "warn",
        )[`meko-christian.github.io/workshop-teamwand`]
        #card(
          [Release — neue Version im Footer],
          kind: "good",
        )[Release-PR mergen, dann Seite neu laden]
      ],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 1 — Klonen
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    1,
    [Klonen],
    notes: "erst verstehen, was auf GitHub liegt und was bei mir · dann klonen",
  )[
    Was liegt auf GitHub — und was holt ihr euch auf den Rechner?
  ]

  #content-slide(
    [Zwei Kopien: Euer Rechner und GitHub],
    notes: "Klonen nur EINMAL pro Rechner · danach nur noch holen und hochladen, immer wieder · origin = Name, unter dem euer Rechner die GitHub-Kopie kennt · Klonen = vollständige Kopie mit ganzer History (.git-Ordner), nicht nur Dateien · Commits entstehen lokal · Issues, PRs, Actions, Reviews gibt es NUR auf GitHub",
  )[
    #set align(left)
    #let label(body) = text(size: 0.85em, weight: "bold")[#body]
    #let hint(body) = text(size: 0.7em, fill: meko_body)[#body]
    #let pfeil(body) = text(size: 1.4em, fill: meko_green)[#body]
    #grid(
      columns: (1fr, 9em, 1fr),
      align: horizon,
      card([Euer Rechner], kind: "good")[
        Eure eigene, vollständige Kopie.
        #v(0.3em)
        - Arbeitsordner mit allen Dateien
        - versteckter Ordner `.git` mit der ganzen History
        - hier entstehen eure Commits — auch offline
      ],
      align(center)[
        #label[Klonen]\
        #pfeil[←]\
        #hint[*nur einmal* pro Rechner]
        #v(0.2em)
        #line(length: 80%, stroke: 0.5pt + luma(190))
        #v(0.1em)
        #hint[danach immer wieder:]
        #v(0.2em)
        #label[Holen (#underline[pull])]\
        #pfeil[←]
        #v(0.3em)
        #pfeil[→]\
        #label[Hochladen (#underline[push])]
      ],
      card(
        [#box(
            baseline: 15%,
            image("assets/github-mark.svg", height: 1em),
          ) GitHub („origin“)],
        kind: "warn",
      )[
        Das Original, für alle erreichbar.
        #v(0.3em)
        - alle Dateien und die ganze History
        - *nur hier:* Issues, Pull Requests, Reviews, CI
        - „origin“ ist nur der Name, unter dem euer Rechner diese Kopie kennt
      ],
    )

    #v(0.6em)
    #set text(size: 0.8em)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 12pt,
      [*Klonen* — einmal: kopiert alles und merkt sich „origin“.],
      [*Holen* — vor jeder Arbeit: neue Commits von GitHub übernehmen.],
      [*Hochladen* — nach dem Commit: eure Commits zu GitHub schicken.],
    )
  ]

  #content-slide(
    [Zwei Kopien — unabhängig voneinander],
    notes: "wichtigster Punkt: nichts synchronisiert sich automatisch · pull und push sind bewusste Schritte · push abgelehnt = GitHub hat auf DIESEM Branch Commits, die ihr nicht habt → erst pull · ein Merge in main blockiert den push auf euren Branch nicht · main in den eigenen Branch holen ist ein eigener Schritt → Etappe 6, Anhang Merge/Rebase · Konflikt nur, wenn dieselbe Stelle geändert wurde · Faustregel: vor der Arbeit pull, nach dem Commit push",
  )[
    #set align(left)
    Nichts gleicht sich von selbst ab — nur wenn ihr *holt (#underline[pull])*
    oder *hochladet (#underline[push])*.

    #v(0.5em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 10pt,
      align: top,
      card([Ihr ändert etwas], kind: "good")[
        Liegt *nur bei euch*. GitHub sieht es erst nach dem *push*.
      ],
      card([Jemand anders ändert etwas], kind: "warn")[
        Liegt *nur auf GitHub*. Ihr seht es erst nach dem *pull*.
      ],

      card([Beide ändern denselben Branch], kind: "bad")[
        Euer *push* wird abgelehnt: GitHub hat auf dem Branch Commits, die ihr
        noch nicht habt. Erst *pull* — Git führt beides zusammen. Neues auf
        `main` holt ihr dagegen eigens in euren Branch (Etappe 6).
      ],
      card([Ihr löscht euren Ordner])[
        GitHub bleibt unverändert. Neu klonen — weg ist nur, was ihr noch nicht
        per *push* hochgeladen habt.
      ],
    )

    #v(0.5em)
    #text(fill: meko_green, weight: "bold")[
      Faustregel: vor der Arbeit pull, nach dem Commit push.
    ]
  ]

  #content-slide(
    [🛠 Etappe 1: Klonen],
    notes: "~5 Min · Agent klont und zeigt die History · Issue liegt auf GitHub, nicht im Ordner",
  )[
    #set align(left)
    #aufgabe(
      5,
      (
        [Klone MeKo-Christian/workshop-teamwand in meinen Projektordner.],
        [Zeig mir die letzten fünf Commits.],
        [Welche Issues sind mir auf GitHub zugewiesen?],
      ),
      [`index.html` im Browser öffnen — die Seite läuft bei euch lokal.],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 2 — Branch & Commit
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    2,
    [Branch & Commit],
    notes: "Branch = eigene Linie, main bleibt unberührt · Commit = Snapshot mit Nachricht · alles nur lokal",
  )[
    Auf eigenem Branch arbeiten — vorerst nur auf eurem Rechner.
  ]

  #content-slide(
    [Was ist `main`?],
    notes: "main = der gemeinsame, abgestimmte Stand · beim Klonen bekommt ihr main · Name ist frei wählbar: früher meist master, wir haben uns für main entschieden · unsere Entscheidung: jeder push auf main geht automatisch auf Staging · neue Arbeit immer vom neuesten main starten → erst pull",
  )[
    #set align(left)
    `main` ist die *Hauptlinie* des Projekts: der Stand, auf den sich alle
    geeinigt haben. Beim Klonen bekommt ihr genau diesen Stand.

    #let commit(pos) = node(
      pos,
      none,
      shape: circle,
      radius: 7pt,
      fill: meko_grey,
      stroke: none,
    )
    #let titel(pos, body) = node(
      pos,
      text(size: 0.7em, fill: meko_body)[#body],
      stroke: none,
    )
    // lib.typ fixes raw at 14pt; match the smaller text on this slide.
    #show raw: set text(size: 12pt)
    #align(center, diagram(
      spacing: (62pt, 12pt),
      edge-stroke: 1.6pt + meko_grey,
      node((-0.7, 0), text(weight: "bold")[`main`], stroke: none),
      ..range(4).map(x => commit((x, 0))),
      ..range(3).map(x => edge((x, 0), (x + 1, 0))),
      titel((0, 1), [Projekt angelegt]),
      titel((1, 1), [feat: add anna]),
      titel((2, 1), [fix: typo in motto]),
      titel((3, 1), [feat: add ben]),
      edge((3, 0), (4.2, 0), "-|>", stroke: (
        paint: meko_green,
        thickness: 1.6pt,
        dash: "dashed",
      )),
      node(
        (4.2, 0),
        text(size: 0.85em, weight: "bold")[Staging],
        fill: rgb("#fff8e1"),
        stroke: 0.75pt + rgb("#e0b73a"),
        corner-radius: 6pt,
        inset: 7pt,
      ),
    ))

    #v(0.4em)
    #set text(size: 0.9em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 12pt,
      align: top,
      card([Nur ein Name])[
        Der Name ist frei wählbar. Früher hieß die Hauptlinie meist `master` —
        wir haben uns für `main` entschieden.
      ],
      card([Geht auf Staging], kind: "warn")[
        Unsere Entscheidung: Jeder push auf `main` landet automatisch auf Staging.
      ],
    )

    #v(0.5em)
    #text(fill: meko_green, weight: "bold")[
      Neue Arbeit startet immer vom neuesten `main` — also erst pull.
    ]
  ]

  #content-slide(
    [Was ist ein Branch?],
    notes: "Branch = eigene Linie von Commits, zweigt von main ab · main bleibt stabil, geht nach jedem Merge auf Staging · ein Issue = ein Branch = ein PR · kostet nichts: nur ein Name, der auf einen Commit zeigt · entsteht lokal, GitHub sieht ihn erst nach push · nach dem Merge gelöscht",
  )[
    #set align(left)
    Ein Branch ist eine *eigene Linie von Commits*. Ihr zweigt von `main` ab,
    arbeitet in Ruhe — und bringt eure Änderung per Pull Request zurück.

    #let commit(pos, fill) = node(
      pos,
      none,
      shape: circle,
      radius: 7pt,
      fill: fill,
      stroke: none,
    )
    #let hinweis(body) = text(size: 0.75em, fill: meko_body)[#body]
    #align(center, diagram(
      spacing: (52pt, 30pt),
      edge-stroke: 1.6pt + meko_grey,
      node((-0.8, 0), text(weight: "bold")[`main`], stroke: none),
      ..range(5).map(x => commit((x, 0), meko_grey)),
      ..range(4).map(x => edge((x, 0), (x + 1, 0))),
      commit((2, 1), meko_green),
      commit((3, 1), meko_green),
      edge(
        (1, 0),
        (2, 1),
        stroke: 1.6pt + meko_green,
        label: hinweis[abzweigen],
        label-side: right,
      ),
      edge((2, 1), (3, 1), stroke: 1.6pt + meko_green),
      edge(
        (3, 1),
        (4, 0),
        stroke: (paint: meko_green, thickness: 1.6pt, dash: "dashed"),
        "-|>",
        label: hinweis[Pull Request → Merge],
        label-side: right,
      ),
      node(
        (-0.8, 1),
        text(fill: meko_green, weight: "bold")[`feat/ada`],
        stroke: none,
      ),
    ))

    #v(0.3em)
    #set text(size: 0.9em)
    // lib.typ fixes raw at 14pt; match the smaller card text here.
    #show raw: set text(size: 12pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 12pt,
      align: top,
      card([Warum?], kind: "good")[
        - `main` bleibt stabil — geht nach jedem Merge auf Staging.
        - Ihr stört niemanden, niemand stört euch.
        - Ein Issue = ein Branch = ein PR: klein, gut zu reviewen.
        - Schiefgegangen? Branch wegwerfen.
      ],
      card([Gut zu wissen])[
        - Kostet nichts: nur ein Name, der auf einen Commit zeigt.
        - Name: Typ und Kurzbeschreibung, z. B. `feat/ada`.
        - Entsteht lokal — GitHub sieht ihn erst nach dem push.
        - Nach dem Merge wird er gelöscht.
      ],
    )
  ]

  #content-slide(
    [🛠 Etappe 2: Branch & Commit],
    notes: "~10 Min · Agent liest AGENTS.md für Branch-Namen und Commit-Nachricht · KEIN Hochladen · auf GitHub nachsehen: Branch gibt es dort nicht → Etappe 1 bestätigt",
  )[
    #set align(left)
    #aufgabe(
      10,
      (
        [Ich will eine Änderung machen. Leg dafür einen Branch nach AGENTS.md an.],
        [Erstelle nun eine persönliche Karte — Name, Emoji, Motto.],
        [Committe das. Noch nicht hochladen.],
        [Zeige mir das Ergebnis lokal im Browser an],
      ),
      [`index.html` ist eure Karte da? Und auf GitHub: gibt es euren Branch dort schon?],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 3 — Push & Pull Request
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    3,
    [Push & Pull Request],
    notes: "Hochladen bringt den Branch zu GitHub · der PR ist die Bitte, ihn in main aufzunehmen",
  )[
    Die Änderung geht zu GitHub — und ihr bittet um Aufnahme in `main`.
  ]

  #content-slide(
    [Der PR-Titel wird zum Changelog],
    notes: "Conventional Commits · beim Merge wird der PR-Titel DER Commit auf main · release-please baut daraus Changelog und Version · deshalb prüft CI den Titel",
  )[
    #set align(left)
    Der Titel des Pull Requests landet später *wörtlich* in den Release-Notes. Darum hat er eine feste Form:

    #v(0.5em)
    #align(center, text(size: 1.2em)[`typ: was sich ändert`])
    #v(0.5em)

    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 12pt,
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
    #v(0.5em)
    #text(
      size: 0.85em,
    )[`feat` = neue Funktion · `fix` = Fehler behoben · `docs`, `chore`, `test` … = Sonstiges]
  ]

  #content-slide(
    [🛠 Etappe 3: Push & Pull Request],
    notes: "~10 Min · nach dem Hochladen ist der Branch auf GitHub sichtbar · Titel und Text prüfen, bevor der PR rausgeht · 'Closes #N' verknüpft das Issue",
  )[
    #set align(left)
    #aufgabe(
      10,
      (
        [Lade meinen Branch hoch.],
        [Erstelle einen Pull Request mit Conventional-Commit-Titel],
        [Gib mir den Link zum PR.],
      ),
      [PR im Browser öffnen: Titel verständlich? Nur eure eine Zeile geändert?],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 4 — Checks
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    4,
    [Checks],
    notes: "CI prüft Formatierung, Lint, Tests, PR-Titel · KI-Review kommentiert nach AGENTS.md · beide laufen automatisch · rot = kein Merge",
  )[
    CI und KI-Review laufen automatisch bei jedem Pull Request.
  ]

  #content-slide(
    [🛠 Etappe 4: Checks],
    notes: "~10 Min · Demo demo/rote-ci, falls bei niemandem was rot ist · nie Regeln abschalten · KI-Review dauert ein paar Minuten · Kommentare bewerten, nicht blind umsetzen · Threads auflösen, sonst kein Merge",
  )[
    #set align(left)
    #aufgabe(
      10,
      (
        [Sind die Checks in meinem PR grün?],
        [Falls rot: Lies das Log und behebe den Fehler — ohne Regeln abzuschalten.],
        [Fass das KI-Review zusammen. Was davon ist berechtigt?],
      ),
      [Jeden Kommentar beantworten und auflösen — vorher lässt sich nicht mergen. Rot ist gut: Der Fehler ist gefunden, bevor ihn jemand sieht.],
    )
  ]

  #content-slide(
    [Skill: `/pr-fix`],
    notes: "Skill = Anleitung als Markdown-Datei, der Agent arbeitet sie Schritt für Schritt ab · /pr-fix: offene Review-Kommentare abarbeiten — genau das, was ihr gerade von Hand gemacht habt · erst sortieren, dann ändern · Fragen werden beantwortet, nicht aufgelöst · Antworten auf Deutsch, stehen unter eurem Namen → lesen! · kein PR → macht nichts",
  )[
    #set align(left)
    Ein *Skill* ist eine Anleitung als Markdown-Datei — der Agent arbeitet sie
    Schritt für Schritt ab. #box[`/pr-fix`] erledigt die offenen Review-Kommentare
    eures Pull Requests.

    #v(0.4em)
    #grid(
      columns: (1fr, 1.6em, 1fr, 1.6em, 1fr, 1.6em, 1fr, 1.6em, 1fr),
      align: horizon,
      step([PR finden], [zum Branch]),
      arrow,
      step([Kommentare], [offene Threads]),
      arrow,
      step([Sortieren], [beheben, beantworten, ablehnen], kind: "warn"),
      arrow,
      step([Beheben], [commit + push]),
      arrow,
      step([Antworten], [auf Deutsch, dann auflösen], kind: "good"),
    )

    #v(0.5em)
    #set text(size: 0.9em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 12pt,
      align: top,
      card([Eingebaute Bremsen], kind: "good")[
        - Kein offener PR → tut nichts.
        - Fragen werden beantwortet, aber nicht aufgelöst.
        - Erst push, dann antworten — nie umgekehrt.
        - Unklarer Kommentar → fragt euch statt zu raten.
      ],
      card([Eure Rolle], kind: "warn")[
        - Die Sortierung prüfen, bevor er ändert.
        - Ablehnen ist erlaubt — mit Begründung.
        - Die Antworten stehen unter eurem Namen: lesen!
      ],
    )

    #v(0.5em)
    #text(fill: meko_green, weight: "bold")[
      Aufruf auf eurem PR-Branch: `/pr-fix` — der Agent arbeitet, ihr prüft.
    ]
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 5 — Review
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    5,
    [Review],
    notes: "Vier-Augen-Prinzip · jede:r reviewt den PR einer anderen Person · Reviewer steht im Issue",
  )[
    Vier Augen: Ein Mensch gibt frei — nie der Autor selbst.
  ]

  #content-slide(
    [Gutes Review],
    notes: "Approve heißt: ich stehe mit dafür ein · KI findet Muster, Mensch prüft Sinn · konkret kommentieren · Änderungen anfordern ist nicht unhöflich",
  )[
    #set align(left)
    #grid(
      columns: (1fr, 1fr),
      gutter: 14pt,
      card([Ihr als Reviewer:in], kind: "good")[
        - Passt der PR zum Issue — und *nur* dazu?
        - Selbst ansehen, nicht nur dem Agenten glauben
        - Ist der Titel ein guter Changelog-Eintrag?
        - Konkret kommentieren: *was* und *warum*
      ],
      card([Der KI-Reviewer], kind: "warn")[
        - Prüft gegen `AGENTS.md`, schnell und gründlich
        - Kennt aber euer Ziel nicht — und kann irren
        - *Gibt nichts frei* — das macht immer ein Mensch
      ],
    )
  ]

  #content-slide(
    [🛠 Etappe 5: Review],
    notes: "~10 Min · Review-Ring: Reviewer steht im Issue · Freigabe selbst im Browser klicken, nicht vom Agenten · der Agent holt den fremden Branch von origin → Etappe 1",
  )[
    #set align(left)
    #aufgabe(
      10,
      (
        [Fordere für meinen PR ein Review von der Person an, die in meinem Issue steht.],
        [Welche PRs soll ich reviewen?],
        [Hol mir diesen PR auf den Rechner und fass zusammen: Passt er zum Issue und zu AGENTS.md?],
      ),
      [Den fremden PR im Browser ansehen und *selbst* freigeben oder Änderungen anfordern.],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 6 — Merge & Staging
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    6,
    [Merge & Staging],
    notes: "jetzt ändert sich main auf GitHub · alle anderen müssen nachziehen",
  )[
    Ab in `main` — und automatisch auf Staging.
  ]

  #content-slide(
    [Merge-Konflikt — keine Panik],
    notes: "jeder Merge ändert main · wer direkt neben euch in team.js steht, bekommt einen Konflikt · falls keiner auftritt: Demo mit demo/konflikt-a + b · beide Zeilen behalten",
  )[
    #set align(left)
    Zwei PRs ändern *dieselbe Stelle*. Wer zuerst merged, gewinnt — der andere muss nachziehen.

    #v(0.5em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 14pt,
      [
        #set text(size: 0.85em)
        ```
        <<<<<<< main
          { login: "anna", … },
        =======
          { login: "ben", … },
        >>>>>>> mein-branch
        ```
      ],
      card([Was richtig ist, wisst ihr], kind: "good")[
        Git kann nicht entscheiden, welche Zeile gilt. Hier: *beide*, alphabetisch.
      ],
    )
    #v(0.6em)
    #prompt[Mein PR hat einen Konflikt mit main. Löse ihn so, dass beide Einträge erhalten bleiben, und erklär mir, was du gemacht hast.]
  ]

  #content-slide(
    [🛠 Etappe 6: Merge & Staging],
    notes: "~15 Min · nacheinander mergen, nicht alle gleichzeitig · Konflikt → Folie vorher · Staging braucht ein paar Minuten · danach lokal holen: euer Rechner kennt den neuen Stand sonst nicht (Etappe 1!)",
  )[
    #set align(left)
    #aufgabe(
      15,
      (
        [Ist mein PR freigegeben und grün? Dann merge ihn.],
        [Hol den neuesten Stand von main auf meinen Rechner.],
        [Lösch meinen alten Branch lokal.],
      ),
      [Nach ein paar Minuten `meko-christian.github.io/workshop-teamwand` öffnen: Seid ihr auf der Seite zu sehen?],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 7 — Release & Prod
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    7,
    [Release & Prod],
    notes: "alle zusammen · Release-PR auf dem Beamer",
  )[
    Was auf Staging läuft, geht jetzt live.
  ]

  #content-slide(
    [Release — Versionen aus PR-Titeln],
    notes: "release-please läuft nach jedem Merge · hält EINEN Release-PR offen · Changelog = eure PR-Titel · Merge des Release-PR = neue Version → Prod mit genau dem Stand von Staging",
  )[
    #set align(left)
    #grid(
      columns: (1fr, 1fr),
      gutter: 18pt,
      [
        Nach jedem Merge sammelt *release-please* alles in *einem* Release-PR:

        #v(0.3em)
        - Changelog aus euren *PR-Titeln*
        - neue Versionsnummer
        - Merge des Release-PRs → *Prod*

        #v(0.3em)
        #text(
          size: 0.85em,
        )[Prod bekommt genau den Stand, der schon auf Staging lief.]
      ],
      card([chore(main): release 0.2.0])[
        #set text(size: 0.9em)
        ```
        ## 0.2.0

        ### Features
        * add anna to the team wall (#9)
        * add ben to the team wall (#11)
        * add carla to the team wall (#12)
        ```
      ],
    )
  ]

  #content-slide(
    [🛠 Etappe 7: Release & Prod],
    notes: "~15 Min · alle zusammen am Beamer · Changelog gemeinsam lesen: welche Titel sind gut? · jemand anderes als der Trainer gibt frei · Prod im Browser, Version im Footer · Rollback = Revert-PR + neues Release",
  )[
    #set align(left)
    #aufgabe(
      15,
      (
        [Zeig mir den offenen Release-PR und fass den Changelog zusammen.],
        [Ist die Release-Pipeline nach dem Merge durchgelaufen?],
      ),
      [Gemeinsam: Changelog verständlich? Freigeben und mergen — dann `meko-christian.github.io/workshop-teamwand` öffnen, Version unten auf der Seite prüfen.],
    )
    #v(0.6em)
    #card([Und wenn Prod kaputt ist?], kind: "warn")[
      Kein Hotfix per Hand: Änderung per Revert-PR zurücknehmen — gleicher Weg, auch unter Zeitdruck.
    ]
  ]

  #content-slide(
    [Das nehmt ihr mit],
    notes: "Runde: was nehmt ihr in euer Projekt mit? · Bonus-Issues für alle, die weiterüben wollen · Spickzettel",
  )[
    #set align(left)
    #grid(
      columns: (1fr, 1fr),
      gutter: 14pt,
      card([Der Ablauf], kind: "good")[
        Klonen → Branch → Commit → Push → PR → Checks → Review → Merge → Staging → Release → Prod
        #v(0.3em)
        Jede Änderung, jedes Mal. Gerade die kleinen.
      ],
      card([Weiterüben])[
        Issues mit Label `bonus`: kleine Features mit Test — gleicher Weg.
        #v(0.3em)
        Für euer eigenes Projekt: Vorlage `MeKo-Tech/go-react-template`.
      ],
    )
    #v(0.6em)
    #text(fill: meko_green, weight: "bold")[
      Der Agent tippt. Verantwortlich seid ihr — und das Review ist eure Unterschrift.
    ]
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Anhang
  // ─────────────────────────────────────────────────────────────────────────

  #section-slide(
    [Anhang],
    notes: "Zusatzthemen bei Bedarf · Vertiefung & Nachschlagen",
  )[]

  // Commit dot with a short label inside. `ghost` draws the discarded original
  // of a rebased commit: hollow and dashed.
  #let knoten(pos, label, fill: meko_grey, ghost: false) = node(
    pos,
    text(size: 9pt, weight: "bold", fill: if ghost { luma(170) } else {
      white
    })[#label],
    shape: circle,
    radius: 9pt,
    fill: if ghost { none } else { fill },
    stroke: if ghost { (paint: luma(170), thickness: 1pt, dash: "dashed") } else {
      none
    },
  )
  #let gruen = 1.6pt + meko_green
  #let hinweis(body) = text(size: 0.7em, fill: meko_body)[#body]

  #content-slide(
    [Merge oder Rebase?],
    notes: "Ausgangslage: euer Branch ist hinter main, weil andere inzwischen gemerged haben · zwei Wege, ihn nachzuziehen · Merge: ein zusätzlicher Commit führt beide Linien zusammen, eure Commits bleiben unverändert · Rebase: eure Commits werden auf das neue main neu aufgesetzt, dabei entstehen neue Commits mit neuen IDs (A′, B′), die alten sind weg · Ergebnis im Code gleich, nur die History sieht anders aus",
  )[
    #set align(left)
    Euer Branch ist hinter `main` — inzwischen wurde `C` gemerged.
    Zwei Wege, ihn auf den neuesten Stand zu bringen:

    #v(0.3em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 14pt,
      align: top,
      card([Merge — zusammenführen], kind: "good")[
        #align(center, diagram(
          spacing: (34pt, 24pt),
          edge-stroke: 1.6pt + meko_grey,
          ..range(3).map(x => knoten((x, 0), ([1], [2], [C]).at(x))),
          edge((0, 0), (1, 0)),
          edge((1, 0), (2, 0)),
          knoten((1, 1), [A], fill: meko_green),
          knoten((2, 1), [B], fill: meko_green),
          knoten((3, 1), [M], fill: meko_green.darken(30%)),
          edge((0, 0), (1, 1), stroke: gruen),
          edge((1, 1), (2, 1), stroke: gruen),
          edge((2, 1), (3, 1), stroke: gruen),
          edge((2, 0), (3, 1), "-|>"),
        ))
        #v(0.2em)
        - `main` wird in euren Branch geholt, ein *Merge-Commit* `M` verbindet beide Linien.
        - Eure Commits `A`, `B` bleiben, wie sie sind.
        - History zeigt ehrlich, was wann passiert ist — mit Verzweigungen.
      ],
      card([Rebase — neu aufsetzen], kind: "warn")[
        #align(center, diagram(
          spacing: (34pt, 24pt),
          edge-stroke: 1.6pt + meko_grey,
          ..range(3).map(x => knoten((x, 0), ([1], [2], [C]).at(x))),
          edge((0, 0), (1, 0)),
          edge((1, 0), (2, 0)),
          knoten((1, 1), [A], ghost: true),
          knoten((2, 1), [B], ghost: true),
          edge((0, 0), (1, 1), stroke: (paint: luma(170), dash: "dashed")),
          edge((1, 1), (2, 1), stroke: (paint: luma(170), dash: "dashed")),
          knoten((3, 1), [A′], fill: meko_green),
          knoten((4, 1), [B′], fill: meko_green),
          edge((2, 0), (3, 1), stroke: gruen),
          edge((3, 1), (4, 1), stroke: gruen),
        ))
        #v(0.2em)
        - Eure Commits werden *auf* das neue `main` neu abgespielt.
        - Dabei entstehen *neue* Commits `A′`, `B′` — die alten sind weg.
        - History wird eine gerade Linie, als hättet ihr erst jetzt angefangen.
      ],
    )

    #v(0.4em)
    #text(fill: meko_green, weight: "bold")[
      Der Code ist danach derselbe — nur die History sieht anders aus.
    ]
  ]

  #content-slide(
    [Merge oder Rebase — was heißt das für uns?],
    notes: "Teamwand und unsere Repos: nur Squash-Merge · der ganze PR wird EIN Commit auf main, Titel = PR-Titel · deshalb ist main immer linear, egal ob ihr im Branch merged oder rebased · im Branch: Merge ist der sichere Standard, auch der Button 'Update branch' auf GitHub macht das · Rebase schreibt die History um → push wird abgelehnt, braucht --force-with-lease · goldene Regel: nie rebasen, was andere schon haben · main ist gegen force push geschützt · Konflikte gibt es bei beiden Wegen, beim Rebase evtl. pro Commit einmal",
  )[
    #set align(left)
    #grid(
      columns: (1fr, 1fr),
      gutter: 14pt,
      align: top,
      card([Auf GitHub: nur Squash-Merge], kind: "good")[
        Der ganze PR wird *ein* Commit auf `main` — mit dem PR-Titel als Nachricht.
        #v(0.3em)
        - `main` bleibt immer eine gerade Linie.
        - Wie es in eurem Branch aussah, ist danach egal.
      ],
      card([Im Branch: Merge ist der Standard])[
        Euren Branch mit `main` abgleichen — beides geht:
        #v(0.3em)
        - *Merge:* sicher, kein Umschreiben. Macht auch der Button „Update branch“.
        - *Rebase:* schöner, aber danach braucht der push `--force-with-lease`.
      ],
    )

    #v(0.5em)
    #card([Goldene Regel], kind: "bad")[
      Nie Commits rebasen, die andere schon haben — z. B. einen Branch, an dem zwei
      arbeiten. Wer seinen Stand schon geholt hat, bekommt sonst doppelte Commits.
      `main` ist deshalb gegen force push gesperrt.
    ]

    #v(0.5em)
    #prompt[Bring meinen Branch auf den Stand von main — per Merge, nicht per Rebase.]
  ]
]

#slides
