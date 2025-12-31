$ErrorActionPreference = "Stop"

Write-Host "Removing print statements from purchase directory..." -ForegroundColor Yellow
Write-Host ""

$files = Get-ChildItem -Path ".\lib\src\purchase" -Filter "*.dart" -Recurse
$totalCleaned = 0

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Remove print statements (handles most cases)
    $content = $content -creplace '(?m)^\s*print\s*\([^;]+\);\s*\r?\n?', ''
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        $totalCleaned++
        Write-Host "  ✓ $($file.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Complete! Cleaned $totalCleaned files" -ForegroundColor Green
Write-Host ""
Write-Host "Run 'flutter analyze' to verify" -ForegroundColor Yellow
