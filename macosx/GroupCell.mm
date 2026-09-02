// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "GroupCell.h"
#import "NSStringAdditions.h"

// Layout
// Leading Stack
static CGFloat const kIndicatorSize = 14.0;
static NSEdgeInsets const kLeadingInsets = NSEdgeInsetsMake(0, 11, 0, 0);

// Trailing Stack
static CGFloat const kTrailingStackSize = 16.0;
static NSEdgeInsets const kTrailingInsets = NSEdgeInsetsMake(1, 0, 1, 5);

@interface GroupCell ()
@property(nonatomic, readonly) NSStackView* leadingStackView;
@property(nonatomic, readonly) NSStackView* trailingStackView;
@property(nonatomic, readonly) NSButton* downloadButton;
@property(nonatomic, readonly) NSButton* uploadButton;
@property(nonatomic, readonly) NSButton* ratioButton;
@end

@implementation GroupCell

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        [self configureViews];
        [self setupConstraints];
    }

    return self;
}

- (void)configureViews
{
    auto indicatorView = [[NSImageView alloc] init];
    indicatorView.imageScaling = NSImageScaleProportionallyDown;

    auto titleField = [[NSTextField alloc] init];
    titleField.editable = NO;
    titleField.selectable = NO;
    titleField.bordered = NO;
    titleField.font = [NSFont boldSystemFontOfSize:NSFont.smallSystemFontSize];
    titleField.drawsBackground = NO;
    titleField.textColor = NSColor.secondaryLabelColor;
    titleField.lineBreakMode = NSLineBreakByTruncatingMiddle;
    titleField.allowsExpansionToolTips = YES;

    auto downloadButton = [NSButton buttonWithTitle:@"" image:[NSImage imageNamed:@"DownArrowGroupTemplate"] target:nil action:nil];
    downloadButton.toolTip = NSLocalizedString(@"Download speed", "Torrent table -> group row -> tooltip");

    auto uploadButton = [NSButton buttonWithTitle:@"" image:[NSImage imageNamed:@"UpArrowGroupTemplate"] target:nil action:nil];
    uploadButton.toolTip = NSLocalizedString(@"Upload speed", "Torrent table -> group row -> tooltip");
    uploadButton.image.accessibilityDescription = NSLocalizedString(@"UL", "Torrent -> status image");

    auto ratioButton = [NSButton buttonWithTitle:@"" image:[NSImage imageNamed:@"YingYangGroupTemplate"] target:nil action:nil];
    ratioButton.toolTip = NSLocalizedString(@"Ratio", "Torrent table -> group row -> tooltip");
    ratioButton.image.accessibilityDescription = NSLocalizedString(@"Ratio", "Torrent -> status image");

    for (NSButton* button in @[ downloadButton, uploadButton, ratioButton ]) {
        button.imageScaling = NSImageScaleProportionallyDown;
        button.imagePosition = NSImageLeft;
        button.bordered = NO;
        button.font = [NSFont boldSystemFontOfSize:NSFont.smallSystemFontSize];
        button.contentTintColor = NSColor.secondaryLabelColor;
        button.lineBreakMode = NSLineBreakByClipping;
    }

    auto leadingStackView = [[NSStackView alloc] initWithFrame:NSZeroRect];
    [leadingStackView addArrangedSubview:indicatorView];
    [leadingStackView addArrangedSubview:titleField];
    leadingStackView.edgeInsets = kLeadingInsets;

    auto trailingStackView = [[NSStackView alloc] initWithFrame:NSZeroRect];

    [trailingStackView addArrangedSubview:downloadButton];
    [trailingStackView addArrangedSubview:uploadButton];
    [trailingStackView addArrangedSubview:ratioButton];
    trailingStackView.edgeInsets = kTrailingInsets;

    for (NSView* view in @[ leadingStackView, trailingStackView ]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
    }

    _indicatorView = indicatorView;
    _titleField = titleField;
    _downloadButton = downloadButton;
    _uploadButton = uploadButton;
    _ratioButton = ratioButton;
    _leadingStackView = leadingStackView;
    _trailingStackView = trailingStackView;
}

- (void)setupConstraints
{
    [NSLayoutConstraint activateConstraints:@[
        // Leading Stack
        [self.leadingStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.leadingStackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.indicatorView.widthAnchor constraintEqualToConstant:kIndicatorSize],
        [self.indicatorView.heightAnchor constraintEqualToConstant:kIndicatorSize],

        // Trailing Stack
        [self.trailingStackView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.titleField.trailingAnchor],
        [self.trailingStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.trailingStackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.trailingStackView.heightAnchor constraintEqualToConstant:kTrailingStackSize],
    ]];

    [self.titleField setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                              forOrientation:NSLayoutConstraintOrientationHorizontal];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    [super setBackgroundStyle:backgroundStyle];

    auto isEmphasized = backgroundStyle == NSBackgroundStyleEmphasized;
    self.titleField.textColor = isEmphasized ? NSColor.labelColor : NSColor.secondaryLabelColor;
}

- (void)setDownloadSpeed:(CGFloat)downloadSpeed uploadSpeed:(CGFloat)uploadSpeed ratio:(CGFloat)ratio
{
    _downloadButton.title = [NSString stringForSpeed:downloadSpeed];
    _uploadButton.title = [NSString stringForSpeed:uploadSpeed];
    _ratioButton.title = [NSString stringForRatio:ratio];
}

- (void)setDisplayRatio:(BOOL)displayRatio
{
    _downloadButton.hidden = displayRatio;
    _uploadButton.hidden = displayRatio;
    _ratioButton.hidden = !displayRatio;
}

- (void)setTooltipForTorrentsCount:(NSUInteger)count
{
    NSString* tooltipGroup;
    if (count == 1) {
        tooltipGroup = NSLocalizedString(@"1 transfer", "Torrent table -> group row -> tooltip");
    } else {
        tooltipGroup = NSLocalizedString(@"%lu transfers", "Torrent table -> group row -> tooltip");
        tooltipGroup = [NSString localizedStringWithFormat:tooltipGroup, count];
    }
    self.toolTip = tooltipGroup;
}

@end
