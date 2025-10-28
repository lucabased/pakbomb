#!/bin/bash

# pakbomb.sh - Package installer for common tool sets
# Usage: pakbomb.sh <config_name>

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Package configurations
declare -A CONFIGS

# Containerization configuration
CONFIGS[docker]="docker docker-compose docker-compose-plugin"
CONFIGS[kubernetes]="kubectl minikube helm"
CONFIGS[k8s]="kubectl minikube helm"

# Hardening configuration (Basic Security)
CONFIGS[hardening]="fail2ban ufw unattended-upgrades"

# Development configuration (Python, Rust, Node.js, etc.)
DEV_PYTHON_PACKAGES="python python-pip python-virtualenv python3-virtualenv python3 python3-pip"
CONFIGS[dev]="git vim nodejs npm rustup rust $PYTHON_PACKAGES"

# Extended FOSS Security // Anti-Virus and Firewall
CONFIGS[avfw]="fail2ban ufw rkhunter clamav"


# System tools configuration
CONFIGS[systools]="cryptsetup htop tree wget curl neofetch ripgrep bat exa fzf git dnsutils jq zip tmux gnupg unzip net-tools lsof ncdu build-essential rsync loc ate nmap"

# Multimedia configuration
CONFIGS[multimedia]="vlc audacity ffmpeg mpv gimp "

# Git configuration
CONFIGS[git]="git git-lfs"

# Latex
CONFIGS[latex]="texlive texlive-latex-extra texlive-science texlive-lang-german texlive-lang-english"


function print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════╗"
    echo "║      P A K B O M B                 ║"
    echo "║   Multi-Package Installer          ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

function print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

function detect_package_manager() {
    if command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

function install_with_pacman() {
    local packages="$1"
    print_info "Installing with pacman..."
    
    if ! command -v pacman &> /dev/null; then
        print_error "pacman not found!"
        return 1
    fi
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
        return 1
    fi
    
    for package in $packages; do
        if pacman -Qi "$package" &> /dev/null; then
            print_success "$package is already installed"
        else
            print_info "Installing $package..."
            pacman -S --noconfirm "$package" && print_success "Installed $package" || print_error "Failed to install $package"
        fi
    done
}

function install_with_apt() {
    local packages="$1"
    print_info "Installing with apt..."
    
    if ! command -v apt-get &> /dev/null; then
        print_error "apt-get not found!"
        return 1
    fi
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
        return 1
    fi
    
    apt-get update
    for package in $packages; do
        if dpkg -l | grep -q "^ii  $package "; then
            print_success "$package is already installed"
        else
            print_info "Installing $package..."
            apt-get install -y "$package" && print_success "Installed $package" || print_error "Failed to install $package"
        fi
    done
}

function install_with_dnf() {
    local packages="$1"
    print_info "Installing with dnf..."
    
    if ! command -v dnf &> /dev/null; then
        print_error "dnf not found!"
        return 1
    fi
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
        return 1
    fi
    
    for package in $packages; do
        if rpm -q "$package" &> /dev/null; then
            print_success "$package is already installed"
        else
            print_info "Installing $package..."
            dnf install -y "$package" && print_success "Installed $package" || print_error "Failed to install $package"
        fi
    done
}

function install_with_yum() {
    local packages="$1"
    print_info "Installing with yum..."
    
    if ! command -v yum &> /dev/null; then
        print_error "yum not found!"
        return 1
    fi
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
        return 1
    fi
    
    for package in $packages; do
        if rpm -q "$package" &> /dev/null; then
            print_success "$package is already installed"
        else
            print_info "Installing $package..."
            yum install -y "$package" && print_success "Installed $package" || print_error "Failed to install $package"
        fi
    done
}

function install_with_zypper() {
    local packages="$1"
    print_info "Installing with zypper..."
    
    if ! command -v zypper &> /dev/null; then
        print_error "zypper not found!"
        return 1
    fi
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
        return 1
    fi
    
    for package in $packages; do
        if zypper se -i "$package" &> /dev/null; then
            print_success "$package is already installed"
        else
            print_info "Installing $package..."
            zypper install -y "$package" && print_success "Installed $package" || print_error "Failed to install $package"
        fi
    done
}

function show_available_configs() {
    echo -e "\n${BLUE}Available configurations:${NC}\n"
    for config in "${!CONFIGS[@]}"; do
        echo -e "${YELLOW}  $config${NC}"
        for package in ${CONFIGS[$config]}; do
            echo -e "    - $package"
        done
        echo
    done
}

function install_packages() {
    local config_name="$1"
    local packages="${CONFIGS[$config_name]}"
    
    if [ -z "$packages" ]; then
        print_error "Unknown configuration: $config_name"
        echo ""
        show_available_configs
        return 1
    fi
    
    print_header
    print_info "Configuration: $config_name"
    print_info "Packages to install: $packages"
    echo ""
    
    local pkg_manager=$(detect_package_manager)
    print_info "Detected package manager: $pkg_manager"
    echo ""
    
    case "$pkg_manager" in
        pacman)
            install_with_pacman "$packages"
            ;;
        apt)
            install_with_apt "$packages"
            ;;
        dnf)
            install_with_dnf "$packages"
            ;;
        yum)
            install_with_yum "$packages"
            ;;
        zypper)
            install_with_zypper "$packages"
            ;;
        *)
            print_error "Unsupported package manager: $pkg_manager"
            print_error "Supported managers: pacman, apt, dnf, yum, zypper"
            return 1
            ;;
    esac
    
    echo ""
    print_success "Installation complete!"
}

function main() {
    if [ $# -eq 0 ]; then
        print_header
        show_available_configs
        echo -e "${YELLOW}Usage:${NC} $0 <config_name>"
        echo -e "${YELLOW}Example:${NC} $0 docker"
        exit 0
    fi
    
    install_packages "$1"
}

main "$@"

