#!/bin/bash

echo "================================================"
echo "   DSC Analyze Keys - Batch Processing Tool"
echo "================================================"
echo

# Find analyze_key.py
if [ -f "analyze_key.py" ]; then
    script="analyze_key.py"
elif [ -f "../analyze_key.py" ]; then
    script="../analyze_key.py"
else
    echo "Error: analyze_key.py not found!"
    echo "Please make sure analyze_key.py is in the current directory or parent directory."
    exit 1
fi

read -p "Enter folder with DSC files to analyze: " folder

if [ ! -d "$folder" ]; then
    echo "Error: Folder '$folder' does not exist!"
    exit 1
fi

echo
echo "Analyzing all DSC (extensionless) files in '$folder'..."
echo

count=0
output_file="keys.txt"

# Clear or create keys.txt
> "$output_file"

for filepath in "$folder"/*; do
    if [ -f "$filepath" ]; then
        filename=$(basename "$filepath")
        
        # Check if file has no extension (no dot in filename)
        if [[ ! "$filename" == *.* ]]; then
            echo "[$count] Analyzing: $filename"
            
            # Run analyze_key.py and capture the key
            key=$(python3 "$script" "$filepath" | grep "Encryption Key:" | awk '{print $3}')
            echo "$filename - $key" >> "$output_file"
            
            ((count++))
        fi
    fi
done

echo
echo "================================================"

if [ $count -eq 0 ]; then
    echo "No DSC (extensionless) files found in '$folder'."
    rm -f "$output_file"
else
    echo "Done! Analyzed $count file(s)."
    echo "Keys saved to: $output_file"
fi

echo
read -p "Press Enter to continue..."
