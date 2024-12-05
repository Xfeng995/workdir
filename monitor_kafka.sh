#!/bin/bash

# 颜色
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)


function monitorkafka2()
{
    /home/nari/kafka_2.11-0.10.1.1/bin/kafka-consumer-groups.sh --bootstrap-server ah2clt1:9092,ah2clt2:9092 -describe --group group_consumer_new2
}
function monitorkafka1()
{
    /home/nari/kafka_2.11-0.10.1.1/bin/kafka-consumer-groups.sh --bootstrap-server ah1clt1:9092,ah1clt2:9092 -describe --group group_consumer_new
}
echo "$(date)                       ****一区kafka堆积情况"****
echo ""
monitorkafka1 |awk '$6 !~ "unknown" && $6 > 20 {print}'
echo ""
echo ""
echo ""
echo ""

echo "$(date)                       ****二区kafka堆积情况"****
echo ""
monitorkafka2 |awk '$6 !~ "unknown" && $6 > 20 {print}'
