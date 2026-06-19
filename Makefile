THEOS_DEVICE_IP = localhost
ARCHS = arm64
TARGET = iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HCRMod
HCRMod_FILES = src/Tweak.x
HCRMod_CFLAGS = -fobjc-arc
HCRMod_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
