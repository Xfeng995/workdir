seq -f "%g" 1 255 |\
xargs -I {} -P 100 -n 1 \
sh -c 'nc -z -w 1 192.168.100.{} 22 \
&& echo "Port 22 on 192.168.100.{} is open" \
|| echo "Port 22 on 192.168.100.{} is close"'