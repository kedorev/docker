echo -e "\033[32mENREGISTREMENT TACHES CRON POUR LA SECURITE DU SERVEUR\033[0m"

apt-get update 
apt-get install sudo
apt-get install crontab

echo -e "\033[32mInstallation logwatch...\033[0m"
sudo apt-get install -y -qq logwatch 
crontab -l | { cat; echo "0 3 * * * logwatch –detail low –format text > /home/vagrant/logwatch.log"; } | crontab -

echo -e "\033[32mInstallation fail2ban...\033[0m"
sudo apt-get install -y -qq fail2ban
echo "# SSH" >> sudo /etc/fail2ban/jail.conf
echo "# 3 retry ? > Ban for 15 minutes" >> sudo /etc/fail2ban/jail.conf
echo "[ssh]" >> sudo /etc/fail2ban/jail.conf
echo "enabled = true" >> sudo /etc/fail2ban/jail.conf
echo "port = ssh" >> sudo /etc/fail2ban/jail.conf
echo "filter = sshd" >> sudo /etc/fail2ban/jail.conf
echo "action = iptables[name=SSH, port=ssh, protocol=tcp]" >> sudo /etc/fail2ban/jail.conf
echo "logpath = /va/log/auth.log" >> sudo /etc/fail2ban/jail.conf
echo "maxretry = 3" >> sudo /etc/fail2ban/jail.conf
echo "bantime = 900" >> sudo /etc/fail2ban/jail.conf

echo "# 360 requests in 2 min > Ban for 10 minutes" >> sudo /etc/fail2ban/jail.conf
echo "[http-get-dos]" >> sudo /etc/fail2ban/jail.conf
echo "enabled = true" >> sudo /etc/fail2ban/jail.conf
echo "port = http,https" >> sudo /etc/fail2ban/jail.conf
echo "filter = http-get-dos" >> sudo /etc/fail2ban/jail.conf
echo "logpath = /var/log/varnish/varnishncsa.log" >> sudo /etc/fail2ban/jail.conf
echo "maxretry = 360" >> sudo /etc/fail2ban/jail.conf
echo "findtime = 120" >> sudo /etc/fail2ban/jail.conf
echo "action = iptables[name=HTTP, port=http, protocol=tcp]" >> sudo /etc/fail2ban/jail.conf
echo "mail-whois-lines[name=%(__name__)s, dest=%(destemail)s, logpath=%(logpath)s]" >> sudo /etc/fail2ban/jail.conf
echo "bantime = 600" >> sudo /etc/fail2ban/jail.conf

echo -e "\033[32mInstallation rkhunter...\033[0m"
sudo apt-get install -y -qq rkhunter
crontab -l | { cat; echo "0 4 * * * /usr/bin/rkhunter --cronjob --update --quiet"; } | crontab -

echo -e "\033[32mInstallation chkrootkit...\033[0m"
sudo apt-get install -y -qq chkrootkit 
crontab -l | { cat; echo "15 4 * * * /usr/bin/chkrootkit > /home/vagrant/chkrootkit.log "; } | crontab -