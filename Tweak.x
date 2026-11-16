#import <Foundation/Foundation.h>
#import <Foundation/NSUserDefaults+Private.h>

// Every class, selector, block signature and response code below was checked
// against the iOS 16.5.1 (20F75) dyld shared cache.

@interface WFSecureConfirmationAlert : NSObject
@property (copy, nonatomic) void (^successHandler)(void);
@end

static NSString *const kDomain = @"com.skfallin.shortcutsnoconfirm";
static BOOL enabled;

static void loadPrefs(CFNotificationCenterRef c, void *o, CFStringRef n, const void *obj, CFDictionaryRef info) {
	NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:kDomain];
	enabled = value ? value.boolValue : YES;
}

// Runs in the shortcut runner: this is the host that shows dialogs for automations.
%hook WFDialogTransformer

// WFSecureConfirmationAlert is built by -[WFAction(RequestUnlock) requestUnlock:]
// (Shut Down/Restart, secure Home accessories). Its Continue button ends up calling successHandler.
- (void)presentAlert:(id)alert {
	if (enabled && [alert isKindOfClass:%c(WFSecureConfirmationAlert)]) {
		void (^success)(void) = ((WFSecureConfirmationAlert *)alert).successHandler;
		if (success) {
			dispatch_async(dispatch_get_main_queue(), success);
			return;
		}
	}
	%orig;
}

// App Intents confirmation: 1 = Yes button (WFLinkConfirmationDialogViewController).
- (void)showLinkActionConfirmationWithActionMetadata:(id)metadata showPrompt:(BOOL)showPrompt dialogString:(id)dialogString viewSnippet:(id)viewSnippet confirmationActionName:(id)name completionHandler:(void (^)(unsigned long long))handler {
	if (enabled && handler) {
		dispatch_async(dispatch_get_main_queue(), ^{ handler(1); });
		return;
	}
	%orig;
}

// SiriKit intent confirmation: 1 = "Confirmed interaction" (WFInteractionDialogViewController).
- (void)showConfirmInteraction:(id)interaction prompt:(id)prompt requireAuthentication:(BOOL)requireAuthentication completionHandler:(void (^)(unsigned long long))handler {
	if (enabled && handler) {
		dispatch_async(dispatch_get_main_queue(), ^{ handler(1); });
		return;
	}
	%orig;
}

%end

// Same switches as Settings > Shortcuts > Advanced; forced on while the tweak is enabled.
%hook WFShortcutsSecuritySettings
+ (BOOL)allowsDeletingWithoutConfirmation { return enabled || %orig; }
+ (BOOL)allowsDeletingLargeAmountsOfData { return enabled || %orig; }
+ (BOOL)allowsSharingLargeAmountsOfData { return enabled || %orig; }
%end

%ctor {
	loadPrefs(NULL, NULL, NULL, NULL, NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, loadPrefs, CFSTR("com.skfallin.shortcutsnoconfirm/preferences.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
