#import "TrackerCell.h"
#import "TrackerNode.h"
#import <libtransmission/web-utils.h> // tr_addressIsIP()

static NSCache<NSString*, NSImage*>* fTrackerIconCache;
static NSMutableSet<NSString*>* fTrackerIconLoading;

@interface TrackerView ()

@property(nonatomic, strong) NSImageView* faviconView;
@property(nonatomic, strong) NSTextField* nameLabel;

@property(nonatomic, strong) NSTextField* lastAnnounceLabel;
@property(nonatomic, strong) NSTextField* nextAnnounceLabel;
@property(nonatomic, strong) NSTextField* lastScrapeLabel;

@property(nonatomic, strong) NSTextField* seederLabel;
@property(nonatomic, strong) NSTextField* leecherLabel;
@property(nonatomic, strong) NSTextField* downloadedLabel;

@property(nonatomic, weak, nullable) TrackerNode* currentNode;

@end

@implementation TrackerView

+ (void)initialize
{
    if (self == [TrackerView self]) {
        fTrackerIconCache = [[NSCache alloc] init];
        fTrackerIconCache.countLimit = 100;
        fTrackerIconLoading = [[NSMutableSet alloc] init];
    }
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setupLayout];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout
{
    self.faviconView = [NSImageView imageViewWithImage:[NSImage imageWithSystemSymbolName:@"globe" accessibilityDescription:nil]];
    self.faviconView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.faviconView.widthAnchor constraintEqualToConstant:16.0],
        [self.faviconView.heightAnchor constraintEqualToConstant:16.0]
    ]];

    self.nameLabel = [NSTextField labelWithString:@""];
    self.nameLabel.font = [NSFont messageFontOfSize:12.0];
    self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    self.lastAnnounceLabel = [NSTextField labelWithString:@""];
    self.nextAnnounceLabel = [NSTextField labelWithString:@""];
    self.lastScrapeLabel = [NSTextField labelWithString:@""];

    self.seederLabel = [NSTextField labelWithString:@""];
    self.leecherLabel = [NSTextField labelWithString:@""];
    self.downloadedLabel = [NSTextField labelWithString:@""];

    NSArray* subLabels = @[
        self.lastAnnounceLabel,
        self.nextAnnounceLabel,
        self.lastScrapeLabel,
        self.seederLabel,
        self.leecherLabel,
        self.downloadedLabel
    ];
    for (NSTextField* label in subLabels) {
        label.font = [NSFont messageFontOfSize:9.5];
        label.textColor = NSColor.secondaryLabelColor;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
    }

    self.seederLabel.alignment = NSTextAlignmentRight;
    self.leecherLabel.alignment = NSTextAlignmentRight;
    self.downloadedLabel.alignment = NSTextAlignmentRight;

    NSGridView* gridView = [NSGridView gridViewWithViews:@[
        @[ self.nameLabel, [NSGridCell emptyContentView] ],
        @[ self.lastAnnounceLabel, self.seederLabel ],
        @[ self.nextAnnounceLabel, self.leecherLabel ],
        @[ self.lastScrapeLabel, self.downloadedLabel ]
    ]];

    gridView.rowSpacing = 1.0;
    gridView.columnSpacing = 8.0;
    gridView.translatesAutoresizingMaskIntoConstraints = NO;

    [gridView columnAtIndex:0].xPlacement = NSGridCellPlacementFill;
    [gridView columnAtIndex:1].width = 95.0;
    [gridView columnAtIndex:1].xPlacement = NSGridCellPlacementFill;

    NSStackView* mainStack = [NSStackView stackViewWithViews:@[ self.faviconView, gridView ]];
    mainStack.spacing = 5.0;
    mainStack.alignment = NSLayoutAttributeTop;
    mainStack.distribution = NSStackViewDistributionFill;
    mainStack.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:mainStack];

    [NSLayoutConstraint activateConstraints:@[
        [mainStack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5.0],
        [mainStack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5.0],
        [mainStack.topAnchor constraintEqualToAnchor:self.topAnchor constant:2.0],
        [mainStack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-2.0]
    ]];
}

#pragma mark - Конфигурация данными

- (void)configureWithNode:(TrackerNode*)node
{
    self.currentNode = node;

    self.nameLabel.stringValue = node.host ?: @"";

    self.lastAnnounceLabel.stringValue = node.lastAnnounceStatusString ?: @"";
    self.nextAnnounceLabel.stringValue = node.nextAnnounceStatusString ?: @"";
    self.lastScrapeLabel.stringValue = node.lastScrapeStatusString ?: @"";

    self.seederLabel.stringValue = [NSString
        stringWithFormat:@"%@: %@", NSLocalizedString(@"Seeders", nil), [self stringForCount:node.totalSeeders]];
    self.leecherLabel.stringValue = [NSString
        stringWithFormat:@"%@: %@", NSLocalizedString(@"Leechers", nil), [self stringForCount:node.totalLeechers]];
    self.downloadedLabel.stringValue = [NSString
        stringWithFormat:@"%@: %@", NSLocalizedString(@"Downloaded", nil), [self stringForCount:node.totalDownloaded]];

    [self updateFavIconForAddress:node.fullAnnounceAddress];
}

- (NSString*)stringForCount:(NSInteger)count
{
    return count != -1 ? [NSString localizedStringWithFormat:@"%ld", count] : NSLocalizedString(@"N/A", nil);
}

#pragma mark - Асинхронный Кеш Иконок

- (void)updateFavIconForAddress:(NSString*)addressString
{
    NSURL* address = [NSURL URLWithString:addressString];
    NSString* host = address.host;

    if (!host || tr_addressIsIP(host.UTF8String)) {
        self.faviconView.image = [NSImage imageWithSystemSymbolName:@"globe" accessibilityDescription:nil];
        return;
    }

    NSArray<NSString*>* hostComponents = [host componentsSeparatedByString:@"."];
    if (hostComponents.count < 2) {
        self.faviconView.image = [NSImage imageWithSystemSymbolName:@"globe" accessibilityDescription:nil];
        return;
    }

    NSString* domain = hostComponents[hostComponents.count - 2];
    NSString* tld = hostComponents[hostComponents.count - 1];
    NSString* baseAddress = [NSString stringWithFormat:@"%@.%@", domain, tld];

    NSImage* cachedIcon = [fTrackerIconCache objectForKey:baseAddress];
    if (cachedIcon) {
        self.faviconView.image = ((id)cachedIcon == NSNull.null) ?
            [NSImage imageWithSystemSymbolName:@"globe" accessibilityDescription:nil] :
            cachedIcon;
        return;
    }

    self.faviconView.image = [NSImage imageWithSystemSymbolName:@"globe" accessibilityDescription:nil];

    if ([fTrackerIconLoading containsObject:baseAddress]) {
        return;
    }
    [fTrackerIconLoading addObject:baseAddress];

    NSString* favIconUrl = [NSString stringWithFormat:@"https://icons.duckduckgo.com/ip3/%@.ico", baseAddress];

    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:favIconUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];

    __weak TrackerView* weakSelf = self;
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;

        if (error) {
            NSLog(@"Unable to get tracker icon: task failed (%@)", error.localizedDescription);
            return;
        }
        BOOL ok = ((NSHTTPURLResponse*)response).statusCode == 200 ? YES : NO;
        if (!ok) {
            NSLog(@"Unable to get tracker icon: status code not OK (%ld)", (long)((NSHTTPURLResponse*)response).statusCode);
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf onDidLoadIconData:data baseAddress:baseAddress];
        });
    }] resume];
}

- (void)onDidLoadIconData:(NSData*)data baseAddress:(NSString*)baseAddress
{
    NSImage* icon = [[NSImage alloc] initWithData:data];
    if (icon) {
        [fTrackerIconCache setObject:icon forKey:baseAddress];
        if ([self.currentNode.fullAnnounceAddress containsString:baseAddress]) {
            self.faviconView.image = icon;
        }
    } else {
        [fTrackerIconCache setObject:(NSImage*)NSNull.null forKey:baseAddress];
    }
    [fTrackerIconLoading removeObject:baseAddress];
}

@end
