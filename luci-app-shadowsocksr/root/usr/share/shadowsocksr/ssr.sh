#!/bin/sh 
# Copyright (C) 2017 yushi By Alx
# Licensed to the public under the GNU General Public License v3.
#



SERVICE_DAEMONIZE=1
NAME=shadowsocksr
EXTRA_COMMANDS=rules
CONFIG_FILE=/var/etc/${NAME}.json
CONFIG_UDP_FILE=/var/etc/${NAME}_u.json
CONFIG_SOCK5_FILE=/var/etc/${NAME}_s.json
server_count=0
redir_tcp=0
redir_udp=0
tunnel_enable=0
local_enable=0
kcp_enable_flag=0
kcp_flag=0
gfw_enable=0
dns_enable_flag=0
switch_enable=1
switch_server=$2
SERVER_TYPE=""
V2RAY_CONFIG_FILE_TMP=/tmp/v2ray_tmp.json
V2RAY_CONFIG_FILE=/tmp/v2ray/v2ray.json
game_mode=`cat /etc/config/shadowsocksr | grep gm`
uci_get_by_name() {
	local ret=$(uci get $NAME.$1.$2 2>/dev/null)
	echo ${ret:=$3}
}

uci_get_by_type() {
	local ret=$(uci get $NAME.@$1[0].$2 2>/dev/null)
	echo ${ret:=$3}
}



get_ws_header() {
	if [ -n "$1" ];then
		echo {\"Host\": \"$1\"}
	else
		echo "null"
	fi
}

get_h2_host() {
	if [ -n "$1" ];then
		echo [\"$1\"]
	else
		echo "null"
	fi
}

get_path(){
	if [ -n "$1" ];then
		echo \"$1\"
	else
		echo "null"
	fi
}
get_function_switch() {
	case "$1" in
		0)
			echo "false"
		;;
		1)
			echo "true"
		;;
	esac
}
get_v2ray(){
	net_work="echo `curl -I -o /dev/null -s -m 10 --connect-timeout 2 -w %{http_code} 'http://www.baidu.com'`|grep 200"
	i=120
	until [ "$net_work" != "200" ]
	do
	i=$(($i-1))
	if [ "$i" -lt 1 ];then		
		echo "网络超时!"
		exit 0
	fi
	sleep 1
	net_work="echo `curl -I -o /dev/null -s -m 10 --connect-timeout 2 -w %{http_code} 'http://www.baidu.com'`|grep 200"
	done

	[ ! -d "/tmp/v2ray/" ] && mkdir /tmp/v2ray

	if [ ! -f "/tmp/v2ray/v2ray" ];then
		wget --no-check-certificate -O- http://opt.cn2qq.com/opt-file/v2ray > /tmp/v2ray/v2ray 
		[ "$?" != "0" ] && exit 0
	fi
	if [ ! -f "/tmp/v2ray/v2ctl" ];then
		wget --no-check-certificate -O- http://opt.cn2qq.com/opt-file/v2ctl > /tmp/v2ray/v2ctl 
		[ "$?" != "0" ] && exit 0
	fi

	chmod +x /tmp/v2ray/*

}

creat_v2ray_json(){
	rm -rf "$V2RAY_CONFIG_FILE_TMP"
	rm -rf "$V2RAY_CONFIG_FILE"
	rm -rf /tmp/v2ray.pb
		echo 生成V2Ray配置文件...
		local kcp="null"
		local tcp="null"
		local ws="null"
		local h2="null"
		local tls="null"

		# tcp和kcp下tlsSettings为null，ws和h2下tlsSettings
		v2ray_security=$(uci_get_by_name $GLOBAL_SERVER security)
		[ "$v2ray_security" == "none" ] && local v2ray_security=""
		
			case "$v2ray_security" in
				tls)
					local tls="{
					\"allowInsecure\": true,
					\"serverName\": null
					}"
				;;
				*)
					local tls="null"
				;;
			esac
		
		v2ray_transport_host=$(uci_get_by_name $GLOBAL_SERVER v2_host)
		if [ "`echo $v2ray_transport_host | grep ","`" ];then
			v2ray_transport_host=`echo $v2ray_transport_host | sed 's/,/", "/g'`
		fi
		v2ray_transport=$(uci_get_by_name $GLOBAL_SERVER transport)
		v2ray_headtype_tcp=$(uci_get_by_name $GLOBAL_SERVER tcp_guise)
		v2ray_path=$(uci_get_by_name $GLOBAL_SERVER v2_path)
		v2ray_mkcp=$(uci_get_by_name $GLOBAL_SERVER kcp_guise)
		server=$(get_server_ip $(uci_get_by_name $GLOBAL_SERVER server))
		echo "server:"$server

		case "$v2ray_transport" in
			tcp)
				if [ "$v2ray_headtype_tcp" == "http" ];then
					local tcp="{
					\"connectionReuse\": true,
					\"header\": {
					\"type\": \"http\",
					\"request\": {
					\"version\": \"1.1\",
					\"method\": \"GET\",
					\"path\": [\"/\"],
					\"headers\": {
					\"Host\": [\"$v2ray_transport_host\"],
					\"User-Agent\": [\"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36\",\"Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_2 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/53.0.2785.109 Mobile/14A456 Safari/601.1.46\"],
					\"Accept-Encoding\": [\"gzip, deflate\"],
					\"Connection\": [\"keep-alive\"],
					\"Pragma\": \"no-cache\"
					}
					},
					\"response\": {
					\"version\": \"1.1\",
					\"status\": \"200\",
					\"reason\": \"OK\",
					\"headers\": {
					\"Content-Type\": [\"application/octet-stream\",\"video/mpeg\"],
					\"Transfer-Encoding\": [\"chunked\"],
					\"Connection\": [\"keep-alive\"],
					\"Pragma\": \"no-cache\"
					}
					}
					}
					}"
				else
					local tcp="null"
				fi        
			;;
			kcp)
				local kcp="{
				\"mtu\": 1350,
				\"tti\": 50,
				\"uplinkCapacity\": 12,
				\"downlinkCapacity\": 100,
				\"congestion\": false,
				\"readBufferSize\": 2,
				\"writeBufferSize\": 2,
				\"header\": {
				\"type\": \"$v2ray_mkcp\",
				\"request\": null,
				\"response\": null
				}
				}"
			;;
			ws)
				local ws="{
				\"connectionReuse\": true,
				\"path\": $(get_path $v2ray_path),
				\"headers\": $(get_ws_header $v2ray_transport_host)
				}"
			;;
			h2)
				local h2="{
        		\"path\": $(get_path $v2ray_path),
        		\"host\": $(get_h2_host $v2ray_transport_host)
      			}"
			;;
		esac
		cat > "$V2RAY_CONFIG_FILE_TMP" <<-EOF
			{
				"log": {
					"access": "/dev/null",
					"error": "/tmp/v2ray_log.log",
					"loglevel": "error"
				},
		EOF
		if [ "$(uci_get_by_type global dns_enable)" == "5" ];then
			echo 配置v2ray dns，用于dns解析...
			cat >> "$V2RAY_CONFIG_FILE_TMP" <<-EOF
				"inbound": {
				"protocol": "dokodemo-door",
				"port": 1053,
				"settings": {
					"address": "8.8.8.8",
					"port": 53,
					"network": "udp",
					"timeout": 0,
					"followRedirect": false
					}
				},
			EOF
		else
			cat >> "$V2RAY_CONFIG_FILE_TMP" <<-EOF
				"inbound": {
					"port": 1080,
					"listen": "0.0.0.0",
					"protocol": "socks",
					"settings": {
						"auth": "noauth",
						"udp": true,
						"ip": "127.0.0.1",
						"clients": null
					},
					"streamSettings": null
				},
			EOF
		fi
		cat >> "$V2RAY_CONFIG_FILE_TMP" <<-EOF
				"inboundDetour": [
					{
						"listen": "0.0.0.0",
						"port": 1234,
						"protocol": "dokodemo-door",
						"settings": {
							"network": "tcp,udp",
							"followRedirect": true
						}
					}
				],
				"outbound": {
					"tag": "agentout",
					"protocol": "vmess",
					"settings": {
						"vnext": [
							{
								"address": "$server",
								"port": $(uci_get_by_name $GLOBAL_SERVER server_port),
								"users": [
									{
										"id": "$(uci_get_by_name $GLOBAL_SERVER vmess_id)",
										"alterId": $(uci_get_by_name $GLOBAL_SERVER alter_id),
										"security": "$(uci_get_by_name $GLOBAL_SERVER security)"
									}
								]
							}
						],
						"servers": null
					},
					"streamSettings": {
						"network": "$v2ray_transport",
						"security": "$(uci_get_by_name $GLOBAL_SERVER security)",
						"tlsSettings": $tls,
						"tcpSettings": $tcp,
						"kcpSettings": $kcp,
						"wsSettings": $ws,
						"httpSettings": $h2
					},
					"mux": {
						"enabled": $(get_function_switch $(uci_get_by_name $GLOBAL_SERVER mux 0)),
						"concurrency": 8
					}
				}
			}
		EOF
		echo 解析V2Ray配置文件...
			
		cat "$V2RAY_CONFIG_FILE_TMP" | jq --tab . > "$V2RAY_CONFIG_FILE"
		echo V2Ray配置文件写入成功到"$V2RAY_CONFIG_FILE"
	

	echo 测试V2Ray配置文件.....
	result=$(/tmp/v2ray/v2ray -test -config="$V2RAY_CONFIG_FILE" | grep "Configuration OK.")
	if [ -n "$result" ];then
		echo $result
		echo V2Ray配置文件通过测试!!!
	else
		#rm -rf "$V2RAY_CONFIG_FILE_TMP"
		#rm -rf "$V2RAY_CONFIG_FILE"
		echo V2Ray配置文件没有通过测试，请检查设置!!!
		exit 0
	fi
}

start_v2ray(){
	
	/tmp/v2ray/v2ray -config="$V2RAY_CONFIG_FILE" >/dev/null 2>&1 &
	
	local i=10
	until [ -n "$V2PID" ]
	do
		i=$(($i-1))
		V2PID=`pidof v2ray`
		if [ "$i" -lt 1 ];then
			echo "v2ray进程启动失败！"
			#close_in_five
		fi
		sleep 1
	done
	echo v2ray启动成功，pid：$V2PID
}


get_server_ip(){
	server_ip=$1
	if echo $server_ip|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$">/dev/null; then         
        	echo "${server_ip}"
	elif  [ "$host" != "${host#*:[0-9a-fA-F]}" ] ;then
		echo "${server_ip}"
        else
         	host_ip=`ping ${server_ip} -s 1 -c 1 | grep PING | cut -d'(' -f 2 | cut -d')' -f1`
         	if echo $host_ip|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$">/dev/null; then
         		echo "${host_ip}"
         	else
         		echo "${server_ip}"
         	fi
        fi


}
gen_config_file() {

	server=$(get_server_ip $(uci_get_by_name $1 server))
        [ $2 = "0" -a  $kcp_flag = "1" ] && hostip="127.0.0.1"
        if [ $2 = "0" ] ;then
        	config_file=$CONFIG_FILE
        elif [ $2 = "1" ]; then
        	config_file=$CONFIG_UDP_FILE
        else
      	  	config_file=$CONFIG_SOCK5_FILE
        fi
        if [ "$(uci_get_by_name $1 fast_open)" = "1" ] ;then
         	fastopen="true";
        else
         	fastopen="false";
        fi
	cat <<-EOF >$config_file
		{
		    
		    "server": "$server",
		    "server_port": $(uci_get_by_name $1 server_port),
		    "local_address": "0.0.0.0",
		    "local_port": $(uci_get_by_name $1 local_port),
		    "password": "$(uci_get_by_name $1 password)",
		    "timeout": $(uci_get_by_name $1 timeout 60),
		    "method": "$(uci_get_by_name $1 encrypt_method)",
		    "protocol": "$(uci_get_by_name $1 protocol)",
		    "obfs": "$(uci_get_by_name $1 obfs)",
		    "obfs_param": "$(uci_get_by_name $1 obfs_param)",
		    "fast_open": $fastopen
		}
EOF
}

get_arg_out() {
	case "$(uci_get_by_type access_control router_proxy 1)" in
		1) echo "-o";;
		2) echo "-O";;
	esac
}




start_rules() {


 	IPSET_CH="china"
	IPSET_GFW="gfwlist"
	IPSET_CHN="chnroute"
	IPSET_CDN="cdn"
	IPSET_HOME="cnhome"
	ipset -! restore  < /etc/gfwlist/cdnlist 2>/dev/null
	ipset -! create $IPSET_GFW nethash && ipset flush $IPSET_GFW
	ipset -! create $IPSET_CDN iphash && ipset flush $IPSET_CDN
	sed -e "s/^/add $IPSET_GFW &/g" /etc/gfwlist/custom | awk '{print $0} END{print "COMMIT"}' | ipset -R
	sed -e "s/^/add $IPSET_CDN &/g" /etc/gfwlist/whiteip | awk '{print $0} END{print "COMMIT"}' | ipset -R
	iptables -t nat -N SHADOWSOCKS
	iptables -t nat -I PREROUTING -p tcp -j SHADOWSOCKS
	iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
	iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
	iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
	iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
	iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
	iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
	iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
	iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN
 	[ -n "$server" ] && iptables -t nat -A SHADOWSOCKS -d $server -j RETURN
	iptables -t nat -N SHADOWSOCKS_GLO
	iptables -t nat -A SHADOWSOCKS_GLO -p tcp -j REDIRECT --to 1234
	iptables -t nat -N SHADOWSOCKS_GFW
	iptables -t nat -A SHADOWSOCKS_GFW -p tcp -m set --match-set $IPSET_GFW dst -m set ! --match-set $IPSET_CDN dst -j REDIRECT --to 1234
	iptables -t nat -N SHADOWSOCKS_CHN
	iptables -t nat -A SHADOWSOCKS_CHN -p tcp -m set --match-set $IPSET_GFW dst -j REDIRECT --to 1234
	iptables -t nat -A SHADOWSOCKS_CHN -p tcp -m set ! --match-set $IPSET_CDN dst -m set ! --match-set $IPSET_CH dst -j REDIRECT --to 1234
	iptables -t nat -A OUTPUT -p tcp -m set --match-set $IPSET_GFW dst -j REDIRECT --to-ports 1234
	iptables -t nat -N SHADOWSOCKS_GAM
    	iptables -t nat -A SHADOWSOCKS_GAM -p tcp -m set ! --match-set $IPSET_CDN dst  -m  set ! --match-set  $IPSET_CH dst  -j REDIRECT --to 1234
	ip rule add fwmark 0x01 table 100
	ip route add local 0.0.0.0/0 dev lo table 100
	if [ -n "$udp_server" ] || [ "$game_mode" != "" ] || [ "$(uci_get_by_type global gfw_enable)" == "gm" ];then
		echo "udp mode" 
		[ "$udp_server" == "" ] && udp_server=$server
		echo "udp server:" $udp_server
		iptables -t mangle -N SHADOWSOCKS
		iptables -t mangle -I PREROUTING -p udp -j SHADOWSOCKS
		iptables -t mangle -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
		iptables -t mangle -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
	 	iptables -t mangle -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
		iptables -t mangle -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
		iptables -t mangle -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
		iptables -t mangle -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
	 	iptables -t mangle -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
		iptables -t mangle -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN
		iptables -t mangle -A SHADOWSOCKS -d $udp_server -j RETURN
		iptables -t mangle -N SHADOWSOCKS_GAM
		iptables -t mangle -A SHADOWSOCKS_GAM -p udp -m set --match-set $IPSET_GFW dst -j TPROXY --on-port 1234 --tproxy-mark 0x01/0x01
	 	iptables -t mangle -A SHADOWSOCKS_GAM -p udp -m set ! --match-set $IPSET_CH dst -m  set ! --match-set  $IPSET_CH dst -j TPROXY --on-port 1234 --tproxy-mark 0x01/0x01
	fi
	load_acl
	iptables -t nat -A SHADOWSOCKS -j $(get_action_chain $(uci_get_by_type global gfw_enable))
	[ "$(uci_get_by_type global gfw_enable)" == "gm" ] && iptables -t mangle -A SHADOWSOCKS -j $(get_action_chain $(uci_get_by_type global gfw_enable))


	
}



load_acl(){
COUNTER=0
while true
do
	local acl_ipaddr=`uci get shadowsocksr.@lan_hosts[$COUNTER].host 2>/dev/null`
	local acl_proxy_mode=`uci get shadowsocksr.@lan_hosts[$COUNTER].type 2>/dev/null`
	local acl_ports=`uci get shadowsocksr.@lan_hosts[$COUNTER].ports 2>/dev/null`
	if [ -z "$acl_proxy_mode" ] && [ -z "$acl_ipaddr" ] && [ -z "$acl_ports" ] ; then
                  break
	fi
	iptables -t nat -A SHADOWSOCKS $(factor $acl_ipaddr "-s") $(factor $acl_ports "-p tcp -m multiport --dport") -$(get_jump_mode $acl_proxy_mode) $(get_action_chain $acl_proxy_mode)
	[ "$acl_proxy_mode" == "gm" ] && [ "$ARG_UDP" != "" ] && iptables -t mangle -A SHADOWSOCKS $(factor $acl_ipaddr "-s") $(factor $acl_ports "-p udp -m multiport --dport") -$(get_jump_mode $acl_proxy_mode) $(get_action_chain $acl_proxy_mode)
	COUNTER=$(($COUNTER+1))
done
}

factor(){
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo ""
	else
		echo "$2 $1"
	fi
}

get_jump_mode(){
	case "$1" in
		disable)
			echo "j"
		;;
		*)
			echo "g"
		;;
	esac
}

clean_firewall_rule() {
  	#ib_nat_exist=`iptables -t nat -L PREROUTING | grep -c SHADOWSOCKS`
	ib_nat_exist=`iptables -t nat -L OUTPUT | grep -c  1234`

  	if [ ! -z "$ib_nat_exist" ];then
     		until [ "$ib_nat_exist" = 0 ]
    		do 
		echo port:1234
       		iptables -t nat -D OUTPUT -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports 1234 2>/dev/null
       		iptables -t nat -D PREROUTING -p tcp -j SHADOWSOCKS 2>/dev/null
       		#iptables -t nat -D PREROUTING  -p udp --dport 53 -j DNAT --to $lanip 2>/dev/null
       		iptables -t mangle -D PREROUTING -p udp -j SHADOWSOCKS 2>/dev/null
       		ib_nat_exist=`expr $ib_nat_exist - 1`
  		done
  	fi
}

del_firewall_rule() {
	clean_firewall_rule
	iptables -t nat -F china 2>/dev/null && iptables -t nat -X china 2>/dev/null
	iptables -t nat -F SHADOWSOCKS 2>/dev/null && iptables -t nat -X SHADOWSOCKS 2>/dev/null
	iptables -t nat -F SHADOWSOCKS_GLO 2>/dev/null && iptables -t nat -X SHADOWSOCKS_GLO 2>/dev/null
	iptables -t nat -F SHADOWSOCKS_GFW 2>/dev/null && iptables -t nat -X SHADOWSOCKS_GFW 2>/dev/null
	iptables -t nat -F SHADOWSOCKS_CHN 2>/dev/null && iptables -t nat -X SHADOWSOCKS_CHN 2>/dev/null
	iptables -t nat -F SHADOWSOCKS_GAM 2>/dev/null && iptables -t nat -X SHADOWSOCKS_GAM 2>/dev/null
	iptables -t nat -F SHADOWSOCKS_HOME 2>/dev/null && iptables -t nat -X SHADOWSOCKS_HOME 2>/dev/null
	iptables -t mangle -F SHADOWSOCKS 2>/dev/null && iptables -t mangle -X SHADOWSOCKS 2>/dev/null
	iptables -t mangle -F SHADOWSOCKS_GAM 2>/dev/null && iptables -t mangle -X SHADOWSOCKS_GAM 2>/dev/null
	remove_fwmark_rule 2>/dev/null
	ip route del local 0.0.0.0/0 table 100 2>/dev/null
}


get_action_chain() {
	case "$1" in
		disable)
			echo "RETURN"
		;;
		global)
			echo "SHADOWSOCKS_GLO"
		;;
		gfw)
			echo "SHADOWSOCKS_GFW"
		;;
		router)
			echo "SHADOWSOCKS_CHN"
		;;
		gm)
			echo "SHADOWSOCKS_GAM"
		;;
		returnhome)
			echo "SHADOWSOCKS_HOME"
		;;
	esac
}



start_pdnsd() {
	local usr_dns="$1"
	local usr_port="$2"
  
	local tcp_dns_list="208.67.222.222, 208.67.220.220"
	[ -z "$usr_dns" ] && usr_dns="8.8.8.8"
	[ -z "$usr_port" ] && usr_port="53"
	mkdir -p /var/etc /var/pdnsd
	
	if ! test -f "/var/pdnsd/pdnsd.cache"; then
		dd if=/dev/zero of="/var/pdnsd/pdnsd.cache" bs=1 count=4 2> /dev/null
		chown -R nobody.nogroup /var/pdnsd
	fi
	
	cat > /var/etc/pdnsd.conf <<EOF
global {
	cache_dir="/var/pdnsd";
	pid_file = /var/run/pdnsd.pid;
	run_as="nobody";
	server_ip = 0.0.0.0;
	server_port = 1053;
	status_ctl = on;
	query_method = tcp_only;
	min_ttl=24h;
	max_ttl=1w;
	timeout=10;
	neg_domain_pol=on;
	proc_limit=2;
	procq_limit=8;
}
server {
	label= "ssr-usrdns";
	ip = $usr_dns;
	port = $usr_port;
	timeout=6;
	uptest=none;
	interval=10m;
	purge_cache=off;
}
server {
	label= "ssr-pdnsd";
	ip = $tcp_dns_list;
	port = 5353;
	timeout=6;
	uptest=none;
	interval=10m;
	purge_cache=off;
}
EOF
	/usr/sbin/pdnsd -c /var/etc/pdnsd.conf -d
}

start_redir() {
	gen_config_file $GLOBAL_SERVER 0
	mkdir -p /var/run /var/etc
	UDP_RELAY_SERVER=$(uci_get_by_type global udp_relay_server)

       if [ "$UDP_RELAY_SERVER" = "" ] ;then
		ARG_UDP=""
		[ "$game_mode" != "" ] && ARG_UDP="-u" && udp_server=$server
	else
		if [ "$UDP_RELAY_SERVER" = "$GLOBAL_SERVER" ] || [ "$UDP_RELAY_SERVER" = "same" ] ;then
			ARG_UDP="-u"
			udp_server=$server
		else 
			ARG_UDP="-U"
			udp_server=$(get_server_ip $(uci_get_by_name $UDP_RELAY_SERVER server))
		fi
	fi
	

	redir_tcp=1
	local last_config_file=$CONFIG_FILE
	local pid_file="/var/run/ssr-retcp.pid"
	echo "last_config_file:"$CONFIG_FILE
	echo $ARG_UDP
	if [ "$ARG_UDP" = "-U" ]; then
		/usr/bin/ssr-redir \
			-c $CONFIG_FILE  \
			-f /var/run/ssr-retcp.pid
		
		gen_config_file $UDP_RELAY_SERVER 1
		last_config_file=$CONFIG_UDP_FILE
		pid_file="/var/run/ssr-reudp.pid"
		redir_udp=1
	fi

	/usr/bin/ssr-redir \
		-c $last_config_file  $ARG_UDP \
		-f $pid_file
		
}



add_dnsmasq(){
	local mode=$(uci_get_by_type global dns_enable)
	case $mode in
          	1)
			local dnsstr="$(uci_get_by_type global tunnel_forward 8.8.4.4:53)"
			local dnsserver=`echo "$dnsstr"|awk -F ':'  '{print $1}'`
			local dnsport=`echo "$dnsstr"|awk -F ':'  '{print $2}'`
			ipset add gfwlist $dnsserver 2>/dev/null
			start_pdnsd $dnsserver $dnsport
			
 			dns_enable_flag=4
		;;
		0)
 			service_start /usr/bin/ssr-tunnel -c $CONFIG_FILE -b 0.0.0.0 -u -l 1053 -L $(uci_get_by_type global tunnel_forward 8.8.4.4:53) -f /var/run/ssr-dns.pid
			dns_enable_flag=1
		;;
		2)
			/usr/sbin/Pcap_DNSProxy \
				-c /etc/pcap-dnsproxy
			dns_enable_flag=3
		;;
		3)
	  		/usr/bin/ssr-local \
			-c $CONFIG_FILE \
			-l $(uci_get_by_type socks5_proxy local_port 1080) \
			-f /var/run/ssr-local.pid
			/usr/bin/dns2socks \
				127.0.0.1:$(uci_get_by_type socks5_proxy local_port) \
				$(uci_get_by_type global tunnel_forward 8.8.4.4:53) \
				127.0.0.1:1053 \
				>/dev/null 2>&1 &
			dns_enable_flag=2
		;;
		4)
			
			
			dnss=`echo "$(uci_get_by_type global tunnel_forward 8.8.4.4:53)"|awk -F ':' '{print $1}'`
			dnsp=`echo "$(uci_get_by_type global tunnel_forward 8.8.4.4:53)"|awk -F ':' '{print $2}'`
			 /usr/bin/dnsproxy \
						-p 1053 \
						-R $dnss \
						-P $dnsp \
						-d	\
						>/dev/null 2>&1 &
			dns_enable_flag=5
			
		;;

         esac


	if [ ! -f "/tmp/dnsmasq.d/gfwlist.conf" ];then
		ln -s /etc/dnsmasq.d/gfwlist.conf /tmp/dnsmasq.d/gfwlist.conf
	fi
	if [ ! -f "/tmp/dnsmasq.d/custom.conf" ];then
		cat /etc/gfwlist/gfwlist | awk '{print "server=/"$1"/127.0.0.1#1053\nipset=/"$1"/gfwlist"}' >> /tmp/dnsmasq.d/custom.conf
	fi
	if [ ! -f "/tmp/dnsmasq.d/sscdn.conf" ];then
		cat /etc/dnsmasq.d/cdn.conf | sed "s/^/ipset=&\/./g" | sed "s/$/\/&cdn/g" | sort | awk '{if ($0!=line) print;line=$0}' >/tmp/dnsmasq.d/sscdn.conf
	fi
	userconf=$(grep -c "" /etc/dnsmasq.d/user.conf)
	if [ $userconf -gt 0  ];then
 		ln -s /etc/dnsmasq.d/user.conf /tmp/dnsmasq.d/user.conf
	fi
	/etc/init.d/dnsmasq restart 
}


start_tunnel() {
	/usr/bin/ssr-tunnel \
		-c $CONFIG_FILE  ${ARG_UDP:="-u"} \
		-l $(uci_get_by_type global tunnel_port 5300) \
		-L $(uci_get_by_type global tunnel_forward 8.8.4.4:53) \
		-f /var/run/ssr-tunnel.pid
	tunnel_enable=1	
	return $?
}
start_local() {
	local local_server=$(uci_get_by_type socks5_proxy server)
	[ "$local_server" = "nil" ] && return 1
	mkdir -p /var/run /var/etc
	gen_config_file $local_server 2
	/usr/bin/ssr-local -c $CONFIG_SOCK5_FILE -u  \
		-l $(uci_get_by_type socks5_proxy local_port 1080) \
		-f /var/run/ssr-local.pid
	local_enable=1	
}



start() { 
	stop
	 SERVER_TYPE=$(uci_get_by_type global server_type)
	
	[ "$(uci_get_by_type global enable)" != 1 ] && return 1
	
	if [ "$SERVER_TYPE" == "SSR" ];then
		echo "server_type: SSR"
		GLOBAL_SERVER=$(uci_get_by_type global global_server)
		switch_enable=0
		[ -n "$switch_server" ] && GLOBAL_SERVER=$switch_server && switch_enable=1
		start_redir
		add_dnsmasq
		start_rules
		echo 3
		[ "$switch_enable" = "0" ] && service_start /usr/share/shadowsocksr/ssr-switch start 60 5 
		service_start /usr/share/shadowsocksr/ssr-monitor $server_count $redir_tcp $redir_udp $tunnel_enable $kcp_enable_flag $local_enable $dns_enable_flag $switch_enable
		
	else
		echo "server_type: v2ray"
		GLOBAL_SERVER=$(uci_get_by_type global global_server_v2)
		get_v2ray
		creat_v2ray_json
		start_v2ray
		add_dnsmasq
		start_rules

	fi
	set_update
}

stop() {

	
 	del_firewall_rule
	ipset -F cdn >/dev/null 2>&1 &
  	ipset -X cdn >/dev/null 2>&1 &
	ipset -F china >/dev/null 2>&1 &
  	ipset -X china >/dev/null 2>&1 &
	ipset -F local >/dev/null 2>&1 &
   	ipset -X local >/dev/null 2>&1 &	
   	ipset -F gfwlist >/dev/null 2>&1 &
   	ipset -X gfwlist >/dev/null 2>&1 &	
	
	killall -q -9 ssr-monitor
	if [ -z "$switch_server" ] ;then
		killall -q -9 ssr-switch
	fi
	killall -q -9 ssr-redir
	killall -q -9 ssr-tunnel
	killall -q -9 ssr-local
	killall -q -9 dnsproxy
	killall -q  pdnsd
	killall -q -9 Pcap_DNSProxy    
        killall -q -9 dns2socks
	killall -q -9 v2ray
        stop_update
}
stop_update() {
   	sed -i '/updategfwlist/d' /etc/crontabs/root >/dev/null 2>&1 

}

set_update() {

	autoupdate=$(uci_get_by_type global auto_update)
	weekupdate=$(uci_get_by_type global week_update)
	dayupdate=$(uci_get_by_type global time_update)
	stop_update
	if [ "$autoupdate" = "1" ];then
		if [ "$weekupdate" = "7" ];then
      			echo "0 $dayupdate * * * /usr/share/shadowsocksr/updategfwlist.sh" >> /etc/crontabs/root
   		else
      			echo "0 $dayupdate * * $weekupdate /usr/share/shadowsocksr/updategfwlist.sh" >> /etc/crontabs/root
   		fi
	fi
}


case "$1" in
  start)
	start
  ;;
  stop)
	stop
  ;;

  *)
  echo "Usage: $0 [start stop ]"
  ;;
esac