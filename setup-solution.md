# TEL Setup Solution

This document details the manual fixes applied to resolve the `tel-setup` failure on Android (Samsung SM-S906U1, ARM64).

## 1. Environment & Dependency Fixes

### ADB Authorization
- Re-authorized the device by revoking USB debugging permissions in Developer Options and reconnecting to trigger the RSA prompt.

### Missing Libraries (Linker Errors)
The system reported `CANNOT LINK EXECUTABLE "apt-get": library "libz.so.1" not found`.
- **Fix**: Created a symbolic link from the existing `libz.so.1.3.2` to `libz.so.1` and ensured permissions were correct.
- **Command**:
  ```bash
  chmod 755 /data/data/com.termux/files/usr/lib/libz.so.1.3.2
  ln -sf /data/data/com.termux/files/usr/lib/libz.so.1.3.2 /data/data/com.termux/files/usr/lib/libz.so.1
  ```

### API Extension
- Downloaded and installed the official `TEL.API.apk` from the `t-e-l/termux-api` repository to ensure full functionality.

## 2. Repository Fixes
The official Termux mirrors were returning 404 errors or failing integrity checks.
- **Fix**: Manually pointed `sources.list` to the Grimler legacy mirror for Android 7+ compatible packages.
- **Command**:
  ```bash
  echo "deb https://grimler.se/termux-packages-24 stable main" > /data/data/com.termux/files/usr/etc/apt/sources.list
  apt-get update
  ```

## 3. Script Patches (`tel-setup`)
Several patches were applied to `../usr/bin/tel-setup` via `sed` to bypass broken logic and deprecated packages:

| Patch | Command | Reason |
| :--- | :--- | :--- |
| **Bypass Mirror Check** | `sed -i "s/pkg install/apt-get install -y/g"` | `pkg` triggers a mirror check that fails on legacy setups. |
| **Fix Deprecated exa** | `sed -i "s/exa/eza/g"` | `exa` is no longer available; `eza` is the modern replacement. |
| **Disable Self-Update** | `sed -i "s/tel-update/#tel-update/g"` | Prevented the script from reverting my manual fixes by pulling from the broken remote. |
| **Fix Syntax Error** | `sed -i "106,108s/^/#/"` | Commented out a multiline `echo` command that was causing a "syntax error near unexpected token" in Zsh. |
| **Disable Connection Check** | `sed -i '32s/^/#/'` | The `check_connection` function was failing despite active internet. |

## 4. Final Result
The setup was completed successfully. The launcher is now active and the terminal is running within a TMUX session managed by TEL.
