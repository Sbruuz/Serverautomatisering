# Definerer path til input- og outputfiler
$inputFile = "C:\\Users\\sofie\\OneDrive - EFIF\\ZBC\\H3\\Serverautomatisering 2\\input.csv"
$outputFile = "C:\\Users\\sofie\\OneDrive - EFIF\\ZBC\\H3\\Serverautomatisering 2\\output.csv"

# Kontrollerer, om inputfilen eksisterer
if (-Not (Test-Path $inputFile)) {
    Write-Host "Inputfilen blev ikke fundet: $inputFile" -ForegroundColor Red
    exit 1
}

# Læs CSV-filen med semikolon som separator
$data = Import-Csv -Path $inputFile -Delimiter ';'
