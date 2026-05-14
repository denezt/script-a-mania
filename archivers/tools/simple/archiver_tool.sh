#!/bin/bash
# Purpose: Archive Files

source archiver.config

logger(){
	_timestamp=$(date '+%F %T')
	[ ! -d "${log_dir}" ] && mkdir -v "${log_dir}"
	printf "[ ${_timestamp} ] ${1}\n" | tee -a "${log_dir}/${log_file}"
}

error(){
	[ ! -d "${error_dir}" ] && mkdir -v "${error_dir}"
	printf "Error: ${1}\n" | tee -a "${error_dir}/${error_file}"
	exit 1
}

# Will create the archive container
create_container(){
	[ ! -d "${archive_container}" ] && mkdir -v "${archive_container}" && \
	printf "Created the archive container\n"
}

run_backup(){
	create_container
	source="${1}"
	_timestamp=$(date '+%s')
	if [ -d "${source}" -o -f "${source}" ];
	then
		archivename=$(echo ${archive_container}/${source}-${_timestamp} | tr '.' '_')
		7z a "${archivename}.7z" "${source}"
		if [ -f "${archivename}.7z" ];
		then
			logger "Archive ${archivename}.7z was successfully created"
		else
			error "Unable to locate an archive name ${archivename}.7z in ${archive_container}"
		fi
	fi
}

extract_value(){
	echo "${1}" | cut -d':' -f2 | cut -d'=' -f2
}

command(){
	printf "\033[36mCOMMANDS:\033[0m\n"
	printf "\033[35mArchive Source\t\t\033[32m[ archive, backup, bkup ]\033[0m\n"
	printf "\033[35mCreate Container\t\033[32m[ create, create-container ]\033[0m\n"
}

usage(){
	printf "\033[36mUSAGE:\033[0m\n"
	printf "\33[35m$0 --action=COMMAND\033[0m\n"
	printf "\033[33mEXAMPLE:\033[0m\n"
	printf "\033[32m# Create Container\033[0m\n"
	printf "\033[35m$0 \033[33m--action=create\033[0m\n"
	printf "\033[32m# Create Archive\033[0m\n"
	printf "\033[35m$0 \033[33m--action=archive \033[34m--filename=myfile.txt\033[0m\n"
	printf "\033[35m$0 \033[33m--action=archive \033[34m--dirname=mydir\033[0m\n"
}

help_menu(){
	printf "\033[36mArchiver Tool\033[0m\n"
	printf "\033[35mExecute Action\t\033[32m[ action:COMMAND, --action=COMMAND ]\033[0m\n"
	printf "\033[35mHelp Menu\t\033[32m[ -h, -help, --help ]\033[0m\n"
	echo;
	command
	echo;
	usage
	exit 0
}

for argv in $@
do
	case $argv in
		-h|-help|--help) help_menu;;
		action:*|--action=*) _action=$(extract_value $argv);;
		src:*|--source=*|filename:*|--filename=*) _filename=$(extract_value $argv);;
	esac
done

case ${_action} in
	archive|backup|bkup) run_backup "${_filename}";;
	create|create-container) create_container;;
	*) error "Missing or unable to execute command";;
esac



