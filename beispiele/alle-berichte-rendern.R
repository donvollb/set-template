# Erstellt alle Berichte des Kohorten-Beispiels nacheinander, protokolliert die Anzahl der Stimmen
# und verteilt die PDFs in Ordner (Schritt 2 von 2; Schritt 1: vorbereitung.R).
#
# Ausführen im Hauptordner des Projekts:  Rscript beispiele/alle-berichte-rendern.R
# (oder in RStudio mit dem Projektordner als Arbeitsverzeichnis)
#
# Ablauf:
#   1. Rendern: kohorte.qmd einmal pro Zeile der Berichtstabelle (params$i); jeder Bericht schreibt
#      seine Anzahl an Stimmen in das Protokoll (params$protokoll)
#   2. Aufräumen: Berichte mit weniger als 10 Stimmen bricht kohorte.qmd ab; diese PDFs werden gelöscht
#   3. Protokoll: Bericht, Stimmen, Status und Zeitpunkt als CSV
#   4. Verteilen: Kopie jedes Berichts in die Ordner aus der Spalte "Ordner" der Berichtstabelle

# Einstellungen -----------------------------------------------------------

vorlage  <- "beispiele/kohorte.qmd"
berichte <- readRDS("daten/kohorte_berichte.rds") # aus vorbereitung.R
auswahl  <- seq_len(nrow(berichte)) # oder z. B. c(3, 5), um nur einzelne Berichte neu zu erstellen
ausgabe  <- "berichte"              # Ordner für PDFs und Protokoll
verteilt <- file.path(ausgabe, "verteilt") # in der Praxis z. B. ein Netzlaufwerk oder Cloud-Ordner
min_n    <- 10                      # Mindestanzahl an Stimmen (wie in kohorte.qmd)

dir.create(ausgabe, showWarnings = FALSE)
protokoll_datei <- file.path(getwd(), ausgabe, "stimmen.csv") # absolut, da der Bericht in beispiele/ läuft
unlink(protokoll_datei)


# 1. Rendern --------------------------------------------------------------

status <- setNames(rep("nicht erstellt", nrow(berichte)), berichte$Code)

for (i in auswahl) {
  datei <- paste0(berichte$Dateiname[i], ".pdf")
  message("Bericht ", i, "/", nrow(berichte), ": ", berichte$Code[i])

  # Bei einem Fehler mit dem nächsten Bericht weitermachen und den Fehler protokollieren
  status[i] <- tryCatch({
    quarto::quarto_render(
      vorlage,
      output_file    = datei,
      execute_params = list(i = i, protokoll = protokoll_datei),
      quiet          = TRUE,
      as_job         = FALSE
    )
    # Quarto legt die PDF neben die Vorlage
    file.rename(file.path(dirname(vorlage), datei), file.path(ausgabe, datei))
    "erstellt"
  }, error = function(e) {
    message(conditionMessage(e))
    paste0("Fehler, zum Prüfen einzeln rendern: quarto render ", vorlage, " -P i:", i)
  })
}


# 2. Aufräumen und 3. Protokoll -------------------------------------------

stimmen <- if (file.exists(protokoll_datei)) read.csv2(protokoll_datei) else data.frame(Code = character(), N = integer())

protokoll <- data.frame(
  Code      = berichte$Code,
  Titel     = berichte$Titel,
  Datei     = paste0(berichte$Dateiname, ".pdf"),
  N         = stimmen$N[match(berichte$Code, stimmen$Code)],
  Status    = unname(status),
  Zeitpunkt = format(Sys.time(), "%Y-%m-%d %H:%M")
)

zu_wenig <- protokoll$Status == "erstellt" & !is.na(protokoll$N) & protokoll$N < min_n
unlink(file.path(ausgabe, protokoll$Datei[zu_wenig]))
protokoll$Status[zu_wenig] <- paste("übersprungen: weniger als", min_n, "Stimmen")

write.csv2(protokoll, file.path(ausgabe, "protokoll.csv"), row.names = FALSE, fileEncoding = "UTF-8")
unlink(protokoll_datei)


# 4. Verteilen ------------------------------------------------------------

# Spalte "Ordner": ein oder mehrere Zielordner, getrennt mit " | "; leer = nicht verteilen
# (z. B. der Master-Bericht zur Kontrolle oder Berichte, die per E-Mail verschickt werden)
for (i in which(protokoll$Status == "erstellt")) {
  ziele <- berichte$Ordner[i]
  if (is.na(ziele) || ziele == "") next

  for (ordner in file.path(verteilt, strsplit(ziele, " | ", fixed = TRUE)[[1]])) {
    dir.create(ordner, recursive = TRUE, showWarnings = FALSE)
    file.copy(file.path(ausgabe, protokoll$Datei[i]), ordner, overwrite = TRUE)
  }
}


# Zusammenfassung ---------------------------------------------------------

print(protokoll[, c("Code", "N", "Status")], row.names = FALSE)
