# Set console window title
$host.UI.RawUI.WindowTitle = "🚀 Freevian Transcriber"

# --- Script & Tools Setup ---
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$OUTDIR = Join-Path $scriptPath "target"
if (-not (Test-Path $OUTDIR)) { New-Item -ItemType Directory -Path $OUTDIR | Out-Null }

$yt_dlp = Join-Path $scriptPath "yt-dlp.exe"
$transcribe_cli = Join-Path $scriptPath "TranscribeCS\TranscribeCS.exe"

# --- Load Configuration ---
$configFile = Join-Path $scriptPath "config.json"
if (-not (Test-Path $configFile)) {
    Write-Host "❌ FATAL: config.json not found!" -ForegroundColor Red
    pause
    exit
}
$config = Get-Content $configFile | ConvertFrom-Json

# Check if model file exists
$modelFullPath = Join-Path $scriptPath $config.model_path
if (-not (Test-Path $modelFullPath)) {
    Write-Host "❌ FATAL: Model file not found at $($config.model_path)" -ForegroundColor Red
    Write-Host "Please check your model_path in config.json or download the model."
    pause
    exit
}

# --- yt-dlp update check ---
Write-Host "⚙️  Checking for yt-dlp updates..." -ForegroundColor Cyan
try {
    $updateJob = Start-Job -ScriptBlock { & $using:yt_dlp -U }
    if (Wait-Job $updateJob -Timeout 5) {
        Receive-Job $updateJob | Out-Null
        Write-Host "✅ yt-dlp update check complete."
    } else {
        Stop-Job $updateJob
        Write-Host "⚠️  yt-dlp update check timed out. Using current version." -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ yt-dlp auto-update failed. Check your network. Using current version." -ForegroundColor Yellow
}
Remove-Job * | Out-Null


# --- Functions ---
function Write-Green($text) {
    Write-Host $text -ForegroundColor Green
}
function Write-Yellow($text) {
    Write-Host $text -ForegroundColor Yellow
}
function Write-Cyan($text) {
    Write-Host $text -ForegroundColor Cyan
}

# --- Main Loop ---
while ($true) {
    Write-Green "# 👉 Enter the video URL to transcribe, or type 'v' to copy 📋, or 'l' to change language 🌐: #"
    Write-Host ""
    Write-Host -NoNewline ">> "
    $VIDEOURL = Read-Host

    if ($VIDEOURL -eq 'v') {
        $files = Get-ChildItem -Path $OUTDIR -Filter *.txt | Sort-Object LastWriteTime -Descending
        if ($files.Count -eq 0) {
            Write-Yellow "⚠️  No .txt files found in '$OUTDIR'."
            continue
        }
        $NEWFILE = $files[0].FullName.Trim()
        Get-Content -LiteralPath $NEWFILE | Set-Clipboard
        Write-Yellow "📋 Copied content of '$($files[0].Name)' to clipboard."
        continue
    }

    if ($VIDEOURL -eq 'l') {
        Write-Cyan "🌐 Current language is '$($config.language)' ($($config.language_list.($config.language)))."
        Write-Host "Available languages:"
        Write-Host ""
        
        # Simple and reliable approach: iterate through language_list directly
        $config.language_list.PSObject.Properties | Sort-Object Name | ForEach-Object {
            Write-Host "  [$($_.Name)]  $($_.Value)"
        }
        
        Write-Host ""
        Write-Host -NoNewline "Enter new language code (or press Enter to cancel): "
        $newLang = Read-Host

        if (-not [string]::IsNullOrWhiteSpace($newLang)) {
            if ($config.language_list.PSObject.Properties.Name -contains $newLang) {
                $config.language = $newLang
                $config | ConvertTo-Json -Depth 5 | Set-Content $configFile
                Write-Green "✅ Language successfully changed to '$newLang' ($($config.language_list.$newLang))."
            } else {
                Write-Host "❌ Invalid language code '$newLang'." -ForegroundColor Red
            }
        }
        Write-Host ""
        continue
    }

    if ([string]::IsNullOrWhiteSpace($VIDEOURL)) {
        Write-Host "👋 Program terminated."
        pause
        break
    }

    # Step 1: Download Audio
    Write-Cyan "⬇️  Step 1: Downloading audio from URL (playlist download is disabled)..."
    & $yt_dlp -f bestaudio --no-playlist --no-warnings -P $OUTDIR $VIDEOURL
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Audio download failed. Please check the URL and your network." -ForegroundColor Red
        continue
    }

    # Get the file path by finding the newest audio/video file in the target directory
    $mediaExtensions = @("*.webm", "*.mp4", "*.mp3", "*.wav", "*.m4a", "*.ogg", "*.flac", "*.aac")
    $mediaFiles = @()
    foreach ($ext in $mediaExtensions) {
        $mediaFiles += Get-ChildItem -Path $OUTDIR -Filter $ext -ErrorAction SilentlyContinue
    }
    $latestFile = $mediaFiles | Sort-Object CreationTime -Descending | Select-Object -First 1
    if (-not $latestFile) {
        Write-Host "❌ Error: Could not find any downloaded audio/video file in '$OUTDIR'." -ForegroundColor Red
        continue
    }
    $audioFilePath = $latestFile.FullName
    Write-Green "✅ Audio downloaded successfully: `"$audioFilePath`""

    # Step 2: Transcribe Audio
    Write-Cyan "🎤 Step 2: Starting transcription..."
    
    $arguments = @(
        "--model", $modelFullPath,
        "--language", $config.language,
        "--output-txt",
        "--no-timestamps",
        $audioFilePath
    )

    if ($config.gpu_index -ne $null) {
        $arguments += "--gpu", $config.gpu_index
    }

    & $transcribe_cli $arguments

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Transcription failed with exit code $LASTEXITCODE." -ForegroundColor Red
    } else {
        $txtPath = [System.IO.Path]::ChangeExtension($audioFilePath, ".txt")
        Write-Green "✨ Transcription successful! Output saved to: `"$txtPath`""
    }
    Write-Host ""
}
