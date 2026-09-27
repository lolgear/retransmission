// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "TrackerTierView.h"

@interface TrackerTierView ()
@property(nonatomic, strong) NSTextField* tierLabel;
@end

@implementation TrackerTierView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        _tierLabel = [NSTextField labelWithString:@""];
        _tierLabel.font = [NSFont systemFontOfSize:12.0 weight:NSFontWeightBold];
        _tierLabel.textColor = [NSColor labelColor];
        _tierLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:_tierLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_tierLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8.0],
            [_tierLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8.0],
            [_tierLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        ]];
    }
    return self;
}

- (void)setTier:(NSString*)tier
{
    self.tierLabel.stringValue = tier;
}

@end

@interface TrackerInputView ()<NSTextFieldDelegate>
@property(nonatomic, strong) NSTextField* trackerField;
@end

@implementation TrackerInputView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        _trackerField = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _trackerField.translatesAutoresizingMaskIntoConstraints = NO;
        _trackerField.font = [NSFont systemFontOfSize:12.0];
        _trackerField.placeholderString = NSLocalizedString(@"Enter tracker announce URL...", @"Inspector -> tracker table");
        _trackerField.bezeled = YES;
        _trackerField.bezelStyle = NSTextFieldSquareBezel;
        _trackerField.editable = YES;
        _trackerField.selectable = YES;
        _trackerField.delegate = self;

        [self addSubview:_trackerField];

        [NSLayoutConstraint activateConstraints:@[
            [_trackerField.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8.0],
            [_trackerField.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8.0],
            [_trackerField.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_trackerField.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    return self;
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == @selector(insertNewline:)) {
        NSString* trimmedAddress = [control.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedAddress.length > 0) {
            if ([self.delegate respondsToSelector:@selector(trackerInputView:didCommitAddress:)]) {
                [self.delegate trackerInputView:self didCommitAddress:trimmedAddress];
            }
        } else {
            [self handleCancel];
        }
        return YES;
    }

    if (commandSelector == @selector(cancelOperation:)) {
        [self handleCancel];
        return YES;
    }

    return NO;
}

- (void)handleCancel
{
    if ([self.delegate respondsToSelector:@selector(trackerInputViewDidCancel:)]) {
        [self.delegate trackerInputViewDidCancel:self];
    }
}

@end
