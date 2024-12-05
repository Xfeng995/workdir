#!/bin/bash

function fun_1 {
	count=0
	while read line
	do
		[ "${line:0:1}" == "#" ] && continue
		ParamName=`echo $line | awk -F" " '{print $1}'`
		ParamValue=`echo $line | awk -F" " '{print $2}'`
		[ -z "${ParamName}" ] && [ -z "${ParamValue}" ] && continue
		if [ "$ParamName" == "PASS_MAX_DAYS" ] && [[ $ParamValue -le 90 ]] && [[ $ParamValue -gt 0  ]]
		then
		        maxdays=$ParamValue
			let count=count+1
		fi
		if [ "$ParamName" == "PASS_MIN_DAYS" -a "$ParamValue" != "" ]
		then
		        mindays=$ParamValue
			let count=count+1
		fi
		if [ "$ParamName" == "PASS_WARN_AGE" -a "$ParamValue" != "" ]
		then
			let count=count+1
		fi		
	done < "/etc/login.defs"
	uptime >> /usr/share/smp/20230518_localfile.txt 
	if [ $count -eq 3 ]  && [[ $mindays -le $maxdays ]]
	then
	    echo yes
	else
	    echo no
	fi
	
}

code[1]="passmax=\`cat /etc/login.defs | grep '/^[[:space:]]*PASS_MAX_DAYS[[:space:]]*[0-9][0-9]*[[:space:]]*$' | awk '{print \$2}'\`
        echo system_max_days=\$passmax

        oldIFS=\$IFS
        IFS=$'\\\n'
        for line in \$(cat /etc/shadow)
        do
                tmp=\$line
                if [ \`echo \$tmp | cut -d : -f2 | grep -v ^[\*\|!]\` ]
                then
                        username=\`echo \$tmp | cut -d : -f1\`
                        user_max_day=\`echo \$tmp | cut -d : -f5\`
                        echo \"\$username\"=\"\$user_max_day\"
                fi
        done
        IFS=\$oldIFS

        unset line
        unset tmp
        unset username
        unset user_max_day
        unset passmax"

function fun_3 {
	if [ -f "/etc/pam.d/common-password" ]
	then
		unset count
		count=0
		n1=`cat /etc/pam.d/common-password | grep -v "^[[:space:]]#*" | grep -i "^[[:space:]]*password\s*[a-z]*\s*pam_cracklib.so\s*.*dcredit=-[1-3]*"`
		n2=`cat /etc/pam.d/common-password | grep -v "^[[:space:]]#*" | grep -i "^[[:space:]]*password\s*[a-z]*\s*pam_cracklib.so\s*.*lcredit=-[1-3]*"`
		n3=`cat /etc/pam.d/common-password | grep -v "^[[:space:]]#*" | grep -i "^[[:space:]]*password\s*[a-z]*\s*pam_cracklib.so\s*.*ocredit=-[1-3]*"`
		n4=`cat /etc/pam.d/common-password | grep -v "^[[:space:]]#*" | grep -i "^[[:space:]]*password\s*[a-z]*\s*pam_cracklib.so\s*.*ucredit=-[1-3]*"`
		minlen=`cat /etc/pam.d/common-password | grep -v "^[[:space:]]#*" | perl -n -e '/^[[:space:]]*password\s*[a-z]*\s*pam_cracklib.so\s*.*minlen=(\d+)+/ && print $1'`
		if [ -n "$n1" ]
		then
			let count=count+1
		fi
		if [ -n "$n2" ]
		then
			let count=count+1
		fi
		if [ -n "$n3" ]
		then
			let count=count+1
		fi
		if [ -n "$n4" ]
		then
			let count=count+1
		fi
		if [ $count -ge 3 ] && [ -n "$minlen" ] && [ $minlen -ge 8 ]
		then 
			echo yes
		else
		        echo no
		fi
	else
		echo no
	fi
}

code[3]="remember=NULL
retry=NULL
difork=NULL
minlen=NULL
ucredit=NULL
lcredit=NULL
dcredit=NULL
ocredit=NULL

if [ \$os_name = \"rhel\" ] || [ \$os_name = \"centos\" ] || [ \$os_name = \"fedora\" ]
then
	echo \$os_name
	remember_item=\`cat /etc/pam.d/system-auth \| gawk '/^[[:space:]]*password[[:space:]]*sufficient[[:space:]]*pam_unix\.so[[:space:]]*.*[[:space:]]*remember=(0|[1-9][0-9]*)[[:space:]]*.*$/{print $0}'\`
	for item in \$(echo \$remember_item)
	do
		if [ -n \"\`echo \$item \| grep remember\`\" ]
		then
			remember=\`echo \$item | cut -f2 -d '='\`
		fi
	done

	pam_cracklib=\`cat /etc/pam.d/system-auth | gawk '/^[[:space:]]*password[[:space:]]*requisite[[:space:]]*pam_cracklib\.so[[:space:]]*/{print \$0}'\`
	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*retry=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
	then
		for item in \$(echo \$pam_cracklib)
        	do
                	if [ -n \"\`echo \$item | grep \"retry=\"\`\" ]
                	then
                        	retry=\`echo \$item | cut -f2 -d '='\`
                	fi
        	done
	fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*difork=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"difork=\"\`\" ]
                        then
                                difork=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*minlen=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"minlen=\"\`\" ]
                        then
                                minlen=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*ucredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"ucredit=\"\`\" ]
                        then
                                ucredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*lcredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"lcredit=\"\`\" ]
                        then
                                lcredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*dcredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"dcredit=\"\`\" ]
                        then
                                dcredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*ocredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"ocredit=\"\`\" ]
                        then
                                ocredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

elif [ \$os_name = \"debian\" ]||[ \$os_name = \"ubuntu\" ]||[ \$os_name = \"linux_mint\" ]	
then
	remember_item=\`cat /etc/pam.d/common-password | gawk '/^[[:space:]]*password[[:space:]]*sufficient[[:space:]]*pam_unix\.so[[:space:]]*.*[[:space:]]*remember=(0|[1-9][0-9]*)[[:space:]]*.*$/{\print \$0}'\`
        for item in \$(echo \$remember_item)
        do
                if [ -n \"\`echo \$item | grep remember\`\" ]
                then
                        remember=\`echo \$item | cut -f2 -d '='\`
                fi
        done

        pam_cracklib=\`cat /etc/pam.d/common-password | gawk '/^[[:space:]]*password[[:space:]]*requisite[[:space:]]*pam_cracklib\.so[[:space:]]*/{print $0}'\`
        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*retry=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"retry=\"\`\" ]
                        then
                                retry=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi
	
	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*difork=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"difork=\"\`\" ]
                        then
                                difork=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*minlen=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"minlen=\"\`\" ]
                        then
                                minlen=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*ucredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"ucredit=\"\`\" ]
			then
				ucredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*lcredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"lcredit=\"\`\" ]
                        then
                                lcredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*dcredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"dcredit=\"\`\" ]
                        then
                                dcredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi
	
	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*ocredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"ocredit=\"\`\" ]
                        then
                                ocredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi
fi

echo remember=\$remember
echo retry=\$retry
echo difork=\$difork
echo minlen=\$minlen
echo ucredit=\$ucredit
echo lcredit=\$lcredit
echo dcredit=\$dcredit
echo ocredit=\$ocredit

unset remember
unset retry
unset difork
unset minlen
unset ucredit
unset lcredit
unset dcredit
unset ocredit"



function fun_2 {
		oldIFS=$IFS
		IFS=$'\n'
		b=0
		for line in $(cat /etc/shadow)
		do
			tmp=`echo $line | cut -d : -f2`
			if [[ -z "$tmp" ]]
			then
			    continue
			fi

			if [[ $tmp = "*" ]]
			then
			    continue
			fi

			B="$6"
			if [[ $tmp == *$B* ]] 
			then
			    b=1
			fi

		done

		if [ $b -eq 1 ] 
		then
		    echo yes
		else
		    echo no
		fi
		IFS=\$oldIFS

}

code[2]="timeout=NULL

        for line in \`cat /etc/profile\`
        do
                if [ -n \"\`echo \$line | gawk '/^[[:space:]]*(export)?[[:space:]]*TMOUT=[0-9]*[[:space:]]*$/{print \$0}'\`\" ]
                then
                        timeout=\`echo \$line | cut -f2 -d \'=\'\`
                fi
        done
        echo timeout=\$timeout"

function fun_4 {
          oldIFS=$IFS
        IFS=$'\n'
	bMatch=0
        for line in $(cat /etc/pam.d/common-password)
        do
                fnd1=`echo $line | sed -n '/^\s*auth\s\+required\s\+\(pam_tally2.so\|pam_tally.so\)\(\s\+[^#]\+\s\+\|\s\+\)deny=[0-9]\+/p' `
		fnd2=`echo $line | sed -n '/^\s*auth\s\+required\s\+\(pam_tally2.so\|pam_tally.so\)\(\s\+[^#]\+\s\+\|\s\+\)unlock_time=[0-9]\+/p' `
		fnd3=`echo $line | sed -n '/^\s*auth\s\+required\s\+\(pam_tally2.so\|pam_tally.so\)\(\s\+[^#]\+\s\+\|\s\+\)no_magic_root\+/p' `
		fnd4=`echo $line | sed -n '/^\s*auth\s\+required\s\+\(pam_tally2.so\|pam_tally.so\)\(\s\+[^#]\+\s\+\|\s\+\)onerr=fail\+/p' `
		if  [ "$fnd1" == "$line" ] &&  [ "$fnd2" == "$line" ] &&  [ "$fnd3" == "$line" ] &&  [ "$fnd4" == "$line" ]
		then
                         for item in $(echo $line | awk '{for(i=1;i<=NF;i++){print $i;}}')
			 do
                              k=${item%=*}
			      v=${item#*=}
			      if [ "$k" == "deny" ]
			      then
			          deny=$v
			      fi

			      if [ "$k" == "unlock_time" ]
			      then
                                  unlock_time=$v
			      fi			      
			 done
                         if [ $deny -ge 3 ] && [ $deny -le 6 ] && [ $unlock_time -ge 180 ] && [ $unlock_time -le 900 ]
			 then
			     bMatch=1	
			 fi
                fi
        done
	if [ $bMatch -eq 1 ]
	then
	    echo yes
	else
	    echo no
	fi
	IFS=$oldIFS
}


code[4]="function fun_deny_unlock {
        oldIFS=\$IFS
        IFS=\$'\\\n'

#       echo open file \"/etc/pam.d/\$1\"
        for line in \$(cat /etc/pam.d/\$1)
        do
                if [ \`echo \$line | grep -v ^[[:space:]]*# | gawk '/^[[:space:]]*auth[[:space:]]*required[[:space:]]*(pam_tally.so|pam_tally2.so)[[:space:]]*deny=[0-9]*[[:space:]]*unlock_time=[0-9]*[[:space:]]*$/{print \$0}'\` ]
                then
                        pam_moudle=\`echo \$line \| awk '{print \$3}'\`
                        echo pam_moudle=\$pam_moudle

                        deny=\`echo \$line \| awk '{print \$4}'| cut -f2 -d '='\`
                        echo deny=\$deny

                        unlock_time=\`echo \$line | awk '{print \$5}'| cut -f2 -d '='\`
                        echo unlock_time=\$unlock_time

                        lib_exist=\` find \/ -name \$pam_moudle 2\> null\`
                        echo lib_exist is \$lib_exist

                        if test \"\$lib_exist\"
                        then
                                echo find the moudle \$pam_moudle
                                break
                        else
                                result=-2
                                echo can\'t find the moudle \$pam_moudle
                                break
                        fi

                elif [ \`echo \$line \| grep -v ^[[:space:]]*# | gawk '/^[[:space:]]*auth[[:space:]]*(include|substack)[[:space:]]*.*$/{print \$0}'\` ]
                then
                        name=\`echo \$line|awk '{print \$3}'\`
                        fun_deny_unlock \$name
                fi
        done
}"



function fun_5 {
     echo yes

}

code[5]="ssh_status=\`ps -ef | grep sshd | grep -v grep\`
	if [[ -z \"\$ssh_status\" ]]
	then
        	ssh_running=0
	else
        	ssh_running=1
	fi
	telnet_status=\`ps -ef | grep telnet | grep -v grep\`
	if [[ -z \"\$telnet_status\" ]]
	then
        	telnet_running=1
	else
        	telnet_running=0
	fi

	if [ \$ssh_running -eq 1 ] && [ \$telnet_running -eq 1 ]
	then
		echo yes
	else
		echo no
	fi
	unset ssh_running ssh_status "

function fun_6 {
	echo yes
}

code[6]="find / -maxdepth 3 -name .netrc 2>/dev/null
        find / -maxdepth 3 -name .rhosts 2>/dev/null
        find / -maxdepth 3 -name hosts.equiv 2>/dev/null
        echo \"totalNum_netrc=\"\`find / -maxdepth 3 -name .netrc 2>/dev/null|wc -l\`
        echo \"totalNum_rhosts=\"\`find / -maxdepth 3 -name .rhosts 2>/dev/null|wc -l\`
        echo \"totalNum_hosts.equiv=\"\`find / -maxdepth 3 -name hosts.equiv 2>/dev/null|wc -l\`"

function fun_7 {
	timeout=0

	oldIFS=$IFS
	IFS=$'\n'
	for line in `cat /etc/profile`
	do
        	#if [ -n "`echo $line | grep '/^[[:space:]]*(export)?[[:space:]]*TMOUT=[0-9]*[[:space:]]*'`" ]
        	#if [ -n "`echo $line | sed -n '/^\s*export\s\+TMOUT=\+[0-9]\+/p'`" ]
		if [ -n "`echo $line | sed -n '/^\s*TMOUT=\+[0-9]\+/p'`" ]
        	then
                	timeout=`echo $line | cut -f2 -d '='`
        	fi
	done
	if [ $timeout -le 600 ]
	then	
		echo yes
	else	
		echo no
	fi
	#echo timeout=$timeout
	IFS=$oldIFS
	
	unset timeout oldIFS line
}

code[7]="timeout=NULL

        for line in \`cat /etc/profile\`
        do
                if [ -n \"\`echo \$line | gawk '/^[[:space:]]*(export)?[[:space:]]*TMOUT=[0-9]*[[:space:]]*$/{print \$0}'\`\" ]
                then
                        timeout=\`echo \$line | cut -f2 -d \'=\'\`
                fi
        done
        echo timeout=\$timeout"



function fun_8 {
     echo yes
}

code[8]="if [ -f /etc/passwd ]
        then
                file_passwd=\`ls -l /etc/passwd | awk '{print \$1}'\`
        else
                file_passwd=NULL
        fi
        echo file_passwd=\$file_passwd
        unset file_passwd

        if [ -f /etc/shadow ]
        then
                file_shadow=\`ls -l /etc/shadow | awk '{print \$1}'\`
        else
                file_shadow=NULL
        fi
        echo file_shadow=\$file_shadow
        unset file_shadow

        if [ -f /etc/group ]
        then
                file_group=\`ls -l /etc/group | awk '{print \$1}'\`
        else
                file_group=NULL
        fi
        echo file_group=\$file_group
        unset file_group

        if [ -f /etc/securetty ]
	then
                file_securetty=\`ls -l /etc/securetty | awk '{print \$1}'\`
        else
                file_securetty=NULL
        fi
        echo file_securetty=\$file_securetty
        unset file_securetty

        if [ -f /etc/services ]
        then
                file_services=\`ls -l /etc/services | awk '{print \$1}'\`
        else
                file_services=NULL
        fi
        echo file_services=\$file_services
        unset file_services

        if [ -f /etc/xinetd.conf ]
        then
                file_xinetd_conf=\`ls -l /etc/xinetd.conf | awk '{print \$1}'\`
        else
                file_xinetd_conf=NULL
        fi
        echo file_xinetd_conf=\$file_xinetd_conf
        unset file_xinetd_conf

        if [ -f /etc/grub.conf ]
        then
                file_grub_conf=\`ls -l /etc/grub.conf | awk '{print \$1}'\`
	else
                file_grub_conf=NULL
        fi
        echo file_grub_conf=\$file_grub_conf
        unset file_grub_conf

        if [ -f /etc/lilo.conf ]
        then
                file_lilo_conf=\`ls -l /etc/lilo.conf 2>/dev/null | awk '{print \$1}'\`
        else
                file_lilo_conf=NULL
        fi
        echo file_lilo_conf=\$file_lilo_conf
        unset file_lilo_conf"

function fun_9 {
    dirPri=$(find $(echo $PATH | tr ':' ' ') -type d \( -perm -0777 \) 2> /dev/null)
    if [  -z "$dirPri" ] 
    then
      echo yes
    else
      echo no
    fi
	
}

code[9]="passmax=\`cat /etc/login.defs | grep '/^[[:space:]]*PASS_MAX_DAYS[[:space:]]*[0-9][0-9]*[[:space:]]*$' | awk '{print \$2}'\`
        echo system_max_days=\$passmax

        oldIFS=\$IFS
        IFS=$'\\\n'
        for line in \$(cat /etc/shadow)
        do
                tmp=\$line
                if [ \`echo \$tmp | cut -d : -f2 | grep -v ^[\*\|!]\` ]
                then
                        username=\`echo \$tmp | cut -d : -f1\`
                        user_max_day=\`echo \$tmp | cut -d : -f5\`
                        echo \"\$username\"=\"\$user_max_day\"
                fi
        done
        IFS=\$oldIFS

        unset line
        unset tmp
        unset username
        unset user_max_day
        unset passmax"

function fun_10 {
	num=`awk -F: '$2 == ""  { print $1 }' /etc/shadow | wc -l`
	
	if [ $num -eq 0 ]
	then
		echo yes
	else
		echo no
	fi
}

code[10]="awk -F: '$2 == \"\"  { print \$1 }' /etc/shadow"


function fun_11 {
    pam_rootok=`cat /etc/pam.d/su | grep auth | grep sufficient | grep pam_rootok.so | grep -v ^#`
    pam_wheel=`cat /etc/pam.d/su | grep auth | grep pam_wheel.so | grep group=wheel | grep -v ^#`

    if [ -n "$pam_rootok" ] && [ -n "$pam_wheel" ]; then
        echo yes
    else
        echo no
    fi
}

code[11]="remember=NULL
retry=NULL
difork=NULL
minlen=NULL
ucredit=NULL
lcredit=NULL
dcredit=NULL
ocredit=NULL

if [ \$os_name = \"rhel\" ] || [ \$os_name = \"centos\" ] || [ \$os_name = \"fedora\" ]
then
	echo \$os_name
	remember_item=\`cat /etc/pam.d/system-auth \| gawk '/^[[:space:]]*password[[:space:]]*sufficient[[:space:]]*pam_unix\.so[[:space:]]*.*[[:space:]]*remember=(0|[1-9][0-9]*)[[:space:]]*.*$/{print $0}'\`
	for item in \$(echo \$remember_item)
	do
		if [ -n \"\`echo \$item \| grep remember\`\" ]
		then
			remember=\`echo \$item | cut -f2 -d '='\`
		fi
	done

	pam_cracklib=\`cat /etc/pam.d/system-auth | gawk '/^[[:space:]]*password[[:space:]]*requisite[[:space:]]*pam_cracklib\.so[[:space:]]*/{print \$0}'\`
	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*retry=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
	then
		for item in \$(echo \$pam_cracklib)
        	do
                	if [ -n \"\`echo \$item | grep \"retry=\"\`\" ]
                	then
                        	retry=\`echo \$item | cut -f2 -d '='\`
                	fi
        	done
	fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*difork=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"difork=\"\`\" ]
                        then
                                difork=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*minlen=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"minlen=\"\`\" ]
                        then
                                minlen=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*ucredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"ucredit=\"\`\" ]
                        then
                                ucredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*lcredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"lcredit=\"\`\" ]
                        then
                                lcredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*dcredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"dcredit=\"\`\" ]
                        then
                                dcredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*ocredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"ocredit=\"\`\" ]
                        then
                                ocredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

elif [ \$os_name = \"debian\" ]||[ \$os_name = \"ubuntu\" ]||[ \$os_name = \"linux_mint\" ]	
then
	remember_item=\`cat /etc/pam.d/common-password | gawk '/^[[:space:]]*password[[:space:]]*sufficient[[:space:]]*pam_unix\.so[[:space:]]*.*[[:space:]]*remember=(0|[1-9][0-9]*)[[:space:]]*.*$/{\print \$0}'\`
        for item in \$(echo \$remember_item)
        do
                if [ -n \"\`echo \$item | grep remember\`\" ]
                then
                        remember=\`echo \$item | cut -f2 -d '='\`
                fi
        done

        pam_cracklib=\`cat /etc/pam.d/common-password | gawk '/^[[:space:]]*password[[:space:]]*requisite[[:space:]]*pam_cracklib\.so[[:space:]]*/{print $0}'\`
        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*retry=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"retry=\"\`\" ]
                        then
                                retry=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi
	
	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*difork=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"difork=\"\`\" ]
                        then
                                difork=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*minlen=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"minlen=\"\`\" ]
                        then
                                minlen=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*ucredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"ucredit=\"\`\" ]
			then
				ucredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*lcredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"lcredit=\"\`\" ]
                        then
                                lcredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi

        if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*dcredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"dcredit=\"\`\" ]
                        then
                                dcredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi
	
	if [ -n \"\`echo \$pam_cracklib | gawk '/[[:space:]]*ocredit=(0|[1-9][0-9]*)[[:space:]]*/{print \$0}'\`\" ]
        then
                for item in \$(echo \$pam_cracklib)
                do
                        if [ -n \"\`echo \$item | grep \"ocredit=\"\`\" ]
                        then
                                ocredit=\`echo \$item | cut -f2 -d '='\`
                        fi
                done
        fi
fi

echo remember=\$remember
echo retry=\$retry
echo difork=\$difork
echo minlen=\$minlen
echo ucredit=\$ucredit
echo lcredit=\$lcredit
echo dcredit=\$dcredit
echo ocredit=\$ocredit

unset remember
unset retry
unset difork
unset minlen
unset ucredit
unset lcredit
unset dcredit
unset ocredit"

function fun_12 {
	count=0
	oldIFS=$IFS
	IFS=$'\n'

	for line in $(cat /etc/passwd)
	do
        	uid=`echo $line | cut -d : -f3`
        	if [ $uid -eq 0 ]
        	then
                	count=$(expr $count + 1)
        	fi
	done

	#echo $count

	if [ $count -le 1 ]
	then	
		echo yes
	else	
		echo no
	fi
	
	IFS=$oldIFS
	unset count line uid oldIFS
}

code[12]="count=0
        oldIFS=\$IFS
        IFS=$'\\\n'

        for line in \$(cat /etc/passwd)
        do
                uid=\`echo \$line | cut -d : -f3\`
                if [ \$uid -eq 0 ]
                then
                        count=\$(expr \$count + 1)
                fi
        done

        echo \$count

        IFS=\$oldIFS
        unset count
        unset line
        unset uid
        unset oldIFS"

function fun_13 {
	echo yes

}


code[13]="if [ -s /etc/sysconfig/syslog ]
then
	if [[ \`cat /etc/sysconfig/syslog | grep SYSLOGD_OPTIONS | grep '\-m'\` ]]
	then
		flag=1
	else
		remote_syslog=no
	fi
	
	if [[ \$flag = 1 ]]
	then
		line=\`cat /etc/services | grep syslog | grep -v .*-.* | awk '{print \$2}'\`
		if test \$line
		then
			if [ \`echo \$line | grep -v -x -E '[0-9]*/tcp|[0-9]*/udp'[[:space:]]*\` ]
			then
				flag=0
				remote_syslog=no
			fi
		else
			flag=0
			remote_syslog=no
		fi
	fi
	unset line
	
	if [[ \$flag = 1 ]]
	then
		oldIFS=\$IFS
		IFS=$'\\\n'
		for line in \$(cat /etc/syslog.conf)
		do
			if [ \`echo \$line | grep -v ^[[:space:]]*#\` ]
			then 
				kind=\`echo \$line | awk '{print \$1}'\`
				where=\`echo \$line | awk '{print \$2}'\`
				if [ \`echo \$where | grep ^@\` ]
				then
					remote_syslog=yes
				fi
			
				IFS=';'
				for item in \$kind
				do
					echo \$item=\$where 
				done
			fi
		done
	fi
	IFS=\$oldIFS
else
	remote_syslog=no
fi		
			
echo remote_syslog=\$remote_syslog"

function fun_14 {
    ssh=`cat /etc/ssh/sshd_config | grep PermitRootLogin | grep no | grep -v ^#`
    if [ -n "$ssh" ]; then
	echo yes
    else
        echo no
    fi
}

code[14]="ssh_status=\`ps -ef | grep sshd | grep -v grep\`
	if [[ -z \"\$ssh_status\" ]]
	then
		echo no
	else
		echo yes
	fi
	unset ssh_status"

tel=`cat /etc/inetd.conf | grep telnet | grep -v ^#`
function fun_15 {
    tel=`cat /etc/inetd.conf | grep telnet`
    if [ -n "$tel" ]; then
	echo yes
    else
        tel1=`cat /etc/inetd.conf | grep telnet | grep -v ^#`
	if [ -n "$tel1" ]; then
	    tel2=`cat /etc/inetd.conf | grep telnet | grep off`
	    if [ -n "$tel1" ]; then
	        echo no
	    else
	        echo yes
	    fi
	else
	    echo yes
	fi
    fi
}

code[15]="oldIFS=\$IFS
IFS=$'\\\n'

for line in \$(cat /etc/shadow)
do
        lock=\`echo \$line | cut -d \: -f2\`
        char=\${lock:0:1}

        if [[ \$char == \"*\" ]] || [[ \$char == \"!\" ]]
        then
                username=\`echo \$line | cut -d \: -f1\`
                echo \$username=locked
        fi
done

IFS=\$oldIFS
unset line
unset char
unset username"

function fun_16 {
	host_allow=`cat /etc/hosts.allow | grep -v "^[[:space:]]*#"`
	host_deny=`cat /etc/hosts.deny | grep -v "^[[:space:]]*#"`
	
	if [[ -n "$host_allow" ]] && [[ -n "$host_deny" ]]
	then
		echo yes
	else
		echo no
	fi
	
	unset host_allow host_deny
}

code[16]="cat /etc/hosts.allow | grep -v \"^[[:space]]*#\"

	cat /etc/hosts.deny | grep -v \"^[[:space]]*#\""


function fun_17 {
    ssh=`cat /etc/ssh/sshd_config | grep PubkeyAuthentication | grep no | grep -v ^#`
    if [ -n "$ssh" ]; then
	echo no
    else
        echo yes
    fi
}

code[17]="if [ -s /etc/syslog.conf ]
        then
                oldIFS=\$IFS
                IFS=$'\\\n'
                for line in \$(cat /etc/syslog.conf)
                do
                        if [ \`echo \$line | grep -v ^[[:space:]]*#\` ]
                        then
                                kind=\`echo \$line | awk '{print \$1}'\`
                                where=\`echo \$line | awk '{print \$2}'\`

                                IFS=';'
                                for item in \$kind
                                do
                                        echo \$item=\$where
                                done
                                IFS=$'\\\n'
                        fi
                done

                IFS=\$oldIFS
        else
                echo syslog=NULL
        fi"

function fun_18 {
    echo yes
}

code[18]="oldIFS=\$IFS
        IFS=$'\\\n'

        for line in \$(cat /etc/passwd)
        do
                gid=\`echo \$line | awk -F ':' '{print \$4}'\`
                if [[ \$gid -ge 500 ]]
                then
                        condition=\`echo \$line | grep -v /sbin/nologin\`
                        if test \$condition
                        then
                                echo \`echo \$line | awk -F : '{print \$1}'\`=\$gid
                        fi
                fi
        done

        unset gid
        unset condition
        unset line
        IFS=\$oldIFS"

function fun_19 {
find=`find /usr/bin/chage /usr/bin/gpasswd /usr/bin/wall /usr/bin/chfn /usr/bin/chsh /usr/bin/newgrp /usr/bin/write /usr/sbin/usernetctl /usr/sbin/traceroute /bin/mount /bin/umount /bin/ping /sbin/netreport -type f -perm +6000 2>/dev/null`
if [ -n "$find" ]; then
    echo no
else
    echo yes
fi
}

code[19]="oldIFS=\$IFS
        IFS=$'\\\n'

        for line in \$(cat /etc/passwd)
        do
                gid=\`echo \$line | awk -F ':' '{print \$4}'\`
                if [[ \$gid -ge 500 ]]
                then
                        condition=\`echo \$line | grep -v /sbin/nologin\`
                        if test \$condition
                        then
                                echo \`echo \$line | awk -F : '{print \$1}'\`=\$gid
                        fi
                fi
        done

        unset gid
        unset condition
        unset line
        IFS=\$oldIFS"

function fun_20 {
 	umask_code=-1
	umask1=`cat /etc/profile | grep umask | grep -v ^# | awk '{print $2}'`
	umask2=`cat /etc/bash.bashrc | grep umask | grep -v ^# | awk 'NR!=1{print $2}'`
	flags=0
	for i in $umask2
	do
	    umask_code=$i
        	#echo umask_code=$umask_code
    		flags=1
	done

	if [ $flags = 0 ]
	then
        	for i in $umask1
        	do
                	umask_code=$i
                	#echo umask_code=$umask_code
        	done
	fi
	
	if [ $umask_code -eq 027 ]
	then	
			echo yes
	else
			echo no
	fi
	unset unmask_code umask1 umask2

}

code[20]="umask1=\`cat /etc/profile | grep \"^umask\" | grep -v ^# | awk '{print \$2}'\`
	
	if [[ \$umask1 -eq 027 ]]
	then	
		echo yes
	else
		echo no
	fi
	unset umask1"




function fun_21 {
	source ~/.bashrc
	alia_ls=`alias | grep -E 'ls='`
	alia_rm=`alias | grep -E 'rm='`
	#echo "$alia"
	if [[ -n "$alia_ls" ]] && [[ -n "$alia_rm" ]]
	then
		echo yes
	else
		echo no
	fi
}

code[21]="source ~/.bashrc
	alia_ls=`alias | grep -E 'ls='`
	alia_rm=`alias | grep -E 'rm='`"





function fun_22 {
	HISTSIZE=`cat /etc/profile | grep HISTSIZE | head -1 | awk -F[=] '{print $2}'`
	#echo HISTSIZE=$HISTSIZE
	if [[ "$HISTSIZE" -le "5" ]]
	then
		echo yes
	else
		echo no
	fi
}

code[22]="HISTSIZE=\`cat /etc/profile | grep HISTSIZE | head -1 | awk -F[=] '{print \$2}'\`
	echo HISTSIZE=\$HISTSIZE"



function fun_23 {

     echo yes

}

code[23]="awk -F: '$2 == \"\"  { print \$1 }' /etc/shadow"

function fun_24 {

    echo yes

}

code[24]="service=\`ps -elf | grep ntp | grep -v grep\`

        if test \$service
        then
                ntp=1
                if [ -s /etc/ntp.conf ]
                then
                        server=\`cat /etc/ntp.conf | grep -v \"^[[:space:]]*#\" | grep ^[[:space:]]*server\`
                else
                        server=0
                fi
        else
                ntp=0
        fi

        echo ntp=\$ntp
        echo server=\$server

        unset ntp
        unset server
        unset service"

function fun_25 {
    soft=`cat /etc/security/limits.conf | grep soft | grep core | grep 0 | grep ^*`
    hard=`cat /etc/security/limits.conf | grep hard | grep core | grep 0 | grep ^*`
    if [ -z "$soft" ] && [ -z "$hard" ]; then
        echo no
    else
        echo yes
    fi
}

code[25]="net_redirect=\`sysctl -n net.ipv4.conf.all.accept_redirects\`"

function fun_26 {
	ssh_status=`ps -ef | grep sshd | grep -v grep`
	if [[ -z "$ssh_status" ]]
	then
		echo no
	else
		echo yes
	fi
	unset ssh_status
}

code[26]="ssh_status=\`ps -ef | grep sshd | grep -v grep\`
	if [[ -z \"\$ssh_status\" ]]
	then
		echo no
	else
		echo yes
	fi
	unset ssh_status"

function fun_27 {
	ip_forward=`cat /proc/sys/net/ipv4/ip_forward`
	#echo ip_forward=$ip_forward
	
	if [ $ip_forward -eq 0 ]
	then
		echo yes
	else	
		echo no
	fi
	
	unset ip_forward
}

code[27]="ip_forward=\`cat /proc/sys/net/ipv4/ip_forward\`
        echo ip_forward=\$ip_forward

        unset ip_forward"

function fun_28 {
	n1=`ps -ef | grep nfs | grep -v grep`
	if [ -z "$n1" ]
	then
	n2=`cat /etc/hosts.allow | grep -v "^[[:space:]]*#" | grep "^[[:space:]]*nfs:.*" | wc -l`
	n3=`cat /etc/hosts.deny | grep -v "^[[:space:]]*#" | grep "^[[:space:]]*nfs:all.*" | wc -l`
	if [ $n2 > 0 -a $n3 > 0 ]
	then
	    echo yes
	else
	    echo no
	fi
	else
	    echo no
	fi
	
}

code[28]="oldIFS=\$IFS
        IFS=$'\\\n'
        service=\`ps -ef | grep nfs | grep -v grep\`

        if test \$service
        then
                NFS=1
                if [ -s /etc/hosts.allow ]
                then
                        for line in \$(cat /etc/hosts.allow)
                        do
                                if [ \`echo \$line | grep -v '^[[:space:]]*#'\` ]
                                then
                                        item=\`echo \$line | awk -F ':' 'print \$1'\`
                                        if [ \`echo \$item | grep -i all\` ]||[ \`echo \$item | grep -i nfs\` ]
                                        then
                                                echo \$line
                                        fi
                                fi
                        done
                fi

                if [ -s /etc/hosts.deny ]
		then
                        for line in \$(cat /etc/hosts.deny)
                        do
                                if [ \`echo \$line | grep -v '^[[:space:]]*#'\` ]
                                then
                                        item=\`echo \$line | awk -F ':' 'print \$1'\`
                                        if [ \`echo \$item | grep -i all\` ]||[ \`echo \$item | grep -i nfs\` ]
                                        then
                                                echo \$line
                                        fi
                                fi
                        done
                fi
        else
                NFS=0
        fi

        echo NFS=\$NFS
        IFS=\$oldIFS

        unset NFS
        unset line
        unset item
        unset service
        unset oldIFS"



function fun_29 {
   bntpservice=0
    bntpconf=0
    iProceExist=`ps -e|grep "ntpd"|grep -v grep | wc -l`
    if [ $iProceExist == 0 ]
        then
            if [ -f "/etc/init.d/ntpd" ]
                then
                    /etc/init.d/ntpd start >> /dev/null 2>&1
            elif [ -f "/etc/init.d/ntp" ]
                 then
                        /etc/init.d/ntp start >> /dev/null 2>&1
                else
                        bntpservice=1
                fi
                sleep 1
        fi
        iProceExist=`ps -ef|grep "ntpd"|grep -v grep | wc -l`
        if [ $iProceExist -le 0 ]
        then
                let bntpservice=1
        fi
        iProceExist=`ps -ef|grep "ntpd"|grep -v grep | wc -l`
        if [ $iProceExist -le 0 ]
        then
                let bntpservice=1
        fi
        iCount=`cat /etc/ntp.conf |  sed -n '/^\s*server\s\+\S\+\s*/p' | wc -l`
        if [[ $iCount -le 0 ]]
        then
        let bntpconf=1
        fi
        if [[ $flag -eq 0 ]] && [[ $bntpconf -eq 0 ]]
        then
            echo yes
        else
            echo no
        fi
}

code[29]="service=\`ps -elf | grep ntp | grep -v grep\`

        if test \$service
        then
                ntp=1
                if [ -s /etc/ntp.conf ]
                then
                        server=\`cat /etc/ntp.conf | grep -v \"^[[:space:]]*#\" | grep ^[[:space:]]*server\`
                else
                        server=0
                fi
        else
                ntp=0
        fi

        echo ntp=\$ntp
        echo server=\$server

        unset ntp
        unset server
        unset service"





function fun_30 {
	net_redirect=`sysctl -n net.ipv4.conf.all.accept_redirects`
	if [ $net_redirect -eq 0 ]
	then
		echo yes
	else
		echo no
	fi
}

code[30]="net_redirect=\`sysctl -n net.ipv4.conf.all.accept_redirects\`"



function fun_31 {
	flag=0
	for f in /proc/sys/net/ipv4/conf/*/accept_source_route
	do
        	result=`cat $f`
        	if [ $result -ne 0 ]
		then
			let 'flag+=1'
		fi
	done
	
	if [ $flag -gt 0 ]
	then
		echo no
	else
		echo yes
	fi
}

code[31]="for f in /proc/sys/net/ipv4/conf/*/accept_source_route
        do
                result=\`cat \$f\`
                echo \$f=\$result
        done"




function fun_32 {
	sys_attack=`cat /proc/sys/net/ipv4/tcp_syncookies`
	if [ $sys_attack -eq 1 ]
	then
		echo yes
	else
		echo no
	fi
}

code[32]="sys_attack=\`cat /proc/sys/net/ipv4/tcp_syncookies\`
	if [ \$sys_attack -eq 1 ]
	then
		echo yes
	else
		echo no
	fi"



function fun_33 {
	email=`ps -ef | grep E-Mail | grep -v grep`
	web=`ps -ef | grep Web | grep -v grep`
	ftp=`ps -ef | grep FTP | grep -v grep`
	telnet=`ps -ef | grep telnet | grep -v grep`
	rlogin=`ps -ef | grep rlogin | grep -v grep`
	smb=`ps -ef | grep SMB | grep -v grep`
	echo "$(date) 检查是否关闭不需要的系统服务和端口" >> /usr/share/smp/20230518_localfile.txt
        netstat -tulnp >> /usr/share/smp/20230518_localfile.txt	
	if [[ -n "$email" ]] || [[ -n "$web" ]] || [[ -n "$ftp" ]] || [[ -n "$telnet" ]] || [[ -n "$rlogin" ]] || [[ -n $smb ]]
	then
		echo no
	else
		echo yes
	fi
	unset service email web ftp telnet rlogin
}

code[33]="service=\`chkconfig \-\-list | awk '{print \$1}'\`
        echo \"\$service\"

        unset service"




function fun_34 {
	file="/lib/modules/`uname -r`/kernel/drivers/net/wireless"
	if [ -e $file ]
	then
		echo no
	else
		echo yes
	fi
}

code[34]="file=\"/lib/modules/`uname -r`/kernel/drivers/net/wireless\""



function fun_35 {
        iCount=`route |grep default |wc -l`
        if [[ $iCount -le 0 ]]
        then
            echo yes
	else
	    echo no
        fi
}

code[35]="cat /etc/host.conf"

function fun_36 {

	file="/lib/modules/`uname -r`/kernel/drivers/cdrom/cdrom.ko"
	if [ -e $file ]
	then
		echo no
	else
		echo yes
	fi
}

code[36]="item=\`netstat -nultp | grep -E ^'tcp|udp'\`

        oldIFS=\$IFS
        IFS=$'\\\n'

        for line in \$item
        do
                proto=\`echo \"\$line\"|awk '{print \$1}'\`
                address=\`echo \"\$line\"|awk '{print \$4}'\`
                socket=\`echo \"\$address\"|awk -F ':' '{print \$2}'\`

                echo \$proto.\$socket
        done

        IFS=\$oldIFS
        unset oldIFS
        unset proto
        unset address
        unset socket"

function fun_37 {
	file="/lib/modules/`uname -r`/kernel/drivers/usb/storage/usb-storage.ko"
	if [ -e $file ]
	then
		echo no
	else
		echo yes
	fi
}

code[37]="file=\"/lib/modules/`uname -r`/kernel/drivers/usb/storage/usb-storage.ko\""


function fun_38 {
	flag=0
	if [ -s /etc/syslog.conf ]
	then
        oldIFS=$IFS
        IFS=$'\n'
        for line in $(cat /etc/syslog.conf)
        do
            if [ `echo $line | grep -v ^[[:space:]]*# | grep '/^[[:space:]]*\*\.err\;kern\.debug\;daemon\.notice[[:space:]]*\/var\/adm\/messages[[:space:]]*/{print $0}'` ]
             then
                        	#kind=`echo $line | awk '{print $1}'`
                        	#where=`echo $line | awk '{print $2}'`

                        	#IFS=';'
                        	#for item in $kind
                        	#do
                            #    	echo $item=$where
                        	#done
                        	#IFS=$'\n'
				flag=1
            fi
        done

        IFS=$oldIFS
	elif [ -s /etc/rsyslog.conf ]
	then
		oldIFS=$IFS
        IFS=$'\n'
        for line in $(cat /etc/rsyslog.conf)
        do
            if [ `echo $line | grep -v ^[[:space:]]*# | grep '/^[[:space:]]*\*\.err\;kern\.debug\;daemon\.notice[[:space:]]*\/var\/adm\/messages[[:space:]]*'` ]
            then
				flag=1
            fi
        done

        IFS=$oldIFS
	fi
	if [ $flag -eq 0 ]
	then
		echo no
	elif [ $flag -eq 1 ]
	then	
		echo yes
	fi
	
	unset flag oldIFS line 
}

code[38]="if [ -s /etc/syslog.conf ]
        then
                oldIFS=\$IFS
                IFS=$'\\\n'
                for line in \$(cat /etc/syslog.conf)
                do
                        if [ \`echo \$line | grep -v ^[[:space:]]*#\` ]
                        then
                                kind=\`echo \$line | awk '{print \$1}'\`
                                where=\`echo \$line | awk '{print \$2}'\`

                                IFS=';'
                                for item in \$kind
                                do
                                        echo \$item=\$where
                                done
                                IFS=$'\\\n'
                        fi
                done

                IFS=\$oldIFS
        else
                echo syslog=NULL
        fi"

function fun_39 {
	if [ -s /etc/syslog.conf ]
	then
        #log=`cat /etc/syslog.conf | grep -v "^[[:space:]]*#" | grep '/^([[:space:]]*authpriv\.\*[[:space:]]*|[[:space:]]*authpriv\.info.*[[:space:]]*|[[:space:]]*\*\.\*[[:space:]]*)'`
	log=`sed -n "/^\s*\(authpriv\.\*\|authpriv\.info\)\s*/p"  /etc/syslog.conf`

		if [[ -n "$log" ]]
		then
			echo yes
		else
			echo no
		fi		
	fi

	if [ -s /etc/rsyslog.conf ]
	then
        #log=`cat /etc/rsyslog.conf | grep -v "^[[:space:]]*#" | grep '/^([[:space:]]*authpriv\.\*[[:space:]]*|[[:space:]]*authpriv\.info.*[[:space:]]*|[[:space:]]*\*\.\*[[:space:]]*)'`
	log=`sed -n "/^\s*\(authpriv\.\*\|authpriv\.info\)\s*/p"  /etc/rsyslog.conf`
		if [[ -n "$log" ]]
		then
			echo yes
		else
			echo no
		fi
	fi	
}

code[39]="if [ -s /etc/syslog.conf ]
        then
                cat /etc/syslog.conf | grep -v \"^[[:space:]]*#\" | grep '/^(authpriv\.\*[[:space:]]*|authpriv\.info.*[[:space:]]*|\*\.\*)'
        fi

        if [ -s /etc/rsyslog.conf ]
        then
                cat /etc/rsyslog.conf | grep -v \"^[[:space:]]*#\" | grep '/^(authpriv\.\*[[:space:]]*|authpriv\.info.*[[:space:]]*|\*\.\*)'
        fi"



function fun_40 {
	service=`ps aux | grep -w auditd | grep -v grep`
	if test "$service"
	then
        audit=1
        if [ -s /var/log/audit/audit.log ]
        then
            #ls_show=`ls -l /var/log/audit/audit.log`
            #lsattr_show=`lsattr /var/log/audit/audit.log`
			echo yes
		else
			echo no
        fi
	else
        echo no
	fi

	#echo audit=$audit
	#echo ls=$ls_show
	#echo lasttr=$lsattr_show

	unset service audit ls_show lsattr_show
}

code[40]="service=\`ps aux | grep -w auditd | grep -v grep\`
        if test \"$service\"
        then
                audit=set
                if [ -s /var/log/audit/audit.log ]
                then
                        ls_show=\`ls -l /var/log/audit/audit.log\`
                        lsattr_show=\`lsattr /var/log/audit/audit.log\`
                fi
        else
                audit=un_set
        fi

        echo audit=\$audit
        echo ls=\$ls_show
        echo lasttr=\$lsattr_show

        unset service audit ls_show lsattr_show"

function fun_41 {
                echo yes
}

code[41]="root_logins=\`who | awk '{print \$1}' | sed -n '/^root$/p' | wc -l\`
        echo root_logins=\$root_logins"

function fun_42 {
	if [ -s /etc/syslog.conf ]
	then
        log=`cat /etc/syslog.conf | sed -n '/^\s*cron\.\*\+/p'`
		if [[ -n "$log" ]]
		then
			echo yes
		else
			echo no	         
		fi		
	fi
	   if [ -s /etc/rsyslog.conf ]
	            then
                        rlog=`cat /etc/rsyslog.conf | sed -n '/^\s*cron\.\*\+/p'`
		        if [[ -n "$rlog" ]]
		        then
			    echo yes
		        else
			    echo no
		        fi
	            fi
}

code[42]="oldIFS=\$IFS
        IFS=$'\\\n'

        if [ -s /etc/syslog.conf ]
        then
                for line in \$(cat /etc/syslog.conf)
                do
                        if test \"\`echo \$line | grep -v ^[[:space:]]*# | awk '{print \$1}' | grep '/^[[:space:]]*(cron|\*\.)'\`\"
                        then
                                cron=set
                                item=\`echo \$line | awk '{print \$1}'\`
                                dir=\`echo \$line | awk '{print \$2}'\`
                                echo \$item=\$dir
                        fi
                done
        else
                cron=unset
        fi

        echo cron=\$cron

        IFS=\$oldIFS

        unset oldIFS
        unset conf
        unset cron"




ipaddr=`echo $1 | gawk '/^([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$/{print $0}'`

if [ -z "$ipaddr" ]
then
	echo Usage:ip address wrong
	exit -1
fi

if [ $# -gt 3 ]
then
        echo Usage:too many args,ignore the fourth !
elif [ $# -lt 3 ]
then
	echo Usage:lack of args!
	exit -1
fi

oldIFS=$IFS
IFS=,
count=0

for (( i=0; i <= 42; i++ ))
do
        arry[$i]=0
done

for arg in $2
do
        if test "`echo $arg | grep -x -E "[0-9]|[1-4][0-9]|5[0-2]"`"
        then
                arry[$arg]=$[${arry[$arg]} + 1]
                if [[ ${arry[$arg]} -gt 1 ]]
                then
                        echo "arg "$arg" repeated emergence,only handle once"
                else
                        count=$[$count + 1]
                fi
        else
                echo "arg "$arg" \"> 52\" or \"< 0\" or \"not a number\",ignore it"
        fi
done

IFS=$oldIFS

unset LANG
#os_full_name=`cat /etc/issue | head -1 | awk -F "release" '{print $1}'`
os_full_name=`cat /etc/issue`
if [[ `echo $os_full_name | grep -i "red hat"` ]]
then
	os_name="rhel"
elif [[ `echo $os_full_name | grep -i "KYLIN"` ]]
then
	os_name="kylin"
elif [[ `echo $os_full_name | grep -i "Rocky"` ]]
then
	os_name="rocky"
elif [[ `echo $os_full_name | grep -i "Linx"` ]]
then
        os_name="linx"
fi

if [[ $os_name = "rhel" ]]
then
	os_version=`cat /etc/issue | head -1 | awk -F "release" '{print $2}'`
elif [[ $os_name = "kylin" ]]
then
	os_version=`cat /etc/issue | head -1 | awk '{print $2}'`
elif [[ $os_name = "rocky" ]]
then
	os_version=`cat /etc/issue | head -n 2 | tail -n 1 | awk '{print $5}'`
elif [[ $os_name = "linx" ]]
then
	os_version=`cat /etc/issue | head -n 2  | awk '{print $2}'`
fi

date=`date "+%Y-%m-%d %H:%M:%S"`
coding=`echo $LANG`
coding_value="UTF-8"

if test "`echo $coding | grep GB`"
then
	coding_value="GBK"
fi

xmlfile=$3
#echo $xmlfile

if [ -e /usr/share/smp/$xmlfile ]
then
	rm -f /usr/share/smp/$xmlfile
	#echo "$xmlfile exists,remove it !"
fi

touch /usr/share/smp/$xmlfile

#echo point2

echo "<?xml version='1.0' encoding='$coding_value'?>" > /usr/share/smp/$xmlfile
echo "<result>" >> /usr/share/smp/$xmlfile
echo "<osName><![CDATA["$os_name"]]></osName>" >> /usr/share/smp/$xmlfile
echo "<version><![CDATA["$os_version"]]></version>" >> /usr/share/smp/$xmlfile
echo "<ip><![CDATA["$ipaddr"]]></ip>" >> /usr/share/smp/$xmlfile
echo "<type><![CDATA[/server/"$os_name"]]></type>" >> /usr/share/smp/$xmlfile
echo "<startTime><![CDATA["$date"]]></startTime>" >> /usr/share/smp/$xmlfile
echo "<pId><![CDATA[$$]]></pId>" >> /usr/share/smp/$xmlfile

echo -e "\t<scripts>" >> /usr/share/smp/$xmlfile

if [[ ${arry[0]} -gt 0 ]]&&[[ $count -eq 1 ]]
then
	for (( i=1; i <= 42; i++ ))
        do
                        echo -e "\t\t<script>" >> /usr/share/smp/$xmlfile
                        echo -e "\t\t\t<id>"$i"</id>" >> /usr/share/smp/$xmlfile
                        echo -e "\t\t\t<code><![CDATA[${code[$i]}]]></code>" >> /usr/share/smp/$xmlfile
                        #echo "$i"
                        value=$(fun_$i)
                        echo -e "\t\t\t<value><![CDATA[$value]]></value>" >> /usr/share/smp/$xmlfile
                        echo -e "\t\t</script>" >> /usr/share/smp/$xmlfile
        done
elif [[ ${arry[0]} -gt 0 ]]&&[[ $count -gt 1 ]]
then
        echo arg "0" means test all the items,ignore other args
        for (( i=1; i <= 42; i++ ))
        do
                        echo -e "\t\t<script>" >> /usr/share/smp/$xmlfile
                        echo -e "\t\t\t<id>"$i"</id>" >> /usr/share/smp/$xmlfile
                        echo -e "\t\t\t<code><![CDATA[${code[$i]}]]></code>" >> /usr/share/smp/$xmlfile
                        #echo "$i"
                        value=$(fun_$i)
                        echo -e "\t\t\t<value><![CDATA[$value]]></value>" >> /usr/share/smp/$xmlfile
                        echo -e "\t\t</script>" >> /usr/share/smp/$xmlfile
        done
else
        for (( i=1; i <= 42; i++ ))
        do
                if [ ${arry[$i]} -gt 0 ]
                then
                        echo -e "\t\t<script>" >> /usr/share/smp/$xmlfile
                        echo -e "\t\t\t<id>"$i"</id>" >> /usr/share/smp/$xmlfile
                        echo -e "\t\t\t<code><![CDATA[${code[$i]}]]></code>" >> /usr/share/smp/$xmlfile
			#echo "$i"
                        value=$(fun_$i)
                        echo -e "\t\t\t<value><![CDATA[$value]]></value>" >> /usr/share/smp/$xmlfile
			echo -e "\t\t</script>" >> /usr/share/smp/$xmlfile

                fi
        done
fi

echo -e "\t</scripts>" >> /usr/share/smp/$xmlfile
enddate=`date "+%Y-%m-%d %H:%M:%S"`
echo "<endTime><![CDATA["$enddate"]]></endTime>" >> /usr/share/smp/$xmlfile
echo "</result>" >> /usr/share/smp/$xmlfile
#echo -e "write  result to xml file\nexecute end!\n"
