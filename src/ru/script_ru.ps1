function Confirm-Action($message) {
    do {
        $input = Read-Host $message
        switch -Regex ($input) {
            '^(Y|y|Н|н)$' { return $true }
            '^(N|n|Т|т)$' { return $false }
            default {
                Write-Host "`nНеверный ввод. Введите Y или N.`n"
            }
        }
    } while ($true)
}

function Select-Targets($lestaExists, $wgExists, $lestaPath, $wgPath) {
    $targets = @()

    if ($lestaExists -and -not $wgExists) {
        Write-Host "Найден клиент Lesta (Мир Танков) - выбран автоматически`n"
        $targets += @{ name = "Lesta (Мир Танков)"; path = $lestaPath }
    } elseif ($wgExists -and -not $lestaExists) {
        Write-Host "Найден клиент Wargaming (World of Tanks) - выбран автоматически`n"
        $targets += @{ name = "Wargaming (World of Tanks)"; path = $wgPath }
    } elseif ($lestaExists -and $wgExists) {
        do {
            Write-Host @"
Найдены оба клиента:
1 - Lesta (Мир Танков)
2 - Wargaming (World of Tanks)
3 - Оба: Lesta и Wargaming
0 - Выход
"@
            switch (Read-Host "Введите номер (1 / 2 / 3 / 0)") {
                '0' {
                    if (Confirm-Action "`nПодтвердите выход (Y/N)") { exit }
                    Write-Host ""
                }
                '1' { return @(@{ name = "Lesta (Мир Танков)"; path = $lestaPath }) }
                '2' { return @(@{ name = "Wargaming (World of Tanks)"; path = $wgPath }) }
                '3' {
                    return @(
                        @{ name = "Lesta (Мир Танков)"; path = $lestaPath },
                        @{ name = "Wargaming (World of Tanks)"; path = $wgPath }
                    )
                }
                default { Write-Host "`nНеверный ввод. Попробуйте снова.`n" }
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
    Write-Host "|                 Настройка чувствительности                  |"
    Write-Host "|       Lesta (Мир Танков) / Wargaming (World of Tanks)       |"
    Write-Host "|                       создано shuxue                        |"
    Write-Host "|=============================================================|`n"

    if (-not ($lestaExists -or $wgExists)) {
        Write-Host "Не найдено ни одного конфигурационного файла клиента Lesta или Wargaming"
        Write-Host "`nУбедитесь, что файл конфигурации присутствует по пути:"
        Write-Host "Lesta: $lestaPath"
        Write-Host "Wargaming: $wgPath"
        Read-Host
        break
    }

    if (-not (Test-Path $xmlExe)) {
        Write-Host "`nНе найден файл bin\xml.exe рядом со скриптом"
        Read-Host
        break
    }

    $targets = Select-Targets $lestaExists $wgExists $lestaPath $wgPath

    do {
        Write-Host ""
        Write-Host @"
Выберите режим настройки:
1 - по умолчанию arcadeMode: sniper = arcade / 2
2 - по умолчанию sniperMode: arcade = sniper * 2
3 - пользовательский: задать вручную
0 - Выход
"@

        $mode = Read-Host "Введите номер (1 / 2 / 3 / 0)"
        switch ($mode) {
            '0' {
                if (Confirm-Action "`nПодтвердите выход (Y/N)") { exit }
            }
            '1' { $modeType = "по умолчанию arcadeMode"; break }
            '2' { $modeType = "по умолчанию sniperMode"; break }
            '3' { $modeType = "пользовательский"; break }
            default { Write-Host "`nНеверный ввод. Попробуйте снова.`n" }
        }
    } while ($mode -notin @('1', '2', '3'))

    foreach ($target in $targets) {
        $wasUpdated = $false
        $xmlFile = $target.path
        $gameName = $target.name

        Write-Host "`nОбработка: $gameName"
        $arcadeValue = & $xmlExe sel -t -v "//arcadeMode/camera/sensitivity" $xmlFile
        $sniperValue = & $xmlExe sel -t -v "//sniperMode/camera/sensitivity" $xmlFile

        if (-not $arcadeValue -or -not $sniperValue) {
            Write-Host "Пропущено $gameName - не удалось прочитать чувствительность"
            continue
        }

        switch ($modeType) {
            'по умолчанию arcadeMode' {
                $newSniper = [math]::Round([double]$arcadeValue.Trim() / 2, 6)
                if ($newSniper -lt 0.01) {
                    Write-Host "Чувствительность arcadeMode: $arcadeValue"
                    Write-Host "Чувствительность sniperMode: $sniperValue"
                    Write-Host "Новая чувствительность sniperMode: $newSniper"
                    Write-Host "`nИтоговая чувствительность sniperMode ниже допустимого. Минимально допустимая чувствительность - 0.01."
                    continue
                }
                Write-Host @"
Чувствительность arcadeMode: $arcadeValue
Чувствительность sniperMode: $sniperValue
Новая чувствительность sniperMode: $newSniper
"@
                if (Confirm-Action "`nПрименить к $($gameName)? (Y/N)") {
                    & $xmlExe ed -L -O -u "//sniperMode/camera/sensitivity" -v " $newSniper " $xmlFile
                    Write-Host "Примененно к: $gameName"
                    $wasUpdated = $true
                }
            }
            'по умолчанию sniperMode' {
                $newArcade = [math]::Round([double]$sniperValue.Trim() * 2, 6)
                if ($newArcade -gt 2) {
                    Write-Host "Чувствительность arcadeMode: $arcadeValue"
                    Write-Host "Чувствительность sniperMode: $sniperValue"
                    Write-Host "Новая чувствительность arcadeMode: $newArcade"
                    Write-Host "`nИтоговая чувствительность arcadeMode выше допустимого. Максимально допустимая чувствительность - 2."
                    continue
                }
                Write-Host @"
Чувствительность arcadeMode: $arcadeValue
Чувствительность sniperMode: $sniperValue
Новая чувствительность arcadeMode: $newArcade
"@
                if (Confirm-Action "`nПрименить к $($gameName)? (Y/N)") {
                    & $xmlExe ed -L -O -u "//arcadeMode/camera/sensitivity" -v " $newArcade " $xmlFile
                    Write-Host "Примененно к: $gameName"
                    $wasUpdated = $true
                }
            }
            'пользовательский' {
                $customLoopComplete = $false
                do {
                    Write-Host @"
Выберите, что хотите изменить:
1 - Только arcadeMode
2 - Только sniperMode
3 - Оба: arcadeMode и sniperMode
0 - Выход
"@
                    $customChoice = Read-Host "Введите номер (1 / 2 / 3 / 0)"
                    switch ($customChoice) {
                        '0' {
                            if (Confirm-Action "`nПодтвердите выход (Y/N)") { exit }
                        }
                        '1' {
                            Write-Host "`nТекущая чувствительность arcadeMode: $arcadeValue"
                            do {
                                $arcadeNew = Read-Host "Введите новую чувствительность для arcadeMode (например, 1.0, 0 - назад)"
                                if ($arcadeNew -eq '0') { break }
                                if ($arcadeNew -match '^\d+(\.\d+)?$') {
                                    $arcadeNewNum = [double]$arcadeNew
                                    if ($arcadeNewNum -lt 0.01) {
                                        Write-Host "Чувствительность arcadeMode ниже допустимого. Минимально допустимая чувствительность - 0.01.`n"
                                        continue
                                    }
                                    if ($arcadeNewNum -gt 2) {
                                        Write-Host "Чувствительность arcadeMode выше допустимого. Максимально допустимая чувствительность - 2.`n"
                                        continue
                                    }
                                    & $xmlExe ed -L -O -u "//arcadeMode/camera/sensitivity" -v " $arcadeNew " $xmlFile
                                    Write-Host "Установленна чувствительность arcadeMode: $arcadeNew"
                                    $wasUpdated = $true
                                    $customLoopComplete = $true
                                    break
                                } else {
                                    Write-Host "Неверный ввод. Попробуйте снова.`n"
                                }
                            } while ($true)
                        }
                        '2' {
                            Write-Host "`nТекущая чувствительность sniperMode: $sniperValue"
                            do {
                                $sniperNew = Read-Host "Введите новую чувствительность для sniperMode (например, 1.0, 0 - назад)"
                                if ($sniperNew -eq '0') { break }
                                if ($sniperNew -match '^\d+(\.\d+)?$') {
                                    $sniperNewNum = [double]$sniperNew
                                    if ($sniperNewNum -lt 0.01) {
                                        Write-Host "Чувствительность sniperMode ниже допустимого. Минимально допустимая чувствительность - 0.01.`n"
                                        continue
                                    }
                                    if ($sniperNewNum -gt 2) {
                                        Write-Host "Чувствительность sniperMode выше допустимого. Максимально допустимая чувствительность - 2.`n"
                                        continue
                                    }
                                    & $xmlExe ed -L -O -u "//sniperMode/camera/sensitivity" -v " $sniperNew " $xmlFile
                                    Write-Host "Установленна чувствительность sniperMode: $sniperNew"
                                    $wasUpdated = $true
                                    $customLoopComplete = $true
                                    break
                                } else {
                                    Write-Host "Неверный ввод. Попробуйте снова.`n"
                                }
                            } while ($true)
                        }
                        '3' {
                            Write-Host "`nТекущая чувствительность arcadeMode: $arcadeValue"
                            Write-Host "Текущая чувствительность sniperMode: $sniperValue"
                            do {
                                $values = Read-Host "Введите два числа через пробел (например, 1.0 0.5, 0 - назад)"
                                if ($values -eq '0') { break }
                                $parts = $values -split '\s+'
                                if ($parts.Count -ne 2) {
                                    Write-Host "Неверный ввод. Введите ровно два числа, разделенные пробелом.`n"
                                    continue
                                }
                                $isArcadeValidFormat = $parts[0] -match '^\d+(\.\d+)?$'
                                $isSniperValidFormat = $parts[1] -match '^\d+(\.\d+)?$'

                                if (-not $isArcadeValidFormat -or -not $isSniperValidFormat) {
                                    Write-Host "Неверный ввод. Введите ровно два числа, разделенные пробелом.`n"
                                    continue
                                }
                                $arcadeNew = [double]$parts[0]
                                $sniperNew = [double]$parts[1]
                                $valid = $true
                                $errorMessages = @()
                                if ($arcadeNew -lt 0.01) {
                                    $errorMessages += "Чувствительность arcadeMode ниже допустимого. Минимально допустимая чувствительность - 0.01."
                                } elseif ($arcadeNew -gt 2) {
                                    $errorMessages += "Чувствительность arcadeMode выше допустимого. Максимально допустимая чувствительность - 2."
                                }
                                if ($sniperNew -lt 0.01) {
                                    $errorMessages += "Чувствительность sniperMode ниже допустимого. Минимально допустимая чувствительность - 0.01."
                                } elseif ($sniperNew -gt 2) {
                                    $errorMessages += "Чувствительность sniperMode выше допустимого. Максимально допустимая чувствительность - 2."
                                }
                                if ($errorMessages.Count -gt 0) {
                                    $errorMessages | ForEach-Object { Write-Host $_ }
                                    Write-Host ""
                                    continue
                                }
                                & $xmlExe ed -L -O -u "//arcadeMode/camera/sensitivity" -v " $arcadeNew " $xmlFile
                                & $xmlExe ed -L -O -u "//sniperMode/camera/sensitivity" -v " $sniperNew " $xmlFile
                                Write-Host "Установленна чувствительность arcadeMode: $arcadeNew"
                                Write-Host "Установленна чувствительность sniperMode: $sniperNew"
                                $wasUpdated = $true
                                $customLoopComplete = $true
                                break
                            } while ($true)
                        }
                        default {
                            Write-Host "`nНеверный ввод. Попробуйте снова.`n"
                        }
                    }
                } while (-not $customLoopComplete)
            }
        }

        if (-not $wasUpdated) {
            Write-Host "Пропущено $gameName"
        }
    }

    if ($wasUpdated) {
        Write-Host "`n=== Готово ==="
    }

    if (-not (Confirm-Action "`nХотите настроить снова? (Y/N)")) {
        break
    }
}
