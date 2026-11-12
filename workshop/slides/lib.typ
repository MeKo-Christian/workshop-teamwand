#import "@preview/polylux:0.4.0": *
#import "@preview/tiaoma:0.3.0"
#import "@preview/pinit:0.2.2": *
#import "lib/monochrome-theme/lib.typ": monochrome-theme

#let meko_green = rgb(0, 136, 133)
#let meko_grey = rgb("#4b4c53")
#let meko_body = rgb("#595959")

#let meko-slide-background() = {
  // Border frame shifted far bottom-left so only the top-right corner is visible
  place(
    bottom + left,
    dx: -768pt,
    dy: 495pt,
    image("assets/border-frame.png", width: 960pt, height: 540pt),
  )
  // Corner decoration bottom-right
  place(
    bottom + right,
    dx: 768pt,
    dy: 495pt,
    image("assets/border-frame.png", width: 960pt, height: 540pt),
  )
  // MeKo.de logo bottom-left
  place(
    bottom + left,
    dx: 30pt,
    dy: -15pt,
    image("assets/meko-logo.png", height: 12pt),
  )
}

#let setup(body) = {
  set page(
    paper: "presentation-16-9",
    margin: (left: 60pt, right: 60pt, top: 40pt, bottom: 50pt),
    footer: {
      h(1fr)
      set text(size: 12pt, fill: meko_grey)
      toolbox.slide-number
    },
    footer-descent: 25pt,
    background: meko-slide-background(),
  )

  set text(
    font: (
      "Calibri",
      "Fira Sans",
      "Noto Sans",
    ),
    size: 18pt,
    weight: "light",
    fill: meko_body,
  )

  // Setup code highlighting
  show raw: set text(font: "Fira Mono", size: 14pt)
  show raw: it => {
    show regex("pin\d+"): it => pin(eval(it.text.slice(3)))
    it
  }

  // show: monochrome-theme

  show emph: set text(fill: meko_green)

  show heading: set text(font: ("Proxima Nova Rg", "Proxima Nova"))
  show heading.where(level: 1): set text(
    size: 23pt,
    fill: meko_green,
    weight: "bold",
  )
  // show heading.where(level: 1): set block(spacing: 30pt)

  show heading.where(level: 2): set text(fill: meko_grey)
  show heading.where(level: 3): set text(fill: meko_grey, size: 20pt)

  show strong: set text(fill: meko_grey)

  set list(marker: text(fill: meko_green, sym.bullet), indent: 1em)

  show link: set text(fill: meko_green)
  show link: content => underline(content)

  body
}

// Speaker note for pdfpc. polylux 0.4.0's toolbox.pdfpc.speaker-note is broken
// on Typst 0.14 (its type() == "string" checks no longer hold), so we emit the
// labelled metadata directly. polylux2pdfpc reads <pdfpc> Note entries per slide.
#let speaker-note(body) = [ #metadata((t: "Note", v: body)) <pdfpc> ]

// Small pill that sits next to a slide title, e.g. to mark slides that are
// meant for a sub-audience. Pass it to content-slide via `badge:`.
#let title-badge(label, fill: meko_grey, dot: meko_green) = box(
  baseline: 20%,
  fill: fill,
  radius: 20pt,
  inset: (x: 8pt, y: 4pt),
  text(
    font: ("Calibri", "Fira Sans", "Noto Sans"),
    size: 10pt,
    weight: "bold",
    fill: white,
  )[#box(baseline: -1pt, circle(radius: 3pt, fill: dot))#h(4pt)#label],
)

// Marks developer-only slides: `content-slide(…, badge: dev-badge)`.
#let dev-badge = title-badge[Für Entwickler]

// One plain-language line on a developer slide: what it means for everyone else.
#let fuer-alle(body) = block(above: 0.5em, below: 0em, text(
  size: 0.72em,
  fill: meko_body,
)[#text(weight: "bold", fill: meko_green)[Für alle:] #body])

#let content-slide(title, body, notes: none, badge: none) = slide[
  === #title#if badge != none [#h(0.6em)#badge]

  #if notes != none { speaker-note(notes) }
  #align(horizon)[
    #body
  ]
]

#let quote-slide(quote, author, source: none, notes: none) = slide[
  #if notes != none { speaker-note(notes) }
  #let quote-mark(glyph) = text(
    size: 80pt,
    fill: meko_green.lighten(35%),
    weight: "bold",
    font: "Proxima Nova Rg",
  )[#glyph]
  #align(horizon)[
    #block(width: 80%, inset: (x: 1.2em))[
      #set align(left)
      #set par(leading: 0.7em)
      #text(size: 28pt, style: "italic", fill: meko_grey)[
        #quote#h(0.1em)#box(
          height: 0pt,
        )
      ]
      #v(1.3em)
      #set align(right)
      #text(size: 19pt, fill: meko_green, weight: "bold")[— #author]
      #if source != none {
        v(0.5em)
        text(size: 12pt, fill: meko_grey, source)
      }
    ]
  ]
]

#let title-slide(
  title: [],
  subtitle: [],
  authors: [],
  extra: [],
  url: none,
  title-image: none,
  notes: none,
) = slide[
  #if notes != none { speaker-note(notes) }
  #set page(footer: none)
  // Background image
  #place(top + left, dx: -60pt, dy: -40pt, image(
    "assets/title-bg.jpeg",
    width: 100% + 120pt,
    height: 100% + 90pt,
  ))
  // Overlay with stent imagery
  #place(top + left, dx: -60pt, dy: -40pt, image(
    "assets/title-overlay.png",
    width: 100% + 120pt,
    height: 100% + 90pt,
  ))
  // White MeKo Medtech logo top-right
  #place(top + right, dx: 30pt, dy: -30pt, image(
    "assets/white-logo.png",
    width: 250pt,
  ))
  #set text(fill: white)
  #show heading.where(level: 1): set text(
    fill: white,
    size: 32pt,
    font: "Proxima Nova Rg",
    weight: "bold",
  )
  #show link: set text(fill: white)

  #place(left + top, dx: 10%, dy: 50%)[
    #block(width: 60%)[
      = #title
      #v(30pt, weak: true)
      #text(size: 20pt)[#subtitle]
      #if authors != [] {
        v(50pt, weak: true)
        set text(style: "italic")
        authors
      }
      #if extra != [] {
        v(10pt, weak: true)
        extra
      }
    ]
  ]

  #if url != none {
    place(bottom + left, dy: -20pt)[
      #grid(
        columns: (auto, 1fr),
        gutter: 1em,
        align: horizon,
        tiaoma.barcode(
          url,
          "QRCode",
          options: (fg-color: white, bg-color: none),
        ),
        {
          set text(size: 14pt)
          link(url)
        },
      )
    ]
  }
]

#let section-slide(title, body, notes: none) = slide[
  // Full-bleed section background via the page background container
  // (spans the whole page incl. margins), and hide the slide number.
  #set page(
    footer: none,
    background: image(
      "assets/section-bg.jpeg",
      width: 100%,
      height: 100%,
    ),
  )
  #set text(fill: white)
  #show heading.where(level: 2): set text(size: 30pt, fill: white)
  #show heading.where(level: 2): set block(spacing: 2em)
  #toolbox.register-section(title)
  #if notes != none { speaker-note(notes) }
  #align(center + horizon)[
    == #title

    #body
  ]
]

#let item-by-item(start: 1, mode: hide, body) = {
  let is-item(it) = (
    type(it) == content
      and it.func()
        in (
          list.item,
          enum.item,
          terms.item,
        )
  )

  let children = if type(body) == content and body.has("children") {
    body.children
  } else {
    body
  }

  let children = children.filter(is-item)

  for i in range(children.len()) {
    only(
      start + i,
      list(..for j in range(i + 1) { (children.at(j).body,) }),
    )
  }
}

#let reveal-code(lines: (), full: false, body) = {
  let lines = lines.map(l => if type(l) == array { l } else { (l,) })
  let max-slide = calc.max(..lines.map(l => l.len()))

  for slide in range(1, max-slide + 1) {
    only(slide, {
      if full {
        body
      } else {
        let visible-lines = lines
          .enumerate()
          .filter(((i, l)) => l.len() >= slide)
          .map(((i, _)) => i + 1)
        show raw.where(block: true): it => {
          let lines-array = it.text.split("\n")
          raw(
            block: true,
            lang: it.lang,
            lines-array
              .enumerate()
              .map(((i, line)) => {
                if i + 1 in visible-lines {
                  line
                } else {
                  " " * line.len()
                }
              })
              .join("\n"),
          )
        }
        body
      }
    })
  }
}
