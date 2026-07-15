<#
.SYNOPSIS
  Chroma Terminal Theme Installer for Windows

.DESCRIPTION
  Detects Windows Terminal, Hyper, Alacritty, Warp terminals and applies Chroma themes.
  Optionally installs JetBrainsMono Nerd Font, oh-my-posh prompt, and CLI tools via winget.

.PARAMETER Theme
  Theme name to apply (spectrum, octagon, ristretto, machine, classic, zen, protorium, relaxed, amber)

.PARAMETER Font
  Install JetBrainsMono Nerd Font

.PARAMETER Prompt
  Install oh-my-posh prompt with Chroma theme config

.PARAMETER Tools
  Install CLI tools via winget

.PARAMETER All
  Install everything (font, prompt, tools)

.PARAMETER ListThemes
  Show all available themes

.PARAMETER Preview
  Show color preview of selected theme

.PARAMETER Help
  Show this help message

.EXAMPLE
  .\bootstrap.ps1
  .\bootstrap.ps1 -Theme octagon
  .\bootstrap.ps1 -Theme spectrum -Font -Prompt
  .\bootstrap.ps1 -All
#>

param(
  [string]$Theme = "",
  [switch]$Font,
  [switch]$Prompt,
  [switch]$Tools,
  [switch]$All,
  [switch]$ListThemes,
  [switch]$Preview,
  [switch]$Help
)

# Requirements
$requiredPSVersion = 5.1
if ($PSVersionTable.PSVersion.Major -lt $requiredPSVersion) {
  Write-Error "PowerShell $requiredPSVersion or higher is required."
  exit 1
}

# ──────────────────────────────────────────────
# Theme definitions
# ──────────────────────────────────────────────
$script:Themes = @{
  "spectrum" = @{
    Display     = "Chroma Spectrum"
    Background  = "#2D2A2E"
    Foreground  = "#FCFCFA"
    Black       = "#2D2A2E"
    Red         = "#FF6188"
    Green       = "#A9DC76"
    Yellow      = "#FFD866"
    Blue        = "#78DCE8"
    Magenta     = "#AB9DF2"
    Cyan        = "#78DCE8"
    White       = "#FCFCFA"
    BrightBlack = "#1A1A1C"
    Comment     = "#69676C"
  }
  "octagon" = @{
    Display     = "Filter Octagon"
    Background  = "#2D2A2E"
    Foreground  = "#FCFCFA"
    Black       = "#2D2A2E"
    Red         = "#FF6188"
    Green       = "#A9DC76"
    Yellow      = "#FFD866"
    Blue        = "#78DCE8"
    Magenta     = "#FC9867"
    Cyan        = "#78DCE8"
    White       = "#FCFCFA"
    BrightBlack = "#1A1A1C"
    Comment     = "#69676C"
  }
  "ristretto" = @{
    Display     = "Filter Ristretto"
    Background  = "#2B2A2B"
    Foreground  = "#FCFCFA"
    Black       = "#2B2A2B"
    Red         = "#E36A6A"
    Green       = "#98C379"
    Yellow      = "#E5C07B"
    Blue        = "#7CB7D9"
    Magenta     = "#C678DD"
    Cyan        = "#56B6C2"
    White       = "#FCFCFA"
    BrightBlack = "#1A1A1C"
    Comment     = "#5C5C5C"
  }
  "machine" = @{
    Display     = "Filter Machine"
    Background  = "#2D2A2E"
    Foreground  = "#FCFCFA"
    Black       = "#2D2A2E"
    Red         = "#FF6188"
    Green       = "#A9DC76"
    Yellow      = "#FFD866"
    Blue        = "#78DCE8"
    Magenta     = "#AB9DF2"
    Cyan        = "#FC9867"
    White       = "#FCFCFA"
    BrightBlack = "#1A1A1C"
    Comment     = "#69676C"
  }
  "classic" = @{
    Display     = "Monokai Classic"
    Background  = "#272822"
    Foreground  = "#F8F8F2"
    Black       = "#272822"
    Red         = "#F92672"
    Green       = "#A6E22E"
    Yellow      = "#E6DB74"
    Blue        = "#66D9EF"
    Magenta     = "#AE81FF"
    Cyan        = "#A1EFE4"
    White       = "#F8F8F2"
    BrightBlack = "#1B1C18"
    Comment     = "#75715E"
  }
  "zen" = @{
    Display     = "Filter Zen"
    Background  = "#2D2A2E"
    Foreground  = "#FCFCFA"
    Black       = "#2D2A2E"
    Red         = "#FF6188"
    Green       = "#A9DC76"
    Yellow      = "#FFD866"
    Blue        = "#78DCE8"
    Magenta     = "#AB9DF2"
    Cyan        = "#FC9867"
    White       = "#FCFCFA"
    BrightBlack = "#1A1A1C"
    Comment     = "#69676C"
  }
  "protorium" = @{
    Display     = "Filter Protorium"
    Background  = "#2D2A2E"
    Foreground  = "#FCFCFA"
    Black       = "#2D2A2E"
    Red         = "#FF6188"
    Green       = "#A9DC76"
    Yellow      = "#FFD866"
    Blue        = "#78DCE8"
    Magenta     = "#AB9DF2"
    Cyan        = "#FC9867"
    White       = "#FCFCFA"
    BrightBlack = "#1A1A1C"
    Comment     = "#69676C"
  }
  "relaxed" = @{
    Display     = "Filter Relaxed"
    Background  = "#3A3A3A"
    Foreground  = "#F8F8F2"
    Black       = "#3A3A3A"
    Red         = "#E06C75"
    Green       = "#98C379"
    Yellow      = "#E5C07B"
    Blue        = "#61AFEF"
    Magenta     = "#C678DD"
    Cyan        = "#56B6C2"
    White       = "#F8F8F2"
    BrightBlack = "#282828"
    Comment     = "#5C6370"
  }
  "amber" = @{
    Display     = "Filter Amber"
    Background  = "#2D2A2E"
    Foreground  = "#FCFCFA"
    Black       = "#2D2A2E"
    Red         = "#E36A6A"
    Green       = "#A9DC76"
    Yellow      = "#E5C07B"
    Blue        = "#78DCE8"
    Magenta     = "#FC9867"
    Cyan        = "#56B6C2"
    White       = "#FCFCFA"
    BrightBlack = "#1A1A1C"
    Comment     = "#5C6370"
  }
}

$script:ThemeNames = @(
  "spectrum", "octagon", "ristretto", "machine",
  "classic", "zen", "protorium", "relaxed", "amber"
)

# ──────────────────────────────────────────────
# Helper functions
# ──────────────────────────────────────────────
function Write-Info  { Write-Host "  ⓘ $($args -join ' ')" -ForegroundColor Blue }
function Write-Ok    { Write-Host "  ✔ $($args -join ' ')" -ForegroundColor Green }
function Write-Warn  { Write-Host "  ⚠ $($args -join ' ')" -ForegroundColor Yellow }
function Write-Error { Write-Host "  ✘ $($args -join ' ')" -ForegroundColor Red }
function Write-Step  { Write-Host "`n▸ $($args -join ' ')" -ForegroundColor Cyan }
function Write-Title { Write-Host "`n  $($args -join ' ')" -ForegroundColor White }

function Test-Command($cmd) {
  try { Get-Command $cmd -ErrorAction Stop | Out-Null; return $true }
  catch { return $false }
}

function Confirm-Action($prompt) {
  $read = Read-Host "$prompt [y/N]"
  return $read -match '^[Yy]'
}

# ──────────────────────────────────────────────
# Terminal detection
# ──────────────────────────────────────────────
function Get-DetectedTerminals {
  $detected = @()

  # Windows Terminal
  if (Test-Command "wt") {
    $detected += "windows-terminal"
    Write-Ok "Windows Terminal detected"
  }

  # Hyper
  $hyperPath = "$env:LOCALAPPDATA\hyper\hyper.exe"
  $hyperPath2 = "$env:ProgramFiles\hyper\hyper.exe"
  if ((Test-Command "hyper") -or (Test-Path $hyperPath) -or (Test-Path $hyperPath2)) {
    $detected += "hyper"
    Write-Ok "Hyper detected"
  }

  # Alacritty
  $alacrittyPath = "$env:LOCALAPPDATA\alacritty\alacritty.exe"
  $alacrittyPath2 = "$env:ProgramFiles\Alacritty\alacritty.exe"
  if ((Test-Command "alacritty") -or (Test-Path $alacrittyPath) -or (Test-Path $alacrittyPath2)) {
    $detected += "alacritty"
    Write-Ok "Alacritty detected"
  }

  # Warp
  $warpPath = "$env:LOCALAPPDATA\Warp\warp.exe"
  $warpPath2 = "$env:ProgramFiles\Warp\warp.exe"
  if (Test-Path $warpPath) -or (Test-Path $warpPath2) {
    $detected += "warp"
    Write-Ok "Warp detected"
  }

  return $detected
}

# ──────────────────────────────────────────────
# Theme application
# ──────────────────────────────────────────────
function Apply-WindowsTerminal($themeName) {
  $colors = $script:Themes[$themeName]
  $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
  $settingsPathPreview = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"

  $targetPath = $null
  if (Test-Path $settingsPath) { $targetPath = $settingsPath }
  elseif (Test-Path $settingsPathPreview) { $targetPath = $settingsPathPreview }

  if (-not $targetPath) {
    Write-Warn "Windows Terminal settings.json not found. Creating a theme scheme file instead."
    # Create a scheme file that can be manually imported
    $schemesDir = "$env:USERPROFILE\.config\chroma-terminal"
    New-Item -ItemType Directory -Force -Path $schemesDir | Out-Null
    $schemeFile = Join-Path $schemesDir "Chroma-$themeName.json"
    $schemeJson = @{
      name = $colors.Display
      background = $colors.Background
      foreground = $colors.Foreground
      cursorColor = $colors.Foreground
      selectionBackground = $colors.Comment
      black = $colors.Black
      red = $colors.Red
      green = $colors.Green
      yellow = $colors.Yellow
      blue = $colors.Blue
      magenta = $colors.Magenta
      cyan = $colors.Cyan
      white = $colors.White
      brightBlack = $colors.BrightBlack
      brightRed = $colors.Red
      brightGreen = $colors.Green
      brightYellow = $colors.Yellow
      brightBlue = $colors.Blue
      brightMagenta = $colors.Magenta
      brightCyan = $colors.Cyan
      brightWhite = $colors.White
    } | ConvertTo-Json -Compress

    Set-Content -Path $schemeFile -Value $schemeJson -Encoding UTF8
    Write-Ok "Created theme scheme file: $schemeFile"
    Write-Warn "Open Windows Terminal Settings (Ctrl+,) and add this scheme in the 'Schemes' section."
    return
  }

  try {
    $settings = Get-Content $targetPath -Raw -Encoding UTF8 | ConvertFrom-Json

    # Check if scheme already exists
    $existingScheme = $settings.schemes | Where-Object { $_.name -eq $colors.Display }
    if ($existingScheme) {
      Write-Ok "Scheme '$( $colors.Display )' already exists in Windows Terminal"
    } else {
      $newScheme = @{
        name = $colors.Display
        background = $colors.Background
        foreground = $colors.Foreground
        cursorColor = $colors.Foreground
        selectionBackground = $colors.Comment
        black = $colors.Black
        red = $colors.Red
        green = $colors.Green
        yellow = $colors.Yellow
        blue = $colors.Blue
        magenta = $colors.Magenta
        cyan = $colors.Cyan
        white = $colors.White
        brightBlack = $colors.BrightBlack
        brightRed = $colors.Red
        brightGreen = $colors.Green
        brightYellow = $colors.Yellow
        brightBlue = $colors.Blue
        brightMagenta = $colors.Magenta
        brightCyan = $colors.Cyan
        brightWhite = $colors.White
      }
      $settings.schemes += $newScheme
      Write-Ok "Added scheme '$( $colors.Display )' to Windows Terminal"
    }

    # Apply to all profiles
    $settings.profiles.list | ForEach-Object {
      $_.colorScheme = $colors.Display
    }

    $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $targetPath -Encoding UTF8
    Write-Ok "Applied '$( $colors.Display )' to all Windows Terminal profiles"
  }
  catch {
    Write-Warn "Could not auto-configure Windows Terminal: $($_.Exception.Message)"
    Write-Warn "You can manually add the scheme from the generated files."
  }
}

function Apply-Hyper($themeName) {
  $colors = $script:Themes[$themeName]
  $hyperFile = "$env:USERPROFILE\.hyper.js"

  if (-not (Test-Path $hyperFile)) {
    Write-Warn "Hyper not configured (no .hyper.js). Skipping."
    return
  }

  $backup = "$hyperFile.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
  Copy-Item $hyperFile $backup
  Write-Info "Backed up .hyper.js → $backup"

  try {
    $content = Get-Content $hyperFile -Raw -Encoding UTF8

    # Build colors object
    $colorsObj = @{
      black   = $colors.Black
      red     = $colors.Red
      green   = $colors.Green
      yellow  = $colors.Yellow
      blue    = $colors.Blue
      magenta = $colors.Magenta
      cyan    = $colors.Cyan
      white   = $colors.White
      lightBlack   = $colors.BrightBlack
      lightRed     = $colors.Red
      lightGreen   = $colors.Green
      lightYellow  = $colors.Yellow
      lightBlue    = $colors.Blue
      lightMagenta = $colors.Magenta
      lightCyan    = $colors.Cyan
      lightWhite   = $colors.White
    }
    $colorsJson = $colorsObj | ConvertTo-Json -Compress

    # Replace colors section in .hyper.js
    $content = $content -replace 'colors:\s*\{[^}]+\}', "colors: $colorsJson"

    Set-Content $hyperFile $content -Encoding UTF8
    Write-Ok "Applied '$($colors.Display)' to Hyper"
  }
  catch {
    Write-Warn "Could not update .hyper.js: $($_.Exception.Message)"
  }
}

function Apply-Alacritty($themeName) {
  $colors = $script:Themes[$themeName]
  $configDir = "$env:APPDATA\alacritty"
  $configFile = "$configDir\alacritty.toml"

  New-Item -ItemType Directory -Force -Path $configDir | Out-Null

  $themeBlock = @"
# --- Chroma Theme: $($colors.Display) ---
[colors.primary]
background = "$($colors.Background)"
foreground = "$($colors.Foreground)"

[colors.cursor]
cursor = "$($colors.Foreground)"
text = "$($colors.Background)"

[colors.selection]
background = "$($colors.Comment)"
text = "$($colors.Foreground)"

[colors.normal]
black = "$($colors.Black)"
red = "$($colors.Red)"
green = "$($colors.Green)"
yellow = "$($colors.Yellow)"
blue = "$($colors.Blue)"
magenta = "$($colors.Magenta)"
cyan = "$($colors.Cyan)"
white = "$($colors.White)"

[colors.bright]
black = "$($colors.BrightBlack)"
red = "$($colors.Red)"
green = "$($colors.Green)"
yellow = "$($colors.Yellow)"
blue = "$($colors.Blue)"
magenta = "$($colors.Magenta)"
cyan = "$($colors.Cyan)"
white = "$($colors.White)"
# --- End Chroma Theme ---
"@

  if (Test-Path $configFile) {
    $content = Get-Content $configFile -Raw -Encoding UTF8
    if ($content -match '# --- Chroma Theme') {
      $content = $content -replace '(?s)# --- Chroma Theme.*?# --- End Chroma Theme ---', ''
      Set-Content $configFile $content -Encoding UTF8
    }
  }

  Add-Content $configFile "`n$themeBlock" -Encoding UTF8
  Write-Ok "Applied '$($colors.Display)' to Alacritty"
}

function Apply-Warp($themeName) {
  $colors = $script:Themes[$themeName]
  $warpDir = "$env:USERPROFILE\.warp\themes"
  New-Item -ItemType Directory -Force -Path $warpDir | Out-Null

$filePath = "$warpDir\chroma-$themeName.yaml"
$themeContent = @"
# Chroma Theme: $($colors.Display)
accent: "$($colors.Magenta)"
background: "$($colors.Background)"
details: "$($colors.Comment)"
foreground: "$($colors.Foreground)"
black: "$($colors.Black)"
red: "$($colors.Red)"
green: "$($colors.Green)"
yellow: "$($colors.Yellow)"
blue: "$($colors.Blue)"
magenta: "$($colors.Magenta)"
cyan: "$($colors.Cyan)"
white: "$($colors.White)"
"@

  Set-Content $filePath $themeContent -Encoding UTF8
  Write-Ok "Applied '$($colors.Display)' to Warp (theme file created)"
  Write-Warn "Select in Warp Settings → Appearance → Themes"
}

# ──────────────────────────────────────────────
# Color preview
# ──────────────────────────────────────────────
function Show-Preview($themeName) {
  $colors = $script:Themes[$themeName]
  Write-Host ""
  Write-Host "  $($colors.Display)" -ForegroundColor White
  Write-Host ""
  Write-Host "  Background:  $($colors.Background)" -NoNewline
  Write-Host "  ⬛" -ForegroundColor $(if ($colors.Background -eq '#2D2A2E') { 'DarkGray' } else { 'Black' })
  Write-Host "  Foreground:  $($colors.Foreground)"
  Write-Host ""
  Write-Host "  Palette:" -ForegroundColor White
  $names = @("Black","Red","Green","Yellow","Blue","Magenta","Cyan","White")
  $vals = @($colors.Black, $colors.Red, $colors.Green, $colors.Yellow, $colors.Blue, $colors.Magenta, $colors.Cyan, $colors.White)
  Write-Host (" " + ($vals | ForEach-Object { "  $_" }) -join '')
  Write-Host ""
}

# ──────────────────────────────────────────────
# Install functions
# ──────────────────────────────────────────────
function Install-Fonts {
  Write-Step "Installing JetBrainsMono Nerd Font"

  # Try oh-my-posh font install first
  if (Test-Command "oh-my-posh") {
    Write-Info "Using oh-my-posh to install JetBrainsMono..."
    oh-my-posh font install JetBrainsMono
    if ($LASTEXITCODE -eq 0) {
      Write-Ok "JetBrainsMono Nerd Font installed via oh-my-posh"
      return
    }
  }

  # Fallback to direct download
  $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  $tmpDir = "$env:TEMP\chroma-fonts"
  $zipFile = "$tmpDir\JetBrainsMono.zip"

  New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null

  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $fontUrl -OutFile $zipFile -UseBasicParsing
  }
  catch {
    Write-Error "Failed to download JetBrainsMono Nerd Font: $($_.Exception.Message)"
    return
  }

  try {
    Expand-Archive -Path $zipFile -DestinationPath "$tmpDir\fonts" -Force
  }
  catch {
    Write-Error "Failed to extract font archive"
    return
  }

  $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
  New-Item -ItemType Directory -Force -Path $fontDir | Out-Null

  $count = 0
  Get-ChildItem "$tmpDir\fonts" -Filter "JetBrainsMono*.ttf" | ForEach-Object {
    $dest = Join-Path $fontDir $_.Name
    if (-not (Test-Path $dest)) {
      Copy-Item $_.FullName $dest
      $count++
    }
  }

  if ($count -gt 0) {
    Write-Ok "Installed $count JetBrainsMono Nerd Font files"
    # Register font (requires admin, try gracefully)
    $shell = New-Object -ComObject Shell.Application
    $fontsFolder = $shell.NameSpace(0x14)
    # Font registration via registry
    Get-ChildItem $fontDir -Filter "JetBrainsMono*.ttf" | ForEach-Object {
      $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
      $name = "JetBrainsMono Nerd Font $($_.BaseName -replace 'JetBrainsMono', '' -replace '^Nerd|NerdFont$', '' -replace '\s+', ' ').Trim()"
      try {
        New-ItemProperty -Path $regPath -Name $name -PropertyType String -Value $_.Name -Force | Out-Null
      } catch {
        # Non-admin, skip registry
      }
    }
  } else {
    Write-Info "JetBrainsMono Nerd Font files already installed"
  }

  Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
}

function Install-OhMyPosh {
  Write-Step "Installing oh-my-posh Prompt"

  if (Test-Command "oh-my-posh") {
    Write-Ok "oh-my-posh is already installed"
  } else {
    try {
      Set-ExecutionPolicy Bypass -Scope Process -Force
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
    }
    catch {
      # Fallback via winget
      if (Test-Command "winget") {
        winget install JanDeDobbeleer.OhMyPosh --silent
      } else {
        Write-Error "Could not install oh-my-posh. Install manually or ensure winget is available."
        return
      }
    }
    Write-Ok "oh-my-posh installed"
  }

  # Install Chroma theme for oh-my-posh
  $ompThemesDir = "$env:USERPROFILE\AppData\Local\Programs\oh-my-posh\themes"
  $scriptDir = Split-Path -Parent $PSCommandPath
  $themeFile = Join-Path $scriptDir "chroma-omp.json"

  if (Test-Path $ompThemesDir) {
    if (Test-Path $themeFile) {
      Copy-Item $themeFile $ompThemesDir -Force
      Write-Ok "Copied oh-my-posh theme to $ompThemesDir"
    } else {
      # Create an oh-my-posh theme from the current colors
      $colors = $script:Themes["spectrum"]
      $ompTheme = @{
        "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json"
        blocks = @(
          @{
            type = "prompt"
            alignment = "left"
            segments = @(
              @{ type = "path"; style = "powerline"; foreground = "#78DCE8"; background = "#2D2A2E"; properties = @{ style = "folder" } }
              @{ type = "git"; style = "powerline"; foreground = "#FFD866"; background = "#2D2A2E" }
              @{ type = "node"; style = "powerline"; foreground = "#A9DC76"; background = "#2D2A2E" }
              @{ type = "python"; style = "powerline"; foreground = "#AB9DF2"; background = "#2D2A2E" }
            )
          }
          @{
            type = "prompt"
            alignment = "right"
            segments = @(
              @{ type = "executiontime"; style = "plain"; foreground = "#69676C"; properties = @{ threshold = 5000 } }
              @{ type = "time"; style = "plain"; foreground = "#69676C" }
            )
          }
        )
        final_space = $true
        console_title_template = "{{ .Folder }}"
        version = 2
      } | ConvertTo-Json -Depth 10
      Set-Content $ompThemeFile $ompTheme -Encoding UTF8
    }
  }

  # Add to PowerShell profile
  $profilePath = $PROFILE.CurrentUserAllHosts
  $profileDir = Split-Path $profilePath -Parent
  New-Item -ItemType Directory -Force -Path $profileDir | Out-Null

  $initLine = "oh-my-posh init pwsh --config '$( Join-Path $ompThemesDir "chroma-omp.json" )' | Invoke-Expression"
  $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue

  if ($profileContent -match "oh-my-posh init") {
    Write-Ok "oh-my-posh already initialized in profile"
  } else {
    Add-Content $profilePath "`n# Chroma Terminal - oh-my-posh prompt`n$initLine`n" -Encoding UTF8
    Write-Ok "Added oh-my-posh init to PowerShell profile"
  }
}

function Install-Tools {
  Write-Step "Installing CLI Tools"

  if (-not (Test-Command "winget")) {
    Write-Warn "winget not found. Install tools manually or install App Installer from Microsoft Store."
    return
  }

  $tools = @{
    "Microsoft.PowerShell" = "PowerShell 7"
    "eza" = "eza" # May not be available on winget
    "bat" = "bat"
    "fd"  = "fd"
    "ripgrep" = "ripgrep"
    "fzf" = "fzf"
  }

  $found = $false
  foreach ($tool in $tools.Keys) {
    $name = $tools[$tool]
    if (Test-Command $tool.Split('.')[-1].ToLower()) {
      Write-Ok "$name is already installed"
    } else {
      try {
        winget install $tool --silent --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
          Write-Ok "$name installed"
          $found = $true
        } else {
          Write-Warn "$name could not be installed via winget"
        }
      } catch {
        Write-Warn "$name install failed"
      }
    }
  }

  # Install zoxide separately (may not be in winget)
  if (-not (Test-Command "zoxide")) {
    try {
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.ps1'))
      Write-Ok "zoxide installed"
    } catch {
      Write-Warn "zoxide could not be installed"
    }
  } else {
    Write-Ok "zoxide is already installed"
  }
}

# ──────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────
function Main {
  Write-Host ""
  Write-Host "╔══════════════════════════════════════╗" -ForegroundColor White
  Write-Host "║  Chroma Terminal Theme Installer      ║" -ForegroundColor White
  Write-Host "╚══════════════════════════════════════╝" -ForegroundColor White
  Write-Host ""

  # Handle flags
  if ($Help) {
    Get-Help $PSCommandPath -Detailed
    return
  }

  if ($ListThemes) {
    Write-Title "Available Themes"
    Write-Host ""
    foreach ($name in $script:ThemeNames) {
      Write-Host "  $( $name.PadRight(16) )$($script:Themes[$name].Display)"
    }
    Write-Host ""
    return
  }

  if ($Preview) {
    if ($Theme -and $script:Themes.ContainsKey($Theme)) {
      Show-Preview $Theme
    } else {
      foreach ($name in $script:ThemeNames) {
        Show-Preview $name
      }
    }
    return
  }

  if ($All) {
    $Font = $true
    $Prompt = $true
    $Tools = $true
  }

  # Interactive theme selection
  if (-not $Theme) {
    Write-Title "Select a theme:"
    Write-Host ""
    for ($i = 0; $i -lt $script:ThemeNames.Count; $i++) {
      Write-Host "  $($i + 1). $( $script:ThemeNames[$i].PadRight(16) )$($script:Themes[$script:ThemeNames[$i]].Display)"
    }
    Write-Host ""
    $choice = Read-Host "Enter theme number or name [1]"
    if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $script:ThemeNames.Count) {
      $script:SelectedTheme = $script:ThemeNames[[int]$choice - 1]
    } elseif ($script:Themes.ContainsKey($choice.ToLower())) {
      $script:SelectedTheme = $choice.ToLower()
    } else {
      $script:SelectedTheme = "spectrum"
      Write-Warn "Invalid choice, using default: spectrum"
    }

    Show-Preview $script:SelectedTheme

    if (-not $Font -and -not $Prompt -and -not $Tools) {
      if (Confirm-Action "Install JetBrainsMono Nerd Font?") { $Font = $true }
      if (Confirm-Action "Install oh-my-posh prompt?") { $Prompt = $true }
      if (Confirm-Action "Install CLI tools (PowerShell 7, bat, fd, ripgrep, fzf, zoxide)?") { $Tools = $true }
    }
  } else {
    if (-not $script:Themes.ContainsKey($Theme.ToLower())) {
      Write-Error "Unknown theme: $Theme"
      Write-Host "Available themes: $($script:ThemeNames -join ', ')"
      exit 1
    }
    $script:SelectedTheme = $Theme.ToLower()
  }

  $colors = $script:Themes[$script:SelectedTheme]

  Write-Step "Detecting Terminals"
  $terminals = Get-DetectedTerminals

  if ($terminals.Count -eq 0) {
    Write-Warn "No supported terminals detected."
  }

  # Apply theme
  Write-Step "Applying Theme: $( $colors.Display )"
  foreach ($term in $terminals) {
    switch ($term) {
      "windows-terminal" { Apply-WindowsTerminal $script:SelectedTheme }
      "hyper"            { Apply-Hyper $script:SelectedTheme }
      "alacritty"        { Apply-Alacritty $script:SelectedTheme }
      "warp"             { Apply-Warp $script:SelectedTheme }
    }
  }

  # Optional installations
  if ($Font) { Install-Fonts }
  if ($Prompt) { Install-OhMyPosh }
  if ($Tools) { Install-Tools }

  # Summary
  Write-Host ""
  Write-Title "╔════════════════════════════════════════════╗"
  Write-Title "║  Setup Complete!                           ║"
  Write-Title "╚════════════════════════════════════════════╝"
  Write-Host ""
  Write-Info "Theme applied: $( $colors.Display )"
  Write-Info "Terminals configured: $( $terminals -join ', ' )"
  if ($Font)   { Write-Info "Font: JetBrainsMono Nerd Font installed" }
  if ($Prompt) { Write-Info "Prompt: oh-my-posh configured (restart PowerShell)" }
  if ($Tools)  { Write-Info "Tools: installed" }
  Write-Host ""
}

Main
