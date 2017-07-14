include $(THEOS)/makefiles/common.mk

ADDITIONAL_OBJCFLAGS = -fobjc-arc
TWEAK_NAME = ProxySwitcher
ProxySwitcher_FILES = $(wildcard *.m *.mm *.x *.xm)

BUNDLE_NAME = ProxySwitcherBundle
ProxySwitcherBundle_INSTALL_PATH = /Library/Application Support/ProxySwitcher

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard; launchctl unload /Library/LaunchDaemons/com.mikaelbo.proxyswitcherd.plist; launchctl load /Library/LaunchDaemons/com.mikaelbo.proxyswitcherd.plist;"

SUBPROJECTS += proxyswitcherprefs
SUBPROJECTS += proxyswitcherd
SUBPROJECTS += proxyswitcheruikit
include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS)/makefiles/bundle.mk
