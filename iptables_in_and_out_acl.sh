#
#!/bin/sh
#

oper=$1

##清楚掉所有配置
clear(){
	echo -e "\nclear all the iptables config."
	iptables -F
	iptables -X
	iptables -Z
	if [[ $? -eq 0 ]]; then
		echo "clear success.":
	else
		echo "clear faild."
	fi
}


##允许开放的运维端口
global_on(){
	echo -e "\nallow access from global ports below:"
	echo -e "   ping[icmp]\n   ssh[22]\n   lo[loop back]"
	iptables -A INPUT -i lo -j ACCEPT      			#允许访问回环网口
	iptables -A OUTPUT -i lo -j ACCEPT      			#允许访问回环网口
	iptables -A INPUT -p icmp -j ACCEPT      		#允许ping功能
	iptables -A OUTPUT -p icmp -j ACCEPT      		#允许ping功能
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT 		#允许远程ssh访问
	iptables -A INPUT -p udp --dport 123 -j ACCEPT 	#允许远程ntp访问
	iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT 		#允许远程ssh访问
	iptables -A OUTPUT -p tcp --dport 6702 -j ACCEPT 	#允许远程ssh访问
	iptables -A OUTPUT -p udp --dport 123 -j ACCEPT 	#允许远程ntp访问
	iptables -A OUTPUT -p udp --dport 516 -j ACCEPT 	#允许远程ntp访问
	iptables -A OUTPUT -p tcp --dport 12345 -j ACCEPT 	#允许远程dameng访问
	iptables -A OUTPUT -p tcp --dport 5236 -j ACCEPT 	#允许远程dameng访问
	iptables -A OUTPUT -p tcp --dport 8888 -j ACCEPT 	#允许远程dameng访问
	if [[ $? -eq 0 ]]; then
		echo "accept success."
	else
		echo "accept faild."
	fi
}

ns5000_on(){
	echo -e "\nallow access from ns5000 ports below:"
	echo -e "   514(UDP)\516(UDP)[syslog]\n  9092[kafka]\n  2181[zookeeper]\n  5209[scannerserver]\n  12345[dm]\n  161(UDP)\162(UDP)[snmp/trap]\n  22[ssh]"
	iptables -A INPUT -p tcp --dport 9092 -j ACCEPT
	iptables -A OUTPUT -p tcp --dport 9092 -j ACCEPT 
	#iptables -A INPUT -p tcp --dport 2181 -j ACCEPT 
	iptables -A INPUT -p tcp --dport 5209 -j ACCEPT 
	iptables -A INPUT -p tcp --dport 12345 -j ACCEPT 
	iptables -A INPUT -p tcp --dport 5236 -j ACCEPT 
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT 

	iptables -A INPUT -p udp --dport 161 -j ACCEPT 
	iptables -A INPUT -p udp --dport 162 -j ACCEPT 
	iptables -A INPUT -p udp --dport 514 -j ACCEPT 
	iptables -A INPUT -p udp --dport 516 -j ACCEPT 
	iptables -A INPUT -s 10.34.12.125 -p tcp --dport 29037 -j ACCEPT 
	iptables -A INPUT -p tcp --dport 8888 -j ACCEPT 
	iptables -A OUTPUT -p tcp --dport 29762 -j ACCEPT 
	iptables -A OUTPUT -p tcp --dport 22222 -j ACCEPT 
	iptables -A OUTPUT -p tcp --dport 33333 -j ACCEPT 
	iptables -A OUTPUT -p tcp --dport 8087 -j ACCEPT 
	iptables -A OUTPUT -p tcp --dport 10112 -j ACCEPT 
	iptables -A OUTPUT -p tcp --dport 5236 -j ACCEPT 
	iptables -A OUTPUT -p tcp --dport 15236 -j ACCEPT 
	iptables -A OUTPUT -d 192.168.12.121 -p tcp --dport 445 -j ACCEPT 
	iptables -A OUTPUT -d 10.34.12.10 -p tcp --dport 4450 -j ACCEPT 
	iptables -A OUTPUT -d 10.34.12.10 -p tcp --dport 4550 -j ACCEPT 
	iptables -A OUTPUT -d 192.168.12.112 -p tcp --dport 4380 -j ACCEPT 
	iptables -A OUTPUT -d 10.34.12.125 -p tcp --dport 29443 -j ACCEPT 
	iptables -A OUTPUT -d 10.34.12.125 -p tcp --dport 29444 -j ACCEPT 
	iptables -A OUTPUT -d 10.34.12.125 -p tcp --dport 29037 -j ACCEPT 
	iptables -A OUTPUT -d 10.34.12.125 -p tcp --dport 29086 -j ACCEPT 
	iptables -A OUTPUT -d 10.34.12.125 -p tcp --dport 29088 -j ACCEPT 
	iptables -A OUTPUT -d 10.34.12.125 -p tcp --dport 29089 -j ACCEPT 

	if [[ $? -eq 0 ]]; then
		echo "accept success."
	else
		echo "accept faild."
	fi
}

##允许本地发起会话
allow(){
	echo -e "\nallow session start by local"
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	if [[ $? -eq 0 ]]; then
		echo "allow success."
	else
		echo "allow faild."
	fi
}

##禁止策略以外的访问
drop(){
	echo -e "\nset default policy to drop"
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	if [[ $? -eq 0 ]]; then
		echo "drop success."
	else
		echo "drop faild."
	fi
}

allow_all(){
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
}

##记录拦截的访问并记录log文件到/var/log/messages
loglog(){
	echo -e "\nlog into /var/log/messages"
        iptables -A INPUT -j LOG --log-prefix "IPTABLES LOG INPUT" --log-level 4
        iptables -A OUTPUT -j LOG --log-prefix "IPTABLES LOG OUPPUT" --log-level 4
	if [[ $? -eq 0 ]]; then
		echo "allow success."
	else
		echo "allow faild."
	fi
}
start(){
	clear;
	global_on;
	ns5000_on;
	allow;
	drop;
        loglog;
}

stop(){
	clear;
	global_on;
	allow_all;
}

show(){
	# 查看防火墙配置情况
	iptables -L -nv --line-numbers
}

case $oper in
show)
  show
;;
stop)
  stop
;;
start)
  start
;;
*)
 echo '$1 param error!'
;;
esac
