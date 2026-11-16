TARGET := iphone:clang:16.5:16.5
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = BackgroundShortcutRunner Shortcuts

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ShortcutsNoConfirm

ShortcutsNoConfirm_FILES = Tweak.x
ShortcutsNoConfirm_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
