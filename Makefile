include $(THEOS)/makefiles/common.mk

ADDITIONAL_OBJCFLAGS = -fobjc-arc
TWEAK_NAME = ProxySwitcher
ProxySwitcher_FILES = $(wildcard *.m *.mm *.x *.xm)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard;"
SUBPROJECTS += proxyswitcher
SUBPROJECTS += proxyswitcherd
include $(THEOS_MAKE_PATH)/aggregate.mk
