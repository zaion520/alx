#!/bin/sh -e
o=0
generate_china_banned()
{
	
		cat $1 | base64 -d > /tmp/gfwlist.txt
		rm -f $1


	cat /tmp/gfwlist.txt | sort -u |
		sed 's#!.\+##; s#|##g; s#@##g; s#http:\/\/##; s#https:\/\/##;' |
		sed '/\*/d; /apple\.com/d; /sina\.cn/d; /sina\.com\.cn/d; /baidu\.com/d; /byr\.cn/d; /jlike\.com/d; /weibo\.com/d; /zhongsou\.com/d; /youdao\.com/d; /sogou\.com/d; /so\.com/d; /soso\.com/d; /aliyun\.com/d; /taobao\.com/d; /jd\.com/d; /qq\.com/d' |
		sed '/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$/d' |
		grep '^[0-9a-zA-Z\.-]\+$' | grep '\.' | sed 's#^\.\+##' | sort -u |
		awk '
BEGIN { prev = "________"; }  {
	cur = $0;
	if (index(cur, prev) == 1 && substr(cur, 1 + length(prev) ,1) == ".") {
	} else {
		print cur;
		prev = cur;
	}
}' | sort -u

}
wget-ssl --no-check-certificate https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt -O /tmp/gfw.b64
generate_china_banned /tmp/gfw.b64 > /tmp/gfw.txt
rm -f /tmp/gfwlist.txt
sed '/.*/s/.*/server=\/\.&\/127.0.0.1#1053\nipset=\/\.&\/gfwlist/' /tmp/gfw.txt >/tmp/gfwnew.txt
mv  /tmp/gfwnew.txt /etc/dnsmasq.d/gfwlist.conf
rm -f /tmp/gfw.txt

if [ -s "/tmp/gfwnew.txt" ];then
	if ( ! cmp -s /tmp/gfwnew.txt /etc/dnsmasq.d/gfwlist.conf );then
		mv  /tmp/gfwnew.txt /etc/dnsmasq.d/gfwlist.conf
		o=1
	fi
fi

wget-ssl --no-check-certificate https://opt.cn2qq.com/opt-file/chnroute.txt -O /tmp/chnroute.txt
echo "create china hash:net family inet hashsize 1024 maxelem 65536" > /tmp/chnroute
awk '!/^$/&&!/^#/{printf("add china %s'" "'\n",$0)}' /tmp/chnroute.txt >> /tmp/chnroute
if [ -s "/tmp/chnroute.txt" ];then
	if ( ! cmp -s /tmp/chnroute /etc/gfwlist/cdnlist );then
		mv /tmp/chnroute /etc/gfwlist/cdnlist
		echo "copy chnroute"
		o=1
	fi
fi

[ $o = 1 ] && /etc/init.d/shadowsocksr start

