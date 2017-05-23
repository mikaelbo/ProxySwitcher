include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ProxySwitcher
ADDITIONAL_OBJCFLAGS = -fobjc-arc
ProxySwitcher_FILES = MBRootListController.m
ProxySwitcher_INSTALL_PATH = /Library/PreferenceBundles
ProxySwitcher_FRAMEWORKS = UIKit
ProxySwitcher_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ProxySwitcher.plist$(ECHO_END)
