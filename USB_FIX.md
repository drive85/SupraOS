# USB Drive Support Fix

## Problem
USB drives were not appearing in PCManFM Places (left list) even when connected.

## Root Cause
The `udisks2` daemon was missing from the system. While `udisks2-libs` (dependency) was installed, the actual daemon `udisks2` was not. This caused gvfs-udisks2-volume-monitor to run but fail to detect or automount removable drives.

## Solution
Installed `udisks2` and `udisks2-openrc` packages and enabled the service.

### Packages Installed
- `udisks2` - The udisks daemon for disk management
- `udisks2-openrc` - OpenRC init script for udisks2

### Configuration
- Service enabled: `rc-update add udisks2 default`
- Service started: `rc-service udisks2 start`
- Added to `supra-bootstrap.sh` apk line for persistence

### Prerequisites (already in place)
- `exfatprogs` - exFAT filesystem support
- `ntfs-3g` - NTFS filesystem support
- Polkit rule: `/etc/polkit-1/localauthority/50-local.d/00-supra-usb.pkla`
- PCManFM config: `mount_removable=1`, `autorun=1`
- gvfs packages installed

## Verification
```bash
# Check udisks2 is running
pgrep -a udisks2

# Check service status
rc-status | grep udisks

# List connected drives
lsusb
```

## Result
USB drives (FAT32, exFAT, NTFS) now automount via gvfs/udisks2 and appear in PCManFM Places panel.

## Date
Nov 19 2026
