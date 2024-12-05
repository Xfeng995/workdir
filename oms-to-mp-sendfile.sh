#!/bin/bash -e

#  调试开关，on表示开启，其他表示关闭
IS_DEBUG="off"
#  调试开关函数
function IS_DEBUG()
{
    [ "$IS_DEBUG" == "on" ] && $@
}

#  判断函数;上一条命令是否执行成功
function _EXEC()
{
    [ $? == 0 ] && $@
}

#  获取程序的当前路径
CURRENT_DIR="$(cd "$(dirname "$0")";pwd)"
IS_DEBUG  echo $CURRENT_DIR


# 设置相关变量
looptime=1
srcdir='/home/feng/exchange32/'
dstdir='/home/feng/exchange32_dst'
bakdir='/home/feng/exchange32_bak'
MaxFile=102400
username='feng'
passwd='ahdl123!@#'


function logtofile()
{
	echo "$(date) $1 ：$2"
	echo "$(date) $1 ：$2" >> ${CURRENT_DIR}/oms-to-mp-sendfile.log

}

# scp传输文件函数
function scpfile()
{
	#sshpass -p 'ahdl123!@#' scp -r ${srcdir}$1 feng@localhost:${dstdir}
	sshpass -p ${passwd} scp -r ${srcdir}$1 ${username}@localhost:${dstdir}
}

# 文件备份函数：传输完成的文件mv 到备份目录下
function bakfile()
{
	mv ${srcdir}$1 ${dstdir}
}

function clearlog()
{
    filesize=`du -k $CURRENT_DIR/oms-to-mp-sendfile.log| awk '{print $1}'`
    if [ $filesize -gt $MaxFile ];then
	echo '' > $CURRENT_DIR/oms-to-mp-sendfile.log
    fi
}


# 获取待发送目标文件
function processfile()
{
for loopfile in $(ls  ${srcdir} |grep -E '^oms-.*-.*.txt$')
do
	echo "$srcdir$loopfile"
	scpfile $loopfile
	_EXEC logtofile $loopfile "文件已发送完成！"
	_EXEC bakfile $loopfile
	_EXEC logtofile $loopfile "文件移动到备份目录"
done
}



while true
do
	omsfilenum=$(ls /home/feng/exchange32/ |grep -E '^oms-.*-.*.txt$' |wc -l)
	if [[ ${omsfilenum} -gt 0 ]];then
		processfile
	else
		echo "$(date) 未检测到模型文件！"
		echo "$(date) 未检测到模型文件！" >> ${CURRENT_DIR}/oms-to-mp-sendfile.log
	fi

	clearlog

	sleep ${looptime}
done
