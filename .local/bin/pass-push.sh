#!/bin/bash

cd $HOME/.password-store || exit 1

# Try to push changes to remote
if git push origin main; then
    echo "$(date): Push successful, stopping pass-push.timer"
    # Stop the systemd user timer to stop retry attempts
    systemctl --user disable pass-push.timer
else
    echo "$(date): Push failed, will retry on next timer."
    # Keep the timer running for next retries
    exit 1
fi
