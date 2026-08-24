// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>
#import "TorrentTableView.h"

@interface TorrentCell : NSTableCellView

@property(nonatomic) NSButton* fActionButton;
@property(nonatomic) NSButton* fControlButton;
@property(nonatomic) NSButton* fRevealButton;

@property(nonatomic) NSImageView* fIconView;
@property(nonatomic) NSImageView* fGroupIndicatorView;

@property(nonatomic) NSStackView* fStackView;
@property(nonatomic) NSTextField* fTorrentTitleField;
@property(nonatomic) NSImageView* fTorrentPriorityView;

@property(nonatomic) NSTextField* fTorrentProgressField;
@property(nonatomic) NSTextField* fTorrentStatusField;

@property(nonatomic) NSView* fTorrentProgressBarView;

@property(nonatomic, weak) TorrentTableView* fTorrentTableView;

- (void)configureViews;
- (void)configurePriorities;
- (void)setupConstraints;

@end
