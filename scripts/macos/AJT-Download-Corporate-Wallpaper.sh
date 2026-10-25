#!/bin/bash
# AjmalTech MDM Assets - Download corporate wallpaper
# Designed to be run as root via JumpCloud Commands on a test Mac.
set -euo pipefail

URL="https://raw.githubusercontent.com/ajmalrasouli/AjmalTech-MDM-Assets/main/wallpapers/macos/desktop/AjmalTech-Wallpaper.jpg"
DESTINATION="/Users/Shared/AjmalTech-Wallpaper.jpg"

echo "Downloading AjmalTech corporate wallpaper..."
/usr/bin/curl --fail --location --silent --show-error "$URL" --output "$DESTINATION"
/usr/sbin/chown root:wheel "$DESTINATION"
/bin/chmod 0644 "$DESTINATION"

if ! /usr/bin/file "$DESTINATION" | /usr/bin/grep -qiE 'JPEG image data|JPEG image'; then
  echo "ERROR: Downloaded file does not appear to be a JPEG image." >&2
  /bin/rm -f "$DESTINATION"
  exit 1
fi

echo "Wallpaper downloaded and validated at: $DESTINATION"
/bin/ls -lh "$DESTINATION"
