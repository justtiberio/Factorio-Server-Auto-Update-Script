# Factorio Server Auto-Update Script

A simple bash script to automatically update your Factorio headless server. Never miss an update again!

## Why This Script?

The Factorio headless server doesn't include an auto-update feature, requiring manual downloads and installations of new versions. With Factorio's regular updates (especially with the recent release of version 2.0!), this can become a tedious task for server administrators.

This script solves that problem by:
- Automatically checking for new Factorio versions
- Downloading and installing updates when available
- Safely stopping and starting your server during updates
- Optionally notifying your players via Discord when updates are happening

## Features

- 🔍 Automatic version detection
- ⚡ Quick and safe update process
- 🧹 Automatic cleanup of temporary files
- 🔔 Optional Discord notifications
- 🛡️ Safe error handling
- 💪 Works across different Linux distributions

## Prerequisites

- Linux system with bash
- Root access or sudo privileges
- Factorio headless server already installed
- `wget` and `curl` installed
- systemd (optional, but recommended)

## Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/justtiberio/Factorio-Server-Auto-Update-Script/refs/heads/main/factorio-server-updater.sh
```

2. Make it executable:
```bash
chmod +x auto-update.sh
```

## Configuration

Open the script in your favorite text editor and modify these variables at the top:

```bash
FACTORIO_PATH="/opt/factorio"  # Change this to your Factorio installation path
DISCORD_WEBHOOK=""            # Optional: Add your Discord webhook URL
```

### Setting Up Discord Notifications (Optional)

1. In your Discord server, go to Server Settings → Integrations → Create Webhook
2. Create a new webhook and copy the URL
3. Paste the webhook URL into the `DISCORD_WEBHOOK` variable in the script

## Usage

### Manual Execution

Run the script with sudo:
```bash
sudo ./auto-update.sh
```

### Automated Checking with Cron

To automatically check for updates, you can set up a cron job:

1. Open your root crontab:
```bash
sudo crontab -e
```

2. Add one of these lines:
```bash
# Check once a day at 4 AM:
0 4 * * * /path/to/auto-update.sh

# Check twice a day (4 AM and 4 PM):
0 4,16 * * * /path/to/auto-update.sh

# Check every 6 hours:
0 */6 * * * /path/to/auto-update.sh
```

Make sure to replace `/path/to/auto-update.sh` with the actual path to your script!

## How It Works

1. The script checks your current Factorio version
2. Compares it with the latest version from Factorio's Website
3. If an update is available:
   - Sends a Discord notification (if configured)
   - Stops the Factorio server
   - Downloads the new version
   - Installs the update
   - Restarts the server
   - Sends a completion notification
   - Cleans up temporary files

## Troubleshooting

### Common Issues

1. **"Please run with sudo" error**
   - The script needs root privileges to update Factorio
   - Run it with `sudo`

2. **"Factorio directory not found" error**
   - Check if your `FACTORIO_PATH` is correct
   - Verify that the directory exists and is accessible

3. **Discord notifications not working**
   - Verify your webhook URL is correct
   - Check if the URL is properly formatted in the script
   - Test your webhook URL manually using curl

## Contributing

Feel free to submit issues and pull requests! All contributions are welcome :)

## Credits

Developed by Tibério in Brazil.

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

For commercial use, please contact the author for licensing options.
