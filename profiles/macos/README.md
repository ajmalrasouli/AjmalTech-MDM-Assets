# macOS Corporate Wallpaper

Deploys and enforces the AjmalTech corporate wallpaper on managed macOS devices.

## Components

### 1. Wallpaper asset deployment

Script:

`scripts/jumpcloud/Install-JC-CorporateWallpaper.sh`

The script:

- Checks whether the wallpaper exists at `/Users/Shared/AjmalTech-Blue-Circuit-Wallpaper.png`
- Downloads it from the AjmalTech GitHub repository when missing or empty
- Verifies the downloaded file is recognised as an image
- Sets ownership to `root:wheel`
- Sets permissions to `644`

Run the JumpCloud command as **root**.

### 2. macOS configuration profile

Profile:

`profiles/macos/AjmalTech-Corporate-Wallpaper.mobileconfig`

The profile uses the macOS `com.apple.desktop` payload and points to:

`/Users/Shared/AjmalTech-Blue-Circuit-Wallpaper.png`

In testing on macOS Tahoe, the profile:

- Applied the AjmalTech wallpaper automatically
- Prevented the logged-in user from changing the wallpaper manually

## Deployment order

1. Deploy the wallpaper asset script through JumpCloud.
2. Confirm the image exists locally.
3. Deploy the `.mobileconfig` profile through JumpCloud MDM.
4. Verify the wallpaper changes.
5. Verify the user cannot change the wallpaper in System Settings.

## Notes

The script is responsible for making the local wallpaper asset available. The configuration profile is responsible for enforcing the desktop wallpaper.

This separation avoids relying on AppleScript/System Events, which can be blocked by macOS TCC when commands are launched from an MDM/root context.
