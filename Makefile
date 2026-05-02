ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

THEOS_PACKAGE_SCHEME = rootless
THEOS_LEAN_AND_MEAN = 1

# ❗ เปลี่ยน SDK ให้ใช้ 15.0 (มีแน่นอนใน GitHub)
TARGET = iphone:clang:15.0:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ffz

$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -DNDEBUG -Wall \
    -Wno-deprecated-declarations -Wno-unused-variable \
    -Wno-unused-value -Wno-unused-function \
    -fvisibility=default

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wall \
    -Wno-deprecated-declarations -Wno-unused-variable \
    -Wno-unused-value -Wno-unused-function \
    -fvisibility=default

# 🔥 LDFLAGS ปรับให้ปลอดภัยขึ้น
$(TWEAK_NAME)_LDFLAGS = -lSystem

# ❗ ลบ JRMemory แบบผิดๆ ออก (มันทำให้พังได้)
# $(TWEAK_NAME)_LDFLAGS += JRMemory.framework/JRMemory

KITTYMEMORY_PATH = KittyMemory

$(TWEAK_NAME)_OBJ_FILES = \
    $(KITTYMEMORY_PATH)/Deps/Keystone/libs-ios/$(THEOS_CURRENT_ARCH)/libkeystone.a

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore \
    CoreGraphics CoreText AVFoundation Accelerate GLKit \
    SystemConfiguration GameController

# ✅ wildcard กัน error ถ้า folder ไม่มี
$(TWEAK_NAME)_FILES = \
    Draw.mm \
    Themes/ThemeManager.mm \
    menuUIKIT/buttons.mm \
    Themes/UIComponents.mm \
    menuUIKIT/touchView.mm \
    Helper/GameRunner.mm \
    $(wildcard Others/*.mm) \
    $(wildcard Esp/*.mm) \
    $(wildcard Esp/*.m) \
    $(wildcard Hosts/*.m) \
    $(wildcard Hosts/*.mm) \
    $(wildcard Hidestream/*.mm) \
    $(wildcard KittyMemory/*.mm) \
    $(wildcard KittyMemory/*.cpp) \
    $(wildcard hook/*.c)

include $(THEOS_MAKE_PATH)/tweak.mk
