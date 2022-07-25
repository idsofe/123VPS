ftppw=`strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 16 | tr -d '\n'`
	(echo $ftppw; echo $ftppw) | pure-pw useradd $varuser -u $varuser -g $varuser -d /home/$varuser -m > /dev/null 2>&1
