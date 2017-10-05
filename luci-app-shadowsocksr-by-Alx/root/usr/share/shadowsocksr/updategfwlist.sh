#!/bin/sh
wget-ssl --no-check-certificate https://g2w.online/ipset/gfwlist,127.0.0.1:1053 -O /tmp/gfwnew.txt
 if [ "$?" == "0" ]; then
         icunt=$(cat /tmp/gfwnew.txt | wc -l)
         icunt1=$(cat /etc/dnsmasq.d/gfwlist.conf | wc -l)
              if [ "$icunt" != "$icunt1" ];then
                           cp -f /tmp/gfwnew.txt /etc/dnsmasq.d/gfwlist.conf
              fi
fi
rm -rf  /tmp/gfwnew.txt
rm -rf  /tmp/gfw.b64
