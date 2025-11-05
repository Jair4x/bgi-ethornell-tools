#!/bin/bash

echo "================================================"
echo "   ARC Rebuild - Batch Processing Tool"
echo "================================================"
echo

# Find arc_rebuild.py
if [ -f "arc_rebuild.py" ]; then
    script="arc_rebuild.py"
elif [ -f "../arc_rebuild.py" ]; then
    script="../arc_rebuild.py"
else
    echo "Error: arc_rebuild.py not found!"
    echo "Please make sure arc_rebuild.py is in the current directory or parent directory."
    exit 1
fi

read -p "Enter parent folder name (e.g., extracted): " parent

if [ ! -d "$parent" ]; then
    echo "Error: Folder '$parent' does not exist!"
    exit 1
fi

echo
echo "Processing all subfolders in '$parent'..."
echo

count=0

for folder in "$parent"/*/; do
    if [ -d "$folder" ]; then
        name=$(basename "$folder")
        echo "[$count] Processing: $name"
        python3 "$script" "$folder" "$name"
        echo
        ((count++))
    fi
done

if [ $count -eq 0 ]; then
    echo "No subfolders found in '$parent'."
else
    echo "================================================"
    echo "Done! Processed $count folder(s)."
    echo "All .arc.new files have been created."
    echo "================================================"
fi

echo
read -p "Press Enter to continue..."
