#!/bin/bash

_allowed_swapsize=60
config="config.settings"

error(){
	printf "\033[35mError:\t\033[31m${1}!\033[0m\n"
	exit 1
}

parse_types(){
	value=${1}
	typeof="${2}"
	case $typeof in
		'number')
		_parse=$(echo ${value}/100 | bc 2> /dev/null)
		[ -z "${_parse}" ] && \
		error "Missing or invalid value ${value} was given"
		;;
		*) error "Missing or invalid data type was given"
	esac
}

test_disk_size(){
	_dirname="${1}"
	_swapsize="${2}"
	if [ -d "${_dirname}" ];
	then
		curr_disk_size=$(df -h "${_dirname}" | tail -n 1 | awk '{print $4}' | tr -d [:alpha:])
		_percentage=$(echo "scale=2;${_swapsize}/${curr_disk_size}" | bc)
		printf "Current Disk Size: ${curr_disk_size}G\n"
 		_predicted_usage=$(echo ${_percentage}*100 | bc | cut -d'.' -f1)
		if [ $_predicted_usage -lt $_allowed_swapsize ];
		then
			printf "Assumed Percentage: ${_predicted_usage}%%\n"
		else
			error "Predicted usage ${_predicted_usage}%% over the ${_allowed_swapsize}%% allowed usage, choose a smaller swap size!!"
		fi
	else
		error "Missing or invalid directory name was given"
	fi
}

define_settings(){
	# Set the root directory
	read -p "Enter main directory location for swapfile: " _dir
	dir="${_dir}"

	# Define the swapfile name
	read -p "What do you want to name the swapfile? (No leading '/'): " _name
	swapfile="${_name}"

	# Define the size of the swapfile
	read -p "Define the size of the swapfile: " _size
	parse_types $_size 'number'
	swap_size="${_size}"

	# Ensure that the usage size is under the max allowed percentage
	test_disk_size "${_dir}" "${swap_size}"

	# Define the rate of swapping
	read -p "Define frequency of swapping: " _rate
	parse_types $_rate 'number'
	swappiness="${_rate}"

}

modify_settings(){
	if [ -e "$config" ];
	then
		printf "Deleting, $config file...\n"
		read -p "Are you sure? [ (Y)es| (N)o ] " _confirm
		_confirm=$(printf "${_confirm}" | tr [:upper:] [:lower:])
		case $_confirm in
			y|yes) rm -vi "${config}";;
			n|no) printf "Exiting, execution and not overwrite current settings.\n"
			exit 0
			;;
		esac
	fi
	define_settings
}

create_swapfile(){
	source config.settings

	# Check Current Swap
	sudo swapon -s

	# Create Swap File
	sudo fallocate -v -l 4G /swapfile
	chmod 600 /swapfile

	# Make it to swap format and activate on your system
	sudo mkswap /swapfile
	sudo swapon /swapfile

	# Make Swap Permanent
	sudo vim /etc/fstab
	# and add below entry to end of file
	/swapfile   none    swap    sw    0   0

	# Check System Swap Memory
	sudo swapon -s
	free -m

	# Update Swappiness Parameter
	sudo vim /etc/sysctl.conf
	# append following configuration to end of file
	vm.swappiness=10

	# Now reload the sysctl configuration file
	sudo sysctl -p
}

modify_settings

