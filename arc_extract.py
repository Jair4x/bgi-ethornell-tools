import struct
import sys
import os

"""
ARC File Extractor for BGI/Ethornell

Extracts all files from BURIKO ARC20 (.arc) archives
"""

def extract_arc(arc_path, output_dir=None):
    """Extract all files from an ARC archive"""
    if output_dir is None:
        output_dir = os.path.splitext(arc_path)[0] + "_extracted"
    
    os.makedirs(output_dir, exist_ok=True)
    
    with open(arc_path, 'rb') as f:
        # Read header
        signature = f.read(16)
        if not signature.startswith(b'BURIKO ARC20'):
            print("Error: Not a valid BURIKO ARC20 file")
            return
        
        file_count = struct.unpack('<I', f.read(4))[0]
        print(f"Archive: {arc_path}")
        print(f"Files: {file_count}")
        print(f"Output: {output_dir}")
        print()
        
        # Read file index
        entries = []
        for i in range(file_count):
            name_bytes = f.read(64)
            name = name_bytes.split(b'\x00', 1)[0].decode('shift-jis', errors='replace')
            offset = struct.unpack('<I', f.read(4))[0]
            size = struct.unpack('<I', f.read(4))[0]
            entries.append((name, offset, size))
        
        # Extract files
        for i, (name, offset, size) in enumerate(entries, 1):
            f.seek(offset)
            data = f.read(size)
            
            output_path = os.path.join(output_dir, name)
            
            # Create subdirectories if needed
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            
            with open(output_path, 'wb') as out:
                out.write(data)
            
            print(f"[{i}/{file_count}] {name} ({size:,} bytes)")
        
        print(f"\nExtracted {file_count} files to {output_dir}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python arc_extract.py <arc_file> [output_dir]")
        print("Example: python arc_extract.py data01500.arc")
        print("         python arc_extract.py data01500.arc extracted_files")
        sys.exit(1)
    
    arc_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None
    
    extract_arc(arc_file, output_dir)


if __name__ == "__main__":
    main()
