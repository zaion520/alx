include $(TOPDIR)/rules.mk

PKG_NAME:=dns2socks
PKG_VERSION:=1.8
PKG_RELEASE:=20150628

PKG_SOURCE:=SourceCode.zip
PKG_SOURCE_SUBDIR:=DNS2SOCKS
PKG_SOURCE_URL:=@SF/dns2socks
#PKG_MD5SUM:=46ffd9c2d5c2ec228807ba2a511517cb

PKG_MAINTAINER:=ghostmaker
PKG_LICENSE:=BSD-3-Clause

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dns2socks/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=The utility to resolve DNS requests via a SOCKS5 tunnel.
  URL:=https://ayera.dl.sourceforge.net
  MAINTAINER:=ghostmaker
  DEPENDS:=+libpthread
endef

define Package/dns2socks
	$(call Package/dns2socks/Default)
endef

define Package/dns2socks/description
  This is a utility to resolve DNS requests via a SOCKS5 tunnel and caches the answers.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	unzip $(DL_DIR)/$(PKG_SOURCE) -d $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(TARGET_CC) \
	$(TARGET_CFLAGS) \
	$(TARGET_CPPFLAGS) \
	$(TARGET_CPPFLAGS) \
	$(FPIC) \
	-o $(PKG_BUILD_DIR)/$(PKG_SOURCE_SUBDIR)/$(PKG_NAME) \
	$(PKG_BUILD_DIR)/$(PKG_SOURCE_SUBDIR)/DNS2SOCKS.c \
	$(TARGET_LDFLAGS) -pthread
endef

define Build/Install
endef

define Package/dns2socks/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_SOURCE_SUBDIR)/$(PKG_NAME) $(1)/usr/bin/dns2socks
endef

#$(shell $(RM) $(DL_DIR)/$(PKG_SOURCE))

$(eval $(call BuildPackage,dns2socks))
