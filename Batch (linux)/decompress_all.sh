#!/bin/bash

echo "================================================"
echo "   DSC Decompress - Batch Processing Tool"
echo "================================================"
echo

# Find dsc_decompress.py
if [ -f "dsc_decompress.py" ]; then
    script="dsc_decompress.py"
elif [ -f "../dsc_decompress.py" ]; then
    script="../dsc_decompress.py"
else
    echo "Error: dsc_decompress.py not found!"
    echo "Please make sure dsc_decompress.py is in the current directory or parent directory."
    exit 1
fi

read -p "Enter parent folder with subfolders (e.g., extracted): " parent

if [ ! -d "$parent" ]; then
    echo "Error: Folder '$parent' does not exist!"
    exit 1
fi

read -p "Enter output parent folder name (e.g., decompressed): " output_parent

if [ -z "$output_parent" ]; then
    echo "Error: Output folder name is required!"
    exit 1
fi

# Create output parent folder if it doesn't exist
if [ ! -d "$output_parent" ]; then
    mkdir -p "$output_parent"
    echo "Created output folder: $output_parent"
fi

echo
echo "Processing all subfolders in '$parent'..."
echo "Output parent folder: $output_parent"
echo

count=0

for subfolder in "$parent"/*/; do
    if [ -d "$subfolder" ]; then
        subfolder_name=$(basename "$subfolder")
        
        echo "================================================"
        echo "Processing subfolder: $subfolder_name"
        echo "================================================"
        
        # Create corresponding output subfolder
        output_subfolder="$output_parent/$subfolder_name"
        if [ ! -d "$output_subfolder" ]; then
            mkdir -p "$output_subfolder"
        fi
        
        subcount=0
        
        for filepath in "$subfolder"*; do
            if [ -f "$filepath" ]; then
                filename=$(basename "$filepath")
                
                # Check if file has no extension (no dot in filename)
                if [[ ! "$filename" == *.* ]]; then
                    echo "  [$subcount] Decompressing: $filename"
                    python3 "$script" "$filepath" "$output_subfolder/"
                    ((subcount++))
                fi
            fi
        done
        
        echo "  Decompressed $subcount file(s) from $subfolder_name"
        echo
        ((count+=subcount))
    fi
done

if [ $count -eq 0 ]; then
    echo "No DSC (extensionless) files found in '$parent'."
else
    echo "================================================"
    echo "Done! Decompressed $count total file(s) to '$output_parent'."
    echo "================================================"
fi

echo
read -p "Press Enter to continue..."
