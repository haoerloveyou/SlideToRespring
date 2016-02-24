@interface _UIActionSlider : UIControl
@end

@interface SBAlertView : UIView
@end

@interface SBPowerDownView : SBAlertView
@end

@interface SpringBoard
- (void)_relaunchSpringBoardNow;
@end

NSString *const PREF_PATH = @"/var/mobile/Library/Preferences/com.cabralcole.slidetorespring.plist";
CFStringRef const PreferencesNotification = CFSTR("com.cabralcole.slidetorespring.settingschanged");

static BOOL tweakEnabled;

%hook SBPowerDownController

- (void)activate
{
	if (tweakEnabled) {
		SBPowerDownView *powerDownView = MSHookIvar<SBPowerDownView*>(self, "_powerDownView"); // Thanks Dan Saba
		_UIActionSlider *actionSlider = MSHookIvar<_UIActionSlider *>(powerDownView, "_actionSlider");
		[actionSlider setTrackText:@"slide to respring"];
		[actionSlider setKnobImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/SlideToRespring/Respring@2x.png"]];
	}
	%orig;
}

- (void)powerDown
{
	if (tweakEnabled) {
		[(SpringBoard *)[UIApplication sharedApplication] _relaunchSpringBoardNow];
	}
	%orig;
}

%end


BOOL is_springboard() // Thanks PoomSmart
{
	NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		return [[executablePath lastPathComponent] isEqualToString:@"springboard"];
	}
	return NO;
}

static void SlideToRespringPrefs()
{
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	tweakEnabled = [prefs[@"STREnabled"] boolValue];
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	system("killall -9 SpringBoard");
	SlideToRespringPrefs();
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (!is_springboard())
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, PreferencesNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
		SlideToRespringPrefs();
		%init;
	[pool drain];
}
