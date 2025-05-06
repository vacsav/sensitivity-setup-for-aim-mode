param (
    [string]$Mode = "backup"
)

$lestaPath = "$env:APPDATA\Lesta\MirTankov\preferences.xml"
$wgPath    = "$env:APPDATA\Wargaming.net\WorldOfTanks\preferences.xml"

$lestaExists = Test-Path $lestaPath
$wgExists    = Test-Path $wgPath

if (-not $lestaExists -and -not $wgExists) {
    Write-Host "Lesta or Wargaming client configuration file not found"
    Write-Host "`nMake sure that the configuration file is present at the path"
    Write-Host "Lesta: lestaPath"
    Write-Host "Wargaming: wgPath"
    pause
    exit
}

Write-Host "`n|=============================================================|"
Write-Host "|                       Sensitivity Setup                     |"
Write-Host "|        Lesta (Mir Tankov) / Wargaming (World of Tanks)      |"
Write-Host "|                       created by shuxue                     |"
Write-Host "|=============================================================|`n"

switch ($Mode) {
    "backup" {
        while ($true) {

            $path = $null

            while (-not $path) {
                Write-Host "`nSelect client for backup:"
                if ($lestaExists) { Write-Host "1. Lesta" }
                if ($wgExists)    { Write-Host "2. Wargaming" }
                Write-Host "0. Exit"

                $choice = Read-Host "Enter a number (1 / 2 / 0)"

                switch ($choice) {
                    "1" {
                        if ($lestaExists) {
                            $path = $lestaPath
                        } else {
                            Write-Host "Lesta file not found."
                        }
                    }
                    "2" {
                        if ($wgExists) {
                            $path = $wgPath
                        } else {
                            Write-Host "Wargaming file not found."
                        }
                    }
                    "0" {
                        while ($true) {
                            $confirm = Read-Host "Are you sure you want to exit? (Y/N)"
                            if ($confirm -match '^[Yy]$') {
                                Write-Host "Exiting..."
                                exit
                            } elseif ($confirm -match '^[Nn]$') {
                                break
                            } else {
                                Write-Host "`nInvalid input. Enter Y or N."
                            }
                        }
                    }
                    default {
                        Write-Host "`nInvalid input. Try again."
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

            Write-Host "`nBackup successfully created:"
            Write-Host (Split-Path $backupFile -Leaf)
        }
    }

    "open" {
        while ($true) {
            $path = $null

            while (-not $path) {
                Write-Host "`nSelect client to open:"
                if ($lestaExists) { Write-Host "1. Lesta" }
                if ($wgExists)    { Write-Host "2. Wargaming" }
                Write-Host "0. Exit"

                $choice = Read-Host "Enter a number (1 / 2 / 0)"

                switch ($choice) {
                    "1" {
                        if ($lestaExists) {
                            $path = $lestaPath
                        } else {
                            Write-Host "Lesta file not found."
                        }
                    }
                    "2" {
                        if ($wgExists) {
                            $path = $wgPath
                        } else {
                            Write-Host "Wargaming file not found."
                        }
                    }
                    "0" {
                        while ($true) {
                            $confirm = Read-Host "Are you sure you want to exit? (Y/N)"
                            if ($confirm -match '^[Yy]$') {
                                Write-Host "Exiting..."
                                exit
                            } elseif ($confirm -match '^[Nn]$') {
                                break
                            } else {
                                Write-Host "`nInvalid input. Enter Y or N."
                            }
                        }
                    }
                    default {
                        Write-Host "`nInvalid input. Try again."
                    }
                }
            }

            if (Test-Path $path) {
                Write-Host "`nOpening in Explorer and Notepad: $path"
                Start-Process explorer.exe -ArgumentList "/select,$path"
                Start-Sleep -Milliseconds 1000
                Start-Process notepad.exe -ArgumentList "`"$path`""
            } else {
                Write-Host "File not found: $path"
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
                    Write-Host "`nSelect client to restore from backup:"
                    if ($lestaExists) { Write-Host "1. Lesta" }
                    if ($wgExists)    { Write-Host "2. Wargaming" }
                    Write-Host "0. Exit"

                    $choice = Read-Host "Enter a number (1 / 2 / 0)"
                    switch ($choice) {
                        "1" {
                            if ($lestaExists) {
                                $path = $lestaPath
                                $backupDir = Join-Path (Split-Path $path) "backups"
                            } else {
                                Write-Host "Lesta file not found."
                            }
                        }
                        "2" {
                            if ($wgExists) {
                                $path = $wgPath
                                $backupDir = Join-Path (Split-Path $path) "backups"
                            } else {
                                Write-Host "Wargaming file not found."
                            }
                        }
                        "0" {
                            while ($true) {
                                $confirm = Read-Host "Are you sure you want to exit? (Y/N)"
                                if ($confirm -match '^[Yy]$') {
                                    Write-Host "Exiting..."
                                    exit
                                } elseif ($confirm -match '^[Nn]$') {
                                    break
                                } else {
                                    Write-Host "`nInvalid input. Enter Y or N."
                                }
                            }
                        }
                        default {
                            Write-Host "`nInvalid input. Try again."
                        }
                    }
                }

                if (-not (Test-Path $backupDir)) {
                    Write-Host "`nNo backups found in:"
                    Write-Host $backupDir
                    Pause
                    continue
                }

                $backups = Get-ChildItem -Path $backupDir -Filter *.xml | Sort-Object LastWriteTime -Descending
                if ($backups.Count -eq 0) {
                    Write-Host "`nNo backups available in:"
                    Write-Host $backupDir
                    Pause
                    continue
                }

                Write-Host "`nAvailable backups:"
                $i = 1
                $backupMap = @{}
                foreach ($file in $backups) {
                    Write-Host "$i - $($file.Name)"
                    $backupMap[$i] = $file
                    $i++
                }

                while ($true) {
                    $sel = Read-Host "`nEnter backup a number to restore (0 = latest, +0 = back to client selection, -0 = exit)"
                    switch ($sel) {
                        "-0" {
                            while ($true) {
                                $confirmExit = Read-Host "Are you sure you want to exit? (Y/N)"
                                if ($confirmExit -match '^[Yy]$') {
                                    Write-Host "Exiting..."
                                    exit
                                } elseif ($confirmExit -match '^[Nn]$') {
                                    Write-Host "Exit canceled, returning to client selection..."
                                    $restartRestore = $true
                                    break
                                } else {
                                    Write-Host "`nInvalid input. Enter Y or N."
                                }
                            }
                            if ($restartRestore) { break }
                        }
                        "+0" {
                            Write-Host "Returning to client selection..."
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
                                    Write-Host "`nRestored from file:"
                                    Write-Host $selectedBackup.Name
                                    break
                                } else {
                                    Write-Host "Invalid number. Try again."
                                }
                            } else {
                                Write-Host "Invalid input. Try again."
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
        Write-Host "Mode '$Mode' is not supported. Exiting..."
        exit
    }
}
