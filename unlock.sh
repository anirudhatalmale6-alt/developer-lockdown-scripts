#!/bin/bash
# Developer Unlock Script
# Run as: sudo bash unlock.sh
# Restores everything blocked by lockdown.sh

echo "=== Removing Developer Lockdown ==="

# -------- 1. RESTORE GIT --------
if [ -f /usr/local/bin/git ]; then
    rm -f /usr/local/bin/git
    echo "[OK] git restored"
else
    echo "[--] git already clean"
fi

# -------- 2. RESTORE NPM --------
rm -f /etc/profile.d/npm-lockdown.sh
rm -f /usr/local/bin/npm
rm -f /usr/local/bin/npx
echo "[OK] npm lockdown removed (reopen terminal to take effect)"

# -------- 3. RESTORE UPLOAD TOOLS --------
for tool in curl wget scp rsync ftp sftp; do
    if [ -f "/usr/bin/$tool" ]; then
        chmod 755 "/usr/bin/$tool" 2>/dev/null && echo "[OK] $tool restored"
    fi
done

# -------- 4. RESTORE USB --------
rm -f /etc/modprobe.d/block-usb.conf
modprobe usb_storage 2>/dev/null
echo "[OK] USB storage restored"

# -------- 5. RESTORE BLUETOOTH --------
systemctl enable bluetooth 2>/dev/null
systemctl start bluetooth 2>/dev/null
echo "[OK] Bluetooth restored"

echo ""
echo "=== Lockdown Removed ==="
echo "NOTE: npm unlock requires new terminal or run: unset -f npm"
