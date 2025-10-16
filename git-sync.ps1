#Requires -Version 5.1
param(
  [string]$Message = ""
)

$ErrorActionPreference = "Stop"

function Write-Section($title) {
  Write-Host "----------------------------------------"
  Write-Host $title
}

function Get-Branch {
  (git rev-parse --abbrev-ref HEAD).Trim()
}

function Is-RepoRoot {
  try { git rev-parse --show-toplevel *> $null; return $true } catch { return $false }
}

function Git-IsDirty {
  git diff --quiet; $code1 = $LASTEXITCODE
  git diff --cached --quiet; $code2 = $LASTEXITCODE
  return -not (($code1 -eq 0) -and ($code2 -eq 0))
}

function Slugify($s) {
  $s = $s.ToLower()
  $s = $s -replace "[^a-z0-9]+","-"
  $s = $s -replace "^-+","" -replace "-+$",""
  return $s
}

function Normalize-LeetCode-Filenames {
  Write-Host "# Normalizing LeetCode filenames..."
  # Rename files like "123. Some Title[... optional stuff ...][.py]" -> "123-some-title.py"
  $files = Get-ChildItem -Recurse -File | Where-Object {
    $_.BaseName -match '^\d+\.\s'
  }

  foreach ($f in $files) {
    $m = [regex]::Match($f.BaseName, '^(?<num>\d+)\.\s*(?<title>.+?)$')
    if (-not $m.Success) { continue }
    $num   = $m.Groups['num'].Value
    $title = $m.Groups['title'].Value

    $slug = Slugify $title
    if ([string]::IsNullOrWhiteSpace($slug)) { continue }

    $newName = "$num-$slug"
    if ($f.Extension -ne ".py") { $newName += ".py" } else { $newName += $f.Extension }

    $dest = Join-Path $f.DirectoryName $newName
    if ($dest -ne $f.FullName) {
      if (-not (Test-Path $dest)) {
        Write-Host ("  + {0} -> {1}" -f $f.BaseName, (Split-Path -Leaf $dest))
        Move-Item -LiteralPath $f.FullName -Destination $dest
      }
      else {
        Write-Warning "  ! Skipped rename (target exists): $dest"
      }
    }
  }
}

if (-not (Is-RepoRoot)) {
  throw "Run this script from inside a Git repository."
}

$repo = (git rev-parse --show-toplevel).Trim()
$branch = Get-Branch

Write-Host ("Repo:   {0}" -f (Split-Path -Leaf $repo))
Write-Host ("Branch: {0}" -f $branch)
Write-Section ""

# 1) Normalize filenames first (works even if dirty; we’ll autostash/commit as needed)
Normalize-LeetCode-Filenames

Write-Host "Pulling latest with rebase..."
# Try a clean pull with autostash. If that fails due to policy or other issue, fallback later.
$pullOk = $true
try {
  git pull --rebase --autostash
} catch {
  $pullOk = $false
  Write-Warning "Pull with rebase failed (probably due to unstaged/index changes)."
}

# 2) Stage & commit anything pending (rename, edits, etc.)
if (Git-IsDirty) {
  Write-Host "Staging changes..."
  git add -A
  if ($Message -and $Message.Trim().Length -gt 0) {
    $msg = $Message
  } else {
    $msg = "sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  }

  Write-Host "Committing: $msg"
  try {
    git commit -m "$msg"
  } catch {
    # No changes to commit (race with autostash), ignore
  }
} else {
  Write-Host "No changes to commit."
}

# 3) If the initial pull failed, retry now that we have a clean index
if (-not $pullOk) {
  Write-Host "Retrying pull --rebase now that changes are committed..."
  git pull --rebase
}

# 4) Push; if rejected, fetch+rebase then push again
Write-Host "Pushing to origin/$branch..."
try {
  git push origin $branch
} catch {
  Write-Warning "Push rejected. Remote is ahead; rebasing on origin/$branch..."
  git fetch origin
  git rebase origin/$branch
  Write-Host "Re-pushing..."
  git push origin $branch
}

Write-Host "Done."
