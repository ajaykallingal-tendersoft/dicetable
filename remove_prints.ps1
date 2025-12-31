#!/usr/bin/env pwsh
# Script to remove all print() statements from Dart files
# This preserves code structure and only removes print statements

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Print Statement Removal Script" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$libPath = ".\lib"
$backupPath = ".\print_statements_backup"

# Safety check
if (-not (Test-Path $libPath)) {
    Write-Host "❌ Error: lib folder not found. Run this from project root." -ForegroundColor Red
    exit 1
}

Write-Host "📁 Scanning Dart files in: $libPath" -ForegroundColor Yellow
$dartFiles = Get-ChildItem -Path $libPath -Recurse -Filter "*.dart"
Write-Host "   Found $($dartFiles.Count) Dart files" -ForegroundColor White
Write-Host ""

# Count total print statements first
Write-Host "🔍 Counting print statements..." -ForegroundColor Yellow
$totalPrints = 0
foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $matches = [regex]::Matches($content, "print\s*\(")
    $totalPrints += $matches.Count
}
Write-Host "   Found $totalPrints print statements to remove" -ForegroundColor White
Write-Host ""

# Confirm before proceeding
Write-Host "⚠️  WARNING: This will modify $($dartFiles.Count) files!" -ForegroundColor Yellow
Write-Host "   A backup will be created at: $backupPath" -ForegroundColor White
Write-Host ""
$confirmation = Read-Host "Continue? (y/n)"
if ($confirmation -ne "y") {
    Write-Host "❌ Cancelled by user" -ForegroundColor Red
    exit 0
}

# Create backup
Write-Host ""
Write-Host "💾 Creating backup..." -ForegroundColor Yellow
if (Test-Path $backupPath) {
    Remove-Item -Path $backupPath -Recurse -Force
}
Copy-Item -Path $libPath -Destination $backupPath -Recurse
Write-Host "   ✅ Backup created at: $backupPath" -ForegroundColor Green
Write-Host ""

# Process files
Write-Host "🧹 Removing print statements..." -ForegroundColor Yellow
$filesModified = 0
$printsRemoved = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    
    # Pattern to match print statements with proper nesting
    # This handles multi-line print statements with balanced parentheses
    $pattern = "^\s*print\s*\([^;]*\);\s*(?:\r?\n)?"
    
    # Remove print statements (handles single-line and multi-line)
    # This regex matches: optional whitespace + print( + content + ); + optional newline
    $newContent = $content -replace "(?m)^\s*print\s*\((?:[^()]|\([^()]*\))*\);\s*\r?\n?", ""
    
    # Also handle inline prints (without leading newline)
    $newContent = $newContent -replace "\s*print\s*\((?:[^()]|\([^()]*\))*\);\s*", ""
    
    if ($newContent -ne $originalContent) {
        # Count how many prints were removed from this file
        $beforeMatches = [regex]::Matches($originalContent, "print\s*\(").Count
        $afterMatches = [regex]::Matches($newContent, "print\s*\(").Count
        $removed = $beforeMatches - $afterMatches
        
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        $filesModified++
        $printsRemoved += $removed
        
        $relativePath = $file.FullName.Replace((Get-Location).Path, "").TrimStart("\")
        Write-Host "   ✓ $relativePath ($removed prints)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ COMPLETE" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   Files Modified: $filesModified" -ForegroundColor White
Write-Host "   Print Statements Removed: $printsRemoved" -ForegroundColor White
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Run: flutter analyze" -ForegroundColor White
Write-Host "   2. Run: flutter test (if you have tests)" -ForegroundColor White
Write-Host "   3. Build and test the app" -ForegroundColor White
Write-Host "   4. If all good, delete backup: rm -r $backupPath" -ForegroundColor White
Write-Host "   5. If issues, restore: rm -r lib; mv $backupPath lib" -ForegroundColor White
Write-Host ""
