/*****************************************************************************
 * VLCMLFile.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2021 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Felix Paul Kühne <fkuehne # videolan.org>
 *          Pierre d'Herbemont <pdherbemont # videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#import "VLCMLFile.h"
#import "VLCMLFile+Init.h"

@interface VLCMLFile ()
{
    medialibrary::FilePtr _file;
}

@property (nonatomic, copy) NSURL *mrl;
@end

@implementation VLCMLFile

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, type: %li, mrl: %@",
            NSStringFromClass([self class]), self.identifier, self.type, self.mrl];
}

- (VLCMLIdentifier)identifier
{
    return _file->id();
}

- (NSURL *)mrl
{
    if (!_mrl) {
        _mrl = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:_file->mrl().c_str()]];
    }
    return _mrl;
}

- (VLCMLFileType)type
{
    return (VLCMLFileType)_file->type();
}

- (time_t)lastModificationDate
{
    return _file->lastModificationDate();
}

- (int64_t)size
{
    return _file->size();
}

- (BOOL)isRemovable
{
    return _file->isRemovable();
}

- (BOOL)isExternal
{
    return _file->isExternal();
}

- (BOOL)isNetwork
{
    return _file->isNetwork();
}

- (BOOL)isMain
{
    return _file->isMain();
}

- (void)deleteFile
{
    /* for safety reasons, we don't allow deleting files that
     * are not indexed by the media library
     * or are on the network */
    if (self.isExternal || self.isNetwork) {
        return;
    }

    __block NSString *path = self.mrl.path;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        @catch (NSException *exception) {
            NSAssert(1, @"VLCMLFile: Delete failed: %@", exception.reason);
        }
    });
}

@end

@implementation VLCMLFile (Internal)

- (instancetype)initWithFilePtr:(medialibrary::FilePtr)filePtr
{
    if (filePtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _file = std::move(filePtr);
    }
    return self;
}

@end
