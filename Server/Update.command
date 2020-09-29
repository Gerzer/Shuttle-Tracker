#!/bin/bash

echo "Stopping daemon..." >> /dev/stdout
supervisorctl stop shuttle >> /var/log/shuttle_update.log
echo "Downloading shuttle server..." >> /dev/stdout
git pull >> /var/log/shuttle_update.log
echo "Building shuttle server..." >> /dev/stdout
swift build -c release >> /var/log/shuttle_update.log
echo "Starting daemon..." >> /dev/stdout
supervisorctl start shuttle >> /var/log/shuttle_update.log
echo "The shuttle server has been updated! You can check out the update log in \`/var/log/shuttle_update.log\`." >> /dev/stdout
