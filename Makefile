ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

THEOS_PACKAGE_SCHEME = rootless
THEOS_LEAN_AND_MEAN = 1

TARGET = iphone:clang:latest:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ffz

$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -DNDEBUG -Wall \
    -Wno-deprecated-declarations -Wno-unused-variable \
    -Wno-unused-value -Wno-unused-function \
    -Wno-module-import-in-extern-c \
    -fno-modules \
    -fvisibility=default

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wall \
    -Wno-deprecated-declarations -Wno-unused-variable \
    -Wno-unused-value -Wno-unused-function

$(TWEAK_NAME)_LDFLAGS  = -lSystem
$(TWEAK_NAME)_LDFLAGS += JRMemory.framework/JRMemory

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore \
    CoreGraphics CoreText AVFoundation Accelerate GLKit \
    SystemConfiguration GameController

$(TWEAK_NAME)_FILES = \
    Draw.mm \
    Themes/ThemeManager.mm \
    menuUIKIT/buttons.mm \
    Themes/UIComponents.mm \
    menuUIKIT/touchView.mm \
    Helper/GameRunner.mm \
    $(wildcard Others/*.mm) \
    $(wildcard Esp/*.mm) \
    $(wildcard Hidestream/*.mm) \
    $(wildcard KittyMemory/*.mm) \
    $(wildcard KittyMemory/*.cpp) \
    $(wildcard Esp/*.m) \
    $(wildcard hook/*.c)

include $(THEOS_MAKE_PATH)/tweak.mk
