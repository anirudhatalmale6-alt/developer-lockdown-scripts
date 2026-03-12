#!/bin/bash
# Developer Lockdown Script
# Run as: sudo bash lockdown.sh
# Blocks: git push, npm publish, upload tools, USB

echo "=== Applying Developer Lockdown ==="

# -------- 1. GIT PUSH BLOCK --------
# Wrapper at /usr/local/bin/git (higher PATH priority than /usr/bin/git)
cat > /usr/local/bin/git << 'GITEOF'
#!/bin/bash
case "$1" in
    push|remote)
        echo "BLOCKED: git $1 is disabled by admin"
        exit 1
        ;;
esac
exec /usr/bin/git "$@"
GITEOF
chmod +x /usr/local/bin/git
echo "[OK] git push/remote blocked"

# -------- 2. NPM LOGIN/PUBLISH BLOCK --------
# Find npm in all user NVM installs and system paths
for NPM_BIN in $(find /home -name "npm" -path "*/bin/npm" 2>/dev/null) /usr/bin/npm /usr/local/bin/npm; do
    if [ -f "$NPM_BIN" ] && [ ! -L "$NPM_BIN" ] && [ ! -f "${NPM_BIN}-real" ]; then
        cp "$NPM_BIN" "${NPM_BIN}-real"
        cat > "$NPM_BIN" << NPMEOF
#!/bin/bash
case "\$1" in
    login|publish|adduser|whoami|token)
        echo "BLOCKED: npm \$1 is disabled by admin"
        exit 1
        ;;
esac
exec "${NPM_BIN}-real" "\$@"
NPMEOF
        chmod +x "$NPM_BIN"
        echo "[OK] npm blocked: $NPM_BIN"
    fi
done

# -------- 3. BLOCK UPLOAD TOOLS --------
for tool in curl wget scp rsync ftp sftp; do
    if [ -f "/usr/bin/$tool" ]; then
        chmod 000 "/usr/bin/$tool" 2>/dev/null && echo "[OK] $tool blocked"
    fi
done

# -------- 4. USB STORAGE BLOCK --------
modprobe -r usb_storage 2>/dev/null
echo "install usb_storage /bin/false" > /etc/modprobe.d/block-usb.conf
echo "[OK] USB storage blocked"

# -------- 5. BLOCK BLUETOOTH FILE TRANSFER --------
systemctl stop bluetooth 2>/dev/null
systemctl disable bluetooth 2>/dev/null
echo "[OK] Bluetooth disabled"

echo ""
echo "=== Developer Lockdown Applied ==="
echo "Blocked: git push, npm publish, curl, wget, scp, rsync, ftp, sftp, USB, Bluetooth"
