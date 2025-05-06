$LESTA_XML = "$env:APPDATA\Lesta\MirTankov\preferences.xml"
$WG_XML = "$env:APPDATA\Wargaming.net\WorldOfTanks\preferences.xml"

Write-Host "`n|=============================================================|"
Write-Host "|                 ��������� ����������������                  |"
Write-Host "|       Lesta (��� ������) / Wargaming (World of Tanks)       |"
Write-Host "|                       ������� shuxue                        |"
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
            Write-Host "������� ����� arcadeMode � sniperMode: $sensitivityRatio"
        } else {
            Write-Host "���� �� ����������������� ����� ����, ������� ���������� ���������."
        }
    } else {
        Write-Host "`n�� ������ ���� Lesta: $LESTA_XML"
    }

    if (Test-Path $WG_XML) {

        [xml]$WgXmlContent = Get-Content $WG_XML
        Write-Host "`n=== Wargaming ==="

        $arcadeSensitivity = $WgXmlContent.root.scriptsPreferences.controlMode.arcadeMode.camera.sensitivity
        Write-Host "���������������� arcadeMode: $arcadeSensitivity"

        $sniperSensitivity = $WgXmlContent.root.scriptsPreferences.controlMode.sniperMode.camera.sensitivity
        Write-Host "���������������� sniperMode: $sniperSensitivity"

        if ($arcadeSensitivity -ne 0 -and $sniperSensitivity -ne 0) {
            $sensitivityRatio = $arcadeSensitivity / $sniperSensitivity
            Write-Host "������� ����� arcadeMode � sniperMode: $sensitivityRatio"
        } else {
            Write-Host "���� �� ����������������� ����� ����, ������� ���������� ���������."
        }
    } else {
        Write-Host "`n�� ������ ���� Wargaming: $WG_XML"
    }

} catch {
    Write-Host "��������� ������: $_"
}

Read-Host -Prompt "`n������� Enter ��� ����������"
