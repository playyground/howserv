#!/bin/sh
clear; printf "\033[0;32mInitializing lnmpstack\033[0m\n"; sleep 3; clear

printf "\033[0;32mUpdating your system\033[0m\n"; sleep 2
apt-get update -y && apt-get upgrade -y && apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && sleep 2 && clear

printf "\033[0;32mChanging default SSH port to unprivileged port\033[0m\n"; sleep 2
SSH="$(shuf -i 1025-65534 -n 1)" && sed -i 's/Port 22/Port $SSH/g' /etc/ssh/sshd_config && /etc/init.d/ssh reload && sleep 2 && clear

printf "\033[0;32mInstalling Nginx-Extras 1.10\033[0m\n"; sleep 2
apt-get install nginx-extras -y && mkdir /etc/nginx/logs/ && touch /etc/nginx/logs/error_nginx.log && rm /etc/nginx/nginx.conf && sudo wget -P /etc/nginx/ https://privacdn.com/lnmpstack/nginx.conf && truncate -s 0 /etc/nginx/sites-available/default && printf 'server {\nlisten 80;\nroot /var/www/html;\n\nserver_name _;\nindex index.php index.html index.htm;\n\nlocation / {\ntry_files $uri $uri/ /$uri.php$is_args$args;\n}\n\nlocation ~\.php$ {\ninclude snippets/fastcgi-php.conf;\nfastcgi_pass unix:run/php/php7.1-fpm.sock;\n}\n}' > /etc/nginx/sites-available/default && clear

printf "\033[0;32mSetting up the firewall\033[0m\n"; sleep 2
yes | ufw enable && ufw allow 443/tcp && ufw limit $SSH/tcp && ufw allow 80/tcp && ufw default deny incoming && ufw default allow outgoing && ufw logging low && touch /etc/rc.local && printf '#!/bin/sh\n/usr/sbin/ufw enable' > /etc/rc.local && clear && ufw status verbose && sleep 3 && clear

printf "\033[0;32mInstalling Fail2Ban\033[0m\n"; sleep 2
apt-get install ufw fail2ban -y && cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local && service fail2ban restart && clear

printf "\033[0;32mSetting Security Updates preferences\033[0m\n"; sleep 2
apt-get install unattended-upgrades -y && truncate -s 0 /etc/apt/apt.conf.d/10periodic && printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Download-Upgradeable-Packages "1";\nAPT::Periodic::AutocleanInterval "7";\nAPT::Periodic::Unattended-Upgrade "1";' > /etc/apt/apt.conf.d/10periodic && clear

printf "\033[0;32mInstalling ZSH\033[0m\n"; sleep 2
apt-get install zsh -y && apt-get install git-core -y && curl -L http://install.ohmyz.sh | sh && which zsh && chsh -s `which zsh` && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc && clear

printf "\033[0;32mInstalling PHP 7.1\033[0m\n"; sleep 2
add-apt-repository -y ppa:ondrej/php && apt-get update && apt-get install -y php7.1-fpm php7.1-cli php7.1-curl php7.1-mysql php7.1-sqlite3 php7.1-gd php7.1-xml php7.1-mcrypt php7.1-mbstring php7.1-iconv && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini && systemctl restart php7.1-fpm && service nginx restart && clear

printf "\033[0;32mInstalling Laravel 5.5\033[0m\n"; sleep 2
rm /var/www/html/index.nginx-debian.html && apt-get install zip unzip php7.0-zip -y && cd ~ && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && cd /var/www/html && rm -f index.nginx-debian.html && composer create-project laravel/laravel . && chown -R www-data:www-data /var/www/html && chmod -R 775 /var/www/html/storage && sed -i 's_root /var/www/html_root /var/www/html/public_g' /etc/nginx/sites-available/default && clear

printf "\033[0;32mFinishing Installation\033[0m\n"; sleep 2
sed -i 's_https://help.ubuntu.com_lnmpstack.com/docs_g' /etc/update-motd.d/10-help-text && sed -i "/\b\(management\|landscape\)\b/d" /etc/update-motd.d/10-help-text && sed -i 's_https://ubuntu.com/advantage_playyground.com/support_g' /etc/update-motd.d/10-help-text && sed -i "/\b\(echo\|ubuntu\)\b/d" /etc/update-motd.d/51-cloudguest && apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && deborphan | xargs apt-get remove --purge && reboot && clear