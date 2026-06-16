import os
import datetime
from pathlib import Path
import glob
from typing import Dict, Any
import ollama  # Real Ollama client library

# -------------------------------------------------------------------
# Configuration – adjust to your needs
# -------------------------------------------------------------------
MODEL_NAME = "gemma4:e2b"          # or any model you have pulled locally
OUTPUT_DIR = "generated_reports"

# -------------------------------------------------------------------
# Core analysis function using the real Ollama API
# -------------------------------------------------------------------
def analyze_config_with_ollama(file_content: str, file_path: Path) -> str:
    """
    Send the configuration content to a local Ollama model and return its analysis.
    """

    # Detailed system prompt
    system_prompt = (
        "You are a Senior DevOps and Observability Expert. "
        "Analyze the following YAML configuration from a Prometheus or Alertmanager system. "
        "Identify any potential performance bottlenecks, critical misconfigurations, or areas "
        "for improved alerting logic. Provide a detailed, actionable analysis in Markdown format. "
        "Focus on operational health and reliability. "
        "If the file is not a valid configuration, mention that clearly."
    )

    # Prepare the user message containing the file content
    user_prompt = f"--- START OF CONFIG ---\n{file_content}\n--- END OF CONFIG ---"

    try:
        # Real call to Ollama chat API
        response = ollama.chat(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ]
        )
        # Extract the text content from the response
        return response['message']['content']

    except ollama.ResponseError as e:
        print(f"Ollama API error for {file_path.name}: {e.error}")
        return f"## ❌ Ollama API Error\nCould not process the file: {e.error}"
    except ConnectionError as e:
        print(f"Could not connect to Ollama server for {file_path.name}: {e}")
        return f"## ❌ Connection Error\nMake sure Ollama is running locally and accessible."
    except Exception as e:
        print(f"Unexpected error during LLM analysis for {file_path.name}: {e}")
        return f"## ❌ Analysis Failed\nAn unexpected error occurred: {e}"


# -------------------------------------------------------------------
# Main report generation logic
# -------------------------------------------------------------------
def generate_intelligent_report(base_dir: str = ".", output_dir: str = OUTPUT_DIR):
    """
    Scan the configuration directory, analyse each YAML file with the local Ollama model,
    and write the generated reports into the output directory.
    """

    print("--- Starting Intelligent Configuration Report Generation ---")

    # 1. Prepare output directory
    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)
    print(f"Output directory: {os.path.abspath(output_dir)}\n")

    # 2. Locate all YAML files inside the config directory
    config_path = Path(base_dir)
    if not config_path.exists():
        print(f"ERROR: Directory '{base_dir}' does not exist. Please create it and place your YAML files there.")
        return

    yaml_files = list(config_path.glob("*.yaml")) + list(config_path.glob("*.yml"))
    if not yaml_files:
        print(f"ERROR: No .yaml or .yml files found in '{base_dir}'.")
        return

    print(f"Found {len(yaml_files)} file(s) to process.\n")

    # 3. Process each file
    for file_path in yaml_files:
        print(f"--- Analysing: {file_path.name} ---")

        # Read the file content
        try:
            with open(file_path, 'r') as f:
                content = f.read()
        except Exception as e:
            print(f"❌ Could not read {file_path.name}: {e}")
            continue

        # Get the LLM analysis (this now uses the real Ollama client)
        analysis = analyze_config_with_ollama(content, file_path)

        # Compose the final report text with a timestamp
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        report_content = (
            f"# Intelligent Configuration Report\n"
            f"**File:** {file_path.name}\n"
            f"**Generated on:** {timestamp}\n\n"
            f"{analysis}\n"
        )

        # Write report to output directory
        output_filename = file_path.stem + "_analysis.md"
        report_path = output_path / output_filename
        try:
            with open(report_path, 'w') as out_f:
                out_f.write(report_content)
            print(f"✅ Report saved: {report_path}\n")
        except Exception as e:
            print(f"❌ Failed to write report for {file_path.name}: {e}\n")

    print("=================================================")
    print("Processing Complete.")
    print("Reports are available in:", os.path.abspath(output_dir))


# -------------------------------------------------------------------
# Guard to run the script directly
# -------------------------------------------------------------------
if __name__ == "__main__":
    # Ensure the config directory exists (create it if missing)
    for dir_name in ["./prometheus", "./alertmanager"]:
        generate_intelligent_report(base_dir=dir_name, output_dir=OUTPUT_DIR)