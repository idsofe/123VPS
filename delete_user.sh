#!/bin/bash

function list
{
	i=0
	#Liet ke danh sach cac domain
	echo -e "\n\nSelect user you want to delete : "
	while read line
	do
		i=$[$i+1]
		echo $i $line
	done < /opt/123VPS/domainlist
}


function enter
{
	sumline=`cat /opt/123VPS/domainlist | wc -l`
	echo -e "\nSelect user you want to delete, only enter number : "
	read usernum
	
	if [[ ! $usernum =~ ^[0-9]+$  ]]
	then
		echo "Wrong ! Please re-enter !"
		enter
	elif [ $usernum -gt $sumline ] || [ $usernum == 0 ]
	then
		echo "Wrong ! Please re-enter !"
                enter			
	fi

}


function selectYN
{
	echo "Select (Yes/No or Yy/Nn) : "
	read answer
	answer=`echo "$answer" | awk '{print tolower($0)}'`
	if [ $answer == "yes" ] || [ $answer == "y" ]
	then
		del_homedir
		del_vhost
		del_ftp

		rm -f /var/spool/mail/$varuser
		chattr -i /opt/123VPS/domainlist
		sed -i "$usernum"d /opt/123VPS/domainlist
		chattr +i /opt/123VPS/domainlist
		echo -e "\n\nUser $varuser has been deleted !"
	elif [ $answer == "no" ] || [ $answer == "n" ]
	then
		true
	else
		selectYN
	fi
}


function del_homedir
{
	echo -e "\n\n\nDelete user's home directory ?"
	echo "Select (Yes/No or Yy/Nn) : "
	read ans
	ans=`echo "$ans" | awk '{print tolower($0)}'`
	function confirm
	{
		if [ $ans == "yes" ] || [ $ans == "y" ]
		then
			userdel -r $varuser
		elif [ $ans == "no" ] || [ $ans == "n" ]
		then
			userdel $varuser
			chown -R nouse. /home/$varuser
		else
			confirm
		fi
	}
	confirm

}


function del_vhost
{
	deldomain=`sed -n "$usernum"p /opt/123VPS/domainlist | awk '{print $2}'`
	
	rm -f /etc/nginx/conf.d/$deldomain.conf
	rm -f /etc/httpd/conf.d/$deldomain.conf
}


function del_ftp
{

	pure-pw list | awk '{print $1}' > /tmp/ftp_user.list
	if [ `grep $varuser /tmp/ftp_user.list` ]
	then
		pure-pw userdel $varuser -m
	fi
	rm -f /tmp/ftp_user.list

}


function delete
{
	echo -e "\n\n\n!!!Make sure you still want to delete this user ?"
	varuser=`sed -n "$usernum"p /opt/123VPS/domainlist | awk '{print $1}'`
	vardomain=`sed -n "$usernum"p /opt/123VPS/domainlist | awk '{print $2}'`

	selectYN

}







function main
{
	list
	enter
	delete
}


main
