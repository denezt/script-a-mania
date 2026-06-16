import os
import datetime
import glob
import ollama

def generate_config_report(base_dir=".", output_dir="generated_reports"):
    """
    Scans a base directory for YAML/JSON configuration files and generates a consolidated report.

    Args:
        base_dir (str): The root directory to scan. Defaults to the current directory.
        output_dir (str): The directory where the final report will be saved.
    """
    print(f"Starting scan in: {os.path.abspath(base_dir)}")

    # 1. Prepare output directory
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created output directory: {output_dir}")

    all_configs = []
    # Define the specific directories to scan (can be customized)
    directories_to_scan = [
        os.path.join(base_dir, "prometheus"),
        os.path.join(base_dir, "alertmanager")
    ]

    # 2. Scan for files
    for d in directories_to_scan:
        if not os.path.exists(d):
            print(f"Warning: Directory not found: {d}")
            continue

        # Use glob to find all relevant config files recursively or directly
        # Using glob for simplicity here, targeting common config files
        for root, _, files in os.walk(d):
            for file in files:
                # Only process files that look like configuration files (e.g., .yml, .yaml)
                if file.endswith(('.yml', '.yaml')):
                    full_path = os.path.join(root, file)
                    all_configs.append(full_path)

    if not all_configs:
        print("No configuration files found to process.")
        return

    # 3. Generate the consolidated report
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    report_filename = os.path.join(output_dir, f"config_report_{timestamp}.txt")

    with open(report_filename, 'w') as f:
        f.write("========================================================\n")
        f.write(f"CONSOLIDATED CONFIGURATION REPORT\n")
        f.write(f"Generated On: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Source Directory Scanned: {os.path.abspath(base_dir)}\n")
        f.write("========================================================\n\n")
        f.write(f"Found {len(all_configs)} Configuration Files:\n")
        f.write("-" * 50 + "\n")
        for config_path in all_configs:

            # Optionally, you could use yaml.safe_load here to parse the data,
            # but for a simple report, listing the paths is sufficient.
            f.write(f"FILE FOUND: {config_path}\n")
            f.write("-" * 20 + "\n")

    print("\n" + "="*50)
    print(f"✅ Report successfully generated!")
    print(f"Report saved to: {os.path.abspath(report_filename)}")
    print("="*50)

if __name__ == "__main__":
    # Execute the main function
    generate_config_report(base_dir=".", output_dir="generated_reports")
