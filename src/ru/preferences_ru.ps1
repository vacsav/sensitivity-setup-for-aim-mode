param (
    [string]$Mode = "backup"
)

$lestaPath = "$env:APPDATA\Lesta\MirTankov\preferences.xml"
$wgPath    = "$env:APPDATA\Wargaming.net\WorldOfTanks\preferences.xml"

$lestaExists = Test-Path $lestaPath
$wgExists    = Test-Path $wgPath

if (-not $lestaExists -and -not $wgExists) {
    Write-Host "Не найдено ни одного конфигурационного файла клиента Lesta или Wargaming"
    Write-Host "`nУбедитесь, что файл конфигурации присутствует по пути:"
    Write-Host "Lesta: $lestaPath"
    Write-Host "Wargaming: $wgPath"
    pause
    exit
}

Write-Host "`n|=============================================================|"
Write-Host "|                 Настройка чувствительности                  |"
Write-Host "|       Lesta (Мир Танков) / Wargaming (World of Tanks)       |"
Write-Host "|                       создано shuxue                        |"
Write-Host "|=============================================================|`n"

switch ($Mode) {
    "backup" {
        while ($true) {

            $path = $null

            while (-not $path) {
                Write-Host "`nВыберите клиент для создания резервной копии:"
                if ($lestaExists) { Write-Host "1. Lesta" }
                if ($wgExists)    { Write-Host "2. Wargaming" }
                Write-Host "0. Выход"

                $choice = Read-Host "Введите номер (1 / 2 / 0)"

                switch ($choice) {
                    "1" {
                        if ($lestaExists) {
                            $path = $lestaPath
                        } else {
                            Write-Host "Файл для Lesta не найден."
                        }
                    }
                    "2" {
                        if ($wgExists) {
                            $path = $wgPath
                        } else {
                            Write-Host "Файл для Wargaming не найден."
                        }
                    }
                    "0" {
                        while ($true) {
                            $confirm = Read-Host "Вы действительно хотите выйти? (Y/N)"
                            if ($confirm -match '^[YyНн]$') {
                                Write-Host "Выход..."
                                exit
                            } elseif ($confirm -match '^[NnТт]$') {
                                break
                            } else {
                                Write-Host "`nНеверный ввод. Введите Y или N."
                            }
                        }
                    }
                    default {
                        Write-Host "`nНеверный ввод. Повторите ввод."
                    }
                }
            }

            $backupDir = Join-Path (Split-Path $path) "backups"
            if (-not (Test-Path $backupDir)) {
                New-Item -Path $backupDir -ItemType Directory | Out-Null
            }

            $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
            $backupFile = Join-Path $backupDir "preferences_backup_$timestamp.xml"

            Copy-Item -Path $path -Destination $backupFile -Force

            Write-Host "`nРезервная копия успешно создана:"
            Write-Host (Split-Path $backupFile -Leaf)
        }
    }

    "open" {
        while ($true) {
            $path = $null

            while (-not $path) {
                Write-Host "`nВыберите клиент для открытия:"
                if ($lestaExists) { Write-Host "1. Lesta" }
                if ($wgExists)    { Write-Host "2. Wargaming" }
                Write-Host "0. Выход"

                $choice = Read-Host "Введите номер (1 / 2 / 0)"

                switch ($choice) {
                    "1" {
                        if ($lestaExists) {
                            $path = $lestaPath
                        } else {
                            Write-Host "Файл для Lesta не найден."
                        }
                    }
                    "2" {
                        if ($wgExists) {
                            $path = $wgPath
                        } else {
                            Write-Host "Файл для Wargaming не найден."
                        }
                    }
                    "0" {
                        while ($true) {
                            $confirm = Read-Host "Вы действительно хотите выйти? (Y/N)"
                            if ($confirm -match '^[YyНн]$') {
                                Write-Host "Выход..."
                                exit
                            } elseif ($confirm -match '^[NnТт]$') {
                                break
                            } else {
                                Write-Host "`nНеверный ввод. Введите Y или N."
                            }
                        }
                    }
                    default {
                        Write-Host "`nНеверный ввод. Повторите ввод."
                    }
                }
            }

            if (Test-Path $path) {
                Write-Host "`nОткрытие в проводнике и блокноте: $path"
                Start-Process explorer.exe -ArgumentList "/select,$path"
                Start-Sleep -Milliseconds 1000
                Start-Process notepad.exe -ArgumentList "`"$path`""
            } else {
                Write-Host "Файл не найден: $path"
            }
        }
    }

    "restore" {
        while ($true) {
            $restartRestore = $false

            while ($true) {
                $path = $null
                $backupDir = $null

                while (-not $path) {
                    Write-Host "`nВыберите клиент для восстановления резервной копии:"
                    if ($lestaExists) { Write-Host "1. Lesta" }
                    if ($wgExists)    { Write-Host "2. Wargaming" }
                    Write-Host "0. Выход"

                    $choice = Read-Host "Введите номер (1 / 2 / 0)"
                    switch ($choice) {
                        "1" {
                            if ($lestaExists) {
                                $path = $lestaPath
                                $backupDir = Join-Path (Split-Path $path) "backups"
                            } else {
                                Write-Host "Файл для Lesta не найден."
                            }
                        }
                        "2" {
                            if ($wgExists) {
                                $path = $wgPath
                                $backupDir = Join-Path (Split-Path $path) "backups"
                            } else {
                                Write-Host "Файл для Wargaming не найден."
                            }
                        }
                        "0" {
                            while ($true) {
                                $confirm = Read-Host "Вы действительно хотите выйти? (Y/N)"
                                if ($confirm -match '^[YyНн]$') {
                                    Write-Host "Выход..."
                                    exit
                                } elseif ($confirm -match '^[NnТт]$') {
                                    break
                                } else {
                                    Write-Host "`nНеверный ввод. Введите Y или N."
                                }
                            }
                        }
                        default {
                            Write-Host "`nНеверный ввод. Повторите ввод."
                        }
                    }
                }

                if (-not (Test-Path $backupDir)) {
                    Write-Host "`nРезервные копии не найдены в:"
                    Write-Host $backupDir
                    Pause
                    continue
                }

                $backups = Get-ChildItem -Path $backupDir -Filter *.xml | Sort-Object LastWriteTime -Descending
                if ($backups.Count -eq 0) {
                    Write-Host "`nНет доступных резервных копий в:"
                    Write-Host $backupDir
                    Pause
                    continue
                }

                Write-Host "`nДоступные резервные копии:"
                $i = 1
                $backupMap = @{}
                foreach ($file in $backups) {
                    Write-Host "$i - $($file.Name)"
                    $backupMap[$i] = $file
                    $i++
                }

                while ($true) {
                    $sel = Read-Host "`nВведите номер резервной копии для восстановления (0 = последняя, +0 = назад к выбору клиента, -0 = выход)"
                    switch ($sel) {
                        "-0" {
                            while ($true) {
                                $confirmExit = Read-Host "Вы действительно хотите выйти? (Y/N)"
                                if ($confirmExit -match '^[YyНн]$') {
                                    Write-Host "Выход..."
                                    exit
                                } elseif ($confirmExit -match '^[NnТт]$') {
                                    Write-Host "Выход отменен, возврат к выбору клиента..."
                                    $restartRestore = $true
                                    break
                                } else {
                                    Write-Host "`nНеверный ввод. Введите Y или N."
                                }
                            }
                            if ($restartRestore) { break }
                        }
                        "+0" {
                            Write-Host "Возврат к выбору клиента..."
                            $restartRestore = $true
                            break
                        }
                        default {
                            if ($sel -match '^\d+$') {
                                $index = [int]$sel
                                if ($index -eq 0) { $index = 1 }
                                if ($backupMap.ContainsKey($index)) {
                                    $selectedBackup = $backupMap[$index]
                                    Copy-Item -Path $selectedBackup.FullName -Destination $path -Force
                                    Write-Host "`nВосстановление завершено из файла:"
                                    Write-Host $selectedBackup.Name
                                    break
                                } else {
                                    Write-Host "Неверный номер. Повторите ввод."
                                }
                            } else {
                                Write-Host "Неверный ввод. Повторите ввод."
                            }
                        }
                    }
                    if ($restartRestore) { break }
                }

                if (-not $restartRestore) { break }
            }
        }
    }

    default {
        Write-Host "Режим '$Mode' не поддерживается. Выход..."
        exit
    }
}
