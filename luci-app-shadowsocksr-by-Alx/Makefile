# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Shadowsocksr by Alx
LUCI_DEPENDS:=+libopenssl +libpthread +ipset +ip +iptables-mod-tproxy +libpcre +zlib +dnsmasq-full +coreutils +coreutils-base64 +curl +libmbedtls +libcurl +shadowsocksr-libev +pdnsd
#+dns2socks +pcap-dnsproxy
LUCI_PKGARCH:=all
PKG_VERSION:=2.0
PKG_RELEASE:=19

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

