// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "DragOverlayView.h"

// Layout

// Badge
static CGFloat const kBadgeWidth = 325.0;
static CGFloat const kBadgeHeight = 84.0;

// MainStack
static CGFloat const kMainStackInset = 10;
static CGFloat const kMainStackSpacing = 5.0;

// Icon
static CGFloat const kIconSize = 64.0;

// TextStack
static CGFloat const kTextStackSpacing = 2.0;

@interface DragOverlayView ()

@property(nonatomic, readonly) NSView* badgeContainer;
@property(nonatomic, readonly) NSImageView* iconImageView;
@property(nonatomic, readonly) NSTextField* titleLabel;
@property(nonatomic, readonly) NSTextField* subtitleLabel;

@end

@implementation DragOverlayView

- (instancetype)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // 1. Background badge container
        _badgeContainer = [[NSView alloc] initWithFrame:NSZeroRect];
        _badgeContainer.translatesAutoresizingMaskIntoConstraints = NO;
        _badgeContainer.wantsLayer = YES;
        _badgeContainer.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.75].CGColor;
        _badgeContainer.layer.cornerRadius = 15.0;
        [self addSubview:_badgeContainer];

        // 2. Icon
        _iconImageView = [[NSImageView alloc] initWithFrame:NSZeroRect];
        _iconImageView.imageScaling = NSImageScaleProportionallyUpOrDown;

        // 3. Title
        _titleLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _titleLabel.editable = NO;
        _titleLabel.selectable = NO;
        _titleLabel.drawsBackground = NO;
        _titleLabel.bordered = NO;
        _titleLabel.font = [NSFont boldSystemFontOfSize:18.0];
        _titleLabel.textColor = NSColor.whiteColor;
        _titleLabel.maximumNumberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

        // 4. Subtitle
        _subtitleLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _subtitleLabel.editable = NO;
        _subtitleLabel.selectable = NO;
        _subtitleLabel.drawsBackground = NO;
        _subtitleLabel.bordered = NO;
        _subtitleLabel.font = [NSFont systemFontOfSize:14.0];
        _subtitleLabel.textColor = NSColor.whiteColor;
        _subtitleLabel.maximumNumberOfLines = 1;
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

        // 5. Vertical TextStack
        NSStackView* textStackView = [NSStackView stackViewWithViews:@[ _titleLabel, _subtitleLabel ]];
        textStackView.orientation = NSUserInterfaceLayoutOrientationVertical;
        textStackView.alignment = NSLayoutAttributeLeading;
        textStackView.spacing = kTextStackSpacing;

        // Prevent the vertical stack from stretching awkwardly in height
        [textStackView setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];

        // 6. Horizontal MainStack
        NSStackView* mainStackView = [NSStackView stackViewWithViews:@[ _iconImageView, textStackView ]];
        mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
        mainStackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
        mainStackView.alignment = NSLayoutAttributeCenterY;
        mainStackView.spacing = kMainStackSpacing;

        // AppKit NSStackView edgeInsets push views INWARD, so we use positive numbers here
        mainStackView.edgeInsets = NSEdgeInsetsMake(0, kMainStackInset, 0, kMainStackInset);

        [_badgeContainer addSubview:mainStackView];

        // 7. Core Auto Layout constraints
        [NSLayoutConstraint activateConstraints:@[
            // Center the badgeContainer inside the DragOverlayView bounds
            [_badgeContainer.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_badgeContainer.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],

            // Explicit dimensions for the badge background
            [_badgeContainer.widthAnchor constraintEqualToConstant:kBadgeWidth],
            [_badgeContainer.heightAnchor constraintEqualToConstant:kBadgeHeight],

            // Explicit dimensions for the icon
            [_iconImageView.widthAnchor constraintEqualToConstant:kIconSize],
            [_iconImageView.heightAnchor constraintEqualToConstant:kIconSize],

            // Stretch the main stack view to fill the badgeContainer entirely
            [mainStackView.leadingAnchor constraintEqualToAnchor:_badgeContainer.leadingAnchor],
            [mainStackView.trailingAnchor constraintEqualToAnchor:_badgeContainer.trailingAnchor],
            [mainStackView.topAnchor constraintEqualToAnchor:_badgeContainer.topAnchor],
            [mainStackView.bottomAnchor constraintEqualToAnchor:_badgeContainer.bottomAnchor]
        ]];
    }
    return self;
}

- (void)setOverlay:(NSImage*)icon mainLine:(NSString*)mainLine subLine:(NSString*)subLine
{
    self.iconImageView.image = icon;
    self.titleLabel.stringValue = mainLine ?: @"";
    self.subtitleLabel.stringValue = subLine ?: @"";
}

@end
