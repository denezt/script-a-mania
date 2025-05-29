#!/bin/bash

_allowed_swapsize=60
config="config.settings"

logger(){
	input_log="${1}"
	printf "[ $(date '+%F') ] ${input_log}\n"
}

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

create_config(){
	option="${1}"
	parameter="${2}"
	case $option in
		append)
		if [ -n "${parameter}" ]; then
			echo "${parameter}" | tee -a "${config}"
		else
			error "Missing parameter for configuration ${config}"
		fi
		;;
		flush|initialize) printf "" > ${config};;
	esac
}

test_disk_size(){
	_dirname="${1}"
	declare -i _swapsize="${2}"
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

# Defines and will parse the values
define_settings(){
	# Set the root directory
	read -p "Enter main directory location for swapfile: [default: /] " _dir
	[ -z "${_dir}" ] && _dir='/'

	# Define the swapfile name
	read -p "What do you want to name the swapfile? [swapfile_001] " _name
	[ -z "${_name}" ] && _name='swapfile_001'

	# Define the size of the swapfile
	read -p "Define the size of the swapfile. [1GB]: " _size
	[ -z "${_size}" ] && _size=1
	_size_number=$(printf $_size | sed "s|[A-Za-z]||g")
	parse_types $_size_number 'number'

	# Ensure that the usage size is under the max allowed percentage
	test_disk_size "${_dir}" "${swap_size}"

	# Define the rate of swapping
	read -p "Define frequency of swapping [default is 60]: " _rate
	[ -z "${_rate}" ] && _rate=60
	parse_types $_rate 'number'

	# Enter values into the config file
	create_config 'initialize'
	create_config 'append' "dir='${_dir}'"
	create_config 'append' "swapfile='${_name}'"
	create_config 'append' "declare -i swap_size='${_size}'"
	create_config 'append' "declare -i swappiness='${_rate}'"
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
	if [ -e "$config" ];
	then
		source $config
		logger "Creating, swapfile with settings:\n"
		cat "${config}"

		swapfile_path="${dir}/${swapfile}"
		# Check Current Swap
		sudo swapon -s

		# Create Swap File
		logger "Creating, swap file"
		sudo dd if=/dev/zero of=${swapfile_path} bs=1M count=$(echo "${swap_size} * 1024" | bc)
		sudo chmod 600 ${swapfile_path}
		# Make it to swap format and activate on your system
		sudo mkswap ${swapfile_path}
		sudo swapon ${swapfile_path}
		logger "Successfully, created swap file ${swapfile_path}"

		# Make Swap Permanent
		logger "Making, swap persistent"
		if [ -n "$(grep -o ${swapfile_path} /etc/fstab)" ];
		then
			# Overwrite following fstab entry.
			old_value="$(grep ${swapfile_path} /etc/fstab)"
			new_value="${swapfile_path}   none    swap    sw    0   0"
			sudo sed -i "s|${old_value}|${new_value}|g" /etc/fstab
		else
			# Append following fstab entry.
			echo "${swapfile_path}   none    swap    sw    0   0" | sudo tee -a /etc/fstab
		fi

		# Check System Swap Memory
		sudo swapon -s
		free -m
		# Update Swappiness Parameter
		if [ -n "$(grep -o 'vm.swappiness' /etc/sysctl.conf)" ];
		then
			# Overwrite following configuration setting.
			old_value="$(grep 'vm.swappiness' /etc/sysctl.conf)"
			new_value="vm.swappiness=${swappiness}"
			sudo sed -i "s|${old_value}|${new_value}|g" /etc/sysctl.conf
		else
			# append following configuration to end of file
			echo "vm.swappiness=${swappiness}" | sudo tee -a /etc/sysctl.conf
		fi
		# Now reload the sysctl configuration file
		sudo sysctl -p
	else
		error "Missing or unable to find $config file"
	fi
}

help_menu(){
	printf "\033[36mSWAPFILE Manager\033[0m\n"
	printf "\033[35mModify Configuration\033[0m\t\033[32m[ --modify, --create-config ]\033[0m\n"
	printf "\033[35mCreate Swapfile\033[0m\t\t\033[32m[ --create, --create-swap ]\033[0m\n"
	exit 0;
}

for argv in $@
do
	case $argv in
		-h|--help|help) help_menu;;
		--modify|--create-config) _modify_config='true';;
		--create|--create-swap) _create_swap='true';;
		*) error "Missing or invalid parameter was given";;
	esac
done

# Execute commands
[ "${_modify_config}" = 'true' ] && modify_settings
[ "${_create_swap}" = 'true' ] && create_swapfile
