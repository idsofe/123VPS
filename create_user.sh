#!/bin/bash

function enterdomain
{
	echo "Enter domain : "
	read vardomain
}

function checkdomain
{
	#Neu ton tai ky ty dac biet thi sai (tru ky tu . va - )
	if [[ $vardomain =~ ^[0-9a-zA-Z.-]+$  ]]
	then
		point_sum=0
		for (( i=0; i<$[${#vardomain}-1]; i++ ))
		do

			#Dem xem co bao nhieu ky tu . trong domain
	        if [ ${vardomain:$i:1} == "." ]
        	then
                point_sum=$[$point_sum + 1]
	        fi		

			#Neu 2 ky tu lien tiep la . thi sai
			if [[ ${vardomain:$i:1} == "." ]]  && [[ ${vardomain:$[$i+1]:1} == "." ]]
			then
				echo "Wrong domain type: too many .. "
				domain
				break

			#Neu 2 ky tu lien tiep la - thi sai
			elif [[ ${vardomain:$i:1} == "-" ]]  && [[ ${vardomain:$[$i+1]:1} == "-" ]]
			then
				echo "Wrong domain type: too many -- "
				domain
				break

			#Neu 2 ky tu lien tiep la .- thi sai
			elif [[ ${vardomain:$i:1} == "." ]]  && [[ ${vardomain:$[$i+1]:1} == "-" ]]
			then
				echo "Wrong domain type: domain cannot contain .- "
				domain
				break

			#Neu 2 ky tu lien tiep la -. thi sai
			elif [[ ${vardomain:$i:1} == "-" ]]  && [[ ${vardomain:$[$i+1]:1} == "." ]]
			then
				echo "Wrong domain type: domain cannot contain -. "
				domain
				break

		
			#Neu ky tu dau va cuoi la . hoac - thi sai
			elif [[ ${vardomain::1} == "." ]] || [[ ${vardomain: -1} == "." ]] || [[ ${vardomain::1} == "-" ]] || [[ ${vardomain: -1} == "-" ]]
			then
				echo "The first/last character cannot be . or - "
				domain
				break
			fi
		done
		
		#Neu domain khong co dau . nao thi bao loi
		if [ $point_sum \= 0 ]
  	     	then
 	                echo "Wrong domain type: domain must contain at least 1 . character "
			domain
   	     	fi

	else
		echo "Wrong domain type: domain contains special characters or empty!"
		domain
	fi

	#Kiem tra xem domain nay co ton tai trong he thong chua, neu co roi thi nhap lai
	#for i in `cat /opt/123VPS/domainlist | awk '{print $2}'`
	#do
    #    	if [ $i == $vardomain ] || [ $i == www.$vardomain ] || [ www.$i == $vardomain ]
	#        then
    #    	        echo "Domain existed!"
	#		domain
	#                break
			
    #    	fi
	#done
	if grep $vardomain /etc/domains
	then
		echo "Domain existed!"
		domain
		break
	fi


	#Kiem tra xem trong /home truoc do da co ton tai domain nay chua
	#for i in `find /home/*/domains/ -type d -name $vardomain`
	#do 
	#	if [ $i == $vardomain ] || [ $i == www.$vardomain ] || [ www.$i == $vardomain ]
	#        then
    #    	        echo "Domain existed !"
	#		domain
	#                break
	#		
    #    	fi
	#done


}


function domain
{
	enterdomain
	checkdomain
}



function enteruser
{
        echo "Enter username : "
        read varuser
}

function checkuser
{
        #Neu username co ky tu dac biet hoac null thi bao loi
        if [[ ! $varuser =~ ^[0-9a-zA-Z]+$  ]]
        then
                echo "Wrong input: username contains special characters or empty!"
                user
        else
		#Neu nhap >10 ky tu thi cat ngan con 10 ky tu
                if [ ${#varuser} -gt 10 ]
                then
                        echo "Your input username is too long!"
                        varuser=${varuser::10}
                        echo "Your username is: " $varuser
                fi
        fi

	#Kiem tra xem user nay co ton tai hay chua, neu co roi thi nhap lai
        if grep -w $varuser /etc/shadow
        then
                echo "This username existed!"
                user
        fi

}


function user
{
        enteruser
        checkuser
}



function selectIP
{
	#Tao danh sach cac IP trong VPS/Server
	IPlist=()

	ips=($(hostname -I))

	for ip in "${ips[@]}"
	do
		IPlist+=($ip)
	done

	#Liet ke danh sach cac IP trong VPS/Server roi chon 1 IP de cau hinh cac file vhost 
	echo -e "\n\nList of IPs:"
	no=1
	for i in ${IPlist[@]}
	do
		echo $no $i
		no=$[no+1]
	done
	
	
	#Nhap stt cua IP, kiem tra xem so vua nhap co > 1 va < tong so IP co trong VPS/Server khong
	ip_list_len=${#IPlist[@]}
	echo -e "\n\n\nSelect IP you want to use for this domain\n!!!Only enter number!!!"	

	
	function check_IP_num
	{
		read num
		if [[ $num =~ ^[0-9]+$  ]] && [[ $num -ge 1 ]] && [[ $num -le $ip_list_len ]]
		then
			ip=${IPlist[num-1]}
			#create_vhost
		else
			echo -e "\n\n\nWrong number! Please type again!"
			check_IP_num
		fi
	}
	check_IP_num
	
	

}



function selectPHP
{
	#Tao danh sach PHP ver
	phplist=()
	phpvers=($(ls /etc/opt/remi))
	
	for i in "${phpvers[@]}"
	do
		phplist+=($i)
	done

	#Nhap stt cua PHP, kiem tra xem so vua nhap co > 1 va < tong so PHP co trong VPS/Server khong (mac dinh cai san 2 PHP nen so luong PHP chac chan >2)
	echo -e "\n\nList of PHP versions:"
	no=1
	for i in ${phplist[@]}
	do
		echo $no $i
		no=$[no+1]
	done


	#Nhap stt cua PHP, kiem tra xem so vua nhap co > 1 va < tong so PHP co trong VPS/Server khong
	php_list_len=${#phplist[@]}
	echo -e "\n\n\nSelect PHP version you want to use for this domain\n!!!Only enter number!!!"	
	function check_PHP_num
	{
		read num
		if [[ $num =~ ^[0-9]+$  ]] && [[ $num -ge 1 ]] && [[ $num -le $php_list_len ]]
		then
			phpver=${phplist[num-1]}
			#create_vhost
		else
			echo -e "\n\n\nWrong number! Please type again!"
			check_PHP_num
		fi
	}
	check_PHP_num

}


function create_home_dir
{
	#Tao user khong co quyen SSH va thu muc chua code web
	useradd -M $varuser -s /sbin/nologin

	#Tao FTP user, auto generate password
	ftppw=`strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 16 | tr -d '\n'`
	(echo $ftppw; echo $ftppw) | pure-pw useradd $varuser -u $varuser -g $varuser -d /home/$varuser -m > /dev/null 2>&1


	mkdir -p /home/$varuser/domains/$vardomain/public_html
	mkdir -p /home/$varuser/.php
	mkdir -p /home/$varuser/tmp
	chown -R $varuser. /home/$varuser

	#Tao thu muc chua cac file config
	mkdir -p /usr/local/123VPS/data/$varuser/domains
	


	
}


function create_vhost
{
	cp /opt/123VPS/sample-files/sample-nginx-vhost.conf /usr/local/123VPS/data/$varuser/nginx.conf
	sed -i "s/place_domain/$vardomain/g" /usr/local/123VPS/data/$varuser/nginx.conf
	sed -i "s/place_user/$varuser/g" /usr/local/123VPS/data/$varuser/nginx.conf
	sed -i "s/place_IP/$ip/g" /usr/local/123VPS/data/$varuser/nginx.conf
	

	cp /opt/123VPS/sample-files/sample-httpd-vhost.conf /usr/local/123VPS/data/$varuser/httpd.conf
	sed -i "s/place_domain/$vardomain/g" /usr/local/123VPS/data/$varuser/httpd.conf
	sed -i "s/place_user/$varuser/g" /usr/local/123VPS/data/$varuser/httpd.conf
	sed -i "s/place_IP/$ip/g" /usr/local/123VPS/data/$varuser/httpd.conf
	sed -i "s/place_php/$phpver/g" /usr/local/123VPS/data/$varuser/httpd.conf


	cp /opt/123VPS/sample-files/sample-php-fpm.conf /usr/local/123VPS/data/$varuser/php-fpm.conf
	sed -i "s/place_user/$varuser/g" /usr/local/123VPS/data/$varuser/php-fpm.conf
	sed -i "s/place_php/$phpver/g" /usr/local/123VPS/data/$varuser/php-fpm.conf

	echo "$varuser:$vardomain" > /usr/local/123VPS/data/$varuser/user_domains
	echo $ip > /usr/local/123VPS/data/$varuser/domains/$vardomain.ips
	echo $phpver > /usr/local/123VPS/data/$varuser/domains/$vardomain.phpver
	
}







function print_result
{
	#In ra username, domain, PHP ver vua duoc tao, cap nhat thong tin vao cac file quan ly
	echo -e "\n"
	echo "Domain : $vardomain"
	echo "Username : $varuser"
	echo "FTP password : $ftppw"
	

	chattr -i /etc/domains
	echo $vardomain >> /etc/domains
	chattr +i /etc/domains
}



function main
{
	domain
	user
	selectIP
	selectPHP
	create_home_dir
	create_vhost
	print_result
}


main
