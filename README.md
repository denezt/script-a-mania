# Script-a-Mania

A curated collection of practical scripts, shell snippets, command-line recipes, and automation helpers for Linux system administrators, DevOps engineers, and developers.

## Overview

`script-a-mania` is a utility repository for repeatable command-line work: archiving, system maintenance, Docker/container experiments, Git cleanup, dependency installation, shell workflows, PowerShell helpers, SQL snippets, and miscellaneous developer utilities.

The repository is primarily Shell and Python, with smaller Java, PowerShell, and PHP examples.

## Repository Structure

| Path | Purpose |
|---|---|
| `archive_tools/` | 7-Zip based archive and backup helper scripts |
| `container/` | Container-related examples and experiments |
| `docker-configs/` | Docker configuration examples |
| `dependencies/` | Dependency installation scripts |
| `git_tools/` | Git maintenance helpers |
| `shell_commands/` | Shell command examples and reusable snippets |
| `sql_scripts/` | SQL-related scripts |
| `system_tools/` | Linux/system administration tools |
| `updating_tools/` | Update and maintenance helpers |
| `powershell/` | PowerShell utilities |
| `wxPython/` | wxPython examples |
| `command_list.sh` | Large command reference / scratchpad of Linux and DevOps commands |

## Key Features

- Linux administration command references
- Archive and backup helpers using `7z`
- Docker and container examples
- Git cleanup utilities
- System monitoring and troubleshooting snippets
- Networking, process, disk, and package-management examples
- Developer utilities for formatting, JSON, SQL, Java, PHP, and PowerShell

## Requirements

Requirements vary by script. Common tools include:

```bash
bash
git
curl
wget
7z
tar
gzip
sed
awk
grep
python3
````

On Debian/Ubuntu systems, install common dependencies with:

```bash
sudo apt update
sudo apt install -y bash git curl wget p7zip-full tar gzip sed awk grep python3
```

## Getting Started

Clone the repository:

```bash
git clone https://github.com/denezt/script-a-mania.git
cd script-a-mania
```

Make a script executable:

```bash
chmod +x path/to/script.sh
```

Run a script:

```bash
./path/to/script.sh
```

View help when available:

```bash
./path/to/script.sh --help
```

## Example: Archive Tool

The archive helper can create an archive container and back up a file or directory.

```bash
cd archive_tools
chmod +x archiver_tool.sh

./archiver_tool.sh --action=create
./archiver_tool.sh --action=archive --filename=myfile.txt
./archiver_tool.sh --action=archive --filename=mydir
```

## Safety Notes

Many scripts and command examples perform system-level operations. Review each command before running it, especially commands involving:

```bash
sudo
rm
dd
mkfs
chattr
iptables
mysql
systemctl
apt
docker
```

Recommended workflow:

```bash
# 1. Read the script
less script.sh

# 2. Run shell syntax checks
bash -n script.sh

# 3. Test in a disposable VM/container first
```

## Best Practices

Before using scripts in production:

* Review the source code.
* Confirm required dependencies.
* Test on non-production systems.
* Back up important data.
* Replace hardcoded paths, usernames, hosts, and credentials.
* Avoid running unknown scripts directly with `sudo`.

## Contributing

Contributions are welcome. Recommended contribution style:

1. Place scripts in the most relevant directory.
2. Add a short header comment explaining purpose and usage.
3. Use safe defaults.
4. Avoid hardcoded secrets.
5. Include examples.
6. Prefer POSIX-compatible shell where practical.
7. Run syntax checks before committing.

Example script header:

```bash
#!/usr/bin/env bash
# Purpose: Short description of what this script does
# Usage: ./script-name.sh [options]
# Requirements: bash, curl, jq
```

## License

This project is released under the Unlicense. See `LICENSE` for details.

## Disclaimer

This repository contains administrative scripts and command examples. Use at your own risk. Always review commands before running them on production systems.


