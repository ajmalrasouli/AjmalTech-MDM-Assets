#!/bin/bash

#Requires macOS

set -u

WALLPAPER_DIR="/Users/Shared"
WALLPAPER_NAME="AjmalTech-Blue-Circuit-Wallpaper.png"
WALLPAPER_PATH="$WALLPAPER_DIR/$WALLPAPER_NAME"

DOWNLOAD_URL="https://raw.githubusercontent.com/ajmalrasouli/AjmalTech-MDM-Assets/main/wallpapers/macos/desktop/AjmalTech%20Blue%20Circuit%20Wallpaper.png"

echo "========================================"
echo "AJMALTECH CORPORATE WALLPAPER ASSET"
echo "========================================"

echo "Wallpaper path: $WALLPAPER_PATH"

# Ensure the shared directory exists.
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Creating $WALLPAPER_DIR..."
    /bin/mkdir -p "$WALLPAPER_DIR"
fi

# Download the wallpaper if it is missing or empty.
if [ ! -s "$WALLPAPER_PATH" ]; then
    echo "Wallpaper missing. Downloading..."

    if ! /usr/bin/curl         --location         --fail         --show-error         --retry 3         --retry-delay 2         --connect-timeout 30         --max-time 120         "$DOWNLOAD_URL"         --output "$WALLPAPER_PATH"; then

        echo "ERROR: Wallpaper download failed."
        /bin/rm -f "$WALLPAPER_PATH"
        exit 1
    fi

    echo "Wallpaper downloaded successfully."
else
    echo "Wallpaper already exists. No download required."
fi

# Validate that the downloaded asset is actually an image.
if ! /usr/bin/file "$WALLPAPER_PATH" | /usr/bin/grep -qi "image"; then
    echo "ERROR: Downloaded file is not recognised as an image."
    exit 1
fi

# Keep the asset readable by the logged-in user while preventing normal users
# from replacing or modifying it.
 /usr/sbin/chown root:wheel "$WALLPAPER_PATH"
 /bin/chmod 644 "$WALLPAPER_PATH"

echo ""
echo "Wallpaper asset ready:"
/bin/ls -lh "$WALLPAPER_PATH"
/usr/bin/file "$WALLPAPER_PATH"

echo ""
echo "Corporate wallpaper asset deployment completed successfully."
exit 0
