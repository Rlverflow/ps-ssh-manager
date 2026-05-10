# --- CONFIGURATION ---
$ScriptDir  = $PSScriptRoot
$ConfigFile = Join-Path $ScriptDir "servers.json"
$LogFolder  = Join-Path $ScriptDir "logs"
$LogFile    = Join-Path $LogFolder "manager.log"
$Version    = "1.5.4"
$DevTeam    = "Rlverflow"
$Socials    = "github.com/Rlverflow"

# --- 1. INITIALIZATION ---
if (-not (Test-Path $LogFolder)) { New-Item -Path $LogFolder -ItemType Directory | Out-Null }
if (-not (Test-Path $ConfigFile)) { "[]" | Set-Content $ConfigFile }

# --- 2. CORE FUNCTIONS ---
function Write-Log {
    param($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$Timestamp] $Message" | Out-File -FilePath $LogFile -Append
}

function Load-Servers {
    $content = Get-Content $ConfigFile -Raw
    if ([string]::IsNullOrWhiteSpace($content)) { return @() }
    try {
        $data = $content | ConvertFrom-Json
        return @($data) 
    } catch {
        Write-Log "CRITICAL: Config corruption detected."
        return @()
    }
}

function Save-Servers {
    param($List)
    $List | ConvertTo-Json -Depth 5 | Set-Content $ConfigFile
}

# --- 3. MAIN LOOP ---
while ($true) {
    Clear-Host
    $servers = @(Load-Servers)
    
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "   SSH MANAGER V$Version"        -ForegroundColor Cyan
    Write-Host "   By $DevTeam"                  -ForegroundColor Gray
    Write-Host "================================" -ForegroundColor Cyan

    if ($servers.Count -eq 0) {
        Write-Host " [!] No servers found. Press [a] to add." -ForegroundColor Yellow
    } else {
        for ($i = 0; $i -lt $servers.Count; $i++) {
            $displayIndex = $i + 1
            $osIcon = if ($servers[$i].ostype -eq "Windows") { "[W]" } else { "[L]" }
            Write-Host "($displayIndex) " -NoNewline -ForegroundColor White
            Write-Host "$osIcon $($servers[$i].name) ($($servers[$i].ip))" -ForegroundColor Green
        }
    }

    Write-Host "--------------------------------"
    Write-Host "[a] Add   [r] Remove   [l] Logs   [v] Info   [q] Quit"
    
    $rawInput = Read-Host "`nSelect Number or Option"
    if ($null -eq $rawInput) { continue }
    $choice = $rawInput.Trim().ToLower()

    # --- 4. LOGIC: NUMERIC CONNECTION ---
    if ($choice -match '^\d+$') {
        $idx = [int]$choice - 1
        if ($idx -ge 0 -and $idx -lt $servers.Count) {
            $t = $servers[$idx]
            Write-Log "CONNECT START: $($t.name) ($($t.ip))"
            
            Write-Host "`n>>> Connecting to $($t.name)..." -ForegroundColor Cyan
            Write-Host ">>> Port: 22 | OS: $($t.ostype)" -ForegroundColor Gray
            
            # Added Timeout safety so a dead server doesn't hang the script
            $sshTarget = "$($t.user)@$($t.ip)"
            ssh -o ConnectTimeout=10 $sshTarget

            if ($LASTEXITCODE -ne 0) {
                Write-Host "`n[!] SSH returned error code $LASTEXITCODE" -ForegroundColor Yellow
                Write-Log "CONNECT FAIL: $($t.name) (Code: $LASTEXITCODE)"
            } else {
                Write-Log "CONNECT END: $($t.name) session closed."
            }
            Read-Host "`nPress Enter to return to menu"
        } else {
            Write-Host "Invalid number: $choice" -ForegroundColor Red ; Start-Sleep 1
        }
        continue
    }

    # --- 5. LOGIC: COMMAND SWITCH ---
    switch ($choice) {
        'q' { exit }
        
        'v' { 
            Clear-Host
            Write-Host "================================" -ForegroundColor Cyan
            Write-Host "   ABOUT RLVERFLOW MANAGER      " -ForegroundColor Cyan
            Write-Host "================================" -ForegroundColor Cyan
            Write-Host "Version: $Version`nTeam: $DevTeam`nSocials: $Socials" -ForegroundColor Magenta
            Read-Host "`nEnter to return"
        }

        'l' {
            Clear-Host
            Write-Host "--- RECENT ACTIVITY ---" -ForegroundColor Yellow
            if (Test-Path $LogFile) { Get-Content $LogFile -Tail 20 }
            else { Write-Host "No logs found." }
            Read-Host "`nEnter to return"
        }

        'a' {
            Clear-Host
            Write-Host "--- ADD NEW SERVER ---" -ForegroundColor Cyan
            
            # OS Selection (The standard if/else fix)
            Write-Host "Step 1: Select OS Type"
            Write-Host "[1] Linux (Default)"
            Write-Host "[2] Windows"
            $osIn = Read-Host "Choice"
            if ($osIn -eq "2") { $ost = "Windows" } else { $ost = "Linux" }

            Write-Host "`nStep 2: Server Credentials"
            $name = (Read-Host "Nickname").Trim()
            $ip   = (Read-Host "IP Address").Trim()
            $user = (Read-Host "Username").Trim()

            if ($name -and $ip) {
                $newObj = [PSCustomObject]@{
                    name   = $name
                    ip     = $ip
                    user   = $user
                    ostype = $ost
                    id     = [guid]::NewGuid().ToString() # Guid prevents delete-bugs
                }
                Save-Servers -List (@($servers) + $newObj)
                Write-Log "ADDED: $name ($ip)"
                Write-Host "Saved successfully!" -ForegroundColor Green ; Start-Sleep 1
            } else {
                Write-Host "Aborted: Name and IP are required." -ForegroundColor Red ; Start-Sleep 2
            }
        }

        'r' {
            $num = Read-Host "Enter Number to remove"
            if ($num -match '^\d+$') {
                $idx = [int]$num - 1
                if ($idx -ge 0 -and $idx -lt $servers.Count) {
                    $targetID = $servers[$idx].id
                    $targetName = $servers[$idx].name
                    $newList = @($servers | Where-Object { $_.id -ne $targetID })
                    Save-Servers -List $newList
                    Write-Log "REMOVED: $targetName"
                    Write-Host "Removed $targetName." -ForegroundColor Yellow ; Start-Sleep 1
                }
            }
        }

        Default {
            if ($choice) { 
                Write-Host "Error: '$choice' is not a valid command." -ForegroundColor Red 
                Start-Sleep 1 
            }
        }
    }
}