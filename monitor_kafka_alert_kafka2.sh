#!/bin/bash

# 颜色
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

# 临时文件
tmpfile=/tmp/kafka_info_tmp_kafka2.txt

declare -A kafka_consumer

function mkafka2()
{
    /home/nari/kafka_2.11-0.10.1.1/bin/kafka-consumer-groups.sh --bootstrap-server ah2clt1:9092,ah2clt2:9092 -describe --group group_consumer_new2
}
function mkafka1()
{
    /home/nari/kafka_2.11-0.10.1.1/bin/kafka-consumer-groups.sh --bootstrap-server ah1clt1:9092,ah1clt2:9092 -describe --group group_consumer_new
}
mkafka2 |awk 'NR>1 {print $2,$6}' |grep -v unknown >${tmpfile}

while read -r topic number
do
kafka_consumer["$topic"]="$number"
done <  ${tmpfile}


for key in "${!kafka_consumer[@]}";do
    printf "主题名:%-20s 积压数:%s\n" "${key}" "${kafka_consumer[$key]}"
    let num=${kafka_consumer[$key]}
    echo $num
    if [[ ${num} -gt 1000 ]];then
        messages="二区kafka总线存在积压\n主题:${key},积压消息数:${kafka_consumer[$key]}"
        zenity --error --text="${messages}" --timeout=5
    elif [[ ${num} -gt 100 ]];then
        messages="二区kafka总线存在积压\n主题:${key},积压消息数:${kafka_consumer[$key]}"
        zenity --warning --text="${messages}" --timeout=5
    elif [[ ${num} -gt 10 ]];then
        messages="二区kafka总线存在积压\n主题:${key},积压消息数:${kafka_consumer[$key]}"
        zenity --info --text="${messages}" --timeout=5
    fi
done
