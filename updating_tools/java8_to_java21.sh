#!/bin/bash
# Migration Analyzer for Java 8 to 21

# Define session directory
dirname='java8to21'

# Define CSV filename
_date="$(date '+%s')"
filename="analysis_data-${_date}"
csvfile="${dirname}/${filename}.csv"
logfile="${dirname}/${filename}.log"
refactor="${dirname}/${filename}.refr"

error(){
    printf "\033[35mError:\t\033[31m${1}\033[0m\n"
    exit 1
}

parse_project_dir(){
    PROJECT_DIR=$1
    if  [ ! -d "$PROJECT_DIR" ];
    then
        error "Unable to locate \'${PROJECT_DIR}\'"
    fi
}

write_to_log(){
    [ ! -d "${dirname}" ] && mkdir -v "${dirname}"
    log_entry="${1}"
    printf "[ $(date '+%F %T') ] ${log_entry}\n" | tee -a $logfile
}

# Looking for any deprecated packages
find_deprecated(){
    PROJECT_DIR=$1
    write_to_log "------------------------------------------------"
    write_to_log "Checking for deprecated APIs..."
    if [ -n "$(egrep -r --include='*.java' '@Deprecated' $PROJECT_DIR)" ];
    then
        # Stream into CSV file.
        echo "Checking for deprecated APIs" | tee -a $refactor
        egrep -r --include='*.java' '@Deprecated' "$PROJECT_DIR" | tee -a $refactor
    else
        write_to_log "No deprecated APIs were found"
    fi
}

# Checking if javax packages exist
find_javax(){
    PROJECT_DIR=$1
    write_to_log "------------------------------------------------"
    write_to_log "Checking for javax package usage (potential migration needed to Jakarta EE)..."
    if [ -n "$(egrep -r --include='*.java' 'javax.' $PROJECT_DIR)" ];
    then
        echo '"Checking for javax package usage (potential migration needed to Jakarta EE)...",""' | tee -a $csvfile
        egrep -r --include='*.java' 'javax.' "$PROJECT_DIR" | sed 's/^/\"/g' | sed 's/\:/\"\,\"/g' | sed 's/\;/\"/g' | tee -a $csvfile
    fi
}

# Looking for internal API usage (e.g., sun.misc.Unsafe)
find_api_internal(){
    PROJECT_DIR=$1
    write_to_log "------------------------------------------------"
    write_to_log "Checking for usage of internal APIs (sun.*)..."
    if [ -n "$(egrep -r --include='*.java' 'sun.' $PROJECT_DIR)" ];
    then
        echo '"Checking for usage of internal APIs (sun.*)...",""' | tee -a $csvfile
        egrep -r --include='*.java' 'sun.' $PROJECT_DIR | sed 's/^/\"/g' | sed 's/\:/\"\,\"/g' | sed 's/\;/\"/g' | tee -a $csvfile
    fi
}

# Looking for reflective access (which might cause issues with Java Modules)
find_reflectives(){
    PROJECT_DIR=$1
    write_to_log "------------------------------------------------"
    write_to_log "Checking for reflective access usage (possible illegal reflective access in Java 9+)..."
    if [ -n "$(egrep -r --include='*.java' 'Class.forName\|getDeclaredField\|setAccessible' $PROJECT_DIR)" ];
    then
        echo 'Checking for reflective access usage (possible illegal reflective access in Java 9+)...' | tee -a $refactor
        egrep -r --include='*.java' 'Class.forName\|getDeclaredField\|setAccessible' $PROJECT_DIR | tee -a $refactor
    fi
}

# Check for refactoring older Java 8 contained 
find_refactor_candidates(){
    write_to_log "------------------------------------------------"
    write_to_log "Identifying usage of old Java language constructs (optional but refactor candidates)..."
    # Look for old-style for loops which could be replaced with Streams
    if [ -n "$(egrep -r --include='*.java' 'for (.* : .*Iterable' $PROJECT_DIR)" ];
    then
        echo 'Identifying usage of old Java language constructs (optional but refactor candidates)...' | tee -a $refactor
        egrep -r --include='*.java' 'for (.* : .*Iterable' $PROJECT_DIR | tee -a $refactor
    fi
}

# List the project's dependencies (checking for old versions)
list_project_dependencies(){
    PROJECT_DIR=$1
    BUILD_TOOL=$2
    write_to_log "------------------------------------------------"
    case $build_tool in
    gradle)
    write_to_log "Listing dependencies from build tools Gradle..."
    [ -z "$(command -v gradle)" ] && error "Missing build automation program 'gradle'"
    if [ -f "$PROJECT_DIR/pom.xml" ]; then
        write_to_log "Found Maven project. Listing dependencies from pom.xml..."
        if [ "$(mvn -f $PROJECT_DIR/pom.xml dependency:tree)" ];
        then
            mvn -f "$PROJECT_DIR/pom.xml" dependency:tree | tee -a $refactor
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
        if [ -n "$(gradle --scan --info --no-daemon -p $PROJECT_DIR dependencies 2> /dev/null)" ];
        then
            gradle --scan --info --no-daemon -p $PROJECT_DIR dependencies 2> /dev/null | tee -a $refactor
        fi
    else
        write_to_log "No Gradle build file found. Please ensure you check your dependencies manually."
    fi
    ;;
    esac
}

# Check for JAR files that might need module migration
find_jars(){
    PROJECT_DIR=$1
    write_to_log "------------------------------------------------"
    write_to_log "Identifying any JARs that might need module migration..."
    if [ -n "$(find $PROJECT_DIR -name "*.jar" -exec jdeps {} \;)" ];
    then
        find $PROJECT_DIR -name "*.jar" -exec jdeps {} \; | tee -a $refactor
    fi

    write_to_log "------------------------------------------------"
    write_to_log "Scan complete. Review the results for changes needed before upgrading to Java 21."
}

run_all_checks(){
    PROJECT_DIR=$1
    BUILD_TOOL=$2
    parse_project_dir "${PROJECT_DIR}"
    write_to_log "Checking Project: ${PROJECT_DIR}"
    echo "Scanning Java 8 project for issues before migrating to Java 21..." 
    find_deprecated "${PROJECT_DIR}"
    # find_javax "${PROJECT_DIR}"
    # find_api_internal "${PROJECT_DIR}"
    # find_reflectives "${PROJECT_DIR}"
    # find_refactor_candidates "${PROJECT_DIR}"
    # Apply when build tool is set
    if [ -n "${BUILD_TOOL}" ];
    then
        list_project_dependencies "${PROJECT_DIR}"
    fi
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
    run_all_checks "${_project_dir}" "${_build_tool}"
    ;;
    *) error "Invalid or unable to execute parameter $_action";;
esac
