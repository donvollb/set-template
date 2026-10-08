// Ruft die Funktion `bericht` aus typst-template.typ mit den Angaben aus dem YAML-Kopf auf.

#show: doc => bericht(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(lfoot)$
  fusszeile: [$lfoot$],
$endif$
$if(header-logo)$
  logo: "$header-logo$",
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
  toc: $if(toc)$true$else$false$endif$,
$if(toc-title)$
  toc-title: [$toc-title$],
$endif$
  toc-depth: $toc-depth$,
  doc,
)
