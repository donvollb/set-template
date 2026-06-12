
// This is an example typst template (based on the default template that ships
// with Quarto). It defines a typst function named 'article' which provides
// various customization options. This function is called from the 
// 'typst-show.typ' file (which maps Pandoc metadata function arguments)
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-show.typ' entirely. You can find 
// documentation on creating typst templates and some examples here: 
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

// Paket für die Richtige Ausrichtung der Zahlen in Tabellen importieren
// Komentar zur Demonstration
#set outline(indent: n => n * 1em)
#show outline.entry: it => {
  v(1.5em, weak: true)  // Vertikaler Abstand
  it
}

#let accent_col_raw = str("$accent_col$")
#let accent_col = accent_col_raw.replace("\\", "")
#let svg = read("_extensions\set-template\images\Logo Meze - Cobranding.svg")
#let recolored = svg.replace("#006a6a", accent_col)

#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (left: 2cm, right: 2cm, top: 4cm, bottom: 2cm),
  paper: "a4",
  lang: "de",
  region: "DE",
  font: "Red Hat Text",
  fontsize: 10pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "Red Hat Text",
  heading-weight: "regular",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  pagenumbering: "Seite 1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    //Kopfzeile
    header: stack(
    spacing: 8pt,
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      image("_extensions/set-template/images/leer.svg", height:  1.3cm),
      image(bytes(recolored), height:  1.3cm)
  //  image(svg, height:  1.3cm)
      ),
    line(length: 100%, stroke: rgb(accent_col)),
  ),
      footer: stack(
    spacing: 4pt,
    line(length: 100%, stroke: rgb(accent_col)),
    context {
      // Text links, Seitenzahl rechts
      "$lfoot$" + h(1fr) + "Seite " + counter(page).display()
    }
  )
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black or heading-decoration == "underline"
           or heading-background-color != none) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = toc_title
    block(above: 3em, below: 3em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

// Tabellen Zentrieren und Abstände einstellen

#show table: it => align(center, block(width: 100%, it))

#show table: set text(hyphenate: false)
// #show table.cell.where(y: 0): set text(hyphenate: false)


#show emph: it => {
  text(weight: "bold", it.body)
}

#set table(inset: 6pt,
           stroke: none)

// Tabellenziffern (also gleich breite Ziffern) aktivieren

#set text(
  features: ("tnum",)
)

// Hyperlinks einfärben

#show link: set text(fill: rgb(accent_col))


// Abstände unter Überschriften und Tabellen anpassen

#show heading: set block(below: 2em)
#show table: it => {
  block(
    below: 2em
  )[
    #it
    #h(0pt)  // unsichtbarer Blocker
  ]
}

// Eigene Überschrift, die unten Platz für Text reserviert
#let custom-heading(it, reserve: 6em) = {
  block(breakable: false, it + v(reserve))
  v(-1 * reserve)
}

// Für alle Überschriften benutzen:
#show heading: custom-heading

#set table(row-gutter: 20pt, stroke: none)