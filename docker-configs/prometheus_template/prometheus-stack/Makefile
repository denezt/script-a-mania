# Makefile for managing Prometheus stack with Node Exporter

.PHONY: all clean setup run down

all: clean setup run
	@echo "Prometheus stack setup complete."

# Target to set up the environment for Prometheus stack
setup:
	@printf "\033[34mSetting up Prometheus stack environment...\033[0m\n"
	@printf "\033[36mCreating 'nodeexp' user for Node Exporter service...\033[0m\n"
	@sudo useradd --no-create-home --shell /usr/sbin/nologin nodeexp || echo "User 'nodeexp' already exists."
	@printf "\033[33mCurrent mount points:\033[0m\n"
	@findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS,PROPAGATION /
	@printf "\033[32m\nSetup complete.\033[0m\n"

# Target to clean up existing Prometheus stack containers and volumes
clean:
	@printf "\033[36mCleaning up existing Prometheus stack containers and volumes...\033[0m\n"
	@docker compose down --remove-orphans -v || printf "\033[34mNo existing containers to remove.\033[34m\n"
	@sudo userdel nodeexp || echo "User 'nodeexp' does not exist."
	@printf "\033[32m\nCleanup complete.\033[0m\n\n"

# Target to run the Prometheus stack containers
run:
	@printf "\033[33mStarting Prometheus stack containers...\033[0m\n"
	@docker compose up -d
	@printf "\033[32mPrometheus stack containers are up and running.\033[0m\n"

# Target to bring the Prometheus stack down and clean up
down: clean
	@echo "\033[32mPrometheus stack has been stopped and cleaned up.\033[0m\n"
