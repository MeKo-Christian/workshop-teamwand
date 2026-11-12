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

  // A prompt for an AI assistant, for participants who use one.
  #let prompt(body) = text(fill: meko_green, weight: "bold")[„#body“]

  // A terminal command inside an exercise step.
  #let cmd(code) = box(
    fill: white,
    stroke: 0.5pt + luma(200),
    radius: 4pt,
    inset: (x: 5pt, y: 3pt),
    outset: (y: 1pt),
    {
      // lib.typ sets raw to 14pt via a show rule; override it here.
      show raw: set text(size: 11.5pt)
      raw(code)
    },
  )

  // Exercise slide body. Left: the steps, with the git command or the click on
  // github.com. Right: the same steps as prompts for an AI assistant. Below:
  // what to check by yourself, whichever way you went — again as a command or
  // click on the left and as a question for an AI assistant on the right.
  #let aufgabe(minuten, schritte, prompts, selbst, selbst-prompt) = {
    let nummeriert(items, fill, stroke, render) = stack(
      spacing: 6pt,
      ..items
        .enumerate()
        .map(((i, body)) => block(
          width: 100%,
          fill: fill,
          stroke: 0.75pt + stroke,
          radius: 8pt,
          inset: (x: 10pt, y: 7pt),
          grid(
            columns: (1.3em, 1fr),
            text(fill: meko_green, weight: "bold")[#(i + 1)], render(body),
          ),
        )),
    )
    set text(size: 0.8em)
    show raw: set text(size: 12.5pt)
    grid(
      columns: (2fr, 1fr),
      column-gutter: 16pt,
      align: top,
      [
        #text(fill: meko_green, weight: "bold")[Selbst machen (ca. #minuten Minuten)]
        #v(0.2em)
        #nummeriert(
          schritte,
          meko_green.lighten(90%),
          meko_green.lighten(30%),
          body => body,
        )
      ],
      [
        #text(fill: meko_grey, weight: "bold")[Oder: sagt eurem KI-Assistenten]
        #v(0.2em)
        #nummeriert(prompts, luma(245), luma(200), prompt)
      ],
    )
    v(0.5em)
    grid(
      columns: (2fr, 1fr),
      column-gutter: 16pt,
      align: top,
      [*Selbst prüfen:* #selbst],
      [#text(fill: meko_grey, weight: "bold")[Oder fragt:] #prompt(selbst-prompt)],
    )
  }

  // The stages of the workshop. Every stage section shows this bar with the
  // current stage highlighted, so the flow stays visible as one piece.
  #let etappen-liste = (
    [Klonen],
    [Branch & Commit],
    [Push & PR],
    [Checks],
    [Review],
    [Merge & Deployment],
    [Release],
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
    subtitle: [Arbeiten mit Git über GitHub],
    authors: [Christian Budde],
    notes: "Begrüßung · heute keine Vorlesung · ihr macht es selbst · eine Änderung, Schritt für Schritt bis auf die Seite",
  )

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Einstieg
  // ─────────────────────────────────────────────────────────────────────────

  #content-slide(
    [Workshop-Agenda],
    notes: "keine Vorkenntnisse nötig: jeder Begriff kommt, wenn wir ihn brauchen · echtes Repo, echte Pipeline, echtes Review · EINE Änderung pro Person · alle gehen gemeinsam Etappe für Etappe · Befehle stehen auf jeder Übungsfolie · KI-Assistent ist erlaubt, ersetzt aber nicht das Verstehen",
  )[
    #set align(left)
    Heute spielt ihr den *kompletten Weg einer Änderung* selbst durch. Am Beispiel-Repo „Teamwand“.
    Vorkenntnisse braucht ihr keine: Jeder Begriff wird eingeführt, wenn wir ihn brauchen.

    #v(0.5em)
    *Eine Änderung pro Person:* jede:r trägt sich in die Teamwand ein.
    Wir gehen den Weg *gemeinsam, Etappe für Etappe*.

    #v(0.7em)
    #align(center, etappen(0, on-dark: false))

    #v(0.7em)
    *Jede Übung zeigt die Befehle zum Selbertippen — mit Beispielprompts für
    einen KI-Assistenten.*
  ]

  #content-slide(
    [Der Weg einer Änderung],
    notes: "einmal komplett zeigen, dann Etappe für Etappe · obere Reihe: jeder PR · untere Reihe: Deployment und Release · in echten Projekten meist zwei Umgebungen: Staging nach jedem Merge, Prod erst mit dem Release · hier eine Seite für beides · niemand ändert main direkt",
  )[
    #set align(left)
    *Jede Änderung* — egal wie klein — nimmt diesen Weg:

    #grid(
      columns: (1fr, 1.6em, 1fr, 1.6em, 1fr, 1.6em, 1fr, 1.6em, 1fr),
      align: horizon,
      step([Klonen], [Kopie holen]),
      arrow,
      step([Branch], [eigene Linie]),
      arrow,
      step([Pull Request], [Bitte um Aufnahme]),
      arrow,
      step([Checks], [automatische Prüfung]),
      arrow,
      step([Review], [ein Mensch], kind: "good"),
    )
    // Hand-off between the rows: an S-curve from Review (last top column) to
    // Deployment (first bottom column), passing the approval gate. The column
    // centres follow from the two grids' column specs below and above.
    #block(above: 0.3em, below: 0.3em, layout(size => {
      let w = size.width
      let gap = 1.6em.to-absolute()
      let x0 = w - (w - 4 * gap) / 5 / 2
      let x1 = (w - 3 * gap) / 4 / 2
      let hgt = 3.2em.to-absolute()
      let tip = 7pt
      // Review is one text line shorter than its row (horizon-aligned), so the
      // curve starts above the block to meet the card's bottom edge.
      let lead = 10pt
      block(width: w, height: hgt, {
        place(curve(
          stroke: 1.5pt + meko_green,
          curve.move((x0, -lead)),
          curve.cubic((x0, hgt * 0.75), (x1, hgt * 0.25), (x1, hgt - tip)),
        ))
        place(polygon(
          fill: meko_green,
          (x1 - 4.5pt, hgt - tip),
          (x1 + 4.5pt, hgt - tip),
          (x1, hgt),
        ))
        place(center + horizon, box(
          fill: meko_green.lighten(90%),
          stroke: 1pt + meko_green,
          radius: 999pt,
          inset: (x: 10pt, y: 5pt),
          {
            show raw: set text(size: 11.5pt)
            set text(size: 0.8em, fill: meko_grey)
            text(fill: meko_green, weight: "bold")[✓ Approval]
            h(0.5em)
            sym.arrow.r
            h(0.5em)
            [Merge in `main`]
          },
        ))
      })
    }))
    #grid(
      columns: (1fr, 1.6em, 1fr, 1.6em, 1fr, 1.6em, 1fr),
      align: horizon,
      step([Deployment], [Seite aktualisiert], kind: "warn"),
      arrow,
      step([Release-PR], [sammelt Änderungen]),
      arrow,
      step([Review + Merge], [neue Version], kind: "good"),
      arrow,
      step([Release], [Version auf der Seite], kind: "warn"),
    )

    #text(size: 0.75em)[
      In echten Projekten gibt es dafür meist mindestens zwei Umgebungen: *Staging* (nach
      jedem Merge), *Prod* erst mit dem Release. Die Teamwand hier hat nur eine Seite für
      beides.
    ]

    #v(0.4em)
    #text(fill: meko_green, weight: "bold")[
      Niemand ändert main direkt — nicht ihr, nicht ein KI-Assistent, nicht die Admins.
    ]
  ]

  #content-slide(
    [Die Teamwand],
    notes: "Repo im Browser zeigen · team.js eine Zeile pro Person, alphabetisch · AGENTS.md: die Projektregeln, geschrieben für Menschen UND KI-Werkzeuge (die lesen die Datei automatisch) · Seite auf GitHub Pages, öffentlich",
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
        - `AGENTS.md` — die Regeln des Projekts, für Menschen *und* KI-Werkzeuge

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

  #content-slide(
    [Was ihr braucht],
    notes: "vorab per Mail verschickt · am Anfang reihum prüfen: git --version, Login auf github.com, Einladung angenommen · user.name/user.email fehlen bei frischer Installation → sonst scheitert der erste Commit · beim ersten push öffnet Git ein Browserfenster für den GitHub-Login (Git Credential Manager) · KI-Assistent ist optional",
  )[
    #set align(left)
    #grid(
      columns: (1fr, 1fr),
      gutter: 14pt,
      align: top,
      card([Werkzeuge], kind: "good")[
        - Einen *GitHub-Account* — und die Einladung ins Repo angenommen
        - *Git* installiert: #raw("git --version") zeigt eine Version
        - Einen *Editor*, z. B. VS Code
        - Einen *Browser* für GitHub und die Seite
      ],
      card([Einmalig: Git sagen, wer ihr seid])[
        Jeder Commit trägt euren Namen. Im Terminal:
        #v(0.3em)
        #show raw: set text(size: 12pt)
        ```
        git config --global user.name "Anna Muster"
        git config --global user.email "eure@mail.de"
        ```
        #v(0.2em)
        Beim ersten *push* fragt Git im Browser nach dem GitHub-Login.
      ],
    )

    #v(0.6em)
    #card([Optional: ein KI-Assistent], kind: "warn")[
      Wer einen nutzt (z. B. GitHub Copilot, Claude Code), kann ihm die Sätze von
      den Übungsfolien geben. Er tippt dann die Befehle — verstehen und prüfen
      müsst ihr trotzdem selbst.
    ]
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
    notes: "~5 Min · Terminal im Ordner öffnen, in dem eure Projekte liegen · clone legt den Unterordner workshop-teamwand an · git log zeigt die History, die mitgekommen ist · Issue liegt auf GitHub, nicht im Ordner",
  )[
    #set align(left)
    #aufgabe(
      5,
      (
        [Klonen — im Terminal, in eurem Projektordner:\
          #cmd("git clone https://github.com/MeKo-Christian/workshop-teamwand")\
          #cmd("cd workshop-teamwand")],
        [Die letzten fünf Commits ansehen: #cmd("git log --oneline -5")],
        [Auf GitHub unter *Issues*: Welches Issue ist euch zugewiesen?],
      ),
      (
        [Klone MeKo-Christian/workshop-teamwand in meinen Projektordner.],
        [Zeig mir die letzten fünf Commits.],
        [Welche Issues sind mir auf GitHub zugewiesen?],
      ),
      [`index.html` im Browser öffnen — die Seite läuft bei euch lokal.],
      [Öffne die Teamwand lokal im Browser.],
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
    notes: "main = der gemeinsame, abgestimmte Stand · beim Klonen bekommt ihr main · Name ist frei wählbar: früher meist master, heute meist main · in diesem Repo: jeder Merge in main geht automatisch auf die Seite (in echten Projekten: Staging) · neue Arbeit immer vom neuesten main starten → erst pull",
  )[
    #set align(left)
    `main` ist die *Hauptlinie* des Projekts. Beim Klonen bekommt ihr genau diesen Stand.

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
        text(size: 0.85em, weight: "bold")[Seite],
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
        Der Name der Hauptlinie ist frei gewählt. Früher hat man es üblicherweise `master` genannt, heute meist `main`.
      ],
      card([Geht auf die Seite], kind: "warn")[
        In diesem Repo landet jeder Merge in `main` automatisch auf der Seite —
        in echten Projekten meist auf Staging.
      ],
    )

    #v(0.5em)
    #text(fill: meko_green, weight: "bold")[
      Neue Arbeit startet immer vom neuesten `main` — also erst pull.
    ]
  ]

  #content-slide(
    [Was ist ein Branch?],
    notes: "Branch = eigene Linie von Commits, zweigt von main ab · main bleibt stabil, geht nach jedem Merge auf die Seite · ein Issue = ein Branch = ein PR · kostet nichts: nur ein Name, der auf einen Commit zeigt · entsteht lokal, GitHub sieht ihn erst nach push · nach dem Merge gelöscht",
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
        - `main` bleibt stabil — geht nach jedem Merge auf die Seite.
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
    [Was ist ein Commit?],
    notes: "Commit = gespeicherter Stand mit Nachricht, Autor, Zeit und ID · zwei Schritte: git add merkt vor, was in den Commit soll, git commit speichert · so landen nur gewollte Dateien im Commit · git status zeigt jederzeit, was geändert und was vorgemerkt ist · alles lokal, GitHub sieht nichts bis zum push",
  )[
    #set align(left)
    Ein Commit ist ein *gespeicherter Stand* eurer Dateien — mit Nachricht,
    Autor, Zeitpunkt und einer eindeutigen ID. Die History ist die Kette dieser
    Commits.

    #v(0.4em)
    #grid(
      columns: (1fr, 1.6em, 1fr, 1.6em, 1fr, 1.6em, 1fr),
      align: horizon,
      step([Ändern], [im Editor]),
      arrow,
      step([Vormerken], [`git add`]),
      arrow,
      step([Committen], [`git commit`], kind: "good"),
      arrow,
      step([Hochladen], [`git push` · Etappe 3], kind: "warn"),
    )

    #v(0.5em)
    #set text(size: 0.9em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 12pt,
      align: top,
      card([Warum zwei Schritte?], kind: "good")[
        Ihr entscheidet mit `git add`, *was* in den Commit kommt — nicht jede
        geänderte Datei gehört dazu.
      ],
      card([Immer gut: `git status`])[
        Zeigt, auf welchem Branch ihr seid, was geändert und was vorgemerkt
        ist.
      ],
    )

    #v(0.4em)
    #text(fill: meko_green, weight: "bold")[
      Ein Commit entsteht nur auf eurem Rechner — GitHub sieht ihn erst nach dem push.
    ]
  ]

  #content-slide(
    [🛠 Etappe 2: Branch & Commit],
    notes: "~10 Min · Branch-Name steht im Issue (Typ/Issue-Nummer-Kurzbeschreibung, siehe AGENTS.md) · eigene Zeile in team.js an der alphabetischen Stelle · KEIN Hochladen · auf GitHub nachsehen: Branch gibt es dort nicht → Etappe 1 bestätigt",
  )[
    #set align(left)
    #aufgabe(
      10,
      (
        [Branch anlegen, Name wie im Issue: #cmd("git switch -c feat/7-teamwand-anna")],
        [`team.js` im Editor öffnen und eure Zeile an der alphabetischen Stelle einfügen — Name, Emoji, Motto.],
        [`index.html` im Browser neu laden: Ist eure Karte da?],
        [Committen, noch nicht hochladen:\
          #cmd("git add team.js")
          #cmd("git commit -m \"feat: add anna to the team wall\"")],
      ),
      (
        [Ich will eine Änderung machen. Leg dafür einen Branch nach AGENTS.md an.],
        [Erstelle eine persönliche Karte für mich — Name, Emoji, Motto.],
        [Zeig mir das Ergebnis lokal im Browser.],
        [Committe das.],
      ),
      [#cmd("git status") — alles committet? Und auf GitHub: Gibt es euren Branch dort schon?],
      [Ist alles committet? Gibt es meinen Branch schon auf GitHub?],
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
    [Was ist ein Pull Request?],
    notes: "PR = Bitte: nehmt meinen Branch in main auf · gibt es nur auf GitHub, nicht in Git selbst · alles an einem Ort: Änderungen (Files changed), Diskussion, Checks, Review, Merge-Button · weitere Commits auf dem Branch landen automatisch im selben PR · Closes #N schließt das Issue beim Merge",
  )[
    #set align(left)
    Ein Pull Request (PR) ist die *Bitte*: „Nehmt meinen Branch in `main` auf.“
    Der PR existiert nur auf GitHub — und bündelt alles, was dafür nötig ist:

    #v(0.4em)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 12pt,
      align: top,
      card([Die Änderung])[
        Reiter *Files changed*: jede Zeile, die anders ist als in `main`.
      ],
      card([Die Prüfung], kind: "warn")[
        Automatische Checks und Kommentare von Menschen (und ggf. Bots).
      ],
      card([Die Entscheidung], kind: "good")[
        Freigabe durch einen Menschen, dann der Button *Merge*.
      ],
    )

    #v(0.5em)
    #set text(size: 0.9em)
    - Neue Commits auf dem Branch landen *automatisch im selben PR* — nach dem push.
    - `Closes #7` im PR-Text schließt das Issue beim Merge.
  ]

  #content-slide(
    [Der PR-Titel wird zum Changelog],
    notes: "Conventional Commits · beim Merge wird der PR-Titel DER Commit auf main · release-please baut daraus Changelog und Version · deshalb prüft CI den Titel",
  )[
    #set align(left)
    Der Titel des Pull Requests landet (in unserer Konfiguration) später *wörtlich* in den Release-Notes. Darum hat er bei uns eine feste Form:

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
    notes: "~10 Min · erster push: Git öffnet ein Browserfenster für den GitHub-Login · -u merkt sich origin als Ziel, danach reicht git push · GitHub zeigt danach oben den gelben Hinweis 'Compare & pull request' · Titel und Text prüfen, bevor der PR rausgeht · 'Closes #N' verknüpft das Issue",
  )[
    #set align(left)
    #aufgabe(
      10,
      (
        [Branch hochladen: #cmd("git push -u origin feat/7-teamwand-anna")],
        [Auf GitHub erscheint *Compare & pull request* — klicken.],
        [Titel `feat: add anna to the team wall`, Text `Closes #7` — dann *Create pull request*.],
      ),
      (
        [Lade meinen Branch hoch.],
        [Erstelle einen Pull Request mit Conventional-Commit-Titel, der mein Issue schließt.],
        [Gib mir den Link zum PR.],
      ),
      [Im PR unter *Files changed*: Titel verständlich? Nur eure eine Zeile geändert?],
      [Was ändert mein PR genau? Passt der Titel zu AGENTS.md?],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 4 — Checks
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    4,
    [Checks],
    notes: "CI prüft Formatierung, Lint, Tests, PR-Titel · läuft automatisch bei jedem push · rot = kein Merge · KI-Review nur, wenn im Repo eingeschaltet",
  )[
    GitHub prüft jeden Pull Request automatisch — bevor ein Mensch draufschaut.
  ]

  #content-slide(
    [Was prüft die CI?],
    notes: "CI = Continuous Integration · GitHub Actions startet bei jedem push eine frische Maschine und führt die Prüfungen aus .github/workflows aus · Prettier = Formatierung, ESLint = typische Fehler, html-validate, node --test = Tests (u. a. Sortierung von team.js), PR-Titel · rot heißt: Details öffnen, Log lesen, im selben Branch beheben, push → läuft neu · Regeln abschalten ist keine Lösung · KI-Reviewer (z. B. Copilot) nur, falls eingeschaltet: beratend, Kommentare bewerten, beantworten, auflösen",
  )[
    #set align(left)
    *CI* (Continuous Integration): Bei jedem push startet GitHub eine frische
    Maschine und prüft euren Branch — jedes Mal gleich, ohne Ausnahme.

    #v(0.4em)
    #grid(
      columns: (1fr, 1.6em, 1.3fr, 1.6em, 1fr),
      align: horizon,
      step([push], [neuer Stand im PR]),
      arrow,
      step([GitHub Actions], [Format · Lint · Tests · PR-Titel]),
      arrow,
      step([✅ oder ❌], [direkt im PR], kind: "good"),
    )

    #v(0.5em)
    #set text(size: 0.9em)
    #grid(
      columns: (1fr, 1fr),
      gutter: 12pt,
      align: top,
      card([Rot? Gut so.], kind: "bad")[
        Der Fehler ist gefunden, bevor ihn jemand sieht. *Details* öffnen, Log
        lesen, im selben Branch beheben, push — die Checks laufen neu.
        Regeln abschalten gilt nicht.
      ],
      card([Kommentare im PR], kind: "warn")[
        Von Menschen — und, falls eingeschaltet, von einem KI-Reviewer wie
        GitHub Copilot. Jeden bewerten, beantworten und auflösen: berechtigt
        → beheben, sonst begründet ablehnen.
      ],
    )
  ]

  #content-slide(
    [🛠 Etappe 4: Checks],
    notes: "~10 Min · Demo demo/rote-ci, falls bei niemandem was rot ist · nie Regeln abschalten · KI-Review (falls eingeschaltet) dauert ein paar Minuten · Kommentare bewerten, nicht blind umsetzen · Threads auflösen, sonst kein Merge",
  )[
    #set align(left)
    #aufgabe(
      10,
      (
        [Im PR unten: Checks abwarten — gelb läuft noch, dann grün oder rot.],
        [Rot? *Details* öffnen, Log lesen, Datei im Editor korrigieren:\
          #cmd("git commit -am \"fix: sort my entry\"")
          #cmd("git push")],
        [Kommentare lesen und beantworten, dann *Resolve conversation*.],
      ),
      (
        [Sind die Checks in meinem PR grün?],
        [Falls rot: Lies das Log und behebe den Fehler — ohne Regeln abzuschalten.],
        [Fass die Kommentare in meinem PR zusammen. Was davon ist berechtigt?],
      ),
      [Alle Checks grün, jeder Kommentar beantwortet und aufgelöst — vorher lässt sich nicht mergen.],
      [Sind alle Checks grün und alle Kommentare aufgelöst?],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 5 — Review
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    5,
    [Review],
    notes: "Vier-Augen-Prinzip · jede:r reviewt den PR einer anderen Person · Reviewer steht im Issue",
  )[
    Das Vier-Augen-Prinzip: Ein Mensch gibt den PR frei.
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
        - Selbst ansehen — gern lokal ausprobieren
        - Ist der Titel ein guter Changelog-Eintrag?
        - Konkret kommentieren: *was* und *warum*
      ],
      card([Ein KI-Reviewer (falls eingeschaltet)], kind: "warn")[
        - Prüft gegen `AGENTS.md`, schnell und gründlich
        - Kennt aber euer Ziel nicht — und kann irren
        - *Gibt nichts frei* — das macht immer ein Mensch
      ],
    )
  ]

  #content-slide(
    [🛠 Etappe 5: Review],
    notes: "~10 Min · Review-Ring: Reviewer steht im Issue · git fetch holt die fremden Branches von origin → Etappe 1 · git switch wechselt auf den fremden Branch, index.html zeigt dessen Stand · Freigabe immer selbst im Browser klicken, auch wer einen KI-Assistenten nutzt",
  )[
    #set align(left)
    #aufgabe(
      10,
      (
        [Im eigenen PR rechts bei *Reviewers* die Person aus eurem Issue eintragen.],
        [*Pull requests* → *Review requests*: den PR öffnen, den ihr prüfen sollt, und *Files changed* lesen.],
        [Lokal ausprobieren: #cmd("git fetch") #cmd("git switch feat/8-teamwand-ben") — `index.html` neu laden.],
        [*Review changes* → *Approve* oder *Request changes*, mit Kommentar.],
      ),
      (
        [Fordere für meinen PR ein Review von der Person an, die in meinem Issue steht.],
        [Welche PRs soll ich reviewen?],
        [Hol mir diesen PR auf den Rechner und fass zusammen: Passt er zum Issue und zu AGENTS.md?],
      ),
      [Freigeben klickt ihr *selbst* im Browser — und nur, was ihr selbst angesehen habt.],
      [Wurde mein PR freigegeben — und von wem?],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 6 — Merge & Deployment
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    6,
    [Merge & Deployment],
    notes: "jetzt ändert sich main auf GitHub · alle anderen müssen nachziehen · nach dem Merge geht die Seite automatisch neu raus",
  )[
    Ab in `main` — und automatisch auf die Seite.
  ]

  #content-slide(
    [Merge-Konflikt — keine Panik],
    notes: "jeder Merge ändert main · wer direkt neben euch in team.js steht, bekommt einen Konflikt · falls keiner auftritt: Demo mit demo/konflikt-a + b · GitHub zeigt im PR 'This branch has conflicts' mit Button 'Resolve conflicts' · Markierungszeilen löschen, beide Einträge behalten · 'Mark as resolved', 'Commit merge' · danach laufen die Checks neu",
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
    #grid(
      columns: (1fr, 1fr),
      gutter: 14pt,
      align: top,
      [
        #set text(size: 0.8em)
        *Selbst:* Im PR *Resolve conflicts* klicken, die Markierungszeilen
        löschen, beide Einträge behalten → *Mark as resolved* → *Commit merge*.
      ],
      [
        #set text(size: 0.8em)
        *KI-Assistent:* #prompt[Mein PR hat einen Konflikt mit main. Löse ihn so, dass beide Einträge erhalten bleiben, und erklär mir, was du gemacht hast.]
      ],
    )
  ]

  #content-slide(
    [🛠 Etappe 6: Merge & Deployment],
    notes: "~15 Min · nacheinander mergen, nicht alle gleichzeitig · Konflikt → Folie vorher · Deployment braucht ein paar Minuten (Actions-Tab: pages) · danach lokal holen: euer Rechner kennt den neuen Stand sonst nicht (Etappe 1!) · -D statt -d: nach einem Squash-Merge erkennt Git den Branch nicht als gemerged",
  )[
    #set align(left)
    #aufgabe(
      15,
      (
        [Freigegeben und grün? Im PR *Squash and merge* — einer nach dem anderen.],
        [Lokal auf den neuen Stand: #cmd("git switch main") #cmd("git pull")],
        [Alten Branch löschen: #cmd("git branch -D feat/7-teamwand-anna")],
      ),
      (
        [Ist mein PR freigegeben und grün? Dann merge ihn.],
        [Hol den neuesten Stand von main auf meinen Rechner.],
        [Lösch meinen alten Branch lokal.],
      ),
      [#cmd("git log --oneline -3") — steht euer Commit in main? Nach ein paar Minuten `meko-christian.github.io/workshop-teamwand` öffnen: Seid ihr auf der Seite zu sehen?],
      [Ist mein Commit in main — und schon auf der Seite live?],
    )
  ]

  // ─────────────────────────────────────────────────────────────────────────
  // Section: Etappe 7 — Release
  // ─────────────────────────────────────────────────────────────────────────

  #etappe(
    7,
    [Release],
    notes: "alle zusammen · Release-PR auf dem Beamer",
  )[
    Alle Änderungen bekommen eine neue Versionsnummer.
  ]

  #content-slide(
    [Release — Versionen aus PR-Titeln],
    notes: "release-please läuft nach jedem Merge · hält EINEN Release-PR offen · Changelog = eure PR-Titel · Merge des Release-PR = neue Version + GitHub-Release · in echten Projekten geht genau dieser Stand dann nach Prod, hier zeigt die Seite die neue Version im Footer",
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
        - Merge des Release-PRs → *neue Version*

        #v(0.3em)
        #text(
          size: 0.85em,
        )[In echten Projekten geht genau dieser Stand dann nach Prod. Hier zeigt die Seite die neue Version im Footer.]
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
    [🛠 Etappe 7: Release],
    notes: "~15 Min · alle zusammen am Beamer · Changelog gemeinsam lesen: welche Titel sind gut? · jemand anderes als der Trainer gibt frei · Seite im Browser, Version im Footer · Rollback = Revert-PR + neues Release",
  )[
    #set align(left)
    #aufgabe(
      15,
      (
        [*Pull requests* → `chore(main): release …` öffnen und den Changelog lesen.],
        [Gemeinsam: freigeben und mergen.],
        [Reiter *Actions*: Ist `pages` durchgelaufen? Unter *Releases* steht die neue Version.],
      ),
      (
        [Zeig mir den offenen Release-PR und fass den Changelog zusammen.],
        [Ist die Release-Pipeline nach dem Merge durchgelaufen?],
      ),
      [`meko-christian.github.io/workshop-teamwand` neu laden — steht unten die neue Version?],
      [Welche Version zeigt die Seite jetzt?],
    )
    #v(0.5em)
    #card([Und wenn die neue Version kaputt ist?], kind: "warn")[
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
        Klonen → Branch → Commit → Push → PR → Checks → Review → Merge → Deployment → Release
        #v(0.3em)
        Jede Änderung, jedes Mal. Gerade die kleinen.
      ],
      card([Weiterüben])[
        Issues mit Label `bonus`: kleine Features mit Test — gleicher Weg.
        #v(0.3em)
        Für euer eigenes Projekt: `main` schützen (Ruleset), CI als Pflicht,
        Squash-Merge, PR-Titel nach Conventional Commits.
      ],
    )
    #v(0.6em)
    #text(fill: meko_green, weight: "bold")[
      Ob ihr tippt oder ein KI-Assistent: Verantwortlich seid ihr — und das Review ist eure Unterschrift.
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
    notes: "Teamwand: nur Squash-Merge · der ganze PR wird EIN Commit auf main, Titel = PR-Titel · deshalb ist main immer linear, egal ob ihr im Branch merged oder rebased · im Branch: Merge ist der sichere Standard, auch der Button 'Update branch' auf GitHub macht das · Rebase schreibt die History um → push wird abgelehnt, braucht --force-with-lease · goldene Regel: nie rebasen, was andere schon haben · main ist gegen force push geschützt · Konflikte gibt es bei beiden Wegen, beim Rebase evtl. pro Commit einmal",
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

    #v(0.3em)
    #set text(size: 0.8em)
    *Selbst:* im PR *Update branch* — oder lokal #cmd("git fetch") #cmd("git merge origin/main") #cmd("git push")\
    *KI-Assistent:* #prompt[Bring meinen Branch auf den Stand von main — per Merge, nicht per Rebase.]
  ]
]

#slides
