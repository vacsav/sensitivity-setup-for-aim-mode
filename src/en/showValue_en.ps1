$LESTA_XML = "$env:APPDATA\Lesta\MirTankov\preferences.xml"
$WG_XML = "$env:APPDATA\Wargaming.net\WorldOfTanks\preferences.xml"

Write-Host "`n|=============================================================|"
Write-Host "|                       Sensitivity Setup                     |"
Write-Host "|        Lesta (Mir Tankov) / Wargaming (World of Tanks)      |"
Write-Host "|                       created by shuxue                     |"
Write-Host "|=============================================================|`n"

try {

    if (Test-Path $LESTA_XML) {

        [xml]$LestaXmlContent = Get-Content $LESTA_XML
        Write-Host "=== Lesta ==="

        $arcadeSensitivity = $LestaXmlContent.root.scriptsPreferences.controlMode.arcadeMode.camera.sensitivity
        Write-Host "arcadeMode sensitivity: $arcadeSensitivity"

        $sniperSensitivity = $LestaXmlContent.root.scriptsPreferences.controlMode.sniperMode.camera.sensitivity
        Write-Host "sniperMode sensitivity: $sniperSensitivity"

        if ($arcadeSensitivity -ne 0 -and $sniperSensitivity -ne 0) {
            $sensitivityRatio = $arcadeSensitivity / $sniperSensitivity
            Write-Host "Difference between arcadeMode and sniperMode: $sensitivityRatio"
        } else {
            Write-Host "One of the sensitivities is zero, unable to calculate the difference."
        }
    } else {
        Write-Host "`nLesta file not found: $LESTA_XML"
    }

    if (Test-Path $WG_XML) {

        [xml]$WgXmlContent = Get-Content $WG_XML
        Write-Host "`n=== Wargaming ==="

        $arcadeSensitivity = $WgXmlContent.root.scriptsPreferences.controlMode.arcadeMode.camera.sensitivity
        Write-Host "arcadeMode sensitivity: $arcadeSensitivity"

        $sniperSensitivity = $WgXmlContent.root.scriptsPreferences.controlMode.sniperMode.camera.sensitivity
        Write-Host "sniperMode sensitivity: $sniperSensitivity"

        if ($arcadeSensitivity -ne 0 -and $sniperSensitivity -ne 0) {
            $sensitivityRatio = $arcadeSensitivity / $sniperSensitivity
            Write-Host "Difference between arcadeMode and sniperMode: $sensitivityRatio"
        } else {
            Write-Host "One of the sensitivities is zero, unable to calculate the difference."
        }
    } else {
        Write-Host "`nWargaming file not found: $WG_XML"
    }

} catch {
    Write-Host "An error occurred: $_"
}

Read-Host -Prompt "`nPress Enter to finish"
