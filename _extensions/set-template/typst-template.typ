// set-template: Typst-Vorlage für Evaluationsberichte
//
// Quarto fügt diese Datei vor dem Bericht ein; typst-show.typ ruft danach `bericht()` auf.
// Platzhalter wie $$accent_col$$ füllt Quarto aus dem YAML-Kopf des Dokuments bzw. aus _extension.yml.


// Angaben aus dem YAML-Kopf ----------------------------------------------------

// Pandoc maskiert Sonderzeichen in Texten aus dem YAML-Kopf mit "\" (z. B. "\#507289",
// "\_extensions/…"). Für Farben und Dateipfade wird die Maskierung wieder entfernt;
// unter Linux wäre der Backslash sonst Teil des Dateinamens.
#let ohne-maskierung(text) = text.replace(regex("\\\\(.)"), m => m.captures.first())

#let akzent = rgb(ohne-maskierung("$accent_col$"))

// Farbe im Logo, die durch die Akzentfarbe ersetzt wird
#let logo-farbe = "#006a6a"


// Hilfsfunktionen für den Berichtstext -----------------------------------------

// Hervorgehobener Begriff, z. B. in Legenden: #begriff[Median]
#let begriff(body) = text(fill: akzent, weight: "semibold", body)

// Kleiner Hinweistext unter Abbildungen oder Tabellen: #hinweis[...]
#let hinweis(body) = block(above: 1.5em, below: 2em, text(size: 0.9em, style: "italic", body))


// Seitenlayout -----------------------------------------------------------------

#let bericht(
  title: none,
  subtitle: none,
  date: none,
  fusszeile: none,
  logo: none,
  lang: "de",
  margin: (x: 2cm, top: 3cm, bottom: 2cm),
  paper: "a4",
  font: ("Red Hat Text",),
  fontsize: 10pt,
  toc: true,
  toc-title: none,
  toc-depth: 1,
  doc,
) = {
  // Logo einlesen und in der Akzentfarbe einfärben
  let kopf-logo = if logo != none {
    image(bytes(read(ohne-maskierung(logo)).replace(logo-farbe, akzent.to-hex())), height: 1.3cm)
  }

  set page(
    paper: paper,
    margin: margin,
    header: stack(
      spacing: 8pt,
      align(right, kopf-logo),
      line(length: 100%, stroke: akzent),
    ),
    footer: stack(
      spacing: 6pt,
      line(length: 100%, stroke: akzent),
      context text(fill: luma(90))[#fusszeile #h(1fr) Seite #counter(page).display()],
    ),
  )

  set text(lang: lang, font: font, size: fontsize, features: ("tnum",)) // gleich breite Ziffern
  set par(justify: true)

  // Überschriften: mit Abstand; nie allein am Seitenende
  show heading: set block(below: 2em)
  show heading: it => {
    block(breakable: false, it + v(6em))
    v(-6em)
  }

  // Links und Verweise in der Akzentfarbe
  show link: set text(fill: akzent)

  // Hervorhebungen (_..._) erscheinen fett, z. B. die Skalenangabe in Tabellenköpfen
  show emph: it => text(weight: "bold", it.body)

  // Tabellen: zentriert, ohne Linien, ohne Silbentrennung
  set table(inset: (x: 6pt, y: 7pt), stroke: none)
  show table: set text(hyphenate: false)
  show table: it => block(below: 2em, align(center, it))

  // tinytable packt Tabellen in eine nicht umbrechbare Abbildung; lange Tabellen
  // (z. B. offene Antworten) liefen dann über das Seitenende. Daher nur den umbrechbaren Inhalt ausgeben.
  show figure.where(kind: table): it => {
    set block(breakable: true)
    it.body
  }

  // Titel
  if title != none {
    align(center, block(inset: 2em)[
      #text(size: 1.5em, weight: "bold", title)
      #if subtitle != none {
        parbreak()
        text(size: 1.25em, subtitle)
      }
      #if date != none {
        parbreak()
        date
      }
    ])
  }

  // Inhaltsverzeichnis, danach beginnt der Bericht auf einer neuen Seite
  if toc {
    show outline.entry: it => v(1.5em, weak: true) + it
    block(above: 3em, outline(title: toc-title, depth: toc-depth, indent: 1.5em))
    pagebreak()
  }

  doc
}
