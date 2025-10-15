# git-sync.ps1 — Windows PowerShell
# Usage:
#   .\git-sync.ps1 "your commit message"
# If no message is provided, a timestamped default is used.

param(
    [string]$Message
)

$ErrorActionPreference = "Stop"

# Ensure we're in a Git repo
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not inside a Git repository."
    exit 1
}

# Choose a commit message
if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# Detect branch name reliably
$branch = (& git symbolic-ref --quiet --short HEAD) 2>$null
if ([string]::IsNullOrWhiteSpace($branch) -or $branch -eq 'HEAD') {
    $remotes = (& git remote 2>$null)
    $hasOrigin = ($remotes -match '(^|\s)origin(\s|$)')
    if ($hasOrigin) {
        $remoteHead = (& git remote show origin 2>$null | Select-String "HEAD branch:").ToString()
        if ($remoteHead -match "HEAD branch:\s+(\S+)") { $branch = $Matches[1] } else { $branch = "main" }
    } else {
        $branch = "main"
    }
}

$repoRoot = (git rev-parse --show-toplevel).Trim()
$repo = Split-Path -Leaf $repoRoot
Set-Location $repoRoot

Write-Host "Repo:   $repo"
Write-Host "Branch: $branch"
Write-Host "----------------------------------------"

# Determine if the repo already has any commits (no fatal output)
$null = & git show-ref --head 2>$null
$hasCommits = ($LASTEXITCODE -eq 0)

# See if 'origin' exists
$remotes = (& git remote 2>$null)
$hasOrigin = ($remotes -match '(^|\s)origin(\s|$)')

# -------------------------------
# Normalize filenames & ensure empty dirs are tracked
# -------------------------------
Write-Host "# Normalize files and track empty folders"

# 1) Convert extensionless files under easy/medium/hard to .py
$lcDirs = @("easy","medium","hard")
foreach ($d in $lcDirs) {
    if (Test-Path $d) {
        # Only files directly or in subfolders of these buckets
        Get-ChildItem -Path $d -File -Recurse | ForEach-Object {
            $f = $_
            if ([string]::IsNullOrWhiteSpace($f.Extension)) {
                $newName = "$($f.Name).py"
                $newPath = Join-Path $f.DirectoryName $newName
                if (-not (Test-Path $newPath)) {
                    Rename-Item -LiteralPath $f.FullName -NewName $newName
                    Write-Host "  + Renamed: $($f.FullName.Replace($repoRoot+'\','')) -> $($newPath.Replace($repoRoot+'\',''))"
                } else {
                    Write-Host "  ! Skipped (target exists): $($f.FullName.Replace($repoRoot+'\',''))"
                }
            }
        }
    }
}

# 2) Ensure empty directories (like 'hard') get tracked via .gitkeep
foreach ($d in $lcDirs) {
    if (Test-Path $d) {
        # If directory has no files (recursively), drop a .gitkeep
        $hasAnyFiles = @(Get-ChildItem -Path $d -File -Recurse) -ne @()
        if (-not $hasAnyFiles) {
            $keep = Join-Path $d ".gitkeep"
            if (-not (Test-Path $keep)) {
                New-Item -ItemType File -Path $keep | Out-Null
                Write-Host "  + Added: $($keep.Replace($repoRoot+'\','')) (to track empty dir)"
            }
        }
    }
}

# -------------------------------
# Pull (when appropriate)
# -------------------------------
if ($hasCommits -and $hasOrigin) {
    git ls-remote --exit-code --heads origin $branch *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Pulling latest with rebase..."
        git pull --rebase origin $branch
    } else {
        Write-Host "Remote branch 'origin/$branch' not found. Will push after committing."
    }
} elseif ($hasCommits -and -not $hasOrigin) {
    Write-Host "No 'origin' remote configured. Skipping pull."
} else {
    Write-Host "No commits yet in this repo. Will create the initial commit if needed."
}

# -------------------------------
# Stage, commit, push
# -------------------------------
Write-Host "Staging changes..."
git add -A

# Commit only if there are staged files
$staged = git diff --cached --name-only
if (-not [string]::IsNullOrWhiteSpace($staged)) {
    Write-Host "Committing: $Message"
    git commit -m "$Message"
    $hasCommits = $true
} else {
    if (-not $hasCommits) {
        # Completely empty repo: ensure at least one file so we can commit
        $rootKeep = ".gitkeep"
        if (-not (Test-Path $rootKeep)) { New-Item -ItemType File -Path $rootKeep | Out-Null }
        git add $rootKeep
        Write-Host "Creating initial commit..."
        git commit -m "$Message"
        $hasCommits = $true
    } else {
        Write-Host "No staged changes to commit."
    }
}

if ($hasCommits) {
    if (-not $hasOrigin) {
        Write-Host "No 'origin' remote configured. Add it first, e.g.:"
        Write-Host "  git remote add origin https://github.com/<user>/<repo>.git"
        Write-Host "Then rerun this script."
        exit 0
    }
    Write-Host "Pushing to origin/$branch..."
    git push -u origin $branch
} else {
    Write-Host "Nothing to push."
}

Write-Host "Done."
