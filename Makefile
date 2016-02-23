GO_EASY_ON_ME = 1
SDKVERSION = 9.2
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = SlideToRespring
SlideToRespring_FILES = Tweak.xm
SlideToRespring_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R SlideToRespring $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)