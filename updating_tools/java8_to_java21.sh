#!/bin/bash
# Migration Analyzer for Java 8 to 21

# Define session directory
DIRNAME='java8to21'

error(){
    printf "\033[35mError:\t\033[31m${1}\033[0m\n"
    exit 1
}

extract_value(){
    echo "${1}" | cut -d'=' -f2 | cut -d':' -f2
}

# Setup Project directory and name
for argv in $@
do
    case $argv in
        dir:*|--dir=*|project:*|--project=*) PROJECT_DIR=$(extract_value "${argv}");;
    esac
done

# Define CSV filename
DATESTAMP="$(date '+%s')"
FILENAME="analysis_data-${DATESTAMP}"
CSVFILE="${DIRNAME}/${PROJECT_DIR}/${FILENAME}.csv"
LOGFILE="${DIRNAME}/${PROJECT_DIR}/${FILENAME}.log"
REFACTOR="${DIRNAME}/${PROJECT_DIR}/${FILENAME}.txt"

parse_project_dir(){
    if  [ ! -d "$PROJECT_DIR" ];
    then
        error "Unable to locate \'${PROJECT_DIR}\'"
    fi
}

write_to_log(){
    log_entry="${1}"
    # Create the main and project directories
    [ ! -d "${DIRNAME}" ] && mkdir -vp "${DIRNAME}/${PROJECT_DIR}"
    printf "[ $(date '+%F %T') ] ${log_entry}\n" | tee -a $LOGFILE
}

# Looking for any deprecated packages 
find_deprecated(){
    write_to_log "------------------------------------------------"
    write_to_log "Checking for deprecated APIs..."
    found_deprecates=$(egrep -r --include="*.java" "@Deprecated" $PROJECT_DIR)
    if [ -n "${found_deprecates}" ];
    then
        # Stream into CSV file.
        echo '"Checking for deprecated APIs",""' | tee -a $REFACTOR
        egrep -r --include="*.java" "@Deprecated" "$PROJECT_DIR" | tee -a $REFACTOR
    else
        write_to_log "No deprecated APIs were found"
    fi
}

# Checking if javax packages exist
find_javax(){
    PROJECT_NAME="${PROJECT_NAME}"
    write_to_log "------------------------------------------------"
    write_to_log "Checking for javax package usage (potential migration needed to Jakarta EE)..."
    found_javax=$(egrep -r --include="*.java" "javax\.[a-z]" $PROJECT_DIR)
    if [ -n "${found_javax}" ];
    then
        echo '"Checking for javax package usage (potential migration needed to Jakarta EE)..."," "' | tee -a $CSVFILE
        egrep -r --include="*.java" "javax\.[a-z]" "$PROJECT_DIR" | sed 's/^/\"/g' | sed 's/\:/\"\,\"/g' | sed 's/\;/\"/g' | tee -a $CSVFILE
    else
        write_to_log "No javax packages or imports were found"
    fi
}

# Looking for internal API usage (e.g., sun.misc.Unsafe)
find_api_internal(){
    write_to_log "------------------------------------------------"
    write_to_log "Checking for usage of internal APIs (sun.*)..."
    found_api_internal=$(egrep -r --include="*.java" "sun\.[a-z]" $PROJECT_DIR)
    if [ -n "${found_api_internal}" ];
    then
        echo '"Checking for usage of internal APIs (sun.*)..."," "' | tee -a $CSVFILE
        egrep -r --include="*.java" "sun\.[a-z]" $PROJECT_DIR | sed 's/^/\"/g' | sed 's/[[:punct:]]$//g' | sed 's/\:/\",\"/g' | sed 's/$/\"/g' | tee -a $CSVFILE
    else
        write_to_log "No sun.* packages or imports were found"
    fi
}

# Looking for reflective access (which might cause issues with Java Modules)
find_reflectives(){
    write_to_log "------------------------------------------------"
    write_to_log "Checking for reflective access usage (possible illegal reflective access in Java 9+)..."
    found_reflectives=$(egrep -r --include="*.java" "Class.forName\|getDeclaredField\|setAccessible" $PROJECT_DIR)
    if [ -n "${found_reflectives}" ];
    then
        echo 'Checking for reflective access usage (possible illegal reflective access in Java 9+)...' | tee -a $REFACTOR
        egrep -r --include="*.java" "Class.forName\|getDeclaredField\|setAccessible" $PROJECT_DIR | tee -a $REFACTOR
    else
        write_to_log "No reflective 'Class.forName\|getDeclaredField\|setAccessible' were found"
    fi
}

# Check for refactoring older Java 8 contained 
find_refactor_candidates(){
    write_to_log "------------------------------------------------"
    write_to_log "Identifying usage of old Java language constructs (optional but refactor candidates)..."
    # Look for old-style for loops which could be replaced with Streams
    found_refactor_candidates=$(egrep -r --include="*.java" "for \(.* : .*Iterable" $PROJECT_DIR)
    if [ -n "${found_refactor_candidates}" ];
    then
        echo 'Identifying usage of old Java language constructs (optional but refactor candidates)...' | tee -a $REFACTOR
        egrep -r --include="*.java" "for \(.* : .*Iterable" $PROJECT_DIR | tee -a $REFACTOR
    else
        write_to_log "No refactoring candidates as in 'for \(.* : .*Iterable' were found"
    fi
}

# List the project's dependencies (checking for old versions)
list_project_dependencies(){
    BUILD_TOOL=$1
    write_to_log "------------------------------------------------"
    case $build_tool in
    gradle)
    write_to_log "Listing dependencies from build tools Gradle..."
    [ -z "$(command -v gradle)" ] && error "Missing build automation program 'gradle'"
    if [ -f "$PROJECT_DIR/pom.xml" ]; then
        write_to_log "Found Maven project. Listing dependencies from pom.xml..."
        loaded_dep_tree=$(mvn -f $PROJECT_DIR/pom.xml dependency:tree)
        if [ -n "${loaded_dep_tree}" ];
        then
            mvn -f "$PROJECT_DIR/pom.xml" dependency:tree | tee -a $REFACTOR
        fi
    else
        write_to_log "No Maven POM (Project Object Model) file found. Please ensure you check your dependencies manually."
    fi
    ;;
    maven)
    echo "Listing dependencies from build tools Maven..."
    [ -z "$(command -v mvn)" ] && error "Missing build automation program 'mvn'"
    if [ -f "$PROJECT_DIR/build.gradle" ]; then
        write_to_log "Found Gradle project. Listing dependencies from build.gradle..."
        loaded_grade_deps=$(gradle --scan --info --no-daemon -p $PROJECT_DIR dependencies 2> /dev/null)
        if [ -n "${loaded_grade_deps}" ];
        then
            gradle --scan --info --no-daemon -p $PROJECT_DIR dependencies 2> /dev/null | tee -a $REFACTOR
        fi
    else
        write_to_log "No Gradle build file found. Please ensure you check your dependencies manually."
    fi
    ;;
    esac
}

# Check for JAR files that might need module migration
find_jars(){
    write_to_log "------------------------------------------------"
    write_to_log "Identifying any JARs that might need module migration..."
    found_jars=$(find $PROJECT_DIR -name "*.jar" -exec jdeps {} \;)
    if [ -n "${found_jars}" ];
    then
        echo "Identifying any JARs that might need module migration..." | tee -a $REFACTOR
        find $PROJECT_DIR -name "*.jar" -exec jdeps {} \; | tee -a $REFACTOR
    else
        write_to_log "No JARs were found"
    fi
    write_to_log "------------------------------------------------"
    write_to_log "Scan complete. Review the results for changes needed before upgrading to Java 21."
}

run_all_checks(){
    BUILD_TOOL=$1
    parse_project_dir "${PROJECT_DIR}"
    write_to_log "Checking Project: ${PROJECT_DIR}"
    echo "Scanning Java 8 project for issues before migrating to Java 21..." 
    find_deprecated
    find_javax
    find_api_internal
    find_reflectives
    find_refactor_candidates
    # Apply when build tool is set
    if [ -n "${BUILD_TOOL}" ];
    then
        list_project_dependencies "${BUILD_TOOL}"
    else
        write_to_log "Skipping build tool dependencies as no build build was defined"
    fi
    find_jars
    exit 0
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
        action:*|--action=*|exec:*|--exec=*) _action=$(extract_value "${argv}");;
        bt:*|--bt=*|build-tool:*|--build-tool=*) _build_tool=$(extract_value "${argv}");;
    esac
done

case $_action in
    rc|run-checks)
    run_all_checks "${_build_tool}"
    ;;
    *) error "Invalid or unable to execute parameter $_action";;
esac
