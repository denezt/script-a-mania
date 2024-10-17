#!/bin/bash
# Migration Analyzer for Java 8 to 21

# Define session directory
dirname='java8to21'

# Define logfile
_date="$(date '+%s')"
logfile="analysis_results-${_date}.txt"

error(){
    printf "\033[35mError:\t\033[31m${1}\033[0m\n"
    exit 1
}

parse_project_dir(){
    PROJECT_DIR=$1
    if  [ ! -d "${PROJECT_DIR}" ];
    then
        error "Unable to locate \'${PROJECT_DIR}\'"
    fi
}

write_to_log(){
    [ ! -d "${dirname}" ] && mkdir -v "${dirname}"
    log_entry="${1}"
    echo "${log_entry}" | tee -a ${dirname}/$logfile
}

# Looking for any deprecated packages
find_deprecated(){
    PROJECT_DIR=$1
    echo "------------------------------------------------"
    echo "Checking for deprecated APIs..."
    for f in $(grep -r --include="*.java" "@Deprecated" "$PROJECT_DIR");
    do
        write_to_log $f
    done
}

# Checking if javax packages exist
find_javax(){
    PROJECT_DIR=$1
    echo "------------------------------------------------"
    echo "Checking for javax package usage (potential migration needed to Jakarta EE)..."
    for f in $(grep -r --include="*.java" "javax." "$PROJECT_DIR");
    do
        write_to_log $f
    done
}

# Looking for internal API usage (e.g., sun.misc.Unsafe)
find_api_internal(){
    PROJECT_DIR=$1
    echo "------------------------------------------------"
    echo "Checking for usage of internal APIs (sun.*)..."
    for f in $(grep -r --include="*.java" "sun." "$PROJECT_DIR");
    do
        write_to_log $f
    done
}

# Looking for reflective access (which might cause issues with Java Modules)
find_reflectives(){
    PROJECT_DIR=$1
    echo "------------------------------------------------"
    echo "Checking for reflective access usage (possible illegal reflective access in Java 9+)..."
    for f in $(grep -r --include="*.java" "Class.forName\|getDeclaredField\|setAccessible" "$PROJECT_DIR");
    do
        write_to_log $f
    done
}

# Check for refactoring older Java 8 contained 
find_refactor_candidates(){
    echo "------------------------------------------------"
    echo "Identifying usage of old Java language constructs (optional but refactor candidates)..."
    # Look for old-style for loops which could be replaced with Streams
    for f in $(grep -r --include="*.java" "for (.* : .*Iterable" "$PROJECT_DIR");
    do
        write_to_log $f
    done
}

# List the project's dependencies (checking for old versions)
list_project_dependencies(){
    PROJECT_DIR=$1
    BUILD_TOOL=$2
    if [ -n "${BUILD_TOOL}" ];
    then
        echo "------------------------------------------------"    
        case $build_tool in
            gradle)
            echo "Listing dependencies from build tools Gradle..."
            [ -z "$(command -v gradle)" ] && error "Missing build automation program 'gradle'"
            if [ -f "$PROJECT_DIR/pom.xml" ]; then
                echo "Found Maven project. Listing dependencies from pom.xml..."
                for f in $(mvn -f "$PROJECT_DIR/pom.xml" dependency:tree);
                do
                    write_to_log $f
                done
            else
                echo "No Maven POM (Project Object Model) file found. Please ensure you check your dependencies manually."
            fi
            ;;
            maven) 
            echo "Listing dependencies from build tools Maven..."
            [ -z "$(command -v mvn)" ] && error "Missing build automation program 'mvn'"
            if [ -f "$PROJECT_DIR/build.gradle" ]; then
                echo "Found Gradle project. Listing dependencies from build.gradle..."
                for f in $(gradle --scan --info --no-daemon -p "$PROJECT_DIR" dependencies 2> /dev/null);
                do
                    write_to_log $f
                done
            else
                echo "No Gradle build file found. Please ensure you check your dependencies manually."
            fi
            ;;
        esac
    else
        write_to_log "No build tool was defined, skipping maven and gradle project dependencies check."
    fi
}

# Check for JAR files that might need module migration
find_jars(){
    PROJECT_DIR=$1
    echo "------------------------------------------------"
    echo "Identifying any JARs that might need module migration..."
    find "$PROJECT_DIR" -name "*.jar" -exec jdeps {} \;
    echo "------------------------------------------------"
    echo "Scan complete. Review the results for changes needed before upgrading to Java 21."
}

run_all_checks(){
    PROJECT_DIR=$1
    parse_project_dir "${PROJECT_DIR}"
    write_to_log "Checking Project: ${PROJECT_DIR}"
    echo "Scanning Java 8 project for issues before migrating to Java 21..." 
    find_deprecated "${PROJECT_DIR}"
    find_javax "${PROJECT_DIR}"
    find_api_internal "${PROJECT_DIR}"
    find_reflectives "${PROJECT_DIR}"
    find_refactor_candidates "${PROJECT_DIR}"
    list_project_dependencies "${PROJECT_DIR}"
    find_jars "${PROJECT_DIR}"
    exit 0
}

extract_value(){
    echo "${1}" | cut -d'=' -f2 | cut -d':' -f2
}

usage(){
    printf "\033[35m$0\t\033[32m--action=run-checks --dir=/my/java/project\033[0m\n"
}

build_tool(){
    printf "\033[36mBUILD TOOLS:\033[0m\n"
    printf "\033[35mGradle Build\t\033[32m[ gradle ]\033[0m\n"
    printf "\033[35mMaven Build\t\033[32m[ maven ]\033[0m\n"
}

commands(){
    printf "\033[36mCOMMANDS:\033[0m\n"
    printf "\033[35mRun Checks\t\033[32m[ rc, run-checks ]\033[0m\n"
    echo;
    build_tool
}

help_menu(){
    printf "\033[36mJava 8 to 21 Update Analyzer\033[0m\n"
    printf "\033[35mExecute Action\t\033[32m[ action:{COMMAND}, --action={COMMAND}, exec:{COMMAND}, --exec={COMMAND} ]\033[0m\n"
    printf "\033[35mDefine Project\t\033[32m[ dir:{PROJECT_DIR}, --dir={PROJECT_DIR}, project:{PROJECT_DIR}, --projec={PROJECT_DIR} ]\033[0m\n"
    echo;
    commands
    usage
    exit 0
}

for argv in $@
do
    case $argv in
        help|-h|-help|--help) help_menu;;
        dir:*|--dir=*|project:*|--project=*) _project_dir=$(extract_value "${argv}");;
        action:*|--action=*|exec:*|--exec=*) _action=$(extract_value "${argv}");;
        bt:*|--bt=*|build-tool:*|--build-tool=*) _build_tool=$(extract_value "${argv}");;
        *) error "Invalid parameter was given";;
    esac
done

case $_action in
    rc|run-checks)
    run_all_checks ${_project_dir}
    ;;
    *) error "Invalid or unable to execute parameter $_action";;
esac