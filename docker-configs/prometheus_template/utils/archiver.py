import os
import sys
import subprocess
import datetime

def main():
    # Check if source directory is provided
    if len(sys.argv) != 2:
        print("Usage: python archive.py <source_directory>")
        sys.exit(1)

    source_dir = sys.argv[1]

    # Create archives directory if not exists
    archives_dir = "archives"
    os.makedirs(archives_dir, exist_ok=True)

    # Get current timestamp
    timestamp = datetime.datetime.now().strftime('%s')

    # Create target file path
    target_file = os.path.join(archives_dir, f"{os.path.basename(source_dir)}_{timestamp}.7z")

    # 7zip command with all parameters
    command = [
        '7z',
        'a',
        '-t7z',
        '-mx=9',
        '-mfb=273',
        '-ms',
        '-md=31',
        '-myx=9',
        '-mtm=-',
        '-mmt',
        '-mmtf',
        '-md=1536m',
        '-mmf=bt3',
        '-mmc=10000',
        '-mpb=0',
        '-mlc=0',
        target_file,
        source_dir
    ]

    try:
        # Run the 7zip command
        result = subprocess.run(command, check=True, capture_output=True, text=True)

        # Check if the directory was added successfully
        if result.returncode == 0:
            print(f"Successfully archived {source_dir} to {target_file}")
        else:
            print(f"Error archiving {source_dir}:")
            print(result.stderr)
            sys.exit(1)

    except subprocess.CalledProcessError as e:
        print(f"Error executing 7z: {e.stderr}")
        sys.exit(1)
    except FileNotFoundError:
        print("7z executable not found. Please ensure 7-Zip is installed and available in PATH.")
        sys.exit(1)

if __name__ == "__main__":
    main()