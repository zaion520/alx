#
# Copyright (C) 2016 Xingwang Liao <kuoruan@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocksr-libev
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/shadowsocksrr/shadowsocksr-libev.git
PKG_SOURCE_DATE:=2017-06-13
PKG_SOURCE_VERSION:=91c72165d4e7ae92eba2d678812a8d11a037932d

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Xingwang Liao <kuoruan@gmail.com>

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocksr-libev/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy
	URL:=https://github.com/shadowsocksr/shadowsocksr-libev
	DEPENDS:=+libev +libudns +libpcre +libpthread +libsodium +libopenssl +zlib
endef

Package/shadowsocksr-libev = $(Package/shadowsocksr-libev/Default)

define Package/shadowsocksr-libev/description
Shadowsocksr-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

CONFIGURE_ARGS += --enable-system-shared-lib --disable-ssp --disable-documentation --disable-assert

define Package/shadowsocksr-libev/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-local $(1)/usr/bin/ssr-local
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(1)/usr/bin/ssr-redir
endef

$(eval $(call BuildPackage,shadowsocksr-libev))
