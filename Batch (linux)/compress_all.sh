#!/bin/bash

echo "================================================"
echo "   DSC Compress - Batch Processing Tool"
echo "================================================"
echo

# Find dsc_compress.py
if [ -f "dsc_compress.py" ]; then
    script="dsc_compress.py"
elif [ -f "../dsc_compress.py" ]; then
    script="../dsc_compress.py"
else
    echo "Error: dsc_compress.py not found!"
    echo "Please make sure dsc_compress.py is in the current directory or parent directory."
    exit 1
fi

read -p "Enter folder with DSC files to compress: " folder

if [ ! -d "$folder" ]; then
    echo "Error: Folder '$folder' does not exist!"
    exit 1
fi

if [ ! -f "keys.txt" ]; then
    echo "Error: keys.txt not found!"
    echo "Please run analyze_all.sh first to generate the keys file."
    exit 1
fi

echo
echo "Reading keys from keys.txt..."
echo "Processing all DSC (extensionless) files in '$folder'..."
echo

count=0

for filepath in "$folder"/*; do
    if [ -f "$filepath" ]; then
        filename=$(basename "$filepath")
        
        # Check if file has no extension (no dot in filename)
        if [[ ! "$filename" == *.* ]]; then
            # Find the key for this file from keys.txt
            key=$(grep "^$filename - " keys.txt | awk '{print $3}')
            
            if [ -n "$key" ]; then
                echo "[$count] Compressing: $filename with key $key"
                python3 "$script" "$filepath" "${filepath}_compressed" "$key"
                echo
                ((count++))
            else
                echo "[$count] Warning: No key found for $filename in keys.txt, skipping..."
                echo
            fi
        fi
    fi
done

if [ $count -eq 0 ]; then
    echo "No DSC (extensionless) files found in '$folder'."
else
    echo "================================================"
    echo "Done! Compressed $count file(s)."
    echo "All files saved with '_compressed' suffix."
    echo "================================================"
fi

echo
read -p "Press Enter to continue..."
