#!/usr/bin/env bash

# Expert-level Ollama service management script
# Features: Error handling, logging, validation, idempotency, and colored output

set -o errexit   # Exit on any command failure
set -o nounset   # Exit on undefined variables
set -o pipefail  # Exit on pipe command failures

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Script configuration
readonly SERVICE_NAME="ollama"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=2
readonly LOG_FILE="/var/log/${SERVICE_NAME}_setup.log"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE" >&2
}

# Check if running as root (or with sudo)
check_privileges() {
    if [[ $EUID -ne 0 ]]; then
        log_warning "This script should be run with sudo privileges"
        if ! command -v sudo &> /dev/null; then
            log_error "sudo is not available. Please run as root."
            exit 1
        fi
    fi
}

# Validate systemd is available
check_systemd() {
    if ! command -v systemctl &> /dev/null; then
        log_error "systemctl not found. This system may not use systemd."
        exit 1
    fi
    
    if [[ ! -d /run/systemd/system ]]; then
        log_error "systemd is not the init system on this machine."
        exit 1
    fi
}

# Check if service exists
service_exists() {
    systemctl list-unit-files | grep -q "^${SERVICE_NAME}.service"
}

# Reload systemd daemon
reload_daemon() {
    log_info "Reloading systemd daemon..."
    if sudo systemctl daemon-reload; then
        log_success "Systemd daemon reloaded successfully"
        return 0
    else
        log_error "Failed to reload systemd daemon"
        return 1
    fi
}

# Enable service (idempotent)
enable_service() {
    if systemctl is-enabled "$SERVICE_NAME" &> /dev/null; then
        log_info "Service ${SERVICE_NAME} is already enabled"
        return 0
    fi
    
    log_info "Enabling ${SERVICE_NAME} service..."
    if sudo systemctl enable "$SERVICE_NAME"; then
        log_success "Service ${SERVICE_NAME} enabled successfully"
        return 0
    else
        log_error "Failed to enable ${SERVICE_NAME} service"
        return 1
    fi
}

# Start service with retry logic
start_service() {
    local attempt=1
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        log_info "Service ${SERVICE_NAME} is already running"
        return 0
    fi
    
    while [[ $attempt -le $MAX_RETRIES ]]; do
        log_info "Starting ${SERVICE_NAME} service (attempt ${attempt}/${MAX_RETRIES})..."
        
        if sudo systemctl start "$SERVICE_NAME"; then
            log_success "Service ${SERVICE_NAME} started successfully"
            return 0
        else
            log_warning "Failed to start ${SERVICE_NAME} (attempt ${attempt}/${MAX_RETRIES})"
            
            if [[ $attempt -lt $MAX_RETRIES ]]; then
                log_info "Waiting ${RETRY_DELAY} seconds before retry..."
                sleep "$RETRY_DELAY"
            fi
            ((attempt++))
        fi
    done
    
    log_error "Failed to start ${SERVICE_NAME} after ${MAX_RETRIES} attempts"
    return 1
}

# Verify service is running and healthy
verify_service() {
    log_info "Verifying ${SERVICE_NAME} service health..."
    sleep 2  # Give service a moment to stabilize
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        local pid=$(systemctl show -p MainPID --value "$SERVICE_NAME")
        local status=$(systemctl show -p ActiveState --value "$SERVICE_NAME")
        log_success "Service ${SERVICE_NAME} is ${status} (PID: ${pid})"
        return 0
    else
        log_error "Service ${SERVICE_NAME} is not active"
        return 1
    fi
}

# Display service status with detailed info
show_status() {
    log_info "Detailed service status:"
    echo "----------------------------------------"
    sudo systemctl status "$SERVICE_NAME" --no-pager || true
    echo "----------------------------------------"
    
    # Check for common issues
    if systemctl is-failed --quiet "$SERVICE_NAME"; then
        log_error "Service is in failed state. Checking logs..."
        sudo journalctl -u "$SERVICE_NAME" -n 20 --no-pager
    fi
}

# Countdown function with visual feedback
countdown() {
    local seconds=${1:-5}
    log_info "Waiting ${seconds} seconds before verification..."
    
    for i in $(seq "$seconds" -1 1); do
        printf "\r${YELLOW}Starting verification in %2d seconds...${NC} " "$i"
        sleep 1
    done
    printf "\n"
}

# Main execution
main() {
    log_info "=== Starting ${SERVICE_NAME} service management ==="
    
    # Pre-flight checks
    check_privileges
    check_systemd
    
    # Verify service exists
    if ! service_exists; then
        log_error "Service ${SERVICE_NAME} does not exist. Please install it first."
        exit 1
    fi
    
    # Execute service management steps
    reload_daemon || exit 1
    enable_service || exit 1
    start_service || exit 1
    
    # Post-startup verification
    countdown 5
    verify_service || {
        log_error "Service verification failed"
        show_status
        exit 1
    }
    
    # Display final status
    show_status
    
    log_success "=== ${SERVICE_NAME} service is successfully configured and running ==="
    
    # Optional: Test connectivity if it's an API service
    if command -v curl &> /dev/null; then
        log_info "Testing service connectivity..."
        if curl -s "http://localhost:11434/api/tags" &> /dev/null; then
            log_success "Ollama API is responding"
        else
            log_warning "Ollama API not responding (may need additional configuration)"
        fi
    fi
}

# Trap errors and cleanup
trap 'log_error "Script interrupted or failed at line $LINENO"; exit 1' ERR INT TERM

# Run main function
main "$@"
