#!/bin/bash

echo "Applying developer lockdown..."

# ---------------- GIT WRAPPER ----------------
# Real git is at /usr/bin/git, wrapper goes to /usr/local/bin/git (higher priority in PATH)
if [ ! -f /usr/local/bin/git ]; then
    sudo bash -c 'cat > /usr/local/bin/git << "GITEOF"
#!/bin/bash
blocked_cmds="push remote"
for cmd in $blocked_cmds; do
    if [[ "$1" == "$cmd" ]]; then
        echo "git $1 blocked by admin"
        exit 1
    fi
done
exec /usr/bin/git "$@"
GITEOF'
    sudo chmod +x /usr/local/bin/git
    echo "  Git push/remote blocked"
else
    echo "  Git wrapper already exists"
fi

# ---------------- NPM WRAPPER (NVM) ----------------
NPM_PATH=$(which npm 2>/dev/null)

if [[ "$NPM_PATH" == *".nvm"* ]]; then
    if [ ! -f "$NPM_PATH-real" ]; then
        cp "$NPM_PATH" "$NPM_PATH-real"
        cat > "$NPM_PATH" << NPMEOF
#!/bin/bash
case "\$1" in
    login|publish|adduser|whoami)
        echo "npm \$1 blocked by admin"
        exit 1
        ;;
esac
exec "${NPM_PATH}-real" "\$@"
NPMEOF
        chmod +x "$NPM_PATH"
        echo "  NPM login/publish blocked"
    else
        echo "  NPM wrapper already exists"
    fi
fi

# ---------------- BLOCK UPLOAD TOOLS ----------------
for tool in curl wget scp rsync ftp; do
    if [ -f "/usr/bin/$tool" ]; then
        sudo chmod 000 "/usr/bin/$tool" 2>/dev/null
    fi
done
echo "  curl/wget/scp/rsync/ftp blocked"

# ---------------- USB BLOCK ----------------
sudo modprobe -r usb_storage 2>/dev/null
echo "  USB storage blocked"

echo ""
echo "Developer lockdown applied"
