#!/bin/bash

source ~/.bashrc
if [ $(id -u) -ne 0 ]; then
	echo "ERROR: This script must be run as root." >> /dev/stderr
	exit
fi
if [ -z $email ]; then
	echo "ERROR: Email not set" >> /dev/stderr
	echo "Specify your email address (needed to register for an SSL certificate) in the \`email\` environment variable, which you should set with the \'export\' command." >> /dev/stdout
	exit
fi
if [ -z $domain ]; then
	echo "ERROR: Domain not set" >> /dev/stderr
	echo "Specify your preferred domain (e.g., \"shuttle.gerzer.software\") in the \`domain\` environment variable, which you should set with the \`export\` command in your \`~/.bashrc\` file." >> /dev/stdout
	exit
fi
echo "Updating package lists..." >> /dev/stdout
apt-get update -y >> /var/log/shuttle_install.log
echo "Installing dependencies..." >> /dev/stdout
apt-get install -y wget clang libtinfo5 libpython2.7-dev libncurses5 libcurl4 git supervisor certbot >> /var/log/shuttle_install.log
cd /tmp/
echo "Downloading Swift..." >> /dev/stdout
wget "https://swift.org/builds/swift-5.3-release/ubuntu1804/swift-5.3-RELEASE/swift-5.3-RELEASE-ubuntu18.04.tar.gz" >> /var/log/shuttle_install.log
echo "Unpacking Swift..." >> /dev/stdout
tar -xvzf swift-5.3-RELEASE-ubuntu18.04.tar.gz >> /var/log/shuttle_install.log
echo "Installing Swift..." >> /dev/stdout
mv swift-5.3-RELEASE-ubuntu18.04 /opt/swift
cd ~/
echo "export PATH=/opt/swift/usr/bin:$PATH" >> .bashrc
source .bashrc
echo "Downloading shuttle server..." >> /dev/stdout
git clone "https://github.com/Gerzer/Rensselaer-Shuttle.git" >> /var/log/shuttle_install.log
mv Rensselaer-Shuttle shuttle
cd shuttle/Server/
chmod +x Update.command
echo "Building shuttle server..." >> /dev/stdout
swift build -c release >> /var/log/shuttle_install.log
echo "Configuring daemon..." >> /dev/stdout
address=$(wget "http://ipecho.net/plain" -O - -q)
echo "#!/bin/bash\n\nexport domain=$domain\n$(pwd)/.build/release/Runner serve --bind $address:443" > Serve.command
chmod +x Serve.command
echo -e "[program:shuttle]\ncommand=$(pwd)/Serve.command\ndirectory=$(pwd)\nstdout_logfile=/var/log/supervisor/shuttle_out.log\nstderr_logfile=/var/log/supervisor/shuttle_err.log" > /etc/supervisor/conf.d/shuttle.conf
supervisorctl reread >> /var/log/shuttle_install.log
echo "Generating SSL certificate..." >> /dev/stdout
certbot certonly --non-interactive --standalone --agree-tos --email $email --domains $domain >> /var/log/shuttle_install.log
echo -e "#!/bin/bash\n\nsupervisorctl stop shuttle" > /etc/letsencrypt/renewal-hooks/pre/shuttle.command
echo -e "#!/bin/bash\n\nsupervisorctl start shuttle" > /etc/letsencrypt/renewal-hooks/post/shuttle.command
chmod +x /etc/letsencrypt/renewal-hooks/pre/shuttle.command
chmod +x /etc/letsencrypt/renewal-hooks/post/shuttle.command
echo "Starting daemon..." >> /dev/stdout
supervisorctl add shuttle >> /var/log/shuttle_install.log
echo "The shuttle server has been installed! You can check out the installation log in \`/var/log/shuttle_install.log\`. Execute \`$(pwd)/Update.command\` at any time to update the server to the latest version." >> /dev/stdout
