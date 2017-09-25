echo "Updating your system" && sleep 2
apt-get update -y && apt-get upgrade -y && apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && sleep 2 && clear

echo "Changing default SSH port to 1500" && sleep 2
sed -i 's/Port 22/Port 1500/g' /etc/ssh/sshd_config && /etc/init.d/ssh reload && sleep 2 && clear

echo "Installing Nginx-Extras Module" && sleep 2
apt-get install nginx-extras -y && mkdir /etc/nginx/logs/ && touch /etc/nginx/logs/error_nginx.log && rm /etc/nginx/nginx.conf && sudo wget -P /etc/nginx/ https://privacdn.com/howserv/nginx.conf && truncate -s 0 /etc/nginx/sites-available/default && printf 'server {\nlisten 80;\nroot /var/www/html;\n\nserver_name _;\nindex index.php index.html index.htm;\n\nlocation / {\ntry_files $uri $uri/ /$uri.php$is_args$args;\n}\n\nlocation ~\.php$ {\ninclude snippets/fastcgi-php.conf;\nfastcgi_pass unix:run/php/php7.1-fpm.sock;\n}\n}' > /etc/nginx/sites-available/default

echo "Setting up the firewall" && sleep 2
yes | ufw enable && ufw allow 443/tcp && ufw limit 1500/tcp && ufw allow 80/tcp && ufw default deny incoming && ufw default allow outgoing && ufw logging low && clear && touch /etc/rc.local && printf '#!/bin/sh\n/usr/sbin/ufw enable' > /etc/rc.local && clear && ufw status verbose && sleep 3 && clear

echo "Installing Fail2Ban" && sleep 2
apt-get install ufw fail2ban -y && cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local && service fail2ban restart && clear

echo "Setting Security Updates preferences" && sleep 2
apt-get install unattended-upgrades -y && truncate -s 0 /etc/apt/apt.conf.d/10periodic && printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Download-Upgradeable-Packages "1";\nAPT::Periodic::AutocleanInterval "7";\nAPT::Periodic::Unattended-Upgrade "1";' > /etc/apt/apt.conf.d/10periodic && clear

echo "Installing ZSH" && sleep 2
apt-get install zsh -y && apt-get install git-core -y && curl -L http://install.ohmyz.sh | sh && which zsh && chsh -s `which zsh` && git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc && clear

echo "Installing PHP" && sleep 2
add-apt-repository -y ppa:ondrej/php && apt-get update && apt-get install -y php7.1-fpm php7.1-cli php7.1-curl php7.1-mysql php7.1-sqlite3 php7.1-gd php7.1-xml php7.1-mcrypt php7.1-mbstring php7.1-iconv && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini && systemctl restart php7.1-fpm && service nginx restart && clear

echo "Finishing Installation"
rm /var/www/html/index.nginx-debian.html && echo "<?php echo 'Hello, world!' ?>" >> /var/www/html/index.php && mkdir /var/www/html/php/ && echo "<?php phpinfo() ?>" >> /var/www/html/php/index.php

echo "Installing updates and restarting" && sleep 2
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && deborphan | xargs apt-get remove --purge && reboot