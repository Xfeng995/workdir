seq -f "%g" 1 65535 |\
xargs -I {} -P 1000 -n 1 \
sh -c 'nc -z -w 1 192.168.100.188 {} \
&& echo "Port {} on 192.168.100.188 is open" \
|| echo "Port {} on 192.168.100.188 is close"'
