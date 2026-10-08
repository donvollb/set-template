# Erzeugt die fiktiven Beispieldaten für die beiden Beispielberichte.
#
# Alle Werte sind zufällig erzeugt (fester Seed, daher reproduzierbar); Fachbereiche und
# Studiengänge sind erfunden, offene Antworten bestehen aus Lorem ipsum.
# Die Variablen haben dieselben Attribute wie Daten aus evasys_read_data():
# label (Fragetext), nr (Fragenummer), type (Fragetyp) und labels (Antwortcodes).
#
# Ausführen im Ordner daten/:  Rscript beispieldaten_erzeugen.R

set.seed(2025)


# Hilfsfunktionen ---------------------------------------------------------

frage <- function(x, label, nr, type, labels = NULL) {
  attr(x, "label") <- label
  attr(x, "nr") <- nr
  attr(x, "type") <- type
  if (!is.null(labels)) attr(x, "labels") <- labels
  x
}

# Ganzzahlige Werte auf eine Skala begrenzen
begrenzen <- function(x, min, max) as.integer(pmin(pmax(round(x), min), max))

# Einen Anteil der Werte auf NA setzen (fehlende Angaben)
luecken <- function(x, anteil) {
  x[runif(length(x)) < anteil] <- NA
  x
}

lorem_woerter <- c(
  "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "sed", "do",
  "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua", "enim",
  "ad", "minim", "veniam", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi",
  "aliquip", "ex", "ea", "commodo", "consequat", "duis", "aute", "irure", "in", "reprehenderit",
  "voluptate", "velit", "esse", "cillum", "fugiat", "nulla", "pariatur", "excepteur", "sint",
  "occaecat", "cupidatat", "non", "proident", "sunt", "culpa", "qui", "officia", "deserunt",
  "mollit", "anim", "id", "est", "laborum"
)

lorem_satz <- function() {
  satz <- paste(sample(lorem_woerter, sample(4:14, 1), replace = TRUE), collapse = " ")
  paste0(toupper(substr(satz, 1, 1)), substr(satz, 2, nchar(satz)), ".")
}

lorem_antwort <- function() paste(replicate(sample(1:3, 1), lorem_satz()), collapse = " ")


# Beispiel 1: Lehrveranstaltungsevaluation --------------------------------

fachbereiche <- c("Musterwissenschaften", "Beispielkunde", "Platzhalterlehre", "Angewandte Fiktion")

lve_info <- data.frame(
  Bericht     = seq_along(fachbereiche),
  Stichprobe  = paste("Fachbereich", fachbereiche),
  Teilbereich = paste(fachbereiche, "- SoSe25"),
  Dateiname   = paste0("LVE-Bericht SoSe25 ", fachbereiche, ".pdf")
)

# Lehrveranstaltungen: Fachbereich, Teilnehmendenzahl, Anzahl Stimmen, Qualität
n_lv <- c(120, 105, 95, 110)
lv <- data.frame(
  Kennung     = 1000L + seq_len(sum(n_lv)),
  Teilbereich = rep(lve_info$Teilbereich, n_lv),
  qualitaet   = rnorm(sum(n_lv), 0, 0.5)
)
lv$stimmen    <- 3L + rnbinom(nrow(lv), size = 1.5, mu = 7)  # Mindestrücklauf 3 Stimmen
lv$Teilnehmer <- pmax(lv$stimmen, round(lv$stimmen / rbeta(nrow(lv), 3, 7)))
ueber_100 <- sample(nrow(lv), 6) # Teilnehmendenzahl bei der Anmeldung zu niedrig angegeben
lv$Teilnehmer[ueber_100] <- round(lv$stimmen[ueber_100] * 0.8)

# Eine Zeile pro Stimme
lve <- lv[rep(seq_len(nrow(lv)), lv$stimmen), c("Teilbereich", "Kennung", "Teilnehmer", "qualitaet")]
n <- nrow(lve)

skala_6 <- c("trifft gar nicht zu" = 1, 2, 3, 4, 5, "trifft voll zu" = 6)

kernfrage <- function(verschiebung) {
  luecken(begrenzen(4.9 + verschiebung + lve$qualitaet + rnorm(n, 0, 0.9), 1, 6), 0.01)
}

lve$FachSemN <- frage(
  luecken(sample(1:14, n, replace = TRUE, prob = c(8, 30, 6, 22, 3, 9, 2, 4, 1, 2, 1, 0.5, 0.5, 0.5)), 0.02),
  label = "Bezogen auf das Fach, dem die vorliegende Veranstaltung zugehört: In welchem Fachsemester sind Sie eingeschrieben?",
  nr = "1.1", type = "sc", labels = setNames(1:14, 1:14)
)
lve$KF_01 <- frage(
  kernfrage(0.1),
  label = "Didaktische Hilfsmittel (z. B. Folien, Begleitmaterialien) waren für mich hilfreich.",
  nr = "2.1", type = "sk", labels = skala_6
)
lve$KF_02 <- frage(
  kernfrage(0.3),
  label = "Die Veranstaltung folgte aus meiner Sicht einer klaren Struktur.",
  nr = "2.2", type = "sk", labels = skala_6
)
lve$KF_03 <- frage(
  kernfrage(0.2),
  label = "Die Veranstaltung war gut organisiert (z. B. Bereitstellung von Materialien, Informationsfluss).",
  nr = "2.3", type = "sk", labels = skala_6
)
lve$Note <- frage(
  luecken(begrenzen(2.1 - 0.8 * lve$qualitaet + rnorm(n, 0, 0.8), 1, 6), 0.01),
  label = "Welche Gesamtnote (Schulnote) geben Sie der Veranstaltung insgesamt?",
  nr = "3.1", type = "sk",
  labels = c("sehr gut" = 1, "gut" = 2, "befriedigend" = 3, "ausreichend" = 4, "mangelhaft" = 5, "ungenügend" = 6)
)
lve$V3_D <- frage(
  luecken(sample(1:2, n, replace = TRUE, prob = c(0.06, 0.94)), 0.01),
  label = "Überschneidet sich der Termin dieser Lehrveranstaltung mit anderen laut Studienverlaufsplan vorgesehenen Pflichtveranstaltungen?",
  nr = "4.1", type = "sc", labels = c("ja" = 1, "nein" = 2)
)
lve$WL <- frage(
  luecken(pmin(round(rgamma(n, shape = 2.2, scale = 1.3)), 13L) + 1L, 0.04), # Code 1 = 0 Stunden
  label = "Zusätzlich zu Ihren Anwesenheitszeiten: Wie viel Zeit (in Stunden) haben Sie für die Veranstaltung im Schnitt pro Woche aufgewendet?",
  nr = "4.2", type = "sc", labels = setNames(1:14, c(0:12, "mehr als 12"))
)

lve$qualitaet <- NULL
rownames(lve) <- NULL


# Beispiel 2: Studieneingangsbefragung ------------------------------------

n <- 320

abschluesse <- c("Bachelor of Arts (B.A.)", "Bachelor of Science (B.Sc.)",
                 "Master of Arts (M.A.)", "Master of Science (M.Sc.)")
studiengaenge <- c("Musterwissenschaft", "Beispielkunde", "Platzhalterlehre", "Angewandte Testologie")

abschluss <- sample(1:4, n, replace = TRUE, prob = c(0.25, 0.35, 0.15, 0.25))
# Musterwissenschaft und Testologie gibt es als B.Sc./M.Sc., die anderen als B.A./M.A.
studiengang <- ifelse(abschluss %in% c(2, 4),
                      sample(c(1, 4), n, replace = TRUE, prob = c(0.6, 0.4)),
                      sample(c(2, 3), n, replace = TRUE, prob = c(0.55, 0.45)))
bachelor <- abschluss %in% 1:2

kohorte <- data.frame(row.names = seq_len(n))

kohorte$abschluss <- frage(
  abschluss,
  label = "Welchen Studienabschluss streben Sie an?",
  nr = "1.1", type = "sc", labels = setNames(1:4, abschluesse)
)
kohorte$studiengang <- frage(
  as.integer(studiengang),
  label = "In welchem Studiengang sind Sie eingeschrieben?",
  nr = "1.2", type = "sc", labels = setNames(1:4, studiengaenge)
)
kohorte$zugang_note <- frage(
  ifelse(bachelor, round(pmin(pmax(rnorm(n, 2.2, 0.55), 1), 4), 1), NA),
  label = "[BACHELOR] Welche Durchschnittsnote hatte Ihr Zeugnis der Hochschulzugangsberechtigung?",
  nr = "1.3", type = "open/num"
)

quellen <- c("Website der Hochschule", "Informationstag", "Freunde und Familie", "Soziale Medien", "Sonstiges")
anteile <- c(0.8, 0.35, 0.45, 0.3, 0.08)
for (k in seq_along(quellen)) {
  kohorte[[paste0("info_", k)]] <- frage(
    ifelse(runif(n) < anteile[k], k, 0L), # angekreuzt: Code der Antwortoption, sonst 0
    label = paste("Wie haben Sie sich vor Studienbeginn informiert? (Mehrfachnennung möglich) :", quellen[k]),
    nr = "2.1", type = "mc"
  )
}

kohorte$info_ausr <- frage(
  luecken(sample(0:6, n, replace = TRUE, prob = c(0.02, 0.03, 0.08, 0.10, 0.25, 0.35, 0.17)), 0.01),
  label = "Vor Beginn meines Studiums war ich ausreichend über den Studiengang informiert.",
  nr = "2.2", type = "sk",
  labels = c("stimme gar nicht zu" = 1, "stimme nicht zu" = 2, "stimme eher nicht zu" = 3,
             "stimme eher zu" = 4, "stimme zu" = 5, "stimme voll zu" = 6, "kann ich nicht beurteilen" = 0)
)

offen <- rep(NA_character_, n)
antwortende <- sample(n, 25)
offen[antwortende] <- replicate(length(antwortende), lorem_antwort())
offen[antwortende[1:4]] <- "Lorem ipsum dolor sit amet." # mehrfach gegebene Antwort
kohorte$offen <- frage(
  offen,
  label = "Welche weiteren Informationen hätten Sie sich vor Studienbeginn gewünscht?",
  nr = "3.1", type = "open/num"
)


# Berichts- und Regeltabelle für input_tabelle() --------------------------

berichte <- data.frame(
  Code        = c("MASTER", "Gesamtbericht", "B.Sc._Musterwissenschaft", "M.Sc._Musterwissenschaft",
                  "B.A._Beispielkunde", "Sonderauswertung"),
  Art         = c("alles.master", "alles", "Studiengang", "Studiengang", "Studiengang", "speziell"),
  Abschluss   = c("alle", "alle", abschluesse[c(2, 4, 1)], "alle"),
  Studiengang = c("alle", "alle", "Musterwissenschaft", "Musterwissenschaft", "Beispielkunde", "alle"),
  Titel       = paste("Befragung 2025:", c("Master-Bericht (alle Fragen)", "Gesamtbericht", "B.Sc. Musterwissenschaft",
                                           "M.Sc. Musterwissenschaft", "B.A. Beispielkunde", "Sonderauswertung")),
  # Wohin alle-berichte-rendern.R den Bericht kopiert (mehrere mit " | ", leer = nicht verteilen)
  Ordner      = c("", "Gesamtberichte | Musterwissenschaft | Beispielkunde", "Musterwissenschaft",
                  "Musterwissenschaft", "Beispielkunde", "")
)

regeln <- data.frame(
  Variable = c("inkl.1.1", "inkl.1.2", "inkl.1.3", "inkl.2.1", "inkl.2.2", "inkl.3.1",
               "header1", "header2", "header3"),
  Bedingung = c(
    "immer TRUE",
    'Art != "speziell"',
    'Art == "alles" | Abschluss %in% c("Bachelor of Arts (B.A.)", "Bachelor of Science (B.Sc.)")',
    "immer TRUE",
    'Studiengang == "Musterwissenschaft"',
    'Art == "speziell"',
    "eine der inkl.1.x-Variablen == TRUE",
    "eine der inkl.2.x-Variablen == TRUE",
    "eine der inkl.3.x-Variablen == TRUE"
  )
)
names(regeln)[2] <- "TRUE (in einen Bericht rein), wenn…"


# Speichern ---------------------------------------------------------------

saveRDS(lve, "lve.rds")
write.csv2(lve_info, "lve_info.csv", row.names = FALSE, fileEncoding = "UTF-8")
saveRDS(kohorte, "kohorte.rds")
writexl::write_xlsx(berichte, "kohorte_berichte.xlsx")
writexl::write_xlsx(regeln, "kohorte_regeln.xlsx")
