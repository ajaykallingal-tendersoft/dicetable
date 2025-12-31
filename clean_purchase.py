import re
from pathlib import Path

def remove_print_statements_from_file(file_path):
    """Remove all print() statements from a Dart file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    lines = content.split('\n')
    result_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        stripped = line.lstrip()
        
        # Check if line contains a print statement
        if 'print(' in stripped:
            # Find if it's a complete statement on this line
            if stripped.startswith('print(') and stripped.rstrip().endswith(');'):
                # Single-line print statement - skip it
                i += 1
                continue
            elif stripped.startswith('print('):
                # Multi-line print statement - find the end
                complete_statement = line
                j = i
               
paren_count = line.count('(') - line.count(')')
                
                while paren_count > 0 and j < len(lines) - 1:
                    j += 1
                    complete_statement += '\n' + lines[j]
                    paren_count += lines[j].count('(') - lines[j].count(')')
                
                # Check if it ends with );
                if complete_statement.rstrip().endswith(');'):
                    # Skip this entire print statement
                    i = j + 1
                    continue
        
        result_lines.append(line)
        i += 1
    
    new_content = '\n'.join(result_lines)
    
    # Return whether file was modified and the new content
    return (original_content != new_content, new_content)

# Process purchase directory
purchase_dir = Path('lib/src/purchase')
files_cleaned = 0
total_files = 0

print("Cleaning purchase directory...")
print()

for dart_file in purchase_dir.rglob('*.dart'):
    total_files += 1
    was_modified, new_content = remove_print_statements_from_file(dart_file)
    
    if was_modified:
        # Write back to file
        with open(dart_file, 'w', encoding='utf-8', newline='\n') as f:
            f.write(new_content)
        files_cleaned += 1
        print(f"✓ {dart_file.name}")

print()
print(f"Complete! Cleaned {files_cleaned} of {total_files} files")
print()
print("Run 'flutter analyze' to verify")
