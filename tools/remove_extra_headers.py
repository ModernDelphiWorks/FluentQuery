import os
import glob
import re

def remove_second_header(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex pattern:
    # 1. Start of file, optional whitespace
    # 2. First comment block { ... } (The License Header)
    # 3. Whitespace
    # 4. Second comment block { ... } that does NOT start with {$ (to avoid compiler directives)
    
    # We use re.DOTALL so . matches newlines
    pattern = r'^\s*(\{.*?\})\s+(\{(?!\$).*?\})'
    
    match = re.search(pattern, content, re.DOTALL)
    
    if match:
        # We found a second header block that is not a directive.
        # We want to keep the first block and remove the second one.
        # We'll construct the new content by taking the first group, 
        # adding some newlines, and then appending the rest of the file 
        # starting from the end of the second match.
        
        first_header = match.group(1)
        second_header_end_pos = match.end(2)
        
        rest_of_file = content[second_header_end_pos:]
        
        # Ensure we don't have too many empty lines at the start of the rest
        rest_of_file = rest_of_file.lstrip()
        
        new_content = first_header + '\n\n' + rest_of_file
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Removed extra header from {os.path.basename(file_path)}")
    else:
        # print(f"No extra header found in {os.path.basename(file_path)}")
        pass

def main():
    directory = r'd:\Ecossistema-Delphi\FluentQuery\Source'
    pas_files = glob.glob(os.path.join(directory, '*.pas'))
    
    print(f"Scanning {len(pas_files)} files...")
    for file_path in pas_files:
        remove_second_header(file_path)

if __name__ == "__main__":
    main()
