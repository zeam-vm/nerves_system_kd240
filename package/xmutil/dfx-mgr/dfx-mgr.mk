################################################################################
#
# dfx-mgr
#
################################################################################
ifeq ($(BR2_PACKAGE_DFX_MGR_USE_XMUTIL_TAG),y)
DFX_MGR_VERSION = $(call qstrip,$(BR2_PACKAGE_XMUTIL_DEFAULT_TAG))
else
DFX_MGR_VERSION = $(call qstrip,$(BR2_PACKAGE_DFX_MGR_TAG))
endif
DFX_MGR_SOURCE = dfx-mgr-$(DFX_MGR_VERSION).tar.gz
DFX_MGR_SITE = $(call github,Xilinx,dfx-mgr,$(DFX_MGR_VERSION))
DFX_MGR_LICENSE = MIT
DFX_MGR_LICENSE_FILES = LICENSE
DFX_MGR_DEPENDENCIES = libdfx libwebsockets libdrm
DFX_MGR_CONF_OPTS = -DWITH_STATIC_LIB=OFF \
                    -DWITH_SHARED_LIB=ON \
                    -DCMAKE_C_FLAGS="-Wno-error=address -Wno-error=unused-parameter -Wno-error=calloc-transposed-args" \
                    -DCMAKE_CXX_FLAGS="-Wno-error=address -Wno-error=unused-parameter -Wno-error=calloc-transposed-args"

# Comment out two lines which needs systemd header
# Nerves doesn't include systemd header, so this line causes building error
define DFX_MGR_TWEAK
	$(SED) 's|^\(#include <systemd/sd-daemon.h>\)$$|// \1|' $(@D)/example/sys/linux/dfx-mgrd.c
	$(SED) 's|^\t\(sd_notify.*\)$$|\t// \1|' $(@D)/example/sys/linux/dfx-mgrd.c
	$(SED) 's|^set (_deps "dfx" "dl" "pthread" "systemd")$$|set (_deps "dfx" "dl" "pthread")|' \
		 $(@D)/example/sys/linux/CMakeLists.txt
endef

DFX_MGR_PRE_BUILD_HOOKS += DFX_MGR_TWEAK

$(eval $(cmake-package))
