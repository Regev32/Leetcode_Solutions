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
# Try short ref; if 'HEAD' (detached or unborn), try remote HEAD; else fall back to 'main'
$branch = (& git symbolic-ref --quiet --short HEAD) 2>$null
if ([string]::IsNullOrWhiteSpace($branch) -or $branch -eq 'HEAD') {
    $remotes = (& git remote 2>$null)
    $hasOrigin = ($remotes -match '(^|\s)origin(\s|$)')
    if ($hasOrigin) {
        $remoteHead = (& git remote show origin 2>$null | Select-String "HEAD branch:").ToString()
        if ($remoteHead -match "HEAD branch:\s+(\S+)") {
            $branch = $Matches[1]
        } else {
            $branch = "main"
        }
    } else {
        $branch = "main"
    }
}

$repo = Split-Path -Leaf (git rev-parse --show-toplevel)

Write-Host "Repo:   $repo"
Write-Host "Branch: $branch"
Write-Host "----------------------------------------"

# Determine if the repo already has any commits (safe: no fatal output)
# If there are no refs, this comes back empty and exit code 1 (but no stderr noise).
$null = & git show-ref --head 2>$null
$hasCommits = ($LASTEXITCODE -eq 0)

# See if 'origin' exists
$remotes = (& git remote 2>$null)
$hasOrigin = ($remotes -match '(^|\s)origin(\s|$)')

# Pull only if we have local commits and the remote branch exists
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
        # Completely empty repo: create a tiny placeholder so first commit can exist
        if (-not (Test-Path ".gitkeep")) {
            New-Item -ItemType File -Path ".gitkeep" | Out-Null
        }
        git add .gitkeep
        Write-Host "Creating initial commit..."
        git commit -m "$Message"
        $hasCommits = $true
    } else {
        Write-Host "No staged changes to commit."
    }
}

# Push if we now have commits
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
