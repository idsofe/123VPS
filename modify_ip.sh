#!/bin/bash

function listdomain
{
	#Liet ke danh sach cac domain
	i=1
	echo -e "\n\nList of domains : "
	for d in `cat /opt/123VPS/domainlist | awk '{print $2}'`
	do
		echo $i $d
		i=$[i+1]
	done
}



function enter
{
	#Nhap stt cua domain muon doi IP
	sumline=`cat /opt/123VPS/domainlist | wc -l`
	echo -e "\nSelect domain you want to change IP, only enter number : "
	read domainnum
	
	if [[ ! $domainnum =~ ^[0-9]+$  ]]
	then
		echo "Wrong ! Please re-enter !"
		enter
	elif [[ $domainnum -gt $sumline ]] || [[ $domainnum == 0 ]]
	then
		echo "Wrong ! Please re-enter !"
                enter			
	fi

	vardomain=`sed -n "$domainnum"p /opt/123VPS/domainlist | awk '{print $2}'`

	#domainIP
}


function listIP
{
	#Hien thi IP ma domain nay dang dung
	oldIP=`sed -n "$domainnum"p /opt/123VPS/domainlist | awk '{print $3}'`
	echo -e "\n\n$vardomain is using IP $oldIP"
	

	#Tao danh sach cac IP trong VPS/Server
	IPlist=()

	ips=($(hostname -I))

	for ip in "${ips[@]}"
	do
		IPlist+=($ip)
	done

	echo -e "\n\nList of IPs :"
	no=1
	for i in ${IPlist[@]}
	do
		echo $no $i
		no=$[no+1]
	done
}



function select_new_IP
{
	#Nhap stt cua IP moi, kiem tra xem so vua nhap co > 1 va < tong so IP co trong VPS/Server khong
	ip_list_len=${#IPlist[@]}
	echo -e "\n\n\nSelect new IP you want to use \n!!!Only enter number!!!"	

	
	function check_IP_num
	{
		read num
		if [[ $num =~ ^[0-9]+$  ]] && [[ $num -ge 1 ]] && [[ $num -le $ip_list_len ]]
		then
			newIP=${IPlist[num-1]}
			changeIP

		else
			echo -e "\n\n\nWrong number ! Please type again !"
			check_IP_num
		fi
	}
	check_IP_num

	
}



function changeIP
{
	chattr -i /opt/123VPS/domainlist
	sed -i "$domainnum s/$oldIP/$newIP/g" /opt/123VPS/domainlist
	chattr +i /opt/123VPS/domainlist

	sed -i "s/$oldIP/$newIP/g" /etc/nginx/conf.d/$vardomain.conf
	sed -i "s/$oldIP/$newIP/g" /etc/httpd/conf.d/$vardomain.conf	

}



function main
{
	listdomain
	enter
	listIP
	select_new_IP
}


main