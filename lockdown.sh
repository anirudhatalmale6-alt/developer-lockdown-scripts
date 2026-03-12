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
# NVM puts its bin/ BEFORE /usr/local/bin in PATH, so /usr/local/bin wrapper won't work.
# Shell functions override PATH entirely — this is the reliable way.
cat > /etc/profile.d/npm-lockdown.sh << 'FUNCEOF'
npm() {
    case "$1" in
        login|publish|adduser|whoami|token)
            echo "BLOCKED: npm $1 is disabled by admin"
            return 1
            ;;
    esac
    command npm "$@"
}
export -f npm
FUNCEOF
chmod +x /etc/profile.d/npm-lockdown.sh
echo "[OK] npm login/publish blocked (shell function)"

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
echo "NOTE: npm block requires new terminal or run: source /etc/profile.d/npm-lockdown.sh"
echo "Blocked: git push, npm publish, curl, wget, scp, rsync, ftp, sftp, USB, Bluetooth"
