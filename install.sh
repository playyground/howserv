echo "Updating your system" && sleep 2
apt-get update -y && apt-get autoremove -y && apt-get autoclean -y && apt-get upgrade -y && sleep 2 && clear

echo "Changing default SSH port to 1500" && sleep 2
sed -i 's/Port 22/Port 1500/g' /etc/ssh/sshd_config && /etc/init.d/ssh reload && sleep 2 && clear

echo "Installing Nginx-Extras Module" && sleep 2
apt-get install nginx-extras -y && sleep 2 && mkdir /etc/nginx/logs/ && touch /etc/nginx/logs/error_nginx.log && sudo wget -P /etc/nginx/ https://privacdn.com/howserv/nginx.conf && clear

echo "Setting up the firewall" && sleep 2
yes | ufw enable && ufw allow 443/tcp && ufw limit 1500/tcp && ufw allow 80/tcp && ufw default deny incoming && ufw default allow outgoing && ufw logging low && clear && touch /etc/rc.local && printf '#!/bin/sh\n/usr/sbin/ufw enable' > /etc/rc.local && clear && ufw status verbose && sleep 3 && clear

echo "Installing fail2ban" && sleep 2
apt-get install ufw fail2ban -y && cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local && service fail2ban restart && clear

echo "Setting Security Updates preferences" && sleep 2
apt-get install unattended-upgrades -y && truncate -s 0 /etc/apt/apt.conf.d/10periodic && printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Download-Upgradeable-Packages "1";\nAPT::Periodic::AutocleanInterval "7";\nAPT::Periodic::Unattended-Upgrade "1";' > /etc/apt/apt.conf.d/10periodic && clear

echo "Installing ZSH" && sleep 2
apt-get install zsh -y && apt-get install git-core -y && curl -L http://install.ohmyz.sh | sh && which zsh && chsh -s `which zsh` && git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc && clear

echo "Installing PHP" && sleep 2
apt-get install php-fpm php-mysql -y && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.0/fpm/php.ini && systemctl restart php7.0-fpm && service nginx restart && clear

echo "Installing updates and restarting" && sleep 2
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get clean -y && sudo apt-get autoclean -y && sudo apt-get autoremove -y && sudo deborphan | xargs sudo apt-get remove --purge && sudo reboot