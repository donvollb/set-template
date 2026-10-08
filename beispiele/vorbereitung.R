# Bereitet die Daten und die Berichtstabelle für das Kohorten-Beispiel vor (Schritt 1 von 2).
#
# Ausführen im Hauptordner des Projekts:  Rscript beispiele/vorbereitung.R
# (oder in RStudio mit dem Projektordner als Arbeitsverzeichnis)
#
# Ablauf:
#   1. evasys-Export (Rohdaten und Codebuch) einlesen und aufbereiten
#   2. Daten bereinigen, z. B. Namen in offenen Antworten unkenntlich machen
#   3. Berichtstabelle und Regeltabelle auswerten: welche Fragen in welchen Bericht kommen
#   4. Berichtsangaben ergänzen (Titel, Dateiname) und Schreibweisen prüfen
#   5. Speichern: daten/kohorte.rds und daten/kohorte_berichte.rds
#
# Danach (Schritt 2): Rscript beispiele/alle-berichte-rendern.R

library(setanalysis)


# 1. evasys-Export einlesen -----------------------------------------------

# Ohne Pfade öffnet sich in RStudio ein Dialog zur Dateiauswahl
daten <- evasys_read_data("daten/evasys_rohdaten.csv", "daten/evasys_codebuch.csv")


# 2. Daten bereinigen -----------------------------------------------------

# Rückschlüsse auf Personen in offenen Antworten verhindern, z. B.:
# daten$offen <- gsub("Frau Beispiel", "[Name entfernt]", daten$offen, fixed = TRUE)


# 3. Berichts- und Regeltabelle auswerten ---------------------------------

# Berichtstabelle: eine Zeile pro Bericht, die erste Zeile ist der Master-Bericht mit allen Fragen
# Regeltabelle: eine Zeile pro Frage, z. B. inkl.1.3 = Abschluss == "Bachelor of Science (B.Sc.)"
berichte <- input_tabelle("daten/kohorte_berichte.xlsx", "daten/kohorte_regeln.xlsx")


# 4. Berichtsangaben ergänzen und prüfen ----------------------------------

berichte$Titel     <- paste("Befragung 2025:", berichte$Titel)
berichte$Dateiname <- paste0("SEB2025_", berichte$Code)

# Kommen die Abschlüsse und Studiengänge der Berichtstabelle genau so in den Daten vor?
# (Tippfehler würden sonst zu leeren Berichten führen)
label_test(berichte$Abschluss, names(attr(daten$abschluss, "labels")))
label_test(berichte$Studiengang, names(attr(daten$studiengang, "labels")))


# 5. Speichern ------------------------------------------------------------

saveRDS(daten, "daten/kohorte.rds")
saveRDS(berichte, "daten/kohorte_berichte.rds")
