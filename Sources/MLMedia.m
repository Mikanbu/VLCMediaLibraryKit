/*****************************************************************************
 * MLMedia.m
 * MediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2017 VLC authors and VideoLAN
 * $Id$
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

#import "MLMedia.h"
#import "MLMedia+Init.h"
#import "MLArtist.h"
#import "MLMediaLibrary.h"
#import "MLMediaMetadata.h"

@interface MLMedia ()
{
    medialibrary::MediaPtr _media;
    medialibrary::IMediaLibrary *_ml;
}
@end

@implementation MLMedia

#pragma mark - Private Helpers

- (void)_cacheFromCurrentMediaPtr
{
    if (_media) {
        _title = [[NSString alloc] initWithUTF8String:_media->title().c_str()];
        _thumbnail = [[NSString alloc] initWithUTF8String:_media->thumbnail().c_str()];
    }
}

#pragma mark - Initialization

- (instancetype)initWithIdentifier:(int64_t)identifier
{
    self = [super init];
    if (self) {
        _ml = (medialibrary::IMediaLibrary *)[MLMediaLibrary sharedInstance];
        if ((_media = _ml->media(identifier))) {
            [self _cacheFromCurrentMediaPtr];
        }
    }
    return self;
}

#pragma mark - Getters/Setters

- (int64_t)identifier
{
    return _media->id();
}

- (MLMediaType)type
{
    return (MLMediaType)_media->type();
}

- (MLMediaSubType)subType
{
    return (MLMediaSubType)_media->subType();
}

- (BOOL)updateTitle:(NSString *)title
{
    BOOL success = _media->setTitle([title UTF8String]);

    NSAssert(success, @"Failed to update title.");
    _title = title;
    return success;
}

- (int64_t)duration
{
    return _media->duration();
}

- (int)playCount
{
    return _media->playCount();
}

- (BOOL)increasePlayCount
{
    return _media->increasePlayCount();
}

- (BOOL)isFavorite
{
    return _media->isFavorite();
}

- (BOOL)setFavorite:(BOOL)favorite
{
    return _media->setFavorite(favorite);
}

- (MLMediaMetadata *)metadataOfType:(MLMetadataType)type
{
//    _media->metadata((medialibrary::IMedia::MetadataType)type);
//
//    MLMediaMetadata *md = [[MLMediaMetadata alloc] initWith:nil];
    return nil;
}

- (uint)insertionDate
{
    return _media->insertionDate();
}

- (uint)releaseDate
{
    return _media->releaseDate();
}

@end

@implementation MLMedia (Internal)

- (instancetype)initWithMediaPtr:(medialibrary::MediaPtr)mediaPtr
{
    self = [super init];
    _media = mediaPtr;
    [self _cacheFromCurrentMediaPtr];
    return self;
}

@end
