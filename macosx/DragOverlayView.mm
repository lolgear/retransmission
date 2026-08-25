// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "DragOverlayView.h"

@interface DragOverlayView ()

@property(nonatomic, strong) NSView* badgeContainer;
@property(nonatomic, strong) NSImageView* iconImageView;
@property(nonatomic, strong) NSTextField* titleLabel;
@property(nonatomic, strong) NSTextField* subtitleLabel;

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
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _iconImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
        [_badgeContainer addSubview:_iconImageView];

        // 3. Title
        _titleLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.editable = NO;
        _titleLabel.selectable = NO;
        _titleLabel.drawsBackground = NO;
        _titleLabel.bordered = NO;
        _titleLabel.font = [NSFont boldSystemFontOfSize:18.0];
        _titleLabel.textColor = NSColor.whiteColor;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_badgeContainer addSubview:_titleLabel];

        // 4. Subtitle
        _subtitleLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _subtitleLabel.editable = NO;
        _subtitleLabel.selectable = NO;
        _subtitleLabel.drawsBackground = NO;
        _subtitleLabel.bordered = NO;
        _subtitleLabel.font = [NSFont systemFontOfSize:14.0];
        _subtitleLabel.textColor = NSColor.whiteColor;
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_badgeContainer addSubview:_subtitleLabel];

        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints
{
    // Activate Auto Layout constraints
    [NSLayoutConstraint activateConstraints:@[
        // Center the badgeContainer within DragOverlayView
        [self.badgeContainer.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.badgeContainer.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],

        // Fixed badge dimensions from the original spec
        [self.badgeContainer.widthAnchor constraintEqualToConstant:325.0],
        [self.badgeContainer.heightAnchor constraintEqualToConstant:84.0],

        // Icon layout constraints (padding: 10.0, size: 64x64, vertically centered)
        [self.iconImageView.leadingAnchor constraintEqualToAnchor:self.badgeContainer.leadingAnchor constant:10.0],
        [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.badgeContainer.centerYAnchor],
        [self.iconImageView.widthAnchor constraintEqualToConstant:64.0],
        [self.iconImageView.heightAnchor constraintEqualToConstant:64.0],

        // Main label layout constraints (spacing from icon: 5.0, padding right: 10.0)
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:5.0],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.badgeContainer.trailingAnchor constant:-10.0],
        // Position the main label slightly above the badge center line
        [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.badgeContainer.centerYAnchor constant:2.0],

        // Sub label layout constraints (aligned horizontally with the main label)
        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.subtitleLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
        // Stack the sub label right under the main label with a 2-point gap
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:2.0]
    ]];
}

- (void)setOverlay:(NSImage*)icon mainLine:(NSString*)mainLine subLine:(NSString*)subLine
{
    self.iconImageView.image = icon;
    self.titleLabel.stringValue = mainLine ?: @"";
    self.subtitleLabel.stringValue = subLine ?: @"";
}

@end
