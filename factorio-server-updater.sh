#!/bin/bash

# Factorio Server Auto-Update Script
# Developed by Tibério in Brazil

# Configuration
FACTORIO_PATH="/opt/factorio"  # [FACTORIO FOLDER PATH HERE]
DISCORD_WEBHOOK=""            # [DISCORD WEBHOOK URL HERE] (Optional)

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Validate Factorio path
if [ ! -d "$FACTORIO_PATH" ]; then
    echo "Error: Factorio directory not found at $FACTORIO_PATH"
    echo "Please update FACTORIO_PATH in the script to point to your Factorio installation"
    exit 1
fi

# Function to send Discord message
send_discord_message() {
    if [ -n "$DISCORD_WEBHOOK" ]; then
        local message="$1"
        curl -H "Content-Type: application/json" \
             -d "{\"content\":\"$message\"}" \
             $DISCORD_WEBHOOK
    fi
}

# Change to Factorio directory
cd "$FACTORIO_PATH"

# Get current version to compare
if [ ! -f "$FACTORIO_PATH/bin/x64/factorio" ]; then
    echo "Error: Factorio executable not found. Please check your installation"
    exit 1
fi

CURRENT_VERSION=$("$FACTORIO_PATH/bin/x64/factorio" --version | head -n1 | cut -d' ' -f2)

# Get latest version from Factorio API
LATEST_VERSION=$(curl -s https://updater.factorio.com/get-available-versions | grep -o '"stable":"[^"]*"' | cut -d'"' -f4)

echo "Current version: $CURRENT_VERSION"
echo "Latest version: $LATEST_VERSION"

# Compare versions
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Update available: $CURRENT_VERSION -> $LATEST_VERSION"
    send_discord_message "🔄 Factorio server update available! Updating from $CURRENT_VERSION to $LATEST_VERSION..."
    
    # Check if systemctl exists and service is active
    if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet factorio; then
        systemctl stop factorio
        send_discord_message "⏸️ Server stopped for update"
    else
        echo "Note: Factorio service not found or not running via systemd"
    fi
    
    # Create temp directory for download
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR
    
    # Download and extract new version
    if wget -O factorio_latest.tar.xz "https://factorio.com/get-download/stable/headless/linux64"; then
        if tar -xf factorio_latest.tar.xz; then
            # Copy new files
            cp -rf factorio/* "$FACTORIO_PATH/"
            
            # Set permissions if factorio user exists
            if getent passwd factorio > /dev/null; then
                chown -R factorio:factorio "$FACTORIO_PATH"
            else
                echo "Note: factorio user not found, skipping permission change"
            fi
            
            # Start the server if systemd is available
            if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet factorio; then
                systemctl start factorio
            fi
            
            echo "Successfully updated to version $LATEST_VERSION"
            send_discord_message "✅ Server updated and started! Now running version $LATEST_VERSION"
        else
            echo "Failed to extract update"
            send_discord_message "❌ Failed to extract update"
            # Try to restart server if it was running
            if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet factorio; then
                systemctl start factorio
            fi
        fi
    else
        echo "Failed to download update"
        send_discord_message "❌ Failed to download update"
        # Try to restart server if it was running
        if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet factorio; then
            systemctl start factorio
        fi
    fi
    
    # Clean up
    cd "$FACTORIO_PATH"
    rm -rf $TEMP_DIR
else
    echo "Already running latest version $CURRENT_VERSION"
fi
