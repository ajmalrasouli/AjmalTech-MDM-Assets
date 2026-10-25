# AjmalTech MDM Assets

Central library for reusable AjmalTech device-management assets used in the MSP lab.

## Repository structure

- `wallpapers/` — corporate wallpapers by operating system and display target.
- `scripts/` — deployment and automation scripts.
- `configuration-profiles/` — macOS and iOS/iPadOS configuration-profile templates.
- `documentation/` — deployment guides, testing notes, and asset standards.

## Safety and usage

- Do not commit passwords, API tokens, private keys, customer data, device serial numbers, or other confidential information.
- Treat this repository as public. Anyone may be able to view and download its contents.
- Use generic sample data in scripts and documentation.
- Test all scripts and configuration profiles on a lab device before wider deployment.
- Keep binary assets such as wallpapers in their relevant OS-specific folder.

## Naming convention

Use descriptive, version-friendly names, for example:

- `AjmalTech-Wallpaper-macOS.jpg`
- `AjmalTech-Wallpaper-Windows-Desktop.jpg`
- `AJT-Deploy-Wallpaper-macOS.sh`

