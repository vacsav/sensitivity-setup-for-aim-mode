function Confirm-Action($message) {
    do {
        $input = Read-Host $message
        switch -Regex ($input) {
            '^(Y|y)$' { return $true }
            '^(N|n)$' { return $false }
            default {
                Write-Host "`nInvalid input. Enter Y or N.`n"
            }
        }
    } while ($true)
}

function Select-Targets($lestaExists, $wgExists, $lestaPath, $wgPath) {
    $targets = @()

    if ($lestaExists -and -not $wgExists) {
        Write-Host "Found client Lesta (Mir Tankov) - auto-selected`n"
        $targets += @{ name = "Lesta (Mir Tankov)"; path = $lestaPath }
    } elseif ($wgExists -and -not $lestaExists) {
        Write-Host "Found client Wargaming (World of Tanks) - auto-selected`n"
        $targets += @{ name = "Wargaming (World of Tanks)"; path = $wgPath }
    } elseif ($lestaExists -and $wgExists) {
        do {
            Write-Host @"
Both clients found. Select client:
1 - Lesta (Mir Tankov)
2 - Wargaming (World of Tanks)
3 - Both: Lesta and Wargaming
0 - Exit
"@
            switch (Read-Host "Enter a number (1 / 2 / 3 / 0)") {
                '0' {
                    if (Confirm-Action "`nConfirm exit? (Y/N)") { exit }
                    Write-Host ""
                }
                '1' { return @(@{ name = "Lesta (Mir Tankov)"; path = $lestaPath }) }
                '2' { return @(@{ name = "Wargaming (World of Tanks)"; path = $wgPath }) }
                '3' {
                    return @(
                        @{ name = "Lesta (Mir Tankov)"; path = $lestaPath },
                        @{ name = "Wargaming (World of Tanks)"; path = $wgPath }
                    )
                }
                default { Write-Host "`nInvalid input. Try again.`n" }
            }
        } while ($true)
    }

    return $targets
}

while ($true) {
    $xmlExe = ".\bin\xml.exe"
    $lestaPath = "$env:APPDATA\Lesta\MirTankov\preferences.xml"
    $wgPath    = "$env:APPDATA\Wargaming.net\WorldOfTanks\preferences.xml"
    $lestaExists = Test-Path $lestaPath
    $wgExists    = Test-Path $wgPath

    Write-Host "`n|=============================================================|"
    Write-Host "|                       Sensitivity Setup                     |"
    Write-Host "|        Lesta (Mir Tankov) / Wargaming (World of Tanks)      |"
    Write-Host "|                       created by shuxue                     |"
    Write-Host "|=============================================================|`n"

    if (-not ($lestaExists -or $wgExists)) {
        Write-Host "Lesta or Wargaming client configuration file not found"
        Write-Host "`nMake sure that the configuration file is present at the path"
        Write-Host "Lesta: lestaPath"
        Write-Host "Wargaming: wgPath"
        Read-Host
        break
    }

    if (-not (Test-Path $xmlExe)) {
        Write-Host "`nMissing bin\xml.exe near the script"
        Read-Host
        break
    }

    $targets = Select-Targets $lestaExists $wgExists $lestaPath $wgPath

    do {
        Write-Host ""
        Write-Host @"
Select the setup mode:
1 - default arcadeMode: sniper = arcade / 2
2 - default sniperMode: arcade = sniper * 2
3 - custom: set manually
0 - Exit
"@

        $mode = Read-Host "Enter a number (1 / 2 / 3 / 0)"
        switch ($mode) {
            '0' {
                if (Confirm-Action "`nConfirm exit? (Y/N)") { exit }
            }
            '1' { $modeType = "default arcadeMode"; break }
            '2' { $modeType = "default sniperMode"; break }
            '3' { $modeType = "custom"; break }
            default { Write-Host "`nInvalid input. Try again.`n" }
        }
    } while ($mode -notin @('1', '2', '3'))

    foreach ($target in $targets) {
        $wasUpdated = $false
        $xmlFile = $target.path
        $gameName = $target.name

        Write-Host "`nProcessing: $gameName"
        $arcadeValue = & $xmlExe sel -t -v "//arcadeMode/camera/sensitivity" $xmlFile
        $sniperValue = & $xmlExe sel -t -v "//sniperMode/camera/sensitivity" $xmlFile

        if (-not $arcadeValue -or -not $sniperValue) {
            Write-Host "Skipped $gameName - failed to read sensitivity"
            continue
        }

        switch ($modeType) {
            'default arcadeMode' {
                $newSniper = [math]::Round([double]$arcadeValue.Trim() / 2, 6)
                if ($newSniper -lt 0.01) {
                    Write-Host "arcadeMode sensitivity: $arcadeValue"
                    Write-Host "sniperMode sensitivity: $sniperValue"
                    Write-Host "New sniperMode sensitivity: $newSniper"
                    Write-Host "`nResulting sniperMode sensitivity is lower than allowed. Minimum allowed is 0.01."
                    continue
                }
                Write-Host @"
arcadeMode sensitivity: $arcadeValue
sniperMode sensitivity: $sniperValue
New sniperMode sensitivity: $newSniper
"@
                if (Confirm-Action "`nApply to $($gameName)? (Y/N)") {
                    & $xmlExe ed -L -O -u "//sniperMode/camera/sensitivity" -v " $newSniper " $xmlFile
                    Write-Host "Applied to: $gameName"
                    $wasUpdated = $true
                }
            }
            'default sniperMode' {
                $newArcade = [math]::Round([double]$sniperValue.Trim() * 2, 6)
                if ($newArcade -gt 2) {
                    Write-Host "arcadeMode sensitivity: $arcadeValue"
                    Write-Host "sniperMode sensitivity: $sniperValue"
                    Write-Host "New arcadeMode sensitivity: $newArcade"
                    Write-Host "`nResulting arcadeMode is higher than allowed. Maximum allowed is 2."
                    continue
                }
                Write-Host @"
arcadeMode sensitivity: $arcadeValue
sniperMode sensitivity: $sniperValue
New arcadeMode sensitivity: $newArcade
"@
                if (Confirm-Action "`nApply to $($gameName)? (Y/N)") {
                    & $xmlExe ed -L -O -u "//arcadeMode/camera/sensitivity" -v " $newArcade " $xmlFile
                    Write-Host "Applied to: $gameName"
                    $wasUpdated = $true
                }
            }
            'custom' {
                $customLoopComplete = $false
                do {
                    Write-Host @"
Choose what to change:
1 - Only arcadeMode
2 - Only sniperMode
3 - Both: arcadeMode and sniperMode
0 - Exit
"@
                    $customChoice = Read-Host "Enter a number (1 / 2 / 3 / 0)"
                    switch ($customChoice) {
                        '0' {
                            if (Confirm-Action "`nConfirm exit? (Y/N)") { exit }
                        }
                        '1' {
                            Write-Host "`nCurrent sensitivity arcadeMode: $arcadeValue"
                            do {
                                $arcadeNew = Read-Host "Enter new value for arcadeMode (e.g., 1.0, 0 - back)"
                                if ($arcadeNew -eq '0') { break }
                                if ($arcadeNew -match '^\d+(\.\d+)?$') {
                                    $arcadeNewNum = [double]$arcadeNew
                                    if ($arcadeNewNum -lt 0.01) {
                                        Write-Host "Sensitivity of arcadeMode is lower than allowed. Minimum allowed is 0.01.`n"
                                        continue
                                    }
                                    if ($arcadeNewNum -gt 2) {
                                        Write-Host "Sensitivity of arcadeMode is higher than allowed. Maximum allowed is 2.`n"
                                        continue
                                    }
                                    & $xmlExe ed -L -O -u "//arcadeMode/camera/sensitivity" -v " $arcadeNew " $xmlFile
                                    Write-Host "arcadeMode sensitivity is set: $arcadeNew"
                                    $wasUpdated = $true
                                    $customLoopComplete = $true
                                    break
                                } else {
                                    Write-Host "Invalid input. Try again.`n"
                                }
                            } while ($true)
                        }
                        '2' {
                            Write-Host "`nCurrent sensitivity sniperMode: $sniperValue"
                            do {
                                $sniperNew = Read-Host "Enter new value for sniperMode (e.g., 1.0, 0 - back)"
                                if ($sniperNew -eq '0') { break }
                                if ($sniperNew -match '^\d+(\.\d+)?$') {
                                    $sniperNewNum = [double]$sniperNew
                                    if ($sniperNewNum -lt 0.01) {
                                        Write-Host "Sensitivity of sniperMode is lower than allowed. Minimum allowed is 0.01.`n"
                                        continue
                                    }
                                    if ($sniperNewNum -gt 2) {
                                        Write-Host "Sensitivity of sniperMode is higher than allowed. Maximum allowed is 2.`n"
                                        continue
                                    }
                                    & $xmlExe ed -L -O -u "//sniperMode/camera/sensitivity" -v " $sniperNew " $xmlFile
                                    Write-Host "sniperMode sensitivity is set: $sniperNew"
                                    $wasUpdated = $true
                                    $customLoopComplete = $true
                                    break
                                } else {
                                    Write-Host "Invalid input. Try again.`n"
                                }
                            } while ($true)
                        }
                        '3' {
                            Write-Host "`nCurrent sensitivity arcadeMode: $arcadeValue"
                            Write-Host "Current sensitivity sniperMode: $sniperValue"
                            do {
                                $values = Read-Host "Enter two values separated by space (e.g., 1.0 0.5, 0 - back)"
                                if ($values -eq '0') { break }
                                $parts = $values -split '\s+'
                                if ($parts.Count -ne 2) {
                                    Write-Host "Invalid input. Enter exactly two numbers separated by a space.`n"
                                    continue
                                }
                                $isArcadeValidFormat = $parts[0] -match '^\d+(\.\d+)?$'
                                $isSniperValidFormat = $parts[1] -match '^\d+(\.\d+)?$'

                                if (-not $isArcadeValidFormat -or -not $isSniperValidFormat) {
                                    Write-Host "Invalid input. Enter exactly two numbers separated by a space.`n"
                                    continue
                                }
                                $arcadeNew = [double]$parts[0]
                                $sniperNew = [double]$parts[1]
                                $valid = $true
                                $errorMessages = @()
                                if ($arcadeNew -lt 0.01) {
                                    $errorMessages += "Sensitivity of arcadeMode is lower than allowed. Minimum allowed is 0.01."
                                } elseif ($arcadeNew -gt 2) {
                                    $errorMessages += "Sensitivity of arcadeMode is higher than allowed. Maximum allowed is 2."
                                }
                                if ($sniperNew -lt 0.01) {
                                    $errorMessages += "Sensitivity of sniperMode is lower than allowed. Minimum allowed is 0.01."
                                } elseif ($sniperNew -gt 2) {
                                    $errorMessages += "Sensitivity of sniperMode is higher than allowed. Maximum allowed is 2."
                                }
                                if ($errorMessages.Count -gt 0) {
                                    $errorMessages | ForEach-Object { Write-Host $_ }
                                    Write-Host ""
                                    continue
                                }
                                & $xmlExe ed -L -O -u "//arcadeMode/camera/sensitivity" -v " $arcadeNew " $xmlFile
                                & $xmlExe ed -L -O -u "//sniperMode/camera/sensitivity" -v " $sniperNew " $xmlFile
                                Write-Host "arcadeMode sensitivity is set: $arcadeNew"
                                Write-Host "sniperMode sensitivity is set: $sniperNew"
                                $wasUpdated = $true
                                $customLoopComplete = $true
                                break
                            } while ($true)
                        }
                        default {
                            Write-Host "`nInvalid input. Try again.`n"
                        }
                    }
                } while (-not $customLoopComplete)
            }
        }

        if (-not $wasUpdated) {
            Write-Host "Skipped $gameName"
        }
    }

    if ($wasUpdated) {
        Write-Host "`n=== Done ==="
    }

    if (-not (Confirm-Action "`nDo you want to setup again? (Y/N)")) {
        break
    }
}
