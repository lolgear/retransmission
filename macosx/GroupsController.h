// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>

@class Torrent;

@interface GroupsController : NSObject

@property(nonatomic, class, readonly) GroupsController* groups;

@property(nonatomic, readonly) NSInteger numberOfGroups;

- (NSInteger)rowValueForIndex:(NSInteger)index;
- (NSInteger)indexForRow:(NSInteger)row;

- (nullable NSString*)nameForIndex:(NSInteger)index;
- (void)setName:(NSString*)name forIndex:(NSInteger)index;

- (nonnull NSImage*)imageForIndex:(NSInteger)index;

- (nullable NSColor*)colorForIndex:(NSInteger)index;
- (void)setColor:(nullable NSColor*)color forIndex:(NSInteger)index;

- (BOOL)usesCustomDownloadLocationForIndex:(NSInteger)index;
- (void)setUsesCustomDownloadLocation:(BOOL)useCustomLocation forIndex:(NSInteger)index;

- (nullable NSString*)customDownloadLocationForIndex:(NSInteger)index;
- (void)setCustomDownloadLocation:(nullable NSString*)location forIndex:(NSInteger)index;

- (BOOL)usesAutoAssignRulesForIndex:(NSInteger)index;
- (void)setUsesAutoAssignRules:(BOOL)useAutoAssignRules forIndex:(NSInteger)index;

- (nullable NSPredicate*)autoAssignRulesForIndex:(NSInteger)index;
- (void)setAutoAssignRules:(nullable NSPredicate*)predicate forIndex:(NSInteger)index;

- (void)addNewGroup;
- (void)removeGroupWithRowIndex:(NSInteger)row;

- (void)moveGroupAtRow:(NSInteger)oldRow toRow:(NSInteger)newRow;

- (nonnull NSMenu*)groupMenuWithTarget:(id)target action:(SEL)action isSmall:(BOOL)small;

- (NSInteger)groupIndexForTorrent:(Torrent*)torrent;
@end
