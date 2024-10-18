#!/usr/bin/env python3

import os
import re
import sys
import subprocess
from datetime import datetime

# Define session directory
dirname = 'java8to21'

# Define CSV filename
timestamp = datetime.now().strftime('%s')
filename = f"analysis_data-{timestamp}"
csvfile = os.path.join(dirname, f"{filename}.csv")
logfile = os.path.join(dirname, f"{filename}.log")
refactor_file = os.path.join(dirname, f"{filename}.refr")

def error(message):
    print(f"\033[35mError:\t\033[31m{message}\033[0m")
    sys.exit(1)

def parse_project_dir(project_dir):
    if not os.path.isdir(project_dir):
        error(f"Unable to locate '{project_dir}'")

def write_to_log(log_entry):
    os.makedirs(dirname, exist_ok=True)
    with open(logfile, 'a') as log:
        log.write(f"[ {datetime.now().strftime('%F %T')} ] {log_entry}\n")
    print(f"[ {datetime.now().strftime('%F %T')} ] {log_entry}")

def find_deprecated(project_dir):
    write_to_log("------------------------------------------------")
    write_to_log("Checking for deprecated APIs...")
    
    deprecated_files = subprocess.run(
        ["egrep", "-r", "--include=*.java", "@Deprecated", project_dir],
        capture_output=True, text=True).stdout

    if deprecated_files:
        with open(refactor_file, 'a') as ref:
            ref.write("Checking for deprecated APIs\n")
            ref.write(deprecated_files)
        print(deprecated_files)
    else:
        write_to_log("No deprecated APIs were found")

def find_javax(project_dir):
    write_to_log("------------------------------------------------")
    write_to_log("Checking for javax package usage (potential migration needed to Jakarta EE)...")
    
    javax_files = subprocess.run(
        ["egrep", "-r", "--include=*.java", "javax.", project_dir],
        capture_output=True, text=True).stdout

    if javax_files:
        with open(csvfile, 'a') as csv:
            csv.write('"Checking for javax package usage (potential migration needed to Jakarta EE)...",""\n')
            csv.write(re.sub(r'[:;]', '","', javax_files))
        print(javax_files)

def find_api_internal(project_dir):
    write_to_log("------------------------------------------------")
    write_to_log("Checking for usage of internal APIs (sun.*)...")
    
    internal_api_files = subprocess.run(
        ["egrep", "-r", "--include=*.java", "sun.", project_dir],
        capture_output=True, text=True).stdout

    if internal_api_files:
        with open(csvfile, 'a') as csv:
            csv.write('"Checking for usage of internal APIs (sun.*)...",""\n')
            csv.write(re.sub(r'[:;]', '","', internal_api_files))
        print(internal_api_files)

def find_reflectives(project_dir):
    write_to_log("------------------------------------------------")
    write_to_log("Checking for reflective access usage (possible illegal reflective access in Java 9+)...")
    
    reflective_access_files = subprocess.run(
        ["egrep", "-r", "--include=*.java", "Class.forName|getDeclaredField|setAccessible", project_dir],
        capture_output=True, text=True).stdout

    if reflective_access_files:
        with open(refactor_file, 'a') as ref:
            ref.write("Checking for reflective access usage (possible illegal reflective access in Java 9+)...\n")
            ref.write(reflective_access_files)
        print(reflective_access_files)

def find_refactor_candidates(project_dir):
    write_to_log("------------------------------------------------")
    write_to_log("Identifying usage of old Java language constructs (optional but refactor candidates)...")
    
    old_construct_files = subprocess.run(
        ["egrep", "-r", "--include=*.java", r"for \(.* : .*Iterable", project_dir],
        capture_output=True, text=True).stdout

    if old_construct_files:
        with open(refactor_file, 'a') as ref:
            ref.write("Identifying usage of old Java language constructs (optional but refactor candidates)...\n")
            ref.write(old_construct_files)
        print(old_construct_files)

def list_project_dependencies(project_dir, build_tool):
    write_to_log("------------------------------------------------")
    if build_tool == 'gradle':
        write_to_log("Listing dependencies from build tools Gradle...")
        if os.path.exists(os.path.join(project_dir, 'pom.xml')):
            write_to_log("Found Maven project. Listing dependencies from pom.xml...")
            maven_result = subprocess.run(
                ["mvn", "-f", os.path.join(project_dir, 'pom.xml'), "dependency:tree"],
                capture_output=True, text=True).stdout
            if maven_result:
                with open(refactor_file, 'a') as ref:
                    ref.write(maven_result)
        else:
            write_to_log("No Maven POM (Project Object Model) file found. Please ensure you check your dependencies manually.")
    elif build_tool == 'maven':
        write_to_log("Listing dependencies from build tools Maven...")
        if os.path.exists(os.path.join(project_dir, 'build.gradle')):
            write_to_log("Found Gradle project. Listing dependencies from build.gradle...")
            gradle_result = subprocess.run(
                ["gradle", "--scan", "--info", "--no-daemon", "-p", project_dir, "dependencies"],
                capture_output=True, text=True).stdout
            if gradle_result:
                with open(refactor_file, 'a') as ref:
                    ref.write(gradle_result)
        else:
            write_to_log("No Gradle build file found. Please ensure you check your dependencies manually.")

def find_jars(project_dir):
    write_to_log("------------------------------------------------")
    write_to_log("Identifying any JARs that might need module migration...")
    
    jars_result = subprocess.run(
        ["find", project_dir, "-name", "*.jar", "-exec", "jdeps", "{}", ";"],
        capture_output=True, text=True).stdout

    if jars_result:
        with open(refactor_file, 'a') as ref:
            ref.write(jars_result)
        print(jars_result)

    write_to_log("------------------------------------------------")
    write_to_log("Scan complete. Review the results for changes needed before upgrading to Java 21.")

def run_all_checks(project_dir, build_tool):
    parse_project_dir(project_dir)
    write_to_log(f"Checking Project: {project_dir}")
    print("Scanning Java 8 project for issues before migrating to Java 21...")

    find_deprecated(project_dir)
    find_javax(project_dir)
    find_api_internal(project_dir)
    find_reflectives(project_dir)
    find_refactor_candidates(project_dir)

    if build_tool:
        list_project_dependencies(project_dir, build_tool)

    find_jars(project_dir)

def extract_value(argument):
    return argument.split('=')[-1].split(':')[-1]

def usage():
    print("\033[35mUsage:\t\033[32mpython migration_analyzer.py --action=run-checks --dir=/my/java/project\033[0m")

def commands():
    print("\033[36mCOMMANDS:\033[0m")
    print("\033[35mRun Checks\t\033[32m[ rc, run-checks ]\033[0m\n")

def help_menu():
    print("\033[36mJava 8 to 21 Update Analyzer\033[0m")
    print("\033[35mExecute Action\t\033[32m[ action:{COMMAND}, --action={COMMAND}, exec:{COMMAND}, --exec={COMMAND} ]\033[0m")
    print("\033[35mDefine Project\t\033[32m[ dir:{PROJECT_DIR}, --dir={PROJECT_DIR}, project:{PROJECT_DIR}, --project={PROJECT_DIR} ]\033[0m\n")
    commands()
    usage()

if __name__ == '__main__':
    _project_dir = None
    _action = None
    _build_tool = None

    for argv in sys.argv[1:]:
        if argv.startswith(('help', '-h', '--help')):
            help_menu()
            sys.exit(0)
        elif argv.startswith(('dir:', '--dir=', 'project:', '--project=')):
            _project_dir = extract_value(argv)
        elif argv.startswith(('action:', '--action=', 'exec:', '--exec=')):
            _action = extract_value(argv)
        elif argv.startswith(('bt:', '--bt=', 'build-tool:', '--build-tool=')):
            _build_tool = extract_value(argv)
        else:
            error("Invalid parameter was given")

    if _action == 'rc' or _action == 'run-checks':
        run_all_checks(_project_dir, _build_tool)
    else:
        error(f"Invalid or unable to execute parameter {_action}")
