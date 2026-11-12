# Shortcuts for developers and trainers. Participants don't need any of this:
# opening index.html in a browser is enough.

deck := "workshop/slides/git-workshop"
handout := "workshop/slides/git-workshop-handout"

export TYPST_FONT_PATHS := env("TYPST_FONT_PATHS", "workshop/slides/fonts")

# Fixed so that unchanged sources produce byte-identical PDFs. Without it every
# rebuild changes the committed PDFs through their creation timestamp.
export SOURCE_DATE_EPOCH := "1700000000"

_default:
    @just --list

# Serve the page on localhost
dev port="8000":
    python3 -m http.server {{ port }} --bind 127.0.0.1

# Fix formatting
fmt:
    npm run format

# Format check, lint and tests, as in CI
check:
    npm run check

# Rebuild the deck and handout PDFs (commit them together with the sources)
slides:
    typst compile --root workshop/slides {{ deck }}.typ
    typst compile --root workshop/slides {{ handout }}.typ

# Rebuild the deck on every change
slides-watch:
    typst watch --root workshop/slides {{ deck }}.typ

# Present the committed deck in pdfpc; extra args go to pdfpc
[positional-arguments]
present *args:
    pdfpc "$@" {{ deck }}.pdf
