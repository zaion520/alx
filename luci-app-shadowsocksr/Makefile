# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Shadowsocksr by klaus
LUCI_DEPENDS:=+libopenssl +libpthread +ipset +ip-full +iptables-mod-tproxy +libpcre +zlib +dnsmasq-full +coreutils +coreutils-base64 +curl +libmbedtls +libcurl +shadowsocksr-libev +pdnsd
LUCI_PKGARCH:=all
PKG_VERSION:=3.0
PKG_RELEASE:=22

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

