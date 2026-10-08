# set-template 2.0.0

Grundlegende Überarbeitung: Die Vorlage nutzt jetzt Typst statt LaTeX und die aktuelle API von
[setanalysis](https://donvollb.github.io/setanalysis/) (≥ 1.1.0).

## Wichtige Änderungen

- Das Format heißt jetzt `set-template-typst`; das LaTeX-Format `set-template-pdf` und `before-title.tex`
  sind entfallen. Dokumente müssen `format: set-template-typst` angeben.
- Die Farbe wird über `accent_col` (Hex-Code) statt über `color` (Farbname) festgelegt und gilt für Layout und
  Grafiken gleichermaßen.
- Die Beispiele verwenden die neuen Funktionsnamen von setanalysis (z. B. `merge_sc()` statt `merge.sc()`).

## Neu

- Typst-Layout mit Kopfzeile (Logo in der Akzentfarbe), Fußzeile, Titel und Inhaltsverzeichnis;
  Logo über `header-logo` austauschbar.
- Lange Tabellen brechen über Seiten um (mit wiederholtem Tabellenkopf); Überschriften rutschen mit dem
  folgenden Inhalt auf die nächste Seite.
- Seitenumbrüche (`{{< pagebreak >}}`) funktionieren auch innerhalb von R-Chunks.
- Typst-Hilfsfunktionen `#begriff[…]` und `#hinweis[…]` für Legenden und Hinweistexte.
- Zweites Beispiel `beispiele/kohorte.qmd`: mehrere Berichte mit unterschiedlichem Inhalt über Berichts- und
  Regeltabelle (`input_tabelle()`), offene Antworten im Anhang.
- Die Schrift Red Hat Text wird mitgeliefert (`_extensions/set-template/fonts/`, SIL Open Font License) und
  über `font-paths` eingebunden; sie muss nicht mehr installiert sein.
- Skript `beispiele/vorbereitung.R`: liest einen evasys-Export mit `evasys_read_data()` ein, wertet Berichts-
  und Regeltabelle mit `input_tabelle()` aus, ergänzt Titel und Dateinamen und prüft Schreibweisen mit
  `label_test()`. Der Kohorten-Bericht liest die vorbereiteten Dateien.
- Skript `beispiele/alle-berichte-rendern.R`: erstellt alle Berichte einer Befragung nacheinander, macht bei
  Fehlern weiter, verwirft Berichte mit zu wenigen Stimmen, schreibt ein Protokoll und verteilt die PDFs in
  Ordner (Spalte `Ordner` der Berichtstabelle).
- Eigene, zufällig erzeugte Beispieldaten in `daten/` (mit Skript zum Erzeugen), für das Kohorten-Beispiel
  als Export im Format von evasys.
- Untertitel pro Bericht aus den Daten.
- GitHub Action, die beide Beispiele und die Skripte bei jedem Push ausführt (Badge in der README).
- Zweisprachige README (deutsch/englisch) mit Vorschaubildern und Beispiel-PDFs in `vorschau/`.

## Behoben

- LVE-Beispiel: Verweise auf nicht vorhandene Variablen und Spalten (`Auswahl`, `Zeitraum`, `StuAbschl_*`),
  nicht ersetzter Platzhalter und ein ungültiger Aufruf von `merge_wl()` entfernt.
- Attribute (Fragetexte, Antwortcodes) bleiben beim Filtern der Daten erhalten (`zeilen_waehlen()` statt
  Datenkopie und `sjlabelled::copy_labels()`).

# set-template 1.0.0

- Erste Fassung: Quarto-Vorlage mit LaTeX-Format (`set-template-pdf`) und LVE-Beispielbericht.
