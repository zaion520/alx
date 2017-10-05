#!/bin/sh

wget-ssl --no-check-certificate https://raw.githubusercontent.com/zaion520/CHN/master/china -O /tmp/china
cp /tmp/china  /etc/ipset/china


