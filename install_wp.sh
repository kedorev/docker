
#!/bin/bash

# Installation automatisée de mysql et phpmyadmin

echo -e "\033[44;1m  _____           _        _ _       _   _              ";
echo -e " |_   _|         | |      | | |     | | (_)             ";
echo -e "   | |  _ __  ___| |_ __ _| | | __ _| |_ _  ___  _ __   ";
echo -e "   | | | '_ \/ __| __/ _\` | | |/ _\` | __| |/ _ \| '_ \  ";
echo -e "  _| |_| | | \__ \ || (_| | | | (_| | |_| | (_) | | | | ";
echo -e " ______|_| |_____/\__\__,___|_|\__,_|\__|_|\___/|_| |_| ";
echo -e " \ \        / /          | |                            ";
echo -e "  \ \  /\  / /__  _ __ __| |_ __  _ __ ___  ___ ___     ";
echo -e "   \ \/  \/ / _ \| '__/ _\` | '_ \| '__/ _ \/ __/ __|    ";
echo -e "    \  /\  / (_) | | | (_| | |_) | | |  __/\__ \__ \    ";
echo -e "     \/  \/ \___/|_|  \__,_| .__/|_|  \___||___/___/    ";
echo -e "                           | |                          ";
echo -e "                           |_|                          ";
echo -e "                                                        \033[0m";

cmdProxy='command'
command type sudo &> /dev/null && cmdProxy='sudo'

echo -e '\033[32mAPT GET UPDATE...\033[0m'

${cmdProxy} apt-get -qq update

echo -e '\033[32mTéléchargement WP-CLI...\033[0m'
${cmdProxy} apt-get install php5 -y -qq
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
${cmdProxy} mv wp-cli.phar /usr/local/bin/wp

echo -e '\033[32mCréation dossier site...\033[0m'
NOW=$(date +"%d-%m-%Y_%k-%M-%S")
DOSSIER="./wp_site_${NOW}"
mkdir ${DOSSIER}
cd ${DOSSIER}
echo -e "\033[36m${DOSSIER}\033[0m"

echo -e '\033[32mTéléchargement fichiers wordpress...\033[0m'
wp core download

echo -e '\033[32mConfiguration du Wordpress...\033[0m'
DB_NAME="wordpress_${NOW}"
DB_USER=root
DB_PASSWORD="$(cat ../tmpPassMySQLRoot)"
DB_PREFIX=wp
LOCALE=en_EN
echo -e " - dbname=${DB_NAME}"
echo -e " - dbuser=${DB_USER}"
echo -e " - dbpass=${DB_PASSWORD}"
echo -e " - dbprefix=${DB_PREFIX}"
echo -e " - locale=${LOCALE}"
wp core config --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASSWORD} --dbprefix=${DB_PREFIX} --locale=${LOCALE}

echo -e '\033[32mCréation base de données...\033[0m'
wp db create

${cmdProxy} apt-get -y -qq install apg
#URL_SITE='localhost:8200'
#TITLE_SITE="Test site wordpress"
#ADMIN_USER='test'
#ADMIN_EMAIL='test@test.com'
echo -e '\033[32mSaisir les infos du site :\033[0m'
read -p "Url du site : " URL_SITE
read -p "Titre du site : " TITLE_SITE
echo -e "\033[32mSaisir les infos de l'administrateur :\033[0m"
read -p "Username Admin : " ADMIN_USER
read -p "Email Admin : " ADMIN_EMAIL
ADMIN_PASSWORD="$(apg -q -a 0 -n 1)"

echo -e '\033[32mInstallation du wordpress...\033[0m'
wp core install --url=${URL_SITE} --title="${TITLE_SITE}" --admin_user=${ADMIN_USER} --admin_password=${ADMIN_PASSWORD} --admin_email=${ADMIN_EMAIL} --skip-email

echo ""
echo -e "\033[36mInstallation du site Wordpress '\033[36;7m${TITLE_SITE} (${URL_SITE})\033[0m\033[36m' terminé\033[0m"
echo -e "\033[36mUser (Email): '\033[36;7m${ADMIN_USER} (${ADMIN_EMAIL})\033[0m\033[36m'\033[0m"
echo -e "\033[36mMot de passe : '\033[36;7m${ADMIN_PASSWORD}\033[0m\033[36m'\033[0m"




