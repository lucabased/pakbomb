# PakBomb 🦾

A powerful CLI tool for installing multiple packages at once using predefined configurations.

## Features

- 🚀 Install multiple packages with a single command
- 🎯 Predefined configurations for common use cases
- 🔄 Automatically detects your package manager (pacman, apt, dnf, yum, zypper)
- ✅ Checks if packages are already installed to avoid duplicates
- 🎨 Beautiful colored output
- ⚡ Fast and efficient

## Installation (one-liner)
```bash
sudo curl -o /usr/local/bin/pakbomb.sh https://dist.lucabased.xyz/pakbomb.sh && sudo chmod +x /usr/local/bin/pakbomb.sh && echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```
/usr/local/bin is now in your PATH and pakbomb.sh can be run from anywhere.

## Usage

```bash
# Show all available configurations
./pakbomb.sh

# Install a specific configuration
./pakbomb.sh <config_name>

# Examples
sudo ./pakbomb.sh docker
sudo ./pakbomb.sh kubernetes
sudo ./pakbomb.sh hardening
```

## Available Configurations

### Docker
```bash
sudo ./pakbomb.sh docker
```
Installs: docker, docker-compose, docker-compose-plugin

### Kubernetes
```bash
sudo ./pakbomb.sh kubernetes
# or
sudo ./pakbomb.sh k8s
```
Installs: kubectl, minikube, helm

### Hardening
```bash
sudo ./pakbomb.sh hardening
```
Installs: fail2ban, ufw, unattended-upgrades

### Development Tools
```bash
sudo ./pakbomb.sh dev
```
Installs: git, vim, code, python, python-pip, nodejs, npm, rust

### Security Tools
```bash
sudo ./pakbomb.sh security
```
Installs: fail2ban, ufw, rkhunter, clamav

### Web Development
```bash
sudo ./pakbomb.sh webdev
```
Installs: nodejs, npm, code, git

### System Tools
```bash
sudo ./pakbomb.sh systools
```
Installs: htop, tree, wget, curl, neofetch

### Git
```bash
sudo ./pakbomb.sh git
```
Installs: git, git-lfs

## Adding New Configurations

Edit `pakbomb.sh` and add entries to the `CONFIGS` associative array:

```bash
# Your new configuration
CONFIGS[myconfig]="package1 package2 package3"
```

Then use it with:
```bash
sudo ./pakbomb.sh myconfig
```

## Supported Package Managers

- **pacman** (Arch Linux)
- **apt** (Debian/Ubuntu)
- **dnf** (Fedora, RHEL 8+)
- **yum** (RHEL, CentOS)
- **zypper** (openSUSE)

## Requirements

- Root privileges (run with `sudo`)
- One of the supported package managers installed on your system

## Installation

1. Make the script executable (already done):
```bash
chmod +x pakbomb.sh
```

2. Optionally, move it to your PATH:
```bash
sudo mv pakbomb.sh /usr/local/bin/pakbomb
```

## Examples

```bash
# Install Docker ecosystem
sudo ./pakbomb.sh docker

# Install Kubernetes tools
sudo ./pakbomb.sh k8s

# Install security hardening tools
sudo ./pakbomb.sh hardening

# Install development environment
sudo ./pakbomb.sh dev
```

## Notes

- The script checks for already installed packages to avoid re-installing
- Failed package installations are logged but won't stop the entire process
- Make sure to run with appropriate privileges (use `sudo`)

