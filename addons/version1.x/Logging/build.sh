#!/bin/bash
#shellcheck source=/dev/null

set -e

########################################################
#
#         Pterodactyl-AutoAddons Installation
#
#         Created and maintained by Vidul
#
#            Protected by GPL 3.0 License
#
########################################################

# Get the latest version before running the script #
get_release() {
curl --silent \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/Ferks-FK/Pterodactyl-AutoAddons/releases/latest |
  grep '"tag_name":' |
  sed -E 's/.*"([^"]+)".*/\1/'
}

# Fixed Variables #
SCRIPT_VERSION="$(get_release)"
SUPPORT_LINK="https://discord.gg/buDBbSGJmQ"

# Update Variables #
update_variables() {
SERVER_DETAILS="$PTERO/app/Http/Controllers/Api/Client/Servers/DatabaseController.php"
CONFIG_FILE="$PTERO/config/app.php"
PANEL_VERSION="$(grep "'version'" "$CONFIG_FILE" | cut -c18-25 | sed "s/[',]//g")"
}

# Visual Functions #
print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

print_warning() {
  echo
  echo -e "* ${YELLOW}WARNING${RESET}: $1"
  echo ""
}

print_error() {
  echo ""
  echo -e "* ${RED}ERROR${RESET}: $1"
  echo ""
}

print() {
  echo ""
  echo -e "* ${GREEN}$1${RESET}"
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

GREEN="\e[0;92m"
YELLOW="\033[1;33m"
RED='\033[0;31m'
RESET="\e[0m"

# OS check #
check_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$(echo "$ID" | awk '{print tolower($0)}')
    OS_VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si | awk '{print tolower($0)}')
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
    OS="SuSE"
    OS_VER="?"
  elif [ -f /etc/redhat-release ]; then
    OS="Red Hat/CentOS"
    OS_VER="?"
  else
    OS=$(uname -s)
    OS_VER=$(uname -r)
  fi

  OS=$(echo "$OS" | awk '{print tolower($0)}')
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}

# Find where pterodactyl is installed #
find_pterodactyl() {
print "Looking for your pterodactyl installation..."

sleep 2
if [ -d "/var/www/pterodactyl" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/pterodactyl"
  elif [ -d "/var/www/panel" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/panel"
  elif [ -d "/var/www/ptero" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/ptero"
  else
    PTERO_INSTALL=false
fi
# Update the variables after detection of the pterodactyl installation #
update_variables
}

# Verify Compatibility #
compatibility() {
print "Checking if the addon is compatible with your panel..."

sleep 2
if [ "$PANEL_VERSION" == "1.7.0" ] || [ "$PANEL_VERSION" == "1.8.1" ]; then
    print "Compatible Version!"
  else
    print_error "Incompatible Version!"
fi
}

# Install Dependencies #
dependencies() {
print "Installing dependencies..."

if node -v &>/dev/null; then
    print "The dependencies are already installed, skipping this step..."
  else
    case "$OS" in
      debian | ubuntu)
        curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && apt-get install -y nodejs
      ;;
      centos)
        [ "$OS_VER_MAJOR" == "7" ] && curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - && sudo yum install -y nodejs yarn
        [ "$OS_VER_MAJOR" == "8" ] && curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash - && sudo dnf install -y nodejs
      ;;
    esac
fi
}

# Panel Backup #
backup() {
print "Performing security backup..."

if [ -d "$PTERO/PanelBackup[Auto-Addons]" ]; then
    print "There is already a backup, skipping step....."
  else
    cd $PTERO
    if [ -d "$PTERO/node_modules" ]; then
        tar -czvf "PanelBackup[Auto-Addons].tar.gz" --exclude "node_modules" -- * .env
        mkdir -p "$PTERO/PanelBackup[Auto-Addons]"
        mv "$PTERO/PanelBackup[Auto-Addons].tar.gz" "$PTERO/PanelBackup[Auto-Addons]"
      else
        tar -czvf "PanelBackup[Auto-Addons].tar.gz" -- * .env
        mkdir -p "$PTERO/PanelBackup[Auto-Addons]"
        mv "$PTERO/PanelBackup[Auto-Addons].tar.gz" "$PTERO/PanelBackup[Auto-Addons]"
    fi
fi
}

# Download Files #
download_files() {
print "Downloading files..."

cd $PTERO/app/Http/Controllers/Api/Client/Servers
rm DatabaseController.php
rm LogsController.php
rm NetworkAlloctionController.php
rm PowerController.php
rm ScheduleController.php
rm ScheduleTaskController.php
rm SettingsController.php
rm SubuserController.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AHCACS/DatabaseController.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AHCACS/LogsController.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AHCACS/NetworkAlloctionController.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AHCACS/PowerController.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AHCACS/ScheduleController.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AHCACS/ScheduleTaskController.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AHCACS/SettingsController.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AHCACS/SubuserController.php
cd $PTERO/app/Models
rm AuditLog.php
rm Permissions.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AM/AuditLog.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/AM/Permissions.php
cd $PTERO/resources/scripts/api/server/
mkdir logs
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/RSAS/getAll.ts
cd $PTERO/resources/scripts/components/server/
mkdir logs
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/RSCS/LogsContainer.tsx
cd $PTERO/routes
rm api-client.php
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/R/api-client.php
cd $PTERO/resources/scripts/routers/
rm ServerRouter.tsx
wget https://raw.githubusercontent.com/VidulHB/Pterodactyl-AutoAddons/blob/main/addons/version1.x/Logging/RSR/ServerRouter.tsx
}

# Check if it is already installed #
verify_installation() {
if grep -q "Installed By Auto-Addons" "$SUBDOMAIN"; then
    print_error "This addon is already installed in your panel, aborting..."
    exit 1
  else
    dependencies
    backup
    download_files
    production
    bye
fi
}

# Check if another conflicting addon is installed #
check_conflict() {
print "Checking if a similar/conflicting addon is already installed..."

sleep 2
if [ -f "$MORE_BUTTONS" ]; then
    print_warning "The addon ${YELLOW}More Buttons${RESET} is already installed, aborting..."
    exit 1
  elif [ -f "$MC_PASTE" ]; then
    print_warning "The addon ${YELLOW}MC Paste${RESET} is already installed, aborting..."
    exit 1
fi
}

# Panel Production #
production() {
print "Producing panel..."
print_warning "This process takes a few minutes, please do not cancel it."

if [ -d "$PTERO/node_modules" ]; then
    cd $PTERO
    yarn build:production && chown -R www-data:www-data * && php artisan migrate && php artisan view:clear && php artisan cache:clear
  else
    npm i -g yarn
    cd $PTERO
    yarn build:production && chown -R www-data:www-data * && php artisan migrate && php artisan view:clear && php artisan cache:clear
fi
}

bye() {
print_brake 50
echo
echo -e "${GREEN}* The addon ${YELLOW}Bigger Console${GREEN} was successfully installed."
echo -e "* A security backup of your panel has been created."
echo -e "* Thank you for using this script."
echo -e "* Support group: ${YELLOW}$(hyperlink "$SUPPORT_LINK")${RESET}"
echo
print_brake 50
}

# Exec Script #
check_distro
find_pterodactyl
if [ "$PTERO_INSTALL" == true ]; then
    print "Installation of the panel found, continuing the installation..."

    compatibility
    check_conflict
    verify_installation
  elif [ "$PTERO_INSTALL" == false ]; then
    print_warning "The installation of your panel could not be located."
    echo -e "* ${GREEN}EXAMPLE${RESET}: ${YELLOW}/var/www/mypanel${RESET}"
    echo -ne "* Enter the pterodactyl installation directory manually: "
    read -r MANUAL_DIR
    if [ -d "$MANUAL_DIR" ]; then
        print "Directory has been found!"
        PTERO="$MANUAL_DIR"
        update_variables
        compatibility
        check_conflict
        verify_installation
      else
        print_error "The directory you entered does not exist."
        find_pterodactyl
    fi
fi