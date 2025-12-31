# Simple Print Removal Script
# Run from project root

$ErrorActionPreference = "Stop"

Write-Host "Removing print statements..." -ForegroundColor Yellow

# Get all Dart files
$files = Get-ChildItem -Path ".\lib" -Filter "*.dart" -Recurse

$totalRemoved = 0
$filesChanged = 0

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Remove single-line print statements
    # Pattern: whitespace + print( + anything + ); + optional newline
    $content = $content -creplace '(?m)^\s*print\([^;]+\);\s*\r?\n?', ''
    
    # Remove print statements that might have nested parentheses  
    # This catches most common cases
    $content = $content -creplace '\s*print\s*\([^\)]*\([^\)]*\)[^\)]*\);\s*', ''
    $content = $content -creplace '\s*print\s*\([^\)]*\);\s*', ''
    
    if ($content -ne $originalContent) {
        # Count removals
        $before = ([regex]::Match($originalContent, 'print\s*\(')).Captures.Count  
        $after = ([regex]::Matches($content, 'print\s*\(')).Count
        $removed = $before - $after
        
        if ($removed -gt 0) {
            $totalRemoved += $removed
            $filesChanged++
            Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
            Write-Host "  $_($file.Name): $removed removed" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "Complete!" -ForegroundColor Green
Write-Host "  Files changed: $filesChanged" -ForegroundColor White
Write-Host "  Statements removed: $totalRemoved" -ForegroundColor White
Write-Host ""
Write-Host "Run 'flutter analyze' to verify" -ForegroundColor Yellow
