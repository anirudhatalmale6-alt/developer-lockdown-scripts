#!/bin/bash

echo "Removing developer lockdown..."

# ---------- RESTORE GIT ----------
if [ -f /usr/local/bin/git ]; then
    sudo rm -f /usr/local/bin/git
    echo "  Git restored"
else
    echo "  Git already clean"
fi

# ---------- RESTORE NVM NPM ----------
NPM_PATH=$(which npm 2>/dev/null)

if [[ "$NPM_PATH" == *".nvm"* ]] && [ -f "$NPM_PATH-real" ]; then
    rm -f "$NPM_PATH"
    mv "$NPM_PATH-real" "$NPM_PATH"
    echo "  NPM restored"
else
    echo "  NPM already clean"
fi

# ---------- RESTORE TOOLS ----------
for tool in curl wget scp rsync ftp; do
    if [ -f "/usr/bin/$tool" ]; then
        sudo chmod 755 "/usr/bin/$tool" 2>/dev/null
    fi
done
echo "  curl/wget/scp/rsync/ftp restored"

# ---------- RESTORE USB ----------
sudo modprobe usb_storage 2>/dev/null
echo "  USB storage restored"

echo ""
echo "Lockdown removed"
