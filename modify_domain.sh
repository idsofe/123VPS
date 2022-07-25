#!/bin/bash

function listdomain
{
	i=1
	#Liet ke danh sach cac domain
	echo -e "\n\nSelect domain you want to change : "
	for d in `cat /opt/123VPS/domainlist | awk '{print $2}'`
	do
		echo $i $d
		i=$[$i+1]
	done
}

function enter_old
{
	sumline=`cat /opt/123VPS/domainlist | wc -l`
	echo -e "\nSelect domain you want to change, only enter number : "
	read oldnum
	
	if [[ ! $oldnum =~ ^[0-9]+$  ]]
	then
		echo "Wrong ! Please re-enter !"
		enter_old
	elif [[ $oldnum -gt $sumline ]] || [[ $oldnum == 0 ]]
	then
		echo "Wrong ! Please re-enter !"
                enter_old			
	fi

	
}

function enter_new
{
	echo "Enter new domain : "
	read new

	#Neu ton tai ky ty dac biet thi sai (tru ky tu . va - )
	if [[ $new =~ ^[0-9a-zA-Z.-]+$  ]]
	then
		point_sum=0
		for (( i=0; i<$[${#new}-1]; i++ ))
		do

			#Dem xem co bao nhieu ky tu . trong domain
	                if [ ${new:$i:1} == "." ]
        	        then
                	        point_sum=$[$point_sum + 1]
	                fi		

			#Neu 2 ky tu lien tiep la . thi sai
			if [[ ${new:$i:1} == "." ]]  && [[ ${new:$[$i+1]:1} == "." ]]
			then
				echo "Wrong domain type : too much .. "
				enter_new
				break

			#Neu 2 ky tu lien tiep la - thi sai
			elif [[ ${new:$i:1} == "-" ]]  && [[ ${new:$[$i+1]:1} == "-" ]]
			then
				echo "Wrong domain type : too much -- "
				enter_new
				break

			#Neu 2 ky tu lien tiep la .- thi sai
			elif [[ ${new:$i:1} == "." ]]  && [[ ${new:$[$i+1]:1} == "-" ]]
			then
				echo "Wrong domain type : domain cannot contain .- "
				enter_new
				break

			#Neu 2 ky tu lien tiep la -. thi sai
			elif [[ ${new:$i:1} == "-" ]]  && [[ ${new:$[$i+1]:1} == "." ]]
			then
				echo "Wrong domain type : domain cannot contain -. "
				enter_new
				break

		
			#Neu ky tu dau va cuoi la . hoac - thi sai
			elif [[ ${new::1} == "." ]] || [[ ${new: -1} == "." ]] || [[ ${new::1} == "-" ]] || [[ ${new: -1} == "-" ]]
			then
				echo "The first/last character cannot be . or - "
				enter_new
				break
			fi
		done
		
		#Neu domain khong co dau . nao thi bao loi
		if [ $point_sum \= 0 ]
  	     	then
 	                echo "Wrong domain type : domain must contain at least 1 . character "
			enter_new
   	     	fi

	else
		echo "Wrong domain type : domain contains special characters or empty !"
		enter_new
	fi

	#Kiem tra xem domain nay co ton tai trong he thong chua, neu co roi thi nhap lai
	for i in `cat /opt/123VPS/domainlist | awk '{print $2}'`
	do
        	if [ $i == $new ] || [ $i == www.$new ] || [ www.$i == $new ]
	        then
        	        echo "Domain existed !"
			enter_new
	                break
			
        	fi
	done

}



function change_dir
{
	old=`sed -n "$oldnum"p /opt/123VPS/domainlist | awk '{print $2}' `
	owner=`grep $old domainlist | awk '{print $1}'`
	chattr -i /opt/123VPS/domainlist
	sed -i "s/$old/$new/g" /opt/123VPS/domainlist
	chattr +i /opt/123VPS/domainlist

	cd /home/$owner/domains
	mv $old $new

}


function edit_vhost
{
	cd /etc/nginx/conf.d
	sed -i "s/$old/$new/g" $old.conf
	mv $old.conf $new.conf
	
	cd /etc/httpd/conf.d
	sed -i "s/$old/$new/g" $old.conf
	mv $old.conf $new.conf
	
}



function main
{
	listdomain
	enter_old
	enter_new
	change_dir
	edit_vhost
}


main
