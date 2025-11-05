# BGI/Ethornell Tools

A collection of Python tools and batch scripts for extracting, decompressing, compressing, and rebuilding BGI/Ethornell .arc archive and DSC (Extensionless) files.

## List of tools

### Arc_extract

A tool to extract all the files inside a .arc archive file. The extracted files are compressed DSC files, so to work on them you need to decompress them first.

**Usage:** `python arc_extract.py <arc_file> [output_dir]`

**Examples:**

- `python arc_extract.py data01500.arc` (Output directory is the name of the file + `"_extracted"`)
- `python arc_extract.py data01500.arc "Extracted files"`

### Arc_rebuild

A tool to remake the .arc file in order to replace it for the patch. Works with both compressed and decompressed DSC (extensionless) files.

**Usage:** `python arc_rebuild.py <input_folder> <output_arc_file>`

**Examples:**

- `python arc_rebuild.py extracted/data01500 data01500_edited` (subfolder)
- `python arc_rebuild.py data01500 data01500_edited` (plain folder)

**Note:** The script automatically adds `.arc.new` extension to the output file. You should remove the `.new` extension when replacing the original .arc file.

### DSC_decompress

A tool to decompress the DSC (extensionless) files you get when extracting the .arc archives using Arc_extract.

Based on the logic GARbro uses when extracting files from a .arc archive file, so you don't need this if you extracted the .arc files using GARbro.

**Usage:** `python dsc_decompress.py <input> [output_file_or_folder]`

**Examples:**

- `python dsc_decompress.py 01_Epilogue1 01_Epilogue1_decompressed`
- `python dsc_decompress.py 01_Epilogue1 decompressed/` (saves to folder with original filename)

### DSC_compress

A tool to compress back the DSC (extensionless) files in order to rebuild the .arc file while minimizing the final size. To get the key, you need Analyze_key.

**Usage:** `python dsc_compress.py <input_file> <output_dsc> <key_hex>`

**Example:** `python dsc_compress.py 01_epilogue1_decompressed 01_epilogue1_compressed 02207D06`

**Note:** Each DSC file has its own encryption key. Use `analyze_key.py` to extract the key from the original file before compressing.

### Analyze_key

A tool to get the encryption key of the original DSC file. The only special thing you need for DSC_compress to work.

**Usage:** `python analyze_key.py <dsc_file>`

**Example:** `python analyze_key.py 01_prologue1`

**Output:** Displays the encryption key in hex format (e.g., `0x02207D06`)

---

## Working in batches? I got you

There are batch files for both Windows (`.bat`) and Linux (`.sh`) in the `Batch (windows)` and `Batch (linux)` folders respectively. These scripts can be run from their folders or from the parent directory - they automatically search for the Python scripts in both locations.

They're made to process multiple files at once, minimizing your work if you're working with the whole game. Plus, they're interactive, so you'll know what each batch file needs.

### Requirements for batch workflow

Before starting, make sure you have:

1. **Python 3.x** installed and available in your PATH
2. **Original .arc files** in a folder (for extraction)
3. **Original compressed DSC files** preserved (needed to extract encryption keys)

### Complete Workflow

A complete workflow working with these tools should look like:

#### Method 1: Starting from .arc files (Recommended)

1. **Extract_all** - Extract all .arc files to subfolders
2. **Analyze_all** - Analyze original compressed DSC files to get encryption keys → generates `keys.txt`
3. **Decompress_all** - Decompress all DSC files for editing
4. *(Edit your decompressed files as needed)*
5. **Compress_all** - Compress edited files using keys from `keys.txt`
6. **Rebuild_all** - Rebuild .arc files from compressed DSC files

#### Method 2: If you extracted with GARbro

1. *(Files are already decompressed)*
2. **Analyze_all** - Run on original compressed DSC files (you need to keep these!) → generates `keys.txt`
3. *(Edit your files as needed)*
4. **Compress_all** - Compress edited files using keys from `keys.txt`
5. **Rebuild_all** - Rebuild .arc files from compressed DSC files

---

## Batch Scripts Documentation

### Extract_all

Extracts all .arc archive files and organizes them into subfolders.

**Interactive prompts:**

- Folder containing .arc files
- Parent folder name to create (e.g., "extracted")

**Output structure:**

```fix
extracted/
  ├── data01500/
  │   └── (compressed DSC files)
  ├── data01600/
  │   └── (compressed DSC files)
  └── script/
      └── (compressed DSC files)
```

### Decompress_all

Decompresses all DSC (extensionless) files from subfolders and organizes them into corresponding output subfolders.

**Interactive prompts:**

- Parent folder with subfolders containing DSC files
- Output parent folder name (e.g., "decompressed")

**Input structure:**

```fix
extracted/
  ├── data01500/
  │   └── (compressed DSC files)
  └── data01600/
      └── (compressed DSC files)
```

**Output structure:**

```fix
decompressed/
  ├── data01500/
  │   └── (decompressed DSC files)
  └── data01600/
      └── (decompressed DSC files)
```

**Note:** Files keep their original names, just decompressed.

### Analyze_all

Analyzes all DSC (extensionless) files in a folder and extracts their encryption keys into a `keys.txt` file.

**Interactive prompts:**

- Folder with original compressed DSC files to analyze

**Output:** Creates `keys.txt` in the current directory with format:

```fix
filename - 0x12345678
01_prologue1 - 0x02207D06
01_epilogue1 - 0x02207D06
...
```

**Important:**

- Run this on the **original compressed DSC files** (from extract_all output)
- Do NOT delete the original compressed files until after running this
- The `keys.txt` file is required for compress_all to work

### Compress_all

Compresses all DSC (extensionless) files using the encryption keys from `keys.txt`.

**Interactive prompts:**

- Folder with decompressed DSC files to compress

**Requirements:**

- `keys.txt` must exist in the current directory (generated by analyze_all)
- Each file in the input folder must have a matching key in `keys.txt`

**Output:** Creates files with `_compressed` suffix (e.g., `01_prologue1_compressed`)

**Note:** If a file doesn't have a key in `keys.txt`, it will be skipped with a warning.

### Rebuild_all

Rebuilds .arc archive files from subfolders containing DSC files (compressed or decompressed).

**Interactive prompts:**

- Parent folder name containing subfolders (e.g., "extracted")

**Input structure:**

```fix
extracted/
  ├── data01500/
  │   └── (DSC files)
  └── data01600/
      └── (DSC files)
```

**Output:** Creates `.arc.new` files:

```fix
data01500.arc.new
data01600.arc.new
```

**Note:** Remove the `.new` extension when you're ready to replace the original .arc files.

---

## Tips and Best Practices

1. **Keep your original files**: Always preserve the original compressed DSC files until you've generated `keys.txt`
2. **Organize your folders**: The batch scripts work best with a clear folder structure
3. **Test your changes**: Before replacing the original .arc files, test the uncompressed files by putting them in the parent folder, where the game's executable is at.
4. **Backup everything**: Always keep backups of original game files before modifying
5. **Check keys.txt**: After running analyze_all, verify that all files have keys in `keys.txt`

---

## Troubleshooting

**"keys.txt not found" error:**

- Run `analyze_all` first on your original compressed DSC files

**"No key found for [filename]" warning:**

- The file is missing from `keys.txt`
- Re-run `analyze_all` on the original compressed files

**Python script not found:**

- Make sure the Python scripts (`.py` files) are in the same directory as the batch scripts, or in the parent directory

**Files not being processed:**

- Batch scripts only process extensionless files (DSC files have no extension like `.txt` or `.bin`)
- Check that your files don't have hidden extensions

---

## Credits

DSC compression/decompression logic based on [GARbro](https://github.com/morkt/GARbro) by Morkt.
