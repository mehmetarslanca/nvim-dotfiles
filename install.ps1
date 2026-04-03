$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:NVIM_DOTFILES_REPO_URL) { $env:NVIM_DOTFILES_REPO_URL } else { "https://github.com/mehmetarslanca/nvim-dotfiles.git" }
$RepoUrlNoGit = $RepoUrl -replace '\.git$', ''
$ConfigDir = Join-Path $env:LOCALAPPDATA "nvim"

function Write-Log {
  param([string]$Message)
  Write-Host "[nvim-dotfiles] $Message"
}

function Test-Command {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Backup-ExistingConfig {
  if (-not (Test-Path $ConfigDir)) {
    return
  }

  $timestamp = Get-Date -Format "yyyyMMddHHmmss"
  $backupDir = "$ConfigDir.backup.$timestamp"
  Move-Item -Path $ConfigDir -Destination $backupDir
  Write-Log "Existing config backed up to $backupDir"
}

function Install-WithWinget {
  winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
  winget install -e --id Neovim.Neovim --accept-package-agreements --accept-source-agreements
  winget install -e --id BurntSushi.ripgrep.MSVC --accept-package-agreements --accept-source-agreements
  winget install -e --id sharkdp.fd --accept-package-agreements --accept-source-agreements
  winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
  winget install -e --id Microsoft.OpenJDK.21 --accept-package-agreements --accept-source-agreements
}

function Install-WithChoco {
  choco install -y git neovim ripgrep fd nodejs-lts openjdk
}

function Install-WithScoop {
  scoop install git neovim ripgrep fd nodejs-lts openjdk
}

function Install-Dependencies {
  if (Test-Command winget) {
    Install-WithWinget
  } elseif (Test-Command choco) {
    Install-WithChoco
  } elseif (Test-Command scoop) {
    Install-WithScoop
  } else {
    Write-Log "No supported Windows package manager detected. Install git, neovim, ripgrep, fd, nodejs, and a JDK manually if needed."
  }
}

function Refresh-Path {
  $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
  $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
  $env:Path = "$machinePath;$userPath"
}

function Install-OpenCode {
  if (Test-Command opencode) {
    Write-Log "opencode already installed"
    return
  }

  if (Test-Command scoop) {
    scoop install opencode
    return
  }

  if (Test-Command choco) {
    choco install -y opencode
    return
  }

  if (Test-Command npm) {
    npm install -g opencode-ai
    return
  }

  Write-Log "OpenCode CLI could not be installed automatically. Install it manually from https://opencode.ai/docs"
}

function Clone-OrUpdateRepo {
  $configRoot = Split-Path $ConfigDir -Parent
  if (-not (Test-Path $configRoot)) {
    New-Item -ItemType Directory -Path $configRoot | Out-Null
  }

  if (Test-Path (Join-Path $ConfigDir ".git")) {
    $remoteUrl = ""
    try {
      $remoteUrl = (git -C $ConfigDir remote get-url origin).Trim()
    } catch {
      $remoteUrl = ""
    }

    if ($remoteUrl -eq $RepoUrl -or $remoteUrl -eq $RepoUrlNoGit) {
      Write-Log "Updating existing nvim-dotfiles checkout"
      git -C $ConfigDir pull --ff-only
      return
    }
  }

  if (Test-Path $ConfigDir) {
    Backup-ExistingConfig
  }

  Write-Log "Cloning nvim-dotfiles into $ConfigDir"
  git clone $RepoUrl $ConfigDir
}

function Bootstrap-Neovim {
  if (-not (Test-Command git)) {
    throw "git is required but not installed."
  }

  if (-not (Test-Command nvim)) {
    throw "neovim is required but not installed."
  }

  Write-Log "Installing plugins via Lazy"
  nvim --headless "+Lazy! sync" +qa

  Write-Log "Triggering startup so Mason tools can install"
  nvim --headless +qa
}

Install-Dependencies
Refresh-Path
Install-OpenCode
Refresh-Path
Clone-OrUpdateRepo
Bootstrap-Neovim
Write-Log "Setup complete"
