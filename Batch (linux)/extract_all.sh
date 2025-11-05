#!/bin/bash

echo "================================================"
echo "   ARC Extract - Batch Processing Tool"
echo "================================================"
echo

# Find arc_extract.py
if [ -f "arc_extract.py" ]; then
    script="arc_extract.py"
elif [ -f "../arc_extract.py" ]; then
    script="../arc_extract.py"
else
    echo "Error: arc_extract.py not found!"
    echo "Please make sure arc_extract.py is in the current directory or parent directory."
    exit 1
fi

read -p "Enter folder with .arc files: " arc_folder

if [ -z "$arc_folder" ]; then
    echo "Error: Folder path is required!"
    exit 1
fi

if [ ! -d "$arc_folder" ]; then
    echo "Error: Folder '$arc_folder' does not exist!"
    exit 1
fi

read -p "Enter parent folder name to create (e.g., extracted): " parent_dir

if [ -z "$parent_dir" ]; then
    echo "Error: Parent folder name is required!"
    exit 1
fi

# Create parent directory if it doesn't exist
if [ ! -d "$parent_dir" ]; then
    mkdir -p "$parent_dir"
    echo "Created parent directory: $parent_dir"
fi

echo
echo "Extracting all .arc files in '$arc_folder'..."
echo

count=0

for arc_file in "$arc_folder"/*.arc; do
    if [ -f "$arc_file" ]; then
        arc_name="${arc_file%.arc}"
        
        echo "[$count] Extracting: $arc_file"
        echo "   Output: $parent_dir/$arc_name"
        
        python3 "$script" "$arc_file" "$parent_dir/$arc_name"
        echo
        
        ((count++))
    fi
done

if [ $count -eq 0 ]; then
    echo "No .arc files found in '$arc_folder'."
else
    echo "================================================"
    echo "Done! Extracted $count archive(s) to '$parent_dir'."
    echo "================================================"
fi

echo
read -p "Press Enter to continue..."
