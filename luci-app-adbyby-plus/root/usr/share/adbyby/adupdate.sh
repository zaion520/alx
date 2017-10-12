#!/bin/sh
a=0
b=0


update_source=$(uci get adbyby.@adbyby[0].update_source 2>/dev/null)
rm -f /tmp/lazy.txt /tmp/video.txt /tmp/user.action
rm -f /usr/share/adbyby/data/*.bak
#/usr/bin/wget -t 1 -T 10 -O /tmp/user.action http://update.adbyby.com/rule3/user.action
if [ $update_source -eq 1 ]; then
/usr/bin/wget -t 1 -T 10 -O /tmp/lazy.txt http://update.adbyby.com/rule3/lazy.jpg
ret1=$?
/usr/bin/wget -t 1 -T 10 -O /tmp/video.txt http://update.adbyby.com/rule3/video.jpg	
ret=$?
fi

[ "$ret" != "0" ] || [ "$ret1" != "0" ] && a=1
if [ "$a" = "1" ];then
/usr/bin/wget --no-check-certificate -O /tmp/video.txt https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/video.txt
ret1=$?
/usr/bin/wget --no-check-certificate -O /tmp/lazy.txt https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/lazy.txt
ret=$?
[ "$ret" != "0" ] || [ "$ret1" != "0" ] && return 0
fi
newMD5=`md5sum  /tmp/lazy.txt | awk '{print $1}'`
oldMD5=`md5sum  /usr/share/adbyby/data/lazy.txt  | awk '{print $1}'`
[ "$oldMD5" != "$newMD5" ]  && b=1

newMD5=`md5sum  /tmp/video.txt | awk '{print $1}'`
oldMD5=`md5sum  /usr/share/adbyby/data/video.txt | awk '{print $1}'`
[ "$oldMD5" != "$newMD5" ]  && b=1	




if [ "$b" = "1" ] ;then
umount /usr/share/adbyby/data
mv /tmp/video.txt /usr/share/adbyby/data/video.txt 
mv /tmp/lazy.txt /usr/share/adbyby/data/lazy.txt 
#mv /tmp/user.action /usr/share/adbyby/user.action 
/etc/init.d/adbyby restart
fi

rm -f /tmp/lazy.txt /tmp/video.txt /tmp/user.action