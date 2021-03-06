#!/bin/bash

green_color='\e[0;32m'
red_color='\e[0;31m'
yellow_color='\e[0;33m'
rest_color='\e[0m'

blow_secret_token=$1
version=$2

if [[ $version != "4.9.7" && $version != '5.1.0' ]]; then
    echo -e "${red_color}The version is not supported!${rest_color}"
    exit 1;
fi;

if [[ $blow_secret_token == "" ]]; then
    echo -e "${red_color}Blow secret token should be specified.${rest_color}"
    exit 1;
fi;


echo -e "${yellow_color}Notice: This Bash script is only available on Ubuntu 16.04 and 18.04!${rest_color}"
echo -e "${green_color}Check the PHPMyAdmin package is installed...${rest_color}"

sudo_prefix=''
if [[ $USER != 'root' ]]; then
    sudo_prefix='sudo '
fi;

check_phpmyadmin=$(${sudo_prefix}dpkg -l | grep phpmyadmin)

if [[ $check_phpmyadmin == "" ]]; then
    echo -e "${red_color}The PHPMyAdmin package is not installed.${rest_color}"
    exit 1;
fi;

${sudo_prefix}mv /usr/share/phpmyadmin/ /usr/share/phpmyadmin.bak
${sudo_prefix} mkdir /usr/share/phpmyadmin/

current_dir=$PWD
cd /usr/share/phpmyadmin/

${sudo_prefix}rm -f ./phpMyAdmin-5.1.0-all-languages.tar.gz
${sudo_prefix}rm -f ./phpMyAdmin-4.9.7-all-languages.tar.gz

echo -e "${green_color}Download PHPMyAdmin-$version archive file...${rest_color}"
echo ""
${sudo_prefix}wget https://files.phpmyadmin.net/phpMyAdmin/$version/phpMyAdmin-$version-all-languages.tar.gz

if [[ ! -f ./phpMyAdmin-$version-all-languages.tar.gz ]]; then
    echo -e "${red_color}The archive file is not downloaded successfully.${rest_color}"
    exit 1;
fi;

echo -e "${yellow_color}Archiving file...${rest_color}"
${sudo_prefix}tar xzf phpMyAdmin-$version-all-languages.tar.gz
${sudo_prefix}mv phpMyAdmin-$version-all-languages/* /usr/share/phpmyadmin

echo -e "${yellow_color}Copy vendor_config.php.example file...${rest_color}"
${sudo_prefix}cp $current_dir/vendor_config$version.php.example /usr/share/phpmyadmin/libraries/vendor_config.php

echo -e "${yellow_color}Copy blowfish_secret.inc.php.example file...${rest_color}"
${sudo_prefix}cp $current_dir/blowfish_secret.inc.php.example /var/lib/phpmyadmin/blowfish_secret.inc.php

${sudo_prefix}sed -i -e "s/token/${blow_secret_token}/g" /var/lib/phpmyadmin/blowfish_secret.inc.php

if [[ $version == '5.1.0' ]]; then
    ${sudo_prefix}cp $current_dir/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
    ${sudo_prefix}sed -i -e "s/token/$blow_secret_token/g" /usr/share/phpmyadmin/config.inc.php
fi;

${sudo_prefix}rm -f /usr/share/phpmyadmin/phpMyAdmin-$version-all-languages.tar.gz
${sudo_prefix}rm -rf /usr/share/phpmyadmin/phpMyAdmin-$version-all-languages
${sudo_prefix}rm -rf /usr/share/phpmyadmin.bak

echo ""

if [[ $? != 0 ]]; then
    echo -e "${red_color}Upgrading PHPMyAdmin package is failed.${rest_color}"
    exit 1;
fi;

echo -e "${green_color}Upgrade PHPMyAdmin package is successful!${rest_color}"
