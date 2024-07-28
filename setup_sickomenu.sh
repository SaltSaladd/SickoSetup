#!/bin/bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if wget is installed
if ! command_exists wget; then
    echo "wget is required but it's not installed. Please install wget and try again."
    exit 1
fi

# Check if unzip is installed
if ! command_exists unzip; then
    echo "unzip is required but it's not installed. Please install unzip and try again."
    exit 1
fi

# Check if wine is installed
if ! command_exists wine; then
    echo "wine is required but it's not installed. Please install wine and try again."
    exit 1
fi

echo "Please enter the path to your Among Us directory:"
read AMONG_US_DIR

# Check if the directory exists
if [ ! -d "$AMONG_US_DIR" ]; then
    echo "The directory $AMONG_US_DIR does not exist. Please check the path and try again."
    exit 1
fi

# Fetch the latest release URL from GitHub
LATEST_RELEASE_URL=$(wget -qO- https://api.github.com/repos/g0aty/SickoMenu/releases/latest | grep browser_download_url | grep Release.zip | cut -d '"' -f 4)

# Check if the URL was found
if [ -z "$LATEST_RELEASE_URL" ]; then
    echo "Could not fetch the latest release URL. Please check the GitHub repository and try again."
    exit 1
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Download the latest release zip file
wget -O "$TEMP_DIR/Release.zip" "$LATEST_RELEASE_URL"

# Extract the zip file
unzip "$TEMP_DIR/Release.zip" -d "$TEMP_DIR"

# Move version.dll to the Among Us directory
mv "$TEMP_DIR/version.dll" "$AMONG_US_DIR"

# Get the Proton prefix path for Among Us
PROTON_APP_ID=945360 # Among Us Steam App ID
STEAM_COMPAT_DATA_PATH="$HOME/.steam/steam/steamapps/compatdata/$PROTON_APP_ID"
PROTON_PREFIX="$STEAM_COMPAT_DATA_PATH/pfx"

# Verify that the Proton prefix exists
if [ ! -d "$PROTON_PREFIX" ]; then
    echo "The Proton prefix for Among Us could not be found. Please ensure the game is installed and run at least once."
    exit 1
fi

# Set the DLL override directly using wine registry settings
WINEPREFIX="$PROTON_PREFIX" wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides" /v version /t REG_SZ /d "native,builtin" /f

echo "SickoMenu should now work properly in the game."

# Cleanup
rm -rf "$TEMP_DIR"

echo "Setup is complete."
