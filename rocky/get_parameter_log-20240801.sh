#!/bin/bash 
#################################################
# FileName: get_paramater_log.sh
# Date: 2022-12-02
# Usage: ./get_patamater_log.sh -somelog|-alllog
# Description: get system infomation
#
#################################################

export LANG=C
E_BADARGS=65

echo_fail() {
	echo -e "\\033[1;31m" "failed"
}

reset_color() {
	echo -en "\\033[0;39m"
}
#判断是否为root用户执行配置脚本
if [ `id -u` -ne 0 ];then
    exit 1
fi

if [ $# -lt 1 -o "x$1" != "x-somelog" -a "x$1" != "x-alllog" ];then
	echo "usage: `basename $0` -somelog bond0"
	echo "usage: `basename $0` -somelog eth0"
	echo "or"
	echo "usage: `basename $0` -alllog bond0"
	echo "usage: `basename $0` -alllog eth0"
	exit $E_BADARGS
fi

disk=`mount | grep 'on / ' | awk '{print $1}'`
#当根目录空间小于1G时，自动退出
df -h | grep ${disk} | awk '{print $4}' |grep -q M
if [ $? -eq 0 ] ;then
    echo "Insufficient space."
    exit 1
fi

echo " Collection start ..."

DATE=$(date +%Y%m%d%H%M%S)
hostname=$(uname -n)
d5000_home=`grep d5000 /etc/passwd | cut -d : -f6`

test -d /tmp/${hostname} || mkdir /tmp/${hostname} 
cd /tmp/${hostname}

ifconfig eth0> ./${hostname}.eth0-mac-address 2>&1
ifconfig ens1> ./${hostname}.ens1-mac-address 2>&1
echo $DISPLAY> ./${hostname}.$USER.DISPLAY 2>&1

# 可信服务配置
#if [ -f /usr/bin/policy_output ] ;then
#    [ -f ./policy ] && mv ./policy ~secadmin
#    /usr/bin/policy_output
#    mv policy ${hostname}.policy
#fi
find /usr/ -name "libGL*" > ${hostname}.libGL 2>/dev/null
which nvidia-smi > /dev/null 2>&1 && nvidia-smi  > ${hostname}.nvidia-smi

ltcs_file="
/etc/ltcs/linx_ltcs.conf
/etc/modprobe.d/linx_ltcs.conf
/etc/security/ltcs/policy.conf
/sys/kernel/security/ltcs/ltcs_on_off
/sys/kernel/security/ltcs/appraise_mode
/sys/kernel/security/ltcs/ltcs_whitelist
/etc/audit/rules.d/audit.rules
"

# CDNS集群信息
cdns_file="
/usr/sbin/rs.sh
/proc/sys/net/ipv4/conf/lo/arp_ignore
/proc/sys/net/ipv4/conf/lo/arp_announce
/proc/sys/net/ipv4/conf/all/arp_ignore
/proc/sys/net/ipv4/conf/all/arp_announce
/usr/local/bind9cndns/sbin/real_sync
/etc/linxipvs.conf
/etc/ha.d/ldirectord.cf
/etc/corosync/authkey
"
cdns_tar_list="
bind/named/chroot
opt/cdns/server/etc
"

# 某现场CDNS集群arp检测地址网络详情收集
if [ -f /sys/class/net/bond0/bonding/arp_ip_target ];then
	for i in `cat /sys/class/net/bond0/bonding/arp_ip_target`
       	do
		ping -c 3 -W 1 $i > ${hostname}.ping.-c.3.-w.1.$i 2>&1
       	done
fi

echo $PATH > ${hostname}.${USER}.PATH
which ipvsadm > /dev/null
if [ $? -eq 0 ];then
	ipvsadm -Ln > ${hostname}.ipvsadm.-Ln 2>&1
	ipvsadm -Ln --stats > ${hostname}.ipvsadm.-Ln.--stats 2>&1
fi
# END CDNS集群信息
cp_list="
/usr/sbin/aisexec
/etc/license/license.conf
/dev/shm/license_status
/etc/license_client.conf
/proc/net/virt_license/license_stat
/etc/linxdfs/VERSION
/etc/kubernetes/version
/etc/docker/version
/etc/systemd/journald.conf
/etc/systemd/logind.conf
/etc/linxsn/linx_engine.conf
/etc/linxsn/linx-spice-gk.conf
/etc/linxsn/linxdfs_sn.conf
/usr/share/smp/white_list.conf
/etc/linxsn/security_sn.conf
/etc/iscsi/iscsid.conf
/etc/lvm/lvm.conf
/etc/security/limits.conf
/proc/sys/fs/file-max
/proc/sys/kernel/hung_task_warnings
/proc/asound/cards
/proc/mounts
/proc/linxsn_info
/proc/scsi/scsi
/proc/vmstat
/proc/cpuinfo
/proc/stat
/proc/net/bonding/bond0
/proc/net/bonding/bond1
/proc/loadavg
/etc/lightdm/lightdm.conf
/etc/linxdfs/VERSION
/etc/kubernetes/version
/etc/linx-container/version
/etc/linx-scontainer/VERSION
${ltcs_file}
${cdns_file}
/etc/fstab
/etc/mcelog/mcelog.conf
/etc/ipwatchd.conf
/etc/csh.cshrc
/etc/profile
/root/.profile
/root/.bashrc 
/etc/exports
/etc/security/LinxSetupSign
/etc/hosts
/etc/issue
/etc/hosts.deny
/etc/hosts.allow
/etc/sysconfig/network
/etc/hostname
/etc/passwd
/etc/group
/etc/shadow
/etc/network/interfaces
/etc/network/routes
/etc/rc.d/rc.local
/etc/rc.local
/etc/X11/xorg.conf
/etc/cgconfig.conf
/etc/cgrules.conf
/etc/ntp.conf
/etc/resolv.conf
/etc/drbd.conf
/etc/proftpd/proftpd.conf
/etc/ssh/sshd_config
/etc/named.conf
/etc/bind/named.conf
/etc/ssh/ssh_config
/etc/inetd.conf
/etc/inittab
/etc/ntp/ntp.conf
/etc/linxsn/cgroup_sn.conf
/etc/linxsn/HA_sn.conf
/etc/linxsn/multipath_sn.conf
/etc/sysctl.conf
/etc/syslog.conf
/etc/rsyslog.conf
/etc/logrotate.conf
/var/lib/logrotate/status
/var/lib/logrotate.status
/usr/share/config/kdm/kdmrc
/usr/share/config/kdm/Xsession
/etc/gdm3/daemon.conf
$d5000_home/conf/nic/sys_netcard_conf.txt
/etc/modprobe.conf
/etc/default/grub
/etc/sysconfig/modules
/etc/modules
/etc/ld.so.conf
/usr/sbin/update_time.sh
/usr/sbin/get_max_mem_process.sh
/usr/sbin/get_parameter_log.sh
/boot/grub/grub.conf
/boot/grub/menu.lst
/boot/grub/grub.cfg
/usr/share/smp/linx_config
/etc/linxsn/smp_sn.conf
/etc/ld.so.conf.d/smp.conf
/etc/corosync/corosync.conf
/etc/corosync/lxha_clientlist.conf
/etc/corosync/lxha_iplist.conf
/etc/corosync/lxhalog_iplist.conf
/etc/multipath.conf
/opt/smp.bak
/etc/crontab
/proc/cmdline
/proc/meminfo
/proc/buddyinfo
/proc/sys/fs/file-nr
/tmp/lsmp
/tmp/corosync.log
/tmp/corosync.log.1
/etc/lxha_gtk.conf
/opt/linxha_gui/configure/config.ini
/opt/cdns/web/options.json
"
for i in $cp_list
do
	if [ -f $i ]
	then
		cp $i  ./${hostname}${i//\//.}  2>&1
	fi
done
echo "10% collected"

ls_al_list="
/sys/kernel/security/linx
/dev/mapper
/dev/disk/by-uuid
/dev/disk/by-id
/var/log
/var/run
~d5000/.ssh
 /boot
/tmp
"

for i in $ls_al_list
do
	if [ -d $i ]
	then
		ls -al $i  >./${hostname}.ls.-al${i//\//.} 2>&1
	fi
done

for user in {oms,ems}
do
    if `grep -q ${user} /etc/passwd` ;then
        user_home=`grep ${user} /etc/passwd | cut -d : -f6`
        cat_list="
        /lxcg/${user}_limits/tasks
        ${user_home}/.tcshrc
        ${user_home}/cgroup_limits/${user}_limits/tasks
        ${user_home}/.cshrc
        ${user_home}/.login
        "
        for i in $cat_list
        do
            [ -f $i ] && cat $i >./${hostname}${i//\//.}
        done
    fi
done

#尝试替换下边的for循环
net_name=`ifconfig -a | grep -E "flags|HWaddr" |awk -F' |:' '{print $1}'`
for i in `echo $net_name`
do
    ifconfig $i |grep -q "HWaddr" && net_mac=`ifconfig $i | awk '/HWaddr/{ print $5 }'` || net_mac=`ifconfig $i | awk '/ether/{ print $2}'`
    if [ -n "${net_mac}" ];then
        ethtool $i >./${hostname}.ethtool.$i 2>&1
        ethtool -i $i >./${hostname}.ethtool.-i.$i 2>&1
        ethtool -S $i >./${hostname}.ethtool.-S.$i 2>&1
    fi
done

#for (( i=0; i<16; i++ ))
#do
#	ETH_NIC=eth"$i"
#	BOND_NIC=bond"$i"
#	ETH_MAC=$(ifconfig ${ETH_NIC} 2>/dev/unll| awk '/HWaddr/{ print $5 }')
#	BOND_MAC=$(ifconfig ${BOND_NIC} 2>/dev/unll| awk '/HWaddr/{ print $5 }')
#	if [ -n "${ETH_MAC}" ]; then
#	     ethtool ${ETH_NIC} > ./${hostname}.ethtool.${ETH_NIC} 2>&1
#	     ethtool -i ${ETH_NIC} >./${hostname}.ethtool.-i.${ETH_NIC} 2>&1
#	     ethtool -S ${ETH_NIC} > ./${hostname}.ethtool.-S.${ETH_NIC} 2>&1
#	fi
#	if [ -n "${BOND_MAC}" ]; then
#	     ethtool ${BOND_NIC} > ./${hostname}.ethtool.${BOND_NIC} 2>&1
#	     ethtool -i ${BOND_NIC} > ./${hostname}.ethtool.-i.${BOND_NIC} 2>&1
#	     ethtool -S ${BOND_NIC} > ./${hostname}.ethtool.-S.${BOND_NIC} 2>&1
#	fi
#done

tar_list="
etc/linx-scontainer/
${cdns_tar_list}
etc/sysctl.d
etc/linxsn
var/spool/cron/crontabs
etc/cron
etc/logrotate.d
sys/devices/system/edac
etc/lvm
sys/block
etc/modprobe.d
etc/ld.so.conf.d
etc/sysconfig/network-devices
etc/network/interfaces.d
usr/share/smp
etc/udev
dev/mapper
etc/udev/rules.d
etc/rc.d 
etc/init.d 
etc/rc.d/init.d 
etc/pam.d
etc/security
etc/ssh
etc/corosync
etc/linxmonitor
"

for i in $tar_list
do
	if [ -d /$i ] ;then
		tar czf ./${hostname}.${i//\//.}.tgz -C /  $i >/dev/null 2>&1 
	fi
done

d5000_file_list="
var/log/netcard
.ssh
.cshrc
"

for i in $d5000_file_list
do
	if [ -f $d5000_home/$i ];then
		tar czf ./${hostname}.${i//\//.}.tgz -C $d5000_home  $i >/dev/null 2>&1 
	fi
done

echo "20% collected"
#高性能桌面录屏软件
[ -f /opt/LXHRD/bin/LXHRD ] && /opt/LXHRD/bin/LXHRD -v >${hostname}.LXHRD.VERSION

command_list="
blkid
lsblk
lsusb
date
locale
lastlog
dmesg
numastat
mii-tool
sas2ircu-status
pvdisplay
iptables-save
free
dmidecode
pvscan
vgdisplay
lvdisplay
pvs
vgs
lvs
lsscsi
lsmod
"

for command in $command_list
do
	if which $command >/dev/null 2>&1 || type $command >/dev/null 2>&1 ;then
		$command >./$hostname.$command  2>&1
	fi
done

ps eauxf>./${hostname}.ps.eauxf 2>&1
ps auxww>./${hostname}.ps.auxww 2>&1

for i in a b c d 
do
	if [ -f /dev/sd$i ];then
		smartctl -a /dev/sd$i  >./${hostname}.smartctl.sd$i  2>&1
	fi
done

parameter_list1="
vvnn
kvvnn
mvvnn
tvvnn
mnn
"
for i in $parameter_list1
do
	lspci -$i>./${hostname}.lspci.$i 2>&1 
done
if which ceph >/dev/null 2>&1 ;then
    timeout 10 ceph -s >./${hostname}.ceph.s 2>&1
    timeout 10 ceph osd tree >./${hostname}.ceph.osd.tree 2>&1
    timeout 10 ceph mon dump >./${hostname}.ceph.mon.dump 2>&1
    timeout 10 ceph version >./${hostname}.ceph.version 2>&1    
    timeout 10 ceph-volume lvm list >./${hostname}.ceph-volume.lvm.list 2>&1
fi

if which auditctl >/dev/null 2>&1 ;then
    auditctl -l >./${hostname}.auditctl.l 2>&1
fi
systemctl status vdsmd.service  >./${hostname}.vdsmd.service.status 2>&1
systemctl status nfs-kernel-server.service  >./${hostname}.nfs-kernel-server.service.status 2>&1
systemctl status mysql.service  >./${hostname}.mysql.service.status 2>&1
/etc/init.d/tomcat9 status >./${hostname}.tomcat9.status 2>&1
ENGINEPATH=/opt/apache-tomcat-9.0.44/webapps/ROOT/cloudDesktopPackage

if [ -n "$ENGINEPATH/edition.xml" ];then
    cat "$ENGINEPATH/edition.xml" >./${hostname}.engine.version 2>&1
fi

if which lscpu >/dev/null 2>&1 ;then
	lscpu >./${hostname}.lscpu 2>&1
	lscpu -p >./${hostname}.lscpu.-p 2>&1
fi

for i in `seq 0 4`
do
	if which smartctl >/dev/null 2>&1
	then
		smartctl -a -d megaraid,$i /dev/sda >./${hostname}.smartctl.-a.-d.megarai.$i.sda 2>&1
	fi
done

ldconfig -p > ./${hostname}.ldconfig.-p  2>&1
df -h >./${hostname}.df.-h 2>&1
df -Th > ./${hostname}.df.-Th 2>&1
df -ih >./${hostname}.df.-ih 2>&1
du -sh /var/spool/postfix/maildrop >./${hostname}.du.sh.var.spool.postfix.maildrop 2>&1

hwclock -r >./${hostname}.hwclock.-r 2>&1
grep -i commit /proc/meminfo >./${hostname}.CommitLimit-Committed_AS 2>&1
grep -i -A2 -B2 -i "Machine check events logged" /var/log/kern* >./${hostname}.var.log.kern.MCE 2>&1
grep -i -A2 -B2 -i "Machine check events logged" /var/log/old/kern* >./${hostname}.var.log.old.kern.MCE 2>&1
last -i >./${hostname}.last.-i.wtmp 2>&1
last -i -f /var/log/btmp >./${hostname}.last.-i.btmp 2>&1

echo "30% collected"

###get_ipmi_info###
get_ipmi_info(){
	if which ipmitool >/dev/null 2>&1 ;then
		ipmitool -I open sel list>./${hostname}.ipmitool.i.open.sel.list   2>&1
		ipmitool -I open sel elist>./${hostname}.ipmitool.i.open.sel.elist   2>&1
		ipmitool -I open sdr>./${hostname}.ipmitool.i.open.sdr  2>&1
		ipmitool -I open sensor list>./${hostname}.ipmitool.i.open.sensor.list 2>&1
		ipmitool -I open chassis restart_cause>./${hostname}.ipmitool.i.open.chassis.restart_cause  2>&1
		ipmitool -I open chassis policy list>./${hostname}.ipmitool.i.open.chassis.policy.list 2>&1
	fi
}
lsmod |grep ipmi >/dev/null 2>&1
if [ $? -ne 0 ];then
	dmidecode |grep -i 'ipmi' >/dev/null 2>&1
	if [ $? -eq 0 ];then
	        modprobe ipmi_devintf >/dev/null 2>&1
	        modprobe ipmi_msghandler >/dev/null 2>&1
	        modprobe ipmi_poweroff >/dev/null 2>&1
	        modprobe ipmi_si >/dev/null 2>&1
	        modprobe ipmi_watchdog >/dev/null 2>&1
			get_ipmi_info
			rmmod ipmi_watchdog >/dev/null 2>&1
            rmmod ipmi_poweroff >/dev/null 2>&1
            rmmod ipmi_devintf >/dev/null 2>&1
            rmmod ipmi_si >/dev/null 2>&1
            rmmod ipmi_msghandler >/dev/null 2>&1
	fi
else
	get_ipmi_info
fi


if  ifconfig | grep -q bond  ;then
    if ifconfig | grep -q 'inet addr';then
        IP=`ifconfig bond0|grep 'inet addr'|awk -F: '{print $2}'|awk '{print $1}'`
    else
        IP=`ifconfig bond0|grep inet|grep -v inet6 |awk  '{print $2}'` 
    fi
    arp-scan -I bond0 -l >./${hostname}.arp-scan.-I.bond0.-l 2>&1
    arping -I bond0 -c 3 -f -D ${IP} >./${hostname}.arping.-I.bond0.-c.3.-f.-D.bond0_IP 2>&1
fi

#append history into ~root/.bash_history or ~sysadmin/.bash_history
history -a
#clear history
history -c
#read ~root/.bash_history or ~sysadmin/.bash_history
history -r
#将~root/.bash_history文件中的unix时间格式转换成可正常显示的格式并保存到./${hostname}.history.root文件中
[ -f ~root/.bash_history ] && (perl -pe 's/#(\d+)/"#".localtime($1)/e' ~root/.bash_history)>./${hostname}.history.root
#将~sysadmin/.bash_history文件中的unix时间格式转换成可正常显示的格式并保存到./${hostname}.history.sysadmin文件中
[ -f ~sysadmin/.bash_history ] && (perl -pe 's/#(\d+)/"#".localtime($1)/e' ~sysadmin/.bash_history)>./${hostname}.history.sysadmin

[ -d .history_log ] || mkdir .history_log
for user in {d5000,ems,oms}
do
    if `grep -q ${user} /etc/passwd` && [ -f ~${user}/.history_log ] ;then
        timeout 5 su - ${user} -c "history -M;history -S"
        mkdir .history_log/${user}
        for filename in `ls ~${user}/.history_log`
        do
            (perl -pe 's/#(\d+)/"#".localtime($1)/e' ~${user}/.history_log/${filename})>.history_log/${user}/${filename}.bak
            mv .history_log/${user}/${filename}.bak  .history_log/${user}/${filename}
        done
        chown -R ${user}.${user} .history_log/${user}
    fi
done

id root   >/dev/null 2>&1
if [ $? -eq 0 ];then
	mkdir .history_log/root
    if [ -d "~root/.history_log" ] ;then
    	for filename in `ls ~root/.history_log`
    	do
    		cp ~root/.history_log/${filename} .history_log/root/${filename}
    	done
    fi
	chown -R root.root .history_log/root 
fi

id kingsoft >/dev/null 2>&1
if [ $? -eq 0 ];then
	timeout 5 su - kingsoft -c "history -a;history -c;history -r"
	(perl -pe 's/#(\d+)/"#".localtime($1)/e' ~kingsoft/.bash_history)>./${hostname}.history.kingsoft
fi

if which numactl  >/dev/null 2>&1 ;then
	numactl --show >./${hostname}.numactl.--show 2>&1
	numactl --hardware >./${hostname}.numactl.--hardware 2>&1
fi
# LVM设备信息
if which dmsetup  >/dev/null 2>&1 ;then
    dmsetup ls --tree >./${hostname}.dmsetup.ls.tree 2>&1
    dmsetup info >./${hostname}.dmsetup.info 2>&1
    dmsetup deps >./${hostname}.dmsetup.deps 2>&1
fi
if which tree  >/dev/null 2>&1 ;then
    tree -l -L 100 /sys/block/ >./${hostname}.tree.l.L.100.sys.block 2>&1
fi
for i in `ls /sys/block/`
do
    echo /sys/block/${i}/queue/scheduler
    cat /sys/block/${i}/queue/scheduler
done >./${hostname}.dev.scheduler 2>&1
ls -l -R /dev/ >>./${hostname}.ls.l.R.dev 2>&1

echo "40% collected"
lspci -vvnn |egrep -i "1002:68a9" >/dev/null 2>&1
if [ $? -ne 0 ];then
	timeout 10 lshw>./${hostname}.lshw 2>&1
else
	cat /dev/null > ./${hostname}.lshw 2>&1
fi
which linxnethatool >/dev/null 2>&1 && linxnethatool version >./${hostname}.linxnethatool.version
which pkginfo >/dev/null 2>&1 && pkginfo -i > ./${hostname}.pkginfo.-i  2>&1
which dpkg >/dev/null 2>&1 && dpkg -l > ./${hostname}.dpkg.-l  2>&1
which dnf > /dev/null 2>&1 && dnf list installed > ./${hostname}.dnf.installed 2>&1
which rpm >/dev/null 2>&1 && rpm -qa > ./${hostname}.rpm.-qa 2>&1
which fc-list >/dev/null 2>&1 && fc-list > ./${hostname}.fc-list  2>&1
fdisk -l >./${hostname}.fdisk.-l 2>&1
iptables -nL >./${hostname}.iptables.-nL 2>&1
iptables -t nat -nL >./${hostname}.iptables.-t.nat.-nL  2>&1
#日志权限
lsattr    /var/log/*  > ./${hostname}.lsattr.var.log
timeout 10 parted  -l >./${hostname}.parted.-l 2>&1  

top -bn1 -H >./${hostname}.top.-bn1.-H 2>&1
top -n 2 -b >./${hostname}.top.-n.2.-b 2>&1
uptime >./${hostname}.uptime 2>&1
#vmstat 1 10 >./${hostname}.vmstat.1_10
uname -a >./${hostname}.uname.-a 2>&1

echo "50% collected"
which crm >/dev/null 2>&1
if [ $? -eq 0 ];then
	crm configure show>./${hostname}.crm.configure.show 2>&1
	crm_mon -1>./${hostname}.crm_mon.-1 2>&1
	crm status>./${hostname}.crm.status 2>&1
	timeout 10 corosync-cfgtool -s >./${hostname}.corosync-cfgtool.-s 2>&1 #网络异常将引起命令执行卡顿
fi

which upadm >/dev/null 2>&1  && upadm show version >./${hostname}.huawei.upadm.show.version  2>&1
which multipath >/dev/null 2>&1  && multipath -ll >./${hostname}.multipath-ll  2>&1
which multipath >/dev/null 2>&1  && multipath -v6 >./${hostname}.multipath-v6  2>&1

lsmod |grep -i "os_sec" >./${hostname}.lsmod.kxht.module.name  2>&1
timeout 10 sysctl -a>./${hostname}.sysctl.-a  2>&1
ulimit -a>./${hostname}.ulimit.-a  2>&1

if id d5000 >/dev/null 2>&1;then
	timeout 10 lsof +c 0 >./${hostname}.lsof  2>&1
	timeout 10 lsof |grep d5000|awk '{print $2}'|uniq|wc -l >./${hostname}.d5000.running.nproc  2>&1
	timeout 5 su - d5000 -c limit>./${hostname}.d5000.su.-d5000.-c.limit  2>&1
	timeout 5 su - d5000 -c "echo $DISPLAY">./${hostname}.d5000.su.-d5000.-c.echo.DISPLAY  2>&1
	crontab -u d5000 -l>./${hostname}.var.spool.cron.crontabs.d5000 2>&1
	ps -u d5000 --sort minflt > ./${hostname}.ps.-u.d5000.sort.minflt 2>&1
    ps -f -u d5000 >./${hostname}.ps.-f.-u.d5000
    timeout 10 lsof -u d5000  >./${hostname}.lsof.-u.d5000 2>&1
fi

echo "60% collected"
which faillog >/dev/null 2>&1 && faillog -a > ./${hostname}.faillog.-a  2>&1
which faillock >/dev/null 2>&1 && faillock > ./${hostname}.faillock 2>&1
netstat -anp>./${hostname}.netstat.-anp 2>&1
netstat -antp>./${hostname}.netstat.-antp 2>&1

iostat -d -x -k 1 10 > ./${hostname}.iostat.-d.-x.-k.1-10
iostat -d -x -k 1 2 |awk '{if ($0 ~ "Device")a++}{if (a >= 2)print}' >./${hostname}.iostat.-d.-x.-k.1-2
sar -n DEV 1 10 > ./${hostname}.sar.-n.DEV.1.10
sar -d -p 1 3  > ./${hostname}.sar.-d.-p.1.3
mysql --version >./${hostname}.mysql.version 2>&1
chkconfig --list  >  ./${hostname}.chkconfig  2>&1
systemctl list-unit-files >  ./${hostname}.systemctl.list.unit  2>&1

ps axu >./${hostname}.ps.aux 2>&1

ps auxww|grep -i "os_master">./${hostname}.ps.auxww.kxht.process.name 2>&1
ps auxww|sort -k 3 -r -n>./${hostname}.ps.auxww.cpu_load_high_low 2>&1
ps auxww|sort -k 4 -r -n>./${hostname}.ps.auxww.mem_percent_greater_less 2>&1
ps auxww|sort -k 5 -r -n>./${hostname}.ps.auxww.mem_virtual_greater_less 2>&1
ps auxww|sort -k 6 -r -n>./${hostname}.ps.auxww.mem_physical_greater_less 2>&1

ps -efL>./${hostname}.ps.-efL  2>&1
ps -eo pid,args:50,psr>./${hostname}.ps.-eo.pid.args.psr  2>&1
ps -eo 'pid,ppid,%cpu,command' |sort -k 3 > ./${hostname}.ps.-eo.pid.ppid.cpu.command 2>&1
ps -eo 'pid,ppid,%mem,command' |sort -k 3 > ./${hostname}.ps.-eo.pid.ppid.mem.command 2>&1
ps -eo 'pid,ppid,stat,command' |awk '{if($3 ~ "Z") print $0}' > ./${hostname}.ps.-eo.pid.ppid.stat.command.Z 2>&1
ps -eo 'pid,ppid,stat,command' |awk '{if($3 ~ "D") print $0}' > ./${hostname}.ps.-eo.pid.ppid.stat.command.D 2>&1

ps -o majflt,minflt -C program >./${hostname}.ps.-o.majflt.minflt.-C.program 2>&1
ps -oe minflt,rss,pmem,pcpu,args,user,etime > ./${hostname}.ps.-eo.minflt.rss.pcpu 2>&1
ps -u root  --sort minflt > ./${hostname}.ps.-u.root.sort.minflt 2>&1
pstree >./${hostname}.pstree  2>&1
ifconfig -a>./${hostname}.ifconfig.-a 2>&1
route -n >./${hostname}.route 2>&1
ip route show>./${hostname}.ip.route.show 2>&1 
ip a >./${hostname}.ip.a 2>&1
timeout 10 ntpq -np>./${hostname}.ntpq.-np  2>&1
timeout 10 ntpdc -np>./${hostname}.ntpdc.-np 2>&1

echo "70% collected"
if which megacli >/dev/null 2>&1 ;then
	#get megaraid's message
	#查raid级别
	megacli -LDInfo -Lall -aALL>./${hostname}.megacli.-LDInfo.-Lall.-aALL 2>&1
	#查raid卡信息
	megacli -AdpAllInfo -aALL>./${hostname}.megacli.-AdpAllInfo.-aALL 2>&1
	#显示所有的物理磁盘信息
	megacli -PDList -aALL>./${hostname}.megacli.-PDList.-aALL 2>&1
	#查看电池信息
	megacli -AdpBbuCmd  -aALL>./${hostname}.megacli.-AdpBbuCmd.-aALL 2>&1
	#查看raid卡日志
	megacli -FwTermLog -Dsply  -aALL>./${hostname}.megacli.-FwTermLog.-Dsply.-aALL 2>&1
	#查看显示适配器个数
	megacli -adpCount>./${hostname}.megacli.adpCount 2>&1
	#查看显示适配器时间
	megacli -AdpGetTime -aALL>./${hostname}.megacli.AdpGetTime.-aALL 2>&1
	#显示所有适配器信息
	megacli -AdpAllInfo -aALL>./${hostname}.megacli.AdpAllInfo.-aALL 2>&1
	#显示所有逻辑磁盘组信息
	megacli -LDInfo -LALL -aALL>./${hostname}.megacli.-LDInfo.LALL.-aALL 2>&1
	#查看充电状态
	megacli -AdpBbuCmd -GetBbuStatus -aALL|grep 'Charger Status'>./${hostname}.megacli.-AdpBbuCmd.-GetBbuStatus.-aALL-grep-Charger_Status 2>&1
	#显示BBU状态信息
	megacli -AdpBbuCmd -GetBbuStatus -aALL>./${hostname}.megacli.-AdpBbuCmd.-GetBbuStatus.-aALL 2>&1
	#显示BBU容量信息
	megacli -AdpBbuCmd -GetBbuCapacityInfo -aALL>./${hostname}.megacli.-AdpBbuCmd.-GetBbuCapacityInfo.-aALL 2>&1
	#显示BBU设计参数
	megacli -AdpBbuCmd -GetBbuDesignInfo -aALL>./${hostname}.megacli.-AdpBbuCmd.-GetBbuDesignInfo.-aALL 2>&1
	#显示当前BBU属性
	megacli -AdpBbuCmd -GetBbuProperties -aALL>./${hostname}.megacli.-AdpBbuCmd.-GetBbuProperties.-aALL 2>&1
	#显示Raid卡型号，Raid设置，Disk相关信息
	megacli -cfgdsply -aALL>./${hostname}.megacli.-cfgdsply.-aALL 2>&1
	#显示mega Raid卡的Cache Policy,在没有电池（BBU），是否打开了Write Cache
	megacli -LDGetProp -Cache -Lall -aALL>./${hostname}.megacli.-LDGetProp.-Cache.-Lall.-aALL 2>&1
fi

if which sas2ircu >/dev/null 2>&1 ; then
	sas2ircu LIST >./${hostname}.sas2ircu.LIST   2>&1
	sas2ircu 0 DISPLAY >./${hostname}.sas2ircu.0.DISPLAY 2>&1 
fi

echo "80% collected"
modprobe sg 2>/dev/null 
ls /dev/sg* >./${hostname}.ls.dev.sgn 2>&1
if [ $? -eq 0 ] ;then
    SGX=$(ls -al /dev/sg*|wc -l)
    for ((i=0;i<$SGX;i++))
    do
    	timeout 10 smartctl -a /dev/sg$i >./${hostname}.smartctl.-a.dev.sg$i  2>&1
    done
fi

lsmod |grep -v Module|awk '{ print $1 }'| while read MODNAME
do
	modinfo ${MODNAME} >./${hostname}.modinfo.${MODNAME} 2>&1
done

#wmli@linx-info.com,2013-05-20,get disk parameter
DISK=$(fdisk -l 2>/dev/null|grep Disk|grep dev|awk -F':' '{print $1}'|awk '{print $NF}' )
DF=$(hostname).Diskinfo
echo 'DiskInfo' > $DF
echo "======================================================" >> $DF  2>&1
if [ $(which hdparm)  ];then
	for i in $DISK
	do
		echo -n "$i " >> $DF  2>&1
		echo "$(hdparm -I $i 2>/dev/null|grep 'device size with M = 1000\*1000:'|awk '{print $(NF-1),$NF}')" >> $DF   2>&1
		echo "$(hdparm -I $i 2>/dev/null|grep 'Model Number:')" >>  $DF  2>&1
		echo "$(hdparm -I $i 2>/dev/null|grep 'Serial Number:')" >>  $DF 2>&1
		echo "$(hdparm -I $i 2>/dev/null|grep 'Transport:')"  >>  $DF  2>&1
		echo "$(hdparm -I $i 2>/dev/null|grep 'Form Factor:')" >>  $DF 2>&1
		echo "$(hdparm -I $i 2>/dev/null|grep 'Nominal Media Rotation Rate: 7200')" >>   $DF  2>&1
		echo "------------------------------------------------------">> $DF  2>&1
	done
else
	echo "hdparm: command not found!">>${DF}
fi

echo "90% collected"
#The use of statistical swap partition
cd /proc
for pid in [0-9]*; do
    command=$(cat -e /proc/$pid/cmdline 2>/dev/null |awk -F'^' '{print $1}')
    swap=$(
        awk '
            BEGIN  { total = 0 }
            /Swap/ { total += $2 }
            END    { print total }
        ' /proc/$pid/smaps 2>/dev/null
    )
    if [[ "${head}" != "yes" ]]; then
	    echo -e "PID\tSWAP\tCOMMAND" >> /tmp/$(hostname)/${hostname}.swap_use.txt 2>/dev/null
            head="yes"
    fi
    echo -e "${pid}\t${swap}\t${command}">> /tmp/$(hostname)/${hostname}.swap_use.txt 2>/dev/null
done

less /tmp/${hostname}/${hostname}.swap_use.txt|grep -v SWAP|sort -k 2 -r -n > /tmp/$(hostname)/${hostname}.swap_greater_less

# get mcelog'message
if which mcelog >/dev/null 2>&1 ;then
	mcelog  --help 2>&1 | grep -i "Valid CPUs" > /tmp/${hostname}/${hostname}.mcelog.hlp 2>&1
	[ -f /tmp/${hostname}/${hostname}.mcelog.hlp ] && less /tmp/${hostname}/${hostname}.mcelog.hlp |grep -i "valid cpus:"|awk -F":" '{print $2}'>/tmp/${hostname}/${hostname}.mcelog.cpu
	cat /dev/null > /tmp/${hostname}/${hostname}.mcelog.txt
	for i in  $(cat /tmp/${hostname}/${hostname}.mcelog.cpu)
	do    
		mcelog --cpu $i --syslog | tee -a /tmp/${hostname}/${hostname}.mcelog.txt 2>&1
	done
else
	echo "no command mcelog" > /tmp/${hostname}/${hostname}.mcelog.txt
fi
somelog(){
    log_file=`find /var/log/ -type f | egrep -v "."[0-9]"$|.gz$"`
    for name in `echo $log_file`
    do
        name2=`echo $name | sed 's/\//./g'`
        tail -160000 $name >/tmp/$(hostname)/${hostname}${name2}.160000
    done
}
if [ "x$1" = "x-alllog" ];then
    LOG_size=`du -sh /var/log/ |awk  '{print $1}' | grep G | awk -F' |G' '{print $1}'`
    if [ "x${LOG_size}" != "x" ] ;then
        if [ `echo "$LOG_size >= 50"|bc` -eq 1 ];then
            somelog
            echo -e "\e[31m /var/log oversize, please manual collect  . \e[0m"
        else
            GZ_file_size=`find /var/log/ -name "*.gz" |xargs du -ch | tail -n 1 |grep G |awk -F ' |G' '{print $1}'`
            if [ "x${GZ_file_size}" != "x" ] ;then
                if [ `echo "${GZ_file_size} >= 5"|bc` -eq 1 ];then
                    somelog
                    echo -e "\e[31m /var/log oversize, please manual collect  . \e[0m"
                else
                    tar czf /tmp/$(hostname)/${hostname}.var.log.tgz -C  /  var/log 2>/dev/null
                fi
            else
                tar czf /tmp/$(hostname)/${hostname}.var.log.tgz -C  /  var/log 2>/dev/null
            fi
        fi
    else
        tar czf /tmp/$(hostname)/${hostname}.var.log.tgz -C  /  var/log 2>/dev/null
    fi
elif [ "x$1" = "x-somelog" ];then
    somelog
fi

echo "100% collected"
#Generated compression package
cd /tmp
if [ -f ./${hostname}*.tgz  ] ;then
    rm ./${hostname}*.tgz
fi

#提取系统序列号
serialFileList="
/etc/default/grub
/boot/grub/grub.cfg
/boot/grub/grub.conf
"
for file in $serialFileList
do
	if test -f $file && grep -q "linx_serial=" $file;then
		serial=$(awk -F'linx_serial=' '/linx_serial/{print $2}' $file | cut -d' ' -f 1 | uniq) 
		if [ -n $serial ];then
			break
		fi
	fi
done

tar czf /tmp/${hostname}.${serial:=null}.${DATE}.tgz  -C  /  tmp/${hostname}
#删除收集目录
if [ -d /tmp/${hostname} ];then
	rm -rf /tmp/${hostname}
fi

export LANG=zh_CN.utf-8
tar_name=/tmp/${hostname}.${serial:=null}.${DATE}.tgz
chmod 644 $tar_name
if [ -f ${tar_name} ];then
    echo -e "\033[32m Collection success \033[0m file name: $tar_name " 
else
    echo -e " \033[31m Collection failed \033[0m"
fi
