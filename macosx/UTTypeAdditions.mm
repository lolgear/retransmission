#import "UTTypeAdditions.h"

static NSString* const kTorrentFileType = @"org.bittorrent.torrent";

@implementation UTType (Torrent)
+ (UTType*)torrent
{
    static UTType* result = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [UTType exportedTypeWithIdentifier:kTorrentFileType conformingToType:UTTypeData];
    });

    return result;
}

+ (UTType*)contentTypeForFilenameExtension:(NSString*)fileExtension isFolder:(BOOL)isFolder
{
    if (isFolder) {
        return UTTypeFolder;
    }

    UTType* fileType = nil;
    if (fileExtension.length > 0) {
        fileType = [UTType typeWithFilenameExtension:fileExtension];
    }

    return fileType ?: UTTypeData;
}
@end
