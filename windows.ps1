Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$NodeVersion = "22"
$WorkspaceRoot = if ($env:WORKSPACE_ROOT) { $env:WORKSPACE_ROOT } else { Join-Path $HOME "GitHub" }

function Main {
    Write-Step "Preparing Windows developer setup"

    Ensure-Administrator
    Ensure-Winget

    Install-CommandLineTools
    Install-Node
    Install-DesktopApps
    Install-AiTools
    Install-PlaywrightBrowsers

    Write-Step "Upgrading installed winget packages"
    winget upgrade --all --accept-package-agreements --accept-source-agreements

    Write-Step "Done"
    Write-Host "Open a new terminal, then use: cd ~/GitHub/<repo>/web; npm ci; npm start"
}

function Write-Step {
    param([Parameter(Mandatory)] [string] $Message)

    Write-Host ""
    Write-Host "==> $Message"
}

function Ensure-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Run this script from an elevated PowerShell terminal."
    }
}

function Ensure-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget is required. Install App Installer from the Microsoft Store, then rerun this script."
    }
}

function Install-WingetPackage {
    param(
        [Parameter(Mandatory)] [string] $Id,
        [Parameter(Mandatory)] [string] $Name
    )

    $installed = winget list --id $Id --exact --source winget 2>$null
    if ($LASTEXITCODE -eq 0 -and $installed -match [regex]::Escape($Id)) {
        Write-Host "Already installed: $Name"
        return
    }

    winget install `
        --id $Id `
        --exact `
        --source winget `
        --accept-package-agreements `
        --accept-source-agreements
}

function Install-CommandLineTools {
    Write-Step "Installing command-line tools"
    Install-WingetPackage -Id "Git.Git" -Name "Git"
    Install-WingetPackage -Id "GitHub.cli" -Name "GitHub CLI"
    Install-WingetPackage -Id "jqlang.jq" -Name "jq"
    Install-WingetPackage -Id "BurntSushi.ripgrep.MSVC" -Name "ripgrep"
    Install-WingetPackage -Id "Microsoft.AzureCLI" -Name "Azure CLI"
    Install-WingetPackage -Id "Microsoft.Bicep" -Name "Bicep"
}

function Install-Node {
    Write-Step "Installing Node.js $NodeVersion"
    Install-WingetPackage -Id "CoreyButler.NVMforWindows" -Name "nvm-windows"
    Import-CurrentPath

    nvm install $NodeVersion
    nvm use $NodeVersion

    node --version
    npm --version
}

function Install-DesktopApps {
    Write-Step "Installing desktop apps"
    Install-WingetPackage -Id "Microsoft.VisualStudioCode" -Name "Visual Studio Code"
    Install-WingetPackage -Id "Google.Chrome" -Name "Google Chrome"
    Install-WingetPackage -Id "Mozilla.Firefox" -Name "Firefox"
    Install-WingetPackage -Id "Microsoft.Azure.StorageExplorer" -Name "Azure Storage Explorer"
}

function Install-AiTools {
    Write-Step "Installing AI-assisted development tools"
    Install-WingetPackage -Id "GitHub.GitHubDesktop" -Name "GitHub Desktop"

    npm install -g @openai/codex

    Install-VsCodeExtension -Extension "GitHub.copilot"
    Install-VsCodeExtension -Extension "GitHub.copilot-chat"
    Install-VsCodeExtension -Extension "openai.chatgpt"

    gh --version
    codex --version
}

function Install-VsCodeExtension {
    param([Parameter(Mandatory)] [string] $Extension)

    $codeCommand = Get-Command code -ErrorAction SilentlyContinue
    if (-not $codeCommand) {
        $codePath = Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\bin\code.cmd"
        if (Test-Path $codePath) {
            & $codePath --install-extension $Extension --force
            return
        }

        Write-Host "Skipping VS Code extension $Extension; VS Code command line tool is unavailable."
        return
    }

    code --install-extension $Extension --force
}

function Install-PlaywrightBrowsers {
    $appDirs = @(
        Join-Path $WorkspaceRoot "score-keeper\web"
        Join-Path $WorkspaceRoot "arcade-shooter\web"
    )

    foreach ($appDir in $appDirs) {
        $packageJson = Join-Path $appDir "package.json"
        $nodeModules = Join-Path $appDir "node_modules"
        $relativePath = Resolve-RelativePath -Path $appDir

        if ((Test-Path $packageJson) -and (Test-Path $nodeModules)) {
            Write-Step "Installing Playwright browsers for $relativePath"
            Push-Location $appDir
            try {
                npx playwright install
            }
            finally {
                Pop-Location
            }
        }
        elseif (Test-Path $packageJson) {
            Write-Host "Skipping Playwright browsers for $relativePath; run npm ci there first."
        }
    }
}

function Import-CurrentPath {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

function Resolve-RelativePath {
    param([Parameter(Mandatory)] [string] $Path)

    if ($Path.StartsWith($WorkspaceRoot)) {
        return $Path.Substring($WorkspaceRoot.Length).TrimStart([char[]]"\/")
    }

    return $Path
}

Main
