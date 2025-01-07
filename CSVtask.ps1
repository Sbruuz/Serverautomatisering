# Definerer path til input- og outputfiler
$inputFile = "C:\\Users\\sofie\\OneDrive - EFIF\\ZBC\\H3\\Serverautomatisering 2\\input.csv"
$outputFile = "C:\\Users\\sofie\\OneDrive - EFIF\\ZBC\\H3\\Serverautomatisering 2\\output.csv"

# Kontrollerer, om inputfilen eksisterer
if (-Not (Test-Path $inputFile)) {
    Write-Host "Inputfilen blev ikke fundet: $inputFile" -ForegroundColor Red
    exit 1
}

# Læser CSV-filen med semikolon som separator
$data = Import-Csv -Path $inputFile -Delimiter ';'

# Iterer gennem rækker og anonymiser data
$anonymizedData = foreach ($row in $data) {
    # Lav en ny række med anonymiserede data
    [PSCustomObject]@{
        Name = $row.Name # Behold originalværdi
        Hobby = $row.Hobby # Behold originalværdi
        Level = $row.Level # Behold originalværdi
        Sensitive_data = "XXXXXX-XXXX" # Masker hele CPR-nummeret
    }
}


# Gemmer den anonymiserede data i en ny CSV-fil med semikolon som separator
$anonymizedData | Export-Csv -Path $outputFile -Delimiter ';' -NoTypeInformation

Write-Host "Anonymiseringen er fuldført. Data er gemt i $outputFile" -ForegroundColor Green

$anonymizedData