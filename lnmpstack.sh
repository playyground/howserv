#!/bin/sh
clear; printf "\033[0;32mInitializing LNMPstack\033[0m\n"; sleep 2; time_start=`date +%M`; clear

printf "\033[0;32mUpdating your system\033[0m\n"; sleep 1
apt-get -q -y update && apt-get -q -y upgrade && apt-get -q -y clean && apt-get -q -y autoclean && apt-get -q -y autoremove && sleep 1 && clear

printf "\033[0;32mChanging default SSH port to random unprivileged port\033[0m\n"; sleep 1
ssh="$(shuf -i 1025-65534 -n 1)" && sed -i "s/Port 22/Port $ssh/g" /etc/ssh/sshd_config && /etc/init.d/ssh reload && sleep 1 && clear

printf "\033[0;32mInstalling Nginx-Extras\033[0m\n"; sleep 1
apt-get -q -y install nginx-extras && mkdir /etc/nginx/logs/ && touch /etc/nginx/logs/error_nginx.log && rm /etc/nginx/nginx.conf && sudo wget -P /etc/nginx/ https://privacdn.com/lnmpstack/nginx.conf && truncate -s 0 /etc/nginx/sites-available/default && printf 'server {\nlisten 80;\nroot /var/www/html;\n\nserver_name _;\nindex index.php index.html index.htm;\n\nlocation / {\ntry_files $uri $uri/ /$uri.php$is_args$args;\n}\n\nlocation ~\.php$ {\ninclude snippets/fastcgi-php.conf;\nfastcgi_pass unix:run/php/php7.1-fpm.sock;\n}\n}' > /etc/nginx/sites-available/default && clear

printf "\033[0;32mSetting up the firewall\033[0m\n"; sleep 1
yes | ufw enable && ufw allow 443/tcp && ufw limit $ssh/tcp && ufw allow 80/tcp && ufw default deny incoming && ufw default allow outgoing && ufw logging low && touch /etc/rc.local && printf '#!/bin/sh\n/usr/sbin/ufw enable' > /etc/rc.local && clear

printf "\033[0;32mInstalling Fail2Ban\033[0m\n"; sleep 1
apt-get -q -y install ufw fail2ban && cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local && service fail2ban restart && clear

printf "\033[0;32mSetting Security Updates preferences\033[0m\n"; sleep 1
apt-get -q -y install unattended-upgrades && truncate -s 0 /etc/apt/apt.conf.d/10periodic && printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Download-Upgradeable-Packages "1";\nAPT::Periodic::AutocleanInterval "7";\nAPT::Periodic::Unattended-Upgrade "1";' > /etc/apt/apt.conf.d/10periodic && clear

printf "\033[0;32mInstalling ZSH\033[0m\n"; sleep 1
apt-get -q -y install zsh && curl -L http://install.ohmyz.sh | sh && which zsh && chsh -s `which zsh` && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc && clear

printf "\033[0;32mInstalling PHP\033[0m\n"; sleep 1
add-apt-repository -y ppa:ondrej/php && apt-get update && apt-get -q -y install php7.1-fpm php7.1-cli php7.1-curl php7.1-mysql php7.1-sqlite3 php7.1-gd php7.1-xml php7.1-mcrypt php7.1-mbstring php7.1-iconv && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.1/fpm/php.ini && systemctl restart php7.1-fpm && service nginx restart && clear

printf "\033[0;32mInstalling Composer\033[0m\n"; sleep 1
 apt-get -q -y install zip unzip php7.0-zip && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && clear
 
 printf "\033[0;32mSetting up LNMPstack Home Directory\033[0m\n"; sleep 1
 rm /var/www/html/index.nginx-debian.html && cd /var/www/html/ && wget https://privacdn.com/lnmpstack/m4hxc2.txt && wget -i m4hxc2.txt && mv index.html index.php && rm /var/www/html/m4hxc2.txt && cd && clear

printf "\033[0;32mFinishing Installation\033[0m\n"; sleep 1
sed -i 's_https://help.ubuntu.com_lnmpstack.com/docs_g' /etc/update-motd.d/10-help-text && sed -i "/\b\(management\|landscape\)\b/d" /etc/update-motd.d/10-help-text && sed -i 's_https://ubuntu.com/advantage_playyground.com/support_g' /etc/update-motd.d/10-help-text && sed -i "/\b\(echo\|ubuntu\)\b/d" /etc/update-motd.d/51-cloudguest && apt-get -q -y update && apt-get -q -y upgrade && apt-get -q -y dist-upgrade && apt-get -q -y clean && apt-get -q -y autoclean && apt-get -q -y autoremove && deborphan | xargs apt-get -q -y remove --purge && time_end=`date +%M` && clear

printf "\033[0;32mInstallation Summary\033[0m\n"; sleep 1
time_exec=`expr $(( $time_end - $time_start ))`
ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
echo ""
echo "Time elapsed: $time_exec minute(s)"
echo ""
echo "SSH Port: $ssh"
echo "SSH Login: ssh -- root@$ip -p $ssh"
echo ""
echo ""

printf "\033[0;32mWould you like to restart your system? (y/n)\033[0m\n"
while true; do
    read yn
    case $yn in
        [Yy]* ) rm -- "$0"; reboot; clear;;
        [Nn]* ) rm -- "$0"; clear;;
        * ) echo "Please answer y or n.";;
    esac
done