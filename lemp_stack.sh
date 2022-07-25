yum -y install epel-release

yum -y install ntpdate

ntpdate vn.pool.ntp.org

yum -y update

yum -y install yum-utils


#Tat firewall & selinux
systemctl stop firewalld

systemctl disable firewalld

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

yum -y install policycoreutils-python

setenforce 0

#semanage port -a -t http_port_t -p tcp 9056
#semanage port -a -t http_port_t -p tcp 9072


#Cai httpd
yum -y install httpd httpd-devel mod_ruid2 mod_fcgid mod_ssl

sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf

sed -i 's/index.html/index.php index.html/g'  /etc/httpd/conf/httpd.conf

echo "IncludeOptional /usr/local/123VPS/data/*/httpd.conf" >> /etc/httpd/conf/httpd.conf

mkdir -p /var/log/httpd/domains

chown -R apache:root /var/log/httpd

systemctl enable httpd

systemctl start httpd


#Cai nginx reverse proxy
yum -y install nginx 

mkdir -p /var/log/nginx/domains

chown -R nginx:root /var/log/nginx

mv /etc/nginx/nginc.conf /etc/nginx.conf.bak
{ head -n $[f-1] /etc/nginx/nginx.conf; echo "include /usr/local/123VPS/data/*/nginx.conf"; tail -n +$[f+1] /etc/nginx/nginx.conf; } > out
echo out > /etc/nginx/nginx.conf
rm -f out

systemctl enable nginx

systemctl start nginx



#Cai PHP + FPM
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm

mkdir -p /etc/php-fpm.d/

yum -y install php56 php56-php-bcmath php56-php-common php56-php-fpm php56-php-imap php56-php-json php56-php-mysql php56-php-pecl-memcache php56-php-pecl-memcached php56-php-gd php56-php-mbstring php56-php-mcrypt php56-php-xml php56-php-pecl-apc php56-php-cli php56-php-pear php56-php-pdo php56-php-zip

mv /etc/opt/remi/php56/php-fpm.d/www.conf /etc/opt/remi/php56/php-fpm.d/www.conf.bak

sed -i 's/error_log = \/opt\/remi\/php56\/root\/var\/log\/php-fpm\/error.log/error_log = \/var\/log\/php56-fpm.log/g' /etc/opt/remi/php56/php-fpm.conf

echo "include=/etc/php-fpm.d/*.conf" >> /etc/opt/remi/php56/php-fpm.conf
echo "include=/usr/local/123VPS/data/*/php-fpm.conf" >> /etc/opt/remi/php56/php-fpm.conf

mv /usr/lib/systemd/system/php56-php-fpm.service /usr/lib/systemd/system/php56-fpm.service 



yum -y install php72 php72-php-bcmath php72-php-common php72-php-fpm php72-php-imap php72-php-json php72-php-mysql php72-php-pecl-memcache php72-php--pecl-memcached php72-php-gd php72-php-mbstring php72-php-mcrypt php72-php-xml php72-php-pecl-apc php72-php-cli php72-php-pear php72-php-pdo php56-php-zip

mv /etc/opt/remi/php72/php-fpm.d/www.conf /etc/opt/remi/php72/php-fpm.d/www.conf.bak


sed -i 's/error_log = \/var\/opt\/remi\/php72\/log\/php-fpm\/error.log/error_log = \/var\/log\/php72-fpm.log/g' /etc/opt/remi/php72/php-fpm.conf

echo "include=/etc/php-fpm.d/*.conf" >> /etc/opt/remi/php72/php-fpm.conf
echo "include=/usr/local/123VPS/data/*/php-fpm.conf" >> /etc/opt/remi/php72/php-fpm.conf

mv /usr/lib/systemd/system/php72-php-fpm.service /usr/lib/systemd/system/php72-fpm.service




#Cai mysql 5.7
yum -y localinstall https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm

rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

yum -y install mysql-community-server

systemctl start mysqld

systemctl enable mysqld

pw=`grep "temporary password" /var/log/mysqld.log | awk '{print $NF}'`
newpw=`tr -dc 'A-Za-z0-9!@#$%^&*()-={}' </dev/urandom | head -c 13`
mysql --password="$pw" --execute="alter user 'root'@'localhost' identified by '$newpw';" --connect-expired-password

touch /root/.my.cnf

echo "[client]
user=root
password=$newpw" > /root/.my.cnf
unset pw
unset newpw



#Cai phpMyAdmin latest (ver 5 yeu cau PHP >=7.2)
useradd -M phpmyadmin -s /sbin/nologin
wget -P /opt https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
tar -xzf /opt/phpMyAdmin-latest-all-languages.tar.gz -C /opt
cp -R /opt/phpMyAdmin-*-all-languages /var/www/html/
chown -R phpmyadmin. /var/www/html/phpMyAdmin
cp /opt/123VPS/sample-files/httpd_phpmyadmin.conf /etc/httpd/conf.d/
cp /opt/123VPS/sample-files/nginx_phpmyadmin.conf /etc/nginx/conf.d/
cp /opt/123VPS/samples-files/fpm_phpmyadmin.conf /etc/php-fpm.d/
mv /var/www/html/phpMyAdmin/config.sample.inc.php /var/www/html/phpMyAdmin/config.inc.php
line_num=`grep -n "blowfish_secret" /var/www/html/phpMyAdmin/config.inc.php | cut -d : -f 1`
key=`strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 32 | tr -d '\n'`
{ head -n $[line_num-1] /var/www/html/phpMyAdmin/config.inc.php; echo "$cfg['blowfish_secret'] = '$key';"; tail -n +$[line_num+1] /var/www/html/phpMyAdmin/config.inc.php; } > out
cat out > /var/www/html/phpMyAdmin/config.inc.php
unset key
rm -f out



#Cai ftp
yum -y install pure-ftpd


#Cai certbot
yum -y install cerbot cerbot-nginx




