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

# Commit message
if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# Detect branch
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

# Has any commit yet? (quiet)
$null = & git show-ref --head 2>$null
$hasCommits = ($LASTEXITCODE -eq 0)

# Has origin?
$remotes = (& git remote 2>$null)
$hasOrigin = ($remotes -match '(^|\s)origin(\s|$)')

# -------------------------------
# Rename solution files -> "NNN-slugified-title.py"
# -------------------------------
Write-Host "# Normalizing LeetCode filenames..."
$lcDirs = @("easy","medium","hard")

# Helper: slugify title
function New-Slug([string]$s) {
    $t = $s.ToLower()
    $t = [regex]::Replace($t, '[^a-z0-9]+', '-')   # non-alnum -> hyphen
    $t = $t.Trim('-')
    return $t
}

foreach ($d in $lcDirs) {
    if (-not (Test-Path $d)) { continue }
    Get-ChildItem -Path $d -File -Recurse | ForEach-Object {
        $file = $_
        # Skip files that already match desired pattern exactly
        if ($file.Name -match '^\d+-[a-z0-9-]+\.py$') { return }

        # Try to extract "NNN. Title ..." (tolerant)
        $m = [regex]::Match($file.Name, '^\s*(\d+)\.\s*(.+?)(?:\.\w+)?$')
        if (-not $m.Success) {
            # fallback: "NNN something"
            $m = [regex]::Match($file.BaseName, '^\s*(\d+)[\.\s_-]+(.+)$')
        }
        if ($m.Success) {
            $id    = $m.Groups[1].Value
            $title = $m.Groups[2].Value
            $slug  = New-Slug $title
            if ([string]::IsNullOrWhiteSpace($slug)) { return }
            $newName = "$id-$slug.py"
            if ($file.Name -ne $newName) {
                $target = Join-Path $file.DirectoryName $newName
                if (-not (Test-Path $target)) {
                    Rename-Item -LiteralPath $file.FullName -NewName $newName
                    Write-Host "  + $($file.Name) -> $newName"
                } else {
                    Write-Host "  ! Skipped (exists): $newName in $($file.DirectoryName)"
                }
            }
        }
    }
}

# -------------------------------
# Pull (only when appropriate)
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

$staged = git diff --cached --name-only
if (-not [string]::IsNullOrWhiteSpace($staged)) {
    Write-Host "Committing: $Message"
    git commit -m "$Message"
    $hasCommits = $true
} else {
    Write-Host "No staged changes to commit."
}

if ($hasCommits) {
    if (-not $hasOrigin) {
        Write-Host "No 'origin' remote configured. Add it, e.g.:"
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