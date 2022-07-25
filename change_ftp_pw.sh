echo "List of ftp users : "

function list_ftp_user
{
	pure-pw list > /tmp/ftp_user.list
	cat -b /tmp/ftp_user.list
}


function select_user
{
	echo -e "\nSelect user you want to change password !\nOnly enter numbers : "
	read usernum
	sumline=`cat /tmp/ftp_user.list | wc -l`
	
	if [[ ! $usernum =~ ^[0-9]+$  ]]
	then
		echo "Wrong ! Please re-enter !"
		select_user
	elif [[ $usernum -gt $sumline ]] || [[ $usernum == 0 ]]
	then
		echo "Wrong ! Please re-enter !"
                select_user
	fi

	
}



function change_pw
{
	varuser=`sed -n "$usernum"p /tmp/ftp_user.list | awk '{print $1}'`
	echo -e "\n\nEnter new password for user $varuser (at least 6 charaters) : "
	read newpw
	
 	if [ ${#newpw} -lt 6 ] || [ -z $newpw ]
	then
		echo -e "\nPassword must have at least 6 characters !!!"
		change_pw
	else
		(echo $newpw; echo $newpw) | pure-pw passwd $varuser -m > /dev/null 2>&1

	fi

}



function print_result
{
	
	echo -e "\nUser : $varuser"
	echo -e "Password : $newpw"
	rm -f /tmp/ftp_user.list

}



function main
{
	list_ftp_user
	select_user
	change_pw
	print_result
}



main