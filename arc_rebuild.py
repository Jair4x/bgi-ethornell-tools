import os
import sys

# Config
HEADER = b"BURIKO ARC20"  # BGI/Ethornell's .arc files always start with this header in bytes.
HEADER_SIZE = 12
FILE_ENTRY_SIZE = 128  # 96 (name) + 4 (offset) + 4 (size) + 24 (padding)

# Create the .arc file
def create_arc(input_files, output_file):
    offsets = []
    sizes = []
    data_offset = 0

    with open(output_file, "wb") as arc_file:
        """
        Write Header
        """
        arc_file.write(HEADER)  # "BURIKO ARC20" as the header
        arc_file.write(len(input_files).to_bytes(4, "little"))  # File count

        """
        Create Index
        """
        for file_path in input_files:
            file_name = os.path.basename(file_path)
            file_size = os.path.getsize(file_path)

            # Save name with padding
            name_encoded = file_name.encode("shift_jis")[:96]  # Truncate if too long
            name_padded = name_encoded + b"\x00" * (96 - len(name_encoded))
            arc_file.write(name_padded)

            # Save offset and size
            arc_file.write(data_offset.to_bytes(4, "little"))
            arc_file.write(file_size.to_bytes(4, "little"))

            # Save extra padding (24 bytes)
            arc_file.write(b"\x00" * 24)

            # Register offset and size
            offsets.append(data_offset)
            sizes.append(file_size)

            # Update the next offset
            data_offset += file_size

        """
        Writing data
        """
        for file_path in input_files:
            with open(file_path, "rb") as f:
                raw_data = f.read()
                arc_file.write(raw_data)
            print(f"File added: {file_path}")

    print(f"File created: {output_file}")
    print("Delete the .new extension when replacing the original .arc file.")


def main():
    # Check command-line arguments
    if len(sys.argv) != 3:
        print("Usage: python arc_rebuild.py <input_folder> <output_file>")
        print("Example: python arc_rebuild.py extracted/data01500 data01500_edited.arc")
        print("         python arc_rebuild.py data01500 data01500_edited.arc")
        sys.exit(1)

    input_folder = sys.argv[1]
    output_file = sys.argv[2]

    # Make sure the input folder exists
    if not os.path.exists(input_folder):
        print(f"Error: Input folder '{input_folder}' does not exist.")
        sys.exit(1)

    if not os.path.isdir(input_folder):
        print(f"Error: '{input_folder}' is not a directory.")
        sys.exit(1)

    # Get all DSC (extensionless) files inside the input folder
    input_files = [
        os.path.join(input_folder, file_name)
        for file_name in os.listdir(input_folder)
        if os.path.isfile(os.path.join(input_folder, file_name)) and "." not in file_name
    ]

    if not input_files:
        print(f"Error: No DSC (extensionless) files found in '{input_folder}'.")
        sys.exit(1)

    
    # Rename the output file
    if not output_file.endswith(".arc"):
        output_file = output_file + ".arc"
        
    output_file = output_file + ".new"

    # Create the arc file
    create_arc(input_files, output_file)


if __name__ == "__main__":
    main()
