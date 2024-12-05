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
	iptables -A INPUT -p icmp -j ACCEPT      		#允许ping功能
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT 	#允许远程ssh访问
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
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT 

	iptables -A INPUT -p udp --dport 161 -j ACCEPT 
	iptables -A INPUT -p udp --dport 162 -j ACCEPT 
	iptables -A INPUT -p udp --dport 514 -j ACCEPT 
	iptables -A INPUT -p udp --dport 516 -j ACCEPT 

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
	if [[ $? -eq 0 ]]; then
		echo "drop success."
	else
		echo "drop faild."
	fi
}

allow_all(){
	iptables -P INPUT ACCEPT
}

start(){
	clear;
	global_on;
	ns5000_on;
	allow;
	drop;
}

stop(){
	clear;
	global_on;
	allow_all;
}

show(){
	# 查看防火墙配置情况
	iptables -L -nv
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
