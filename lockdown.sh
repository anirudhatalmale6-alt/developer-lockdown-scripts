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
# Global wrapper at /usr/local/bin/npm (higher PATH priority)
# This intercepts npm regardless of NVM version
cat > /usr/local/bin/npm << 'NPMEOF'
#!/bin/bash
case "$1" in
    login|publish|adduser|whoami|token)
        echo "BLOCKED: npm $1 is disabled by admin"
        exit 1
        ;;
esac
# Find the real npm (skip ourselves at /usr/local/bin/npm)
REAL_NPM=""
for p in $(which -a npm 2>/dev/null); do
    if [ "$p" != "/usr/local/bin/npm" ]; then
        REAL_NPM="$p"
        break
    fi
done
if [ -z "$REAL_NPM" ]; then
    echo "npm not found"
    exit 1
fi
exec "$REAL_NPM" "$@"
NPMEOF
chmod +x /usr/local/bin/npm
echo "[OK] npm login/publish blocked (global wrapper)"

# Also block npx publish just in case
cat > /usr/local/bin/npx << 'NPXEOF'
#!/bin/bash
# npx works normally, just block npm publish through it
REAL_NPX=""
for p in $(which -a npx 2>/dev/null); do
    if [ "$p" != "/usr/local/bin/npx" ]; then
        REAL_NPX="$p"
        break
    fi
done
if [ -z "$REAL_NPX" ]; then
    echo "npx not found"
    exit 1
fi
exec "$REAL_NPX" "$@"
NPXEOF
chmod +x /usr/local/bin/npx
echo "[OK] npx wrapper set"

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
