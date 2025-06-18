# Set console window title
$host.UI.RawUI.WindowTitle = "Freevian Downloader"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$OUTDIR = Join-Path $scriptPath "target"
$TRANSDIR = $OUTDIR

if (-not (Test-Path $OUTDIR)) { New-Item -ItemType Directory -Path $OUTDIR | Out-Null }
if (-not (Test-Path $TRANSDIR)) { New-Item -ItemType Directory -Path $TRANSDIR | Out-Null }

$yt_dlp = Join-Path $scriptPath "yt-dlp.exe"
Write-Host "Checking for yt-dlp updates..."
try {
    $updateResult = & $yt_dlp -U 2>&1
    if ($LASTEXITCODE -ne 0 -or $updateResult -match "unable|fail|timeout|connection|SSL|proxy|refused|unreachable|网络|墙|timed out") {
        Write-Host "yt-dlp auto-update failed or network unavailable. Will use current version." -ForegroundColor Yellow
    } else {
        Write-Host "yt-dlp update check completed."
    }
} catch {
    Write-Host "yt-dlp auto-update failed. Check your network connection." -ForegroundColor Yellow
}

# Start WhisperDesktop.exe GUI
Start-Process -FilePath "$scriptPath\WhisperDesktop.exe" -WorkingDirectory $scriptPath

Write-Host "All audio will be saved to: `"$OUTDIR`""
Write-Host ""

function Write-Green($text) {
    Write-Host $text -ForegroundColor Green
}
function Write-Orange($text) {
    Write-Host $text -ForegroundColor DarkYellow
}
function Write-Yellow($text) {
    Write-Host $text -ForegroundColor Yellow
}

function Activate-Window($title) {
    $nircmd = Join-Path $scriptPath "nircmd.exe"
    Start-Process -FilePath $nircmd -ArgumentList @("win", "activate", "ititle", "$title") -WindowStyle Hidden
    Start-Process -FilePath $nircmd -ArgumentList @("win", "settopmost", "ititle", "$title", "1") -WindowStyle Hidden
    Start-Sleep -Seconds 1
    Start-Process -FilePath $nircmd -ArgumentList @("win", "settopmost", "ititle", "$title", "0") -WindowStyle Hidden
}

while ($true) {
    Write-Green "# Enter the video URL to download audio, or type 'v' to copy the latest transcription to clipboard: #"
    Write-Host ""
    Write-Host -NoNewline ">> "
    $VIDEOURL = Read-Host

    if ($VIDEOURL -eq 'v') {
        $files = Get-ChildItem -Path $TRANSDIR -Filter *.txt | Sort-Object LastWriteTime -Descending
        if ($files.Count -eq 0) {
            Write-Host "No .txt files found in '$TRANSDIR'."
            continue
        }
        $NEWFILE = $files[0].FullName.Trim()
        $FILENAME = $files[0].Name

        Write-Host "Trying to read: [$NEWFILE]"

        if (Test-Path -LiteralPath $NEWFILE) {
            Get-Content -LiteralPath $NEWFILE | Set-Clipboard
            Write-Orange "Copied '$FILENAME' content to clipboard."
        } else {
            Write-Host "File does NOT exist: [$NEWFILE]"
            Write-Host "Available .txt files in folder:"
            Get-ChildItem -Path $TRANSDIR -Filter *.txt | ForEach-Object { Write-Host $_.FullName }
        }
        continue
    }

    if ([string]::IsNullOrWhiteSpace($VIDEOURL)) {
        Write-Host "Program terminated."
        pause
        break
    }

    # Download original audio without transcoding
    & $yt_dlp -f bestaudio -P $OUTDIR $VIDEOURL

    # Get the path of the just-downloaded audio file
    $NEWFILE = (& $yt_dlp -f bestaudio -P $OUTDIR --print after_move:filepath $VIDEOURL 2>&1 | Select-Object -First 1).Trim()

    if (-not $NEWFILE -or $NEWFILE -eq "") {
        Write-Host "Download failed or file not found."
        continue
    }

    Write-Host $NEWFILE
    $NEWFILE | Set-Clipboard

    Activate-Window "Freevian Downloader"
    Activate-Window "Transcribe Audio File"

    Write-Host ""
}
