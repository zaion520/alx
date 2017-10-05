#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=autosamba
PKG_VERSION:=1
PKG_RELEASE:=8
PKG_ARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  TITLE:=Samba autoconfig hotplug script.
  MAINTAINER:=Lean
  DEPENDS:=+luci-app-samba +block-mount +kmod-usb-storage +kmod-usb-storage-extras +kmod-fs-ext4 +kmod-fs-vfat +kmod-fs-exfat +ntfs-3g
endef

define Package/$(PKG_NAME)/description
A hotplug script to config Samba share automatically.
endef

define Build/Compile
endef

define Package/autosamba/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/block
	$(INSTALL_BIN) ./files/20-smb $(1)/etc/hotplug.d/block/20-smb
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/15-automount $(1)/etc/15-automount
	$(INSTALL_BIN) ./files/zzz-move-automount $(1)/etc/uci-defaults/zzz-move-automount
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
