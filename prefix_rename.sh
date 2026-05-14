#!/usr/bin/env zsh

# Recursive file renaming script
# Renames files to include their parent folder name as a prefix
# Usage: ./recursive_rename.sh <root_directory>

rename_files_in_folder() {
    local folder="$1"
    local prefix="$2"
    
    # Get the folder name (last part of the path)
    local folder_name=$(basename "$folder")
    
    # Build the new prefix
    if [ -z "$prefix" ]; then
        local new_prefix="$folder_name"
    else
        local new_prefix="${prefix}_${folder_name}"
    fi
    
    # Process all files in current folder
    for file in "$folder"/*; do
        # Skip if file doesn't exist (empty directory)
        [ -e "$file" ] || continue
        
        if [ -f "$file" ]; then
            # It's a file
            local filename=$(basename "$file")
            
            # Check if file already starts with the new prefix
            if [[ ! "$filename" =~ ^${new_prefix}_ ]]; then
                # File doesn't have the prefix, rename it
                local new_filename="${new_prefix}_${filename}"
                local new_path="${folder}/${new_filename}"
                
                if [ "$file" != "$new_path" ]; then
                    mv "$file" "$new_path"
                    echo "Renamed: $filename → $new_filename"
                fi
            else
                echo "Skipped: $filename (already has prefix)"
            fi
        elif [ -d "$file" ]; then
            # It's a directory, recurse into it
            rename_files_in_folder "$file" "$new_prefix"
        fi
    done
}

# Main script
# Use provided directory or current directory (.) if none provided
root_dir="${1:-.}"

# Check if root directory exists
if [ ! -d "$root_dir" ]; then
    echo "Error: Directory '$root_dir' does not exist."
    exit 1
fi

echo "Starting recursive file rename in: $root_dir"
echo "---"

# Start the recursion with empty prefix (root folder name won't be added to prefix)
# Process subdirectories of root without adding root name to prefix
for item in "$root_dir"/*; do
    if [ -f "$item" ]; then
        # File in root directory - rename with just the filename
        filename=$(basename "$item")
        echo "Skipped: $filename (in root directory)"
    elif [ -d "$item" ]; then
        # Subdirectory - start recursion from here with empty prefix
        rename_files_in_folder "$item" ""
    fi
done

echo "---"
echo "Done!"
