# set-template

**Deutsch** · [English](README.en.md)

![Quarto Extension](https://img.shields.io/badge/quarto-extension-blue)
![Format: Typst](https://img.shields.io/badge/format-typst-239dad)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)
[![Beispiele](https://github.com/donvollb/set-template/actions/workflows/beispiele.yaml/badge.svg)](https://github.com/donvollb/set-template/actions/workflows/beispiele.yaml)

Quarto-Vorlage für personalisierte Evaluationsberichte als PDF, z. B. aus der
Lehrveranstaltungsevaluation oder aus Befragungen von Studierenden und Absolvent\*innen.
Die Auswertung übernimmt das R-Paket [setanalysis](https://github.com/donvollb/setanalysis):
Eine Zeile Code pro Frage erzeugt Überschrift, Tabelle und Abbildung. Diese Vorlage liefert
das Layout (Typst) und zwei lauffähige Beispielberichte mit zufällig erzeugten Beispieldaten.

![Vorschau des LVE-Beispielberichts](vorschau/lve-bericht.png)

## Funktionen

- **Typst-Format** mit Kopfzeile (Logo), Fußzeile, Seitenzahlen und Inhaltsverzeichnis
- **Eine Akzentfarbe** (`accent_col`) für Linien, Links, Logo, Hervorhebungen und die Grafiken aus setanalysis
- **Mehrere Berichte aus einer Datei:** Parameter `i` wählt den Bericht; die inkl.-Logik von setanalysis
  legt fest, welche Fragen in welchem Bericht erscheinen
- **Lange Tabellen brechen sauber um** (Tabellenkopf wird wiederholt), Überschriften rutschen mit dem folgenden Inhalt auf die nächste Seite
- **Offene Antworten im Anhang** mit Links hin und zurück
- **Kompletter Ablauf als Beispiel:** evasys-Export einlesen, Berichte festlegen, alle Berichte erstellen,
  protokollieren und verteilen
- **Schrift wird mitgeliefert** (Red Hat Text), keine Installation nötig

## Voraussetzungen

- [Quarto](https://quarto.org) ≥ 1.7 (enthält Typst)
- [R](https://www.r-project.org) mit dem Paket **setanalysis** (derzeit Entwicklungsstand):

  ```r
  # install.packages("pak")
  pak::pak("donvollb/setanalysis@dev")
  ```

- Für die Skripte zum Kohorten-Beispiel zusätzlich die R-Pakete quarto (Rendern) und writexl
  (nur zum Neuerzeugen der Beispieldaten).

Die Schrift **Red Hat Text** bringt die Extension selbst mit (`_extensions/set-template/fonts/`), für die
Grafiken registriert setanalysis sie beim Laden. Sie muss also nicht installiert sein.

## Installation

Neues Projekt mit Vorlage und Beispielen anlegen:

```bash
quarto use template donvollb/set-template
```

Quarto fragt nach einem Ordnernamen und benennt `template.qmd` nach diesem Ordner um.
Nur das Format in ein bestehendes Projekt übernehmen:

```bash
quarto add donvollb/set-template
```

## Verwendung

```bash
quarto render template.qmd           # Bericht 1 (Parameter i aus dem YAML-Kopf)
quarto render template.qmd -P i:3    # Bericht 3
quarto render                        # alle Beispiele
```

Alle Berichte einer Befragung in zwei Schritten erstellen:

```bash
Rscript beispiele/vorbereitung.R           # 1. Daten und Berichtstabelle vorbereiten
Rscript beispiele/alle-berichte-rendern.R  # 2. alle Berichte erstellen, protokollieren, verteilen
```

1. `vorbereitung.R` liest den evasys-Export (Rohdaten und Codebuch) mit `evasys_read_data()` ein, wertet
   Berichts- und Regeltabelle mit `input_tabelle()` aus, ergänzt Titel und Dateinamen, prüft die
   Schreibweisen mit `label_test()` und speichert alles in `daten/`.
2. `alle-berichte-rendern.R` rendert `beispiele/kohorte.qmd` für jede Zeile der Berichtstabelle, macht bei
   Fehlern mit dem nächsten Bericht weiter, verwirft Berichte mit weniger als 10 Stimmen, schreibt ein
   Protokoll (`berichte/protokoll.csv`: Bericht, Stimmen, Status) und kopiert die PDFs in die Ordner aus
   der Spalte `Ordner` der Berichtstabelle.

Die Ergebnisse von Schritt 1 liegen bei, die Beispiele lassen sich also auch direkt rendern.

Gerenderte Beispiele: [LVE-Bericht](vorschau/lve-bericht.pdf) ·
[Kohorte: Master-Bericht](vorschau/kohorte-master.pdf) ·
[Kohorte: Bericht „Sonderauswertung“](vorschau/kohorte-sonderauswertung.pdf)

## Aufbau

```
├── _extensions/set-template/   Format „set-template-typst“
│   ├── _extension.yml          Voreinstellungen (Seitenränder, Schrift, Farbe, Logo …)
│   ├── typst-template.typ      Layout: Kopf- und Fußzeile, Titel, Tabellen, Überschriften
│   ├── typst-show.typ          übergibt die Angaben aus dem YAML-Kopf an das Layout
│   ├── chunk-ausgabe.lua       erlaubt Seitenumbrüche in R-Chunks
│   ├── fonts/                  Red Hat Text mit Lizenz (SIL Open Font License)
│   └── images/                 Logos
├── template.qmd                Beispiel 1: LVE-Bericht pro Fachbereich
├── beispiele/
│   ├── vorbereitung.R          Beispiel 2, Schritt 1: evasys-Export einlesen, Berichte festlegen
│   ├── alle-berichte-rendern.R Beispiel 2, Schritt 2: alle Berichte erstellen, protokollieren, verteilen
│   └── kohorte.qmd             Beispiel 2: Bericht mit unterschiedlichem Inhalt je Berichtstabellen-Zeile
├── daten/                      fiktive Beispieldaten
│   ├── beispieldaten_erzeugen.R  erzeugt die Daten (zufällig, reproduzierbar)
│   ├── lve.rds, lve_info.csv     Beispiel 1: Daten und Info-Tabelle
│   ├── evasys_*.csv              Beispiel 2: Export im Format von evasys (Rohdaten, Codebuch)
│   ├── kohorte_*.xlsx            Beispiel 2: Berichts- und Regeltabelle
│   └── kohorte*.rds              Beispiel 2: Ergebnis von vorbereitung.R
└── vorschau/                   gerenderte Beispiel-PDFs und Vorschaubilder
```

### Beispiel 1: LVE-Bericht (`template.qmd`)

Ein Bericht pro Fachbereich: `params$i` wählt die Zeile der Info-Tabelle, die Daten werden auf den
Fachbereich gefiltert. Enthält Rücklauf, Fachsemester, Kernfragen (aggregiert je Lehrveranstaltung),
Gesamtnote, Workload und die Legenden.

### Beispiel 2: Mehrere Berichte mit unterschiedlichem Inhalt (`beispiele/kohorte.qmd`)

Für Befragungen, bei denen jeder Bericht (z. B. pro Studiengang) andere Fragen enthält:

1. Die **Berichtstabelle** enthält eine Zeile pro Bericht (Code, Abschluss, Studiengang, Titel …).
2. Die **Regeltabelle** legt pro Frage fest, wann sie erscheint, z. B. `inkl.1.3` →
   `Abschluss == "Bachelor of Science (B.Sc.)"`.
3. `input_tabelle()` berechnet daraus `TRUE`/`FALSE` je Bericht und Frage (in `vorbereitung.R`). Der
   Bericht setzt die Werte als Variablen; `merge_sc(…, nr = "1.3")` fragt dann `inkl.1.3` ab, ganze
   Abschnitte werden über `eval: !expr header1` ein- oder ausgeblendet.

Die beiden Tabellen liegen als `daten/kohorte_berichte.xlsx` und `daten/kohorte_regeln.xlsx` bei.

### Beispieldaten

Alle Daten in `daten/` sind zufällig erzeugt; Fachbereiche und Studiengänge sind erfunden, offene
Antworten bestehen aus Lorem ipsum. Das Kohorten-Beispiel liegt als Export im Format von evasys vor
(Rohdaten und Codebuch, inklusive typischer Platzhalter wie `[Freitextfeld]`), das LVE-Beispiel direkt
als R-Datei mit denselben Attributen, die `evasys_read_data()` erzeugt (Fragetext, Fragenummer,
Fragetyp, Antwortcodes). Neu erzeugen lassen sich die Daten mit `Rscript beispieldaten_erzeugen.R` im
Ordner `daten/`, danach `beispiele/vorbereitung.R` ausführen.

![Vorschau des Kohorten-Beispiels](vorschau/kohorte.png)

## Anpassen

### Angaben im YAML-Kopf

| Feld          | Bedeutung                                              | Voreinstellung                    |
|---------------|--------------------------------------------------------|-----------------------------------|
| `title`, `subtitle` | Titel auf der ersten Seite (`subtitle` lässt sich pro Bericht aus R setzen, siehe Beispiele) | – |
| `lfoot`       | Text links in der Fußzeile                             | leer                              |
| `accent_col`  | Akzentfarbe für Layout und Grafiken                    | `"#507289"`                       |
| `header-logo` | Logo rechts in der Kopfzeile (SVG)                     | `images/Logo Meze - Cobranding.svg` |
| `toc`, `toc-title`, `toc-depth` | Inhaltsverzeichnis                   | `true`, `INHALTSVERZEICHNIS`, `1` |
| `margin`, `fontsize`, `mainfont` | Seitenränder und Schrift            | 2/3/2 cm, `10pt`, `Red Hat Text`  |
| `params: i`   | welcher Bericht erstellt wird                          | `1`                               |

Im Logo wird die Farbe `#006a6a` durch die Akzentfarbe ersetzt. Ein anderes Logo lässt sich mit
`header-logo: pfad/zum/logo.svg` (relativ zum Dokument) einbinden.

RPTU-Farben für `accent_col`:

| Farbe              | Code      | Farbe              | Code      |
|--------------------|-----------|--------------------|-----------|
| Schiefer (blaugrau)| `#507289` | Petrol (dunkelgrün)| `#006b6b` |
| Ozean (grüngrau)   | `#77b6ba` | Apfel (hellgrün)   | `#26d07c` |
| Nacht (dunkelblau) | `#042c58` | Pflaume (violett)  | `#4c3575` |
| Tag (hellblau)     | `#6ab2e7` | Fuchsia (pink)     | `#d13896` |
| Himbeere (rot)     | `#e31b4c` | Mango (orange)     | `#ffa252` |

### Bausteine im Bericht

- Auswertungsfunktionen aus setanalysis in R-Chunks, z. B. `merge_sc()`, `merge_mc()`, `merge_sk()`,
  `merge_aggr_sk()`, `merge_open()`; Überblick mit `?setanalysis`.
- `appendix_open()` gehört ans Ende jedes Berichts (gibt die gesammelten offenen Antworten aus).
- Seitenumbruch: `{{< pagebreak >}}` im Text oder in einem Chunk.
- Typst-Hilfsfunktionen der Vorlage: `#begriff[…]` (hervorgehobener Begriff in der Akzentfarbe),
  `#hinweis[…]` (kleiner Hinweistext), jeweils in einem ```` ```{=typst} ````-Block.

## Lizenz

**Code:** [MIT License](LICENSE)

**Schrift:** Red Hat Text, © The Red Hat Project Authors, [SIL Open Font License 1.1](_extensions/set-template/fonts/OFL.txt)

**Logos:** Eigentum der [RPTU (Rheinland-Pfälzische Technische Universität Kaiserslautern-Landau)](https://rptu.de)
