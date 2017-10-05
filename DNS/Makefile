#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=Luci-app-dns
PKG_VERSION:=1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/Luci-app-dns
    SECTION:=luci
    CATEGORY:=LuCI
    SUBMENU:=3. Applications
    TITLE:=DNS for LuCI
    PKGARCH:=all
endef

define Package/Luci-app-dns/description
A hotplug script to config Samba share automatically.
endef

define Build/Compile
endef

define Package/Luci-app-dns/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/root/etc/config/* $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/sdns $(1)/etc/init.d/sdns
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) ./files/ethinfo $(1)/bin/ethinfo
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/luci/model/cbi/* $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/* $(1)/usr/lib/lua/luci/controller


endef

$(eval $(call BuildPackage,Luci-app-dns))
