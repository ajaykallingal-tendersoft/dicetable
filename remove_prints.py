import os
import re
import shutil
from pathlib import Path

print("=" * 60)
print("  Print Statement Removal Script")
print("=" * 60)
print()

lib_path = Path("lib")
backup_path = Path("print_statements_backup")

# Safety check
if not lib_path.exists():
    print("❌ Error: lib folder not found. Run this from project root.")
    exit(1)

print(f"📁 Scanning Dart files in: {lib_path}")
dart_files = list(lib_path.rglob("*.dart"))
print(f"   Found {len(dart_files)} Dart files")
print()

# Count total print statements first
print("🔍 Counting print statements...")
total_prints = 0
for file in dart_files:
    content = file.read_text(encoding='utf-8')
    matches = re.findall(r'print\s*\(', content)
    total_prints += len(matches)

print(f"   Found {total_prints} print statements to remove")
print()

# Confirm before proceeding
print(f"⚠️  WARNING: This will modify {len(dart_files)} files!")
print(f"   A backup will be created at: {backup_path}")
print()
confirmation = input("Continue? (y/n): ")
if confirmation.lower() != 'y':
    print("❌ Cancelled by user")
    exit(0)

# Create backup
print()
print("💾 Creating backup...")
if backup_path.exists():
    shutil.rmtree(backup_path)
shutil.copytree(lib_path, backup_path)
print(f"   ✅ Backup created at: {backup_path}")
print()

# Process files
print("🧹 Removing print statements...")
files_modified = 0
prints_removed = 0

# Regex pattern to match print statements
# Handles both single-line and multi-line print statements
def remove_print_statements(content):
    """Remove all print() statements from Dart code."""
    # Pattern matches: optional whitespace + print( + balanced parens + ); + optional newline
    # This handles nested parentheses up to reasonable depth
    
    lines = content.split('\n')
    result_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        stripped = line.lstrip()
        
        # Check if line starts with print(
        if stripped.startswith('print('):
            # Find the complete print statement (might span multiple lines)
            complete_statement = line
            paren_count = line.count('(') - line.count(')')
            j = i
            
            # Continue until parentheses are balanced
            while paren_count > 0 and j < len(lines) - 1:
                j += 1
                complete_statement += '\n' + lines[j]
                paren_count += lines[j].count('(') - lines[j].count(')')
            
            # Check if this is a complete print statement ending with ;
            if complete_statement.rstrip().endswith(');'):
                # Skip this print statement (don't add to result)
                i = j + 1
                continue
        
        result_lines.append(line)
        i += 1
    
    return '\n'.join(result_lines)

for file in dart_files:
    try:
        content = file.read_text(encoding='utf-8')
        original_content = content
        
        # Remove print statements
        new_content = remove_print_statements(content)
        
        if new_content != original_content:
            # Count how many prints were removed
            before_count = len(re.findall(r'print\s*\(', original_content))
            after_count = len(re.findall(r'print\s*\(', new_content))
            removed = before_count - after_count
            
            file.write_text(new_content, encoding='utf-8')
            files_modified += 1
            prints_removed += removed
            
            relative_path = file.relative_to(Path.cwd())
            print(f"   ✓ {relative_path} ({removed} prints)")
    
    except Exception as e:
        print(f"   ❌ Error processing {file}: {e}")

print()
print("=" * 60)
print("  ✅ COMPLETE")
print("=" * 60)
print(f"   Files Modified: {files_modified}")
print(f"   Print Statements Removed: {prints_removed}")
print()
print("📋 Next Steps:")
print("   1. Run: flutter analyze")
print("   2. Run: flutter test (if you have tests)")
print("   3. Build and test the app")
print(f"   4. If all good, delete backup: rmdir /s {backup_path}")
print(f"   5. If issues, restore: rmdir /s lib && move {backup_path} lib")
print()
