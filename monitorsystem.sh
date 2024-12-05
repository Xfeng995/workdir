#!/bin/bash
#
# author: Hyf
# time: 2024-11-27
#

# 设置监控日志文件的路径
LOG_FILE="/var/log/system_monitor.log"

# 获取当前日期和时间
current_time=$(date +"%Y-%m-%d %H:%M:%S")

# 分割线
Line_break="-----------------------------------------------------------"

# 写入日志文件头部信息
echo "${current_time}System Resource Monitoring Log" >> $LOG_FILE
echo "${Line_break}" >> $LOG_FILE
echo $current_time >> $LOG_FILE
echo "${Line_break}" >> $LOG_FILE

# 获取内存使用情况
echo "Memory Usage:            at ${current_time}" >> $LOG_FILE
free -m >> $LOG_FILE
echo "${Line_break}" >> $LOG_FILE

# 获取CPU使用率
echo "CPU Usage:            at ${current_time}" >> $LOG_FILE
mpstat -P ALL 1 1 >> $LOG_FILE
echo "${Line_break}" >> $LOG_FILE

# 获取CPU占用率最高的前10个进程
echo "Top 10 CPU consuming processes:            at ${current_time}" >> $LOG_FILE
ps -eo pid,comm,%cpu,%mem | grep -v PID | sort -k7,7nr | head -n 10 >> $LOG_FILE
echo "${Line_break}" >> $LOG_FILE

# 获取指定目录的磁盘空间使用情况
echo "/Directory Disk Space Usage:            at ${current_time}" >> $LOG_FILE
df -hP / >> $LOG_FILE
echo "${Line_break}" >> $LOG_FILE

# 获取进程CPU和内存使用排行
echo "Process CPU and Memory Usage Ranking:            at ${current_time}" >> "$LOG_FILE"
ps -eo pid,user,%cpu,%mem,command --sort=-%cpu | head -10 >> "$LOG_FILE"
echo "${Line_break}" >> "$LOG_FILE"
ps -eo pid,user,%cpu,%mem,command --sort=-%mem | head -10 >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 获取线程使用情况
echo "Thread Usage:            at ${current_time}" >> "$LOG_FILE"
top -b -n1 | grep "Threads" | awk '{print $2}' >> "$LOG_FILE"

echo "${Line_break}" >> $LOG_FILE
# 获取僵尸进程和孤儿进程的数量
echo "Zombie and Orphan Process Count:            at ${current_time}" >> "$LOG_FILE"
ps aux | grep 'Z' | wc -l >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 获取运行中的进程数
echo "Running Process Count:            at ${current_time}" >> "$LOG_FILE"
ps -e | grep -v PID | wc -l >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 获取系统负载平均值（1分钟、5分钟、15分钟）
echo "System Load Averages:            at ${current_time}" >> "$LOG_FILE"
uptime | awk -F': ' '{print $2}' >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 获取系统启动时间
echo "System Boot Time:            at ${current_time}" >> "$LOG_FILE"
last reboot |head -1 >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 获取系统运行时间
echo "System Uptime:            at ${current_time}" >> "$LOG_FILE"
uptime  >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 获取磁盘I/O统计（读/写速度、IOPS）
echo "Disk I/O Statistics:            at ${current_time}" >> "$LOG_FILE"
iostat -kx >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 获取磁盘队列长度
echo "Disk Queue Length:            at ${current_time}" >> "$LOG_FILE"
iostat -d -x >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 获取文件系统inode使用情况
echo "Filesystem Inode Usage:            at ${current_time}" >> "$LOG_FILE"
df -iP >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 获取磁盘SMART状态
echo "Disk SMART Status:            at ${current_time}" >> "$LOG_FILE"
smartctl -a /dev/sda >> "$LOG_FILE"
echo "${Line_break}" >> $LOG_FILE

# 循环每3秒钟采集一次数据
#while true
#do
#    sleep 3
#    # 重复上述监控操作，将结果追加到日志文件中
#    # 这里省略了重复的监控代码，以保持简洁
#done
