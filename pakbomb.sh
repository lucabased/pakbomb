#!/bin/bash
# pakbomb.sh - Package installer for common tool sets
# Usage: pakbomb.sh <config_name>
set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Remote script URL
SCRIPT_URL="https://raw.githubusercontent.com/lucabased/pakbomb/refs/heads/main/pakbomb.sh"

# Package configurations
declare -A CONFIGS

CONFIGS[docker]="docker docker-compose docker-compose-plugin"
CONFIGS[kubernetes]="kubectl minikube helm"
CONFIGS[k8s]="kubectl minikube helm"
CONFIGS[hardening]="fail2ban ufw unattended-upgrades"
# Development configuration (Python, Rust, Node.js, etc.)
DEV_PYTHON_PACKAGES="python python-pip python-virtualenv python3-virtualenv virtualenv python3 python3-pip"
CONFIGS[dev]="git vim nodejs npm rustup rust $PYTHON_PACKAGES"
# Extended FOSS Security // Anti-Virus and Firewall
CONFIGS[avfw]="fail2ban ufw rkhunter clamav"
CONFIGS[systools]="cryptsetup htop tree wget curl neofetch ripgrep bat exa fzf git dnsutils jq zip tmux gnupg unzip net-tools lsof ncdu build-essential rsync loc ate nmap"
CONFIGS[multimedia]="vlc audacity ffmpeg mpv gimp "
CONFIGS[git]="git git-lfs"
CONFIGS[latex]="texlive texlive-latex-extra texlive-science texlive-lang-german texlive-lang-english"
CONFIGS[communications]="signal-desktop telegram-desktop discord pidgin pidgin-otr"
CONFIGS[gaming]="steam steam-native-runtime lutris wine-staging winetricks vulkan-icd-loader"
CONFIGS[audio]="audacity reaper ardour audacious jack2 helm"
CONFIGS[video]="kdenlive blender ffmpeg openshot openshot-blender-git vlc"
CONFIGS[editing]="kdenlive blender ffmpeg openshot openshot-blender-git gimp inkscape"
CONFIGS[network]="wireshark-qt tcpdump nmap netcat nethogs iftop vnstat net-tools"
CONFIGS[vpn]="openvpn wireguard-tools networkmanager-openvpn networkmanager-wireguard"
CONFIGS[passman]="keepassxc pass"
CONFIGS[email]="thunderbird evolution"
CONFIGS[office]="libreoffice-fresh libreoffice-fresh-de libreoffice-lang-de thunderbird"
CONFIGS[sci]="octave gnuplot gnuradio gnuradio-companion python-scipy python-numpy python-matplotlib"
CONFIGS[science]="octave gnuplot gnuradio gnuradio-companion python-scipy python-numpy python-matplotlib"
CONFIGS[iot]="arduino-cli platformio cmake ninja gcc-avr avr-libc"
CONFIGS[embedded]="arduino-cli platformio cmake ninja gcc-avr avr-libc"
CONFIGS[cloud]="aws-cli azure-cli google-cloud-sdk terraform ansible"
CONFIGS[aws]="aws-cli terraform"
CONFIGS[terraform]="terraform ansible packer vault"
CONFIGS[shell]="neovim zsh oh-my-zsh-git tmux fzf ripgrep bat exa fd zoxide starship"
CONFIGS[productivity]="neovim zsh oh-my-zsh-git tmux fzf ripgrep bat exa fd zoxide starship"
CONFIGS[build]="gcc gcc-fortran clang cmake ninja make meson bazel"
CONFIGS[compiler]="gcc gcc-fortran clang cmake ninja make meson"
CONFIGS[golang]="go gopls"
CONFIGS[java]="jdk-openjdk maven gradle"
CONFIGS[rust-dev]="rust rustup cargo"
CONFIGS[tex]="texlive-most texlive-lang texlive-fontsextra"
CONFIGS[ai]="python-pytorch python-torchvision python-torchaudio python-transformers python-tensorflow"
CONFIGS[db]="postgresql mysql mariadb mongodb-tools sqlite redis"
CONFIGS[archive]="p7zip unrar zip unzip gzip bzip2 xz"
CONFIGS[monitoring]="htop iotop btop glances nvtop nvidia-utils"
CONFIGS[backup]="rsync timeshift restic borg"
CONFIGS[virt]="qemu libvirt virt-manager virt-viewer qemu-arch-extra dnsmasq ebtables bridge-utils"
# Testing & CI
CONFIGS[testing]="bash-completion shellcheck shfmt"


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

function get_update_info() {
    local script_path="$0"
    local remote_url="$SCRIPT_URL"
    
    # Only check for updates if we have curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        return 0
    fi
    
    # Get local script's hash
    local local_hash=$(sha256sum "$script_path" 2>/dev/null | awk '{print $1}')
    
    if [ -z "$local_hash" ]; then
        return 0
    fi
    
    # Get remote script's hash (download temporarily)
    local temp_remote=$(mktemp)
    local download_success=false
    
    if command -v curl &> /dev/null; then
        if curl -sSL "$remote_url" -o "$temp_remote" 2>/dev/null; then
            download_success=true
        fi
    elif command -v wget &> /dev/null; then
        if wget -qO "$temp_remote" "$remote_url" 2>/dev/null; then
            download_success=true
        fi
    fi
    
    if [ "$download_success" = false ]; then
        rm -f "$temp_remote"
        return 0
    fi
    
    # Verify the downloaded content is actually the script
    if ! grep -q "install_with" "$temp_remote" 2>/dev/null; then
        rm -f "$temp_remote"
        return 0
    fi
    
    local remote_hash=$(sha256sum "$temp_remote" 2>/dev/null | awk '{print $1}')
    
    # Clean up temp file
    rm -f "$temp_remote"
    
    if [ -z "$remote_hash" ]; then
        return 0
    fi
    
    # Output hashes separated by newline
    echo "$local_hash"
    echo "$remote_hash"
    echo "$remote_url"
    
    # Return status: 1 if update available, 0 if not
    if [ "$local_hash" != "$remote_hash" ]; then
        return 1  # Update available
    fi
    
    return 0  # No update needed
}

function check_for_updates() {
    # Get update info and check if update is available
    local update_info=$(get_update_info)
    
    # get_update_info returns 1 if update is available
    return $?
}

function download_update() {
    local script_path="$0"
    local remote_url="$SCRIPT_URL"
    local backup_script="${script_path}.bak"
    
    # Download the update to a temporary file
    local temp_update=$(mktemp)
    local download_success=false
    
    echo -e "${CYAN}Downloading update...${NC}"
    
    if command -v curl &> /dev/null; then
        if curl -sSL "$remote_url" -o "$temp_update" 2>/dev/null; then
            download_success=true
        fi
    elif command -v wget &> /dev/null; then
        if wget -qO "$temp_update" "$remote_url" 2>/dev/null; then
            download_success=true
        fi
    fi
    
    if [ "$download_success" = false ]; then
        print_error "Failed to download update"
        rm -f "$temp_update"
        return 1
    fi
    
    # Verify the downloaded content is actually the script
    if ! grep -q "install_with" "$temp_update" 2>/dev/null; then
        print_error "Verification failed: Downloaded content does not appear to be the pakbomb script"
        rm -f "$temp_update"
        return 1
    fi
    
    # Create a backup
    cp "$script_path" "$backup_script"
    
    # Replace the script
    chmod +x "$temp_update"
    mv "$temp_update" "$script_path"
    
    print_success "Script updated successfully!"
    echo -e "${YELLOW}Backup saved to: $backup_script${NC}"
    
    return 0
}

function auto_update() {
    # Get update information
    local update_info=$(get_update_info)
    
    # get_update_info returns 1 if update is available, 0 if not
    local has_update=$?
    
    if [ $has_update -eq 0 ]; then
        return 0  # No update needed, exit early
    fi
    
    # If we reach here, an update is available
    # Parse the update info (format: local_hash\nremote_hash\nurl)
    local local_hash=$(echo "$update_info" | sed -n '1p')
    local remote_hash=$(echo "$update_info" | sed -n '2p')
    local update_url=$(echo "$update_info" | sed -n '3p')
    
    echo -e "\n${CYAN}══════════════════════════════════════${NC}"
    echo -e "${CYAN}    A U T O - U P D A T E R${NC}"
    echo -e "${CYAN}══════════════════════════════════════${NC}"
    echo -e "${YELLOW}A new version of pakbomb.sh is available!${NC}"
    echo ""
    echo -e "${BLUE}Update source:${NC}"
    echo -e "  ${update_url}"
    echo ""
    echo -e "${BLUE}File hashes:${NC}"
    echo -e "  ${RED}Current:${NC}  ${local_hash:0:16}..."
    echo -e "  ${GREEN}Remote:${NC}   ${remote_hash:0:16}..."
    echo ""
    echo -e "${YELLOW}Would you like to update now? (y/N)${NC}"
    echo -e "${CYAN}Press Ctrl+C to skip update and continue${NC}"
    echo -e "${CYAN}══════════════════════════════════════${NC}"
    
    read -t 10 -p "$(echo -e ${YELLOW}'Enter your choice: '${NC})" response 2>/dev/null || response=""
    
    echo ""
    
    case "$response" in
        [yY]|[yY][eE][sS])
            if download_update; then
                echo -e "${GREEN}Restarting script with new version...${NC}\n"
                exec "$0" "$@"
            else
                echo -e "${RED}Update failed. Continuing with current version.${NC}\n"
            fi
            ;;
        *)
            echo -e "${YELLOW}Skipping update. Continuing with current version.${NC}\n"
            ;;
    esac
}

function main() {
    # Check for updates before proceeding
    auto_update
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

