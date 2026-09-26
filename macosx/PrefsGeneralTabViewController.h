#import <AppKit/AppKit.h>
#import <libtransmission/transmission.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrefsGeneralTabViewController : NSViewController

@property(nonatomic, readonly) tr_session* fHandle;
@property(nonatomic, readonly) NSUserDefaults* fDefaults;

- (instancetype)initWithHandle:(tr_session*)handle;
- (void)updateDefaultsStates;

@end

NS_ASSUME_NONNULL_END
