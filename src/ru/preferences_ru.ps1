param (
    [string]$Mode = "backup"
)

$lestaPath = "$env:APPDATA\Lesta\MirTankov\preferences.xml"
$wgPath    = "$env:APPDATA\Wargaming.net\WorldOfTanks\preferences.xml"

$lestaExists = Test-Path $lestaPath
$wgExists    = Test-Path $wgPath

if (-not $lestaExists -and -not $wgExists) {
    Write-Host "�� ������� �� ������ ����������������� ����� ������� Lesta ��� Wargaming"
    Write-Host "`n���������, ��� ���� ������������ ������������ �� ����:"
    Write-Host "Lesta: $lestaPath"
    Write-Host "Wargaming: $wgPath"
    pause
    exit
}

Write-Host "`n|=============================================================|"
Write-Host "|                 ��������� ����������������                  |"
Write-Host "|       Lesta (��� ������) / Wargaming (World of Tanks)       |"
Write-Host "|                       ������� shuxue                        |"
Write-Host "|=============================================================|`n"

switch ($Mode) {
    "backup" {
        while ($true) {

            $path = $null

            while (-not $path) {
                Write-Host "`n�������� ������ ��� �������� ��������� �����:"
                if ($lestaExists) { Write-Host "1. Lesta" }
                if ($wgExists)    { Write-Host "2. Wargaming" }
                Write-Host "0. �����"

                $choice = Read-Host "������� ����� (1 / 2 / 0)"

                switch ($choice) {
                    "1" {
                        if ($lestaExists) {
                            $path = $lestaPath
                        } else {
                            Write-Host "���� ��� Lesta �� ������."
                        }
                    }
                    "2" {
                        if ($wgExists) {
                            $path = $wgPath
                        } else {
                            Write-Host "���� ��� Wargaming �� ������."
                        }
                    }
                    "0" {
                        while ($true) {
                            $confirm = Read-Host "�� ������������� ������ �����? (Y/N)"
                            if ($confirm -match '^[Yy��]$') {
                                Write-Host "�����..."
                                exit
                            } elseif ($confirm -match '^[Nn��]$') {
                                break
                            } else {
                                Write-Host "`n�������� ����. ������� Y ��� N."
                            }
                        }
                    }
                    default {
                        Write-Host "`n�������� ����. ��������� ����."
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

            Write-Host "`n��������� ����� ������� �������:"
            Write-Host (Split-Path $backupFile -Leaf)
        }
    }

    "open" {
        while ($true) {
            $path = $null

            while (-not $path) {
                Write-Host "`n�������� ������ ��� ��������:"
                if ($lestaExists) { Write-Host "1. Lesta" }
                if ($wgExists)    { Write-Host "2. Wargaming" }
                Write-Host "0. �����"

                $choice = Read-Host "������� ����� (1 / 2 / 0)"

                switch ($choice) {
                    "1" {
                        if ($lestaExists) {
                            $path = $lestaPath
                        } else {
                            Write-Host "���� ��� Lesta �� ������."
                        }
                    }
                    "2" {
                        if ($wgExists) {
                            $path = $wgPath
                        } else {
                            Write-Host "���� ��� Wargaming �� ������."
                        }
                    }
                    "0" {
                        while ($true) {
                            $confirm = Read-Host "�� ������������� ������ �����? (Y/N)"
                            if ($confirm -match '^[Yy��]$') {
                                Write-Host "�����..."
                                exit
                            } elseif ($confirm -match '^[Nn��]$') {
                                break
                            } else {
                                Write-Host "`n�������� ����. ������� Y ��� N."
                            }
                        }
                    }
                    default {
                        Write-Host "`n�������� ����. ��������� ����."
                    }
                }
            }

            if (Test-Path $path) {
                Write-Host "`n�������� � ���������� � ��������: $path"
                Start-Process explorer.exe -ArgumentList "/select,$path"
                Start-Sleep -Milliseconds 1000
                Start-Process notepad.exe -ArgumentList "`"$path`""
            } else {
                Write-Host "���� �� ������: $path"
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
                    Write-Host "`n�������� ������ ��� �������������� ��������� �����:"
                    if ($lestaExists) { Write-Host "1. Lesta" }
                    if ($wgExists)    { Write-Host "2. Wargaming" }
                    Write-Host "0. �����"

                    $choice = Read-Host "������� ����� (1 / 2 / 0)"
                    switch ($choice) {
                        "1" {
                            if ($lestaExists) {
                                $path = $lestaPath
                                $backupDir = Join-Path (Split-Path $path) "backups"
                            } else {
                                Write-Host "���� ��� Lesta �� ������."
                            }
                        }
                        "2" {
                            if ($wgExists) {
                                $path = $wgPath
                                $backupDir = Join-Path (Split-Path $path) "backups"
                            } else {
                                Write-Host "���� ��� Wargaming �� ������."
                            }
                        }
                        "0" {
                            while ($true) {
                                $confirm = Read-Host "�� ������������� ������ �����? (Y/N)"
                                if ($confirm -match '^[Yy��]$') {
                                    Write-Host "�����..."
                                    exit
                                } elseif ($confirm -match '^[Nn��]$') {
                                    break
                                } else {
                                    Write-Host "`n�������� ����. ������� Y ��� N."
                                }
                            }
                        }
                        default {
                            Write-Host "`n�������� ����. ��������� ����."
                        }
                    }
                }

                if (-not (Test-Path $backupDir)) {
                    Write-Host "`n��������� ����� �� ������� �:"
                    Write-Host $backupDir
                    Pause
                    continue
                }

                $backups = Get-ChildItem -Path $backupDir -Filter *.xml | Sort-Object LastWriteTime -Descending
                if ($backups.Count -eq 0) {
                    Write-Host "`n��� ��������� ��������� ����� �:"
                    Write-Host $backupDir
                    Pause
                    continue
                }

                Write-Host "`n��������� ��������� �����:"
                $i = 1
                $backupMap = @{}
                foreach ($file in $backups) {
                    Write-Host "$i - $($file.Name)"
                    $backupMap[$i] = $file
                    $i++
                }

                while ($true) {
                    $sel = Read-Host "`n������� ����� ��������� ����� ��� �������������� (0 = ���������, +0 = ����� � ������ �������, -0 = �����)"
                    switch ($sel) {
                        "-0" {
                            while ($true) {
                                $confirmExit = Read-Host "�� ������������� ������ �����? (Y/N)"
                                if ($confirmExit -match '^[Yy��]$') {
                                    Write-Host "�����..."
                                    exit
                                } elseif ($confirmExit -match '^[Nn��]$') {
                                    Write-Host "����� �������, ������� � ������ �������..."
                                    $restartRestore = $true
                                    break
                                } else {
                                    Write-Host "`n�������� ����. ������� Y ��� N."
                                }
                            }
                            if ($restartRestore) { break }
                        }
                        "+0" {
                            Write-Host "������� � ������ �������..."
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
                                    Write-Host "`n�������������� ��������� �� �����:"
                                    Write-Host $selectedBackup.Name
                                    break
                                } else {
                                    Write-Host "�������� �����. ��������� ����."
                                }
                            } else {
                                Write-Host "�������� ����. ��������� ����."
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
        Write-Host "����� '$Mode' �� ��������������. �����..."
        exit
    }
}
