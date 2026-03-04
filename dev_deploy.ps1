# Dev Deploy Script - Deploy to local Kodi addon directory
# Usage: .\dev_deploy.ps1

# Fix encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$SourceDir = $PSScriptRoot
$TargetDir = "C:\Users\bxy\AppData\Roaming\Kodi\addons\metadata.tvshows.tmdb.cn.optimization"

Write-Host "Starting deployment to dev environment..." -ForegroundColor Green
Write-Host "Source Dir: $SourceDir"
Write-Host "Target Dir: $TargetDir"
Write-Host ""

# 1. Create target dir if not exists
if (-not (Test-Path $TargetDir)) {
    Write-Host "Creating target directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# 2. Define Exclusions
$ExcludeDirs = @('.git', '.vscode', '.idea', '__pycache__', 'dist', 'test', 'venv')
$ExcludeFiles = @('*.pyc', '.gitignore', 'dev_deploy.ps1', 'build_package.py', '.DS_Store', 'run_tests.py')

# 3. Clean Target Dir (Optional: remove everything first to ensure clean state)
# Write-Host "Cleaning target directory..." -ForegroundColor Yellow
# if (Test-Path $TargetDir) {
#     Get-ChildItem -Path $TargetDir -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
# }

# 4. Copy Logic
function Copy-ProjectFiles {
    param (
        [string]$Source,
        [string]$Destination
    )
    
    $items = Get-ChildItem -Path $Source -Recurse
    
    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($Source.Length + 1)
        
        # Check Exclude Dirs
        $shouldExclude = $false
        foreach ($excludeDir in $ExcludeDirs) {
            # Check if current path segment starts with excluded dir
            # Simple check: path has strictly at start, or contains \excludeDir\
            if ($relativePath.StartsWith($excludeDir) -or $relativePath -like "*\$excludeDir\*") {
                $shouldExclude = $true
                break
            }
        }
        
        # Check Exclude Files
        if (-not $shouldExclude) {
            foreach ($excludeFile in $ExcludeFiles) {
                if ($item.Name -like $excludeFile) {
                    $shouldExclude = $true
                    break
                }
            }
        }
        
        if (-not $shouldExclude) {
            $targetPath = Join-Path -Path $Destination -ChildPath $relativePath
            
            if ($item.PSIsContainer) {
                # Create Directory
                if (-not (Test-Path $targetPath)) {
                    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                }
            } else {
                # Copy File
                $targetDir = Split-Path -Path $targetPath -Parent
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                Copy-Item -Path $item.FullName -Destination $targetPath -Force
                Write-Host "  Copy: $relativePath" -ForegroundColor Gray
            }
        }
    }
}

# 5. Execute Copy
Write-Host "Copying files..." -ForegroundColor Yellow
Copy-ProjectFiles -Source $SourceDir -Destination $TargetDir

Write-Host ""
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "Target Dir: $TargetDir"
Write-Host "Tip: Restart Kodi or Reload Addons to see changes." -ForegroundColor Cyan
