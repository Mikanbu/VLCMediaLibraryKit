/*****************************************************************************
 * VLCMedia.m
 * MediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2018 VLC authors and VideoLAN
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

#import "VLCMedia.h"
#import "VLCMedia+Init.h"
#import "VLCLabel+Init.h"
#import "VLCMovie+Init.h"
#import "VLCFile+Init.h"
#import "VLCAlbumTrack+Init.h"
#import "VLCShowEpisode+Init.h"
#import "VLCMediaMetadata+Init.h"


@interface VLCMedia ()
{
    medialibrary::MediaPtr _media;
}
@end

@implementation VLCMedia

#pragma mark - Getters/Setters

- (int64_t)identifier
{
    return _media->id();
}

- (VLCMediaType)type
{
    return (VLCMediaType)_media->type();
}

- (VLCMediaSubType)subType
{
    return (VLCMediaSubType)_media->subType();
}

- (NSString *)title
{
    if (!_title) {
        _title = [[NSString alloc] initWithUTF8String:_media->title().c_str()];
    }
    return _title;
}

- (BOOL)updateTitle:(NSString *)title
{
    BOOL success = _media->setTitle([title UTF8String]);

    NSAssert(success, @"Failed to update title.");
    _title = title;
    return success;
}

- (VLCAlbumTrack *)albumTrack
{
    if (!_albumTrack) {
        _albumTrack = [[VLCAlbumTrack alloc] initWithAlbumTrackPtr:_media->albumTrack()];
    }
    return _albumTrack;
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

- (VLCShowEpisode *)showEpisode
{
    if (!_showEpisode) {
        _showEpisode = [[VLCShowEpisode alloc] initWithShowEpisodePtr:_media->showEpisode()];
    }
    return _showEpisode;
}

- (NSArray<VLCFile *> *)files
{
    auto files = _media->files();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &file : files) {
        [result addObject:[[VLCFile alloc] initWithFilePtr:file]];
    }
    return result;
}

- (VLCFile *)addExternalMrl:(NSString *)mrl fileType:(VLCFileType)type
{
    return [[VLCFile alloc] initWithFilePtr:_media->addExternalMrl([mrl UTF8String], (medialibrary::IFile::Type)type)];
}

- (BOOL)isFavorite
{
    return _media->isFavorite();
}

- (BOOL)setFavorite:(BOOL)favorite
{
    return _media->setFavorite(favorite);
}

- (BOOL)addLabel:(VLCLabel *)label
{
    return _media->addLabel([label labelPtr]);
}

- (BOOL)removeLabel:(VLCLabel *)label
{
    return _media->removeLabel([label labelPtr]);
}

- (VLCMovie *)movie
{
    if (!_movie) {
        _movie = [[VLCMovie alloc] initWithMoviePtr:_media->movie()];
    }
    return _movie;
}

- (NSArray<VLCLabel *> *)labels
{
    if (!_labels) {
        auto labels = _media->labels();
        NSMutableArray *result = [NSMutableArray array];

        for (const auto &label : labels) {
            [result addObject:[[VLCLabel alloc] initWithLabelPtr:label]];
        }
    }
    return _labels;
}

- (NSString *)thumbnail
{
    if (!_thumbnail) {
        _thumbnail = [[NSString alloc] initWithUTF8String:_media->thumbnail().c_str()];
    }
    return _thumbnail;
}

- (uint)insertionDate
{
    return _media->insertionDate();
}

- (uint)releaseDate
{
    return _media->releaseDate();
}

- (VLCMediaMetadata *)metadataOfType:(VLCMetadataType)type
{
    return [[VLCMediaMetadata alloc] initWithMediaMetadata:_media->metadata((medialibrary::IMedia::MetadataType)type)];
}

- (BOOL)setMetadataOfType:(VLCMetadataType)type stringValue:(NSString *)value
{
    return _media->setMetadata((medialibrary::IMedia::MetadataType)type , [value UTF8String]);
}

- (BOOL)setMetadataOfType:(VLCMetadataType)type intValue:(int64_t)value
{
    return _media->setMetadata((medialibrary::IMedia::MetadataType)type, value);
}


@end

@implementation VLCMedia (Internal)

- (instancetype)initWithMediaPtr:(medialibrary::MediaPtr)mediaPtr
{
    self = [super init];
    if (self) {
        _media = mediaPtr;
    }
    return self;
}

- (medialibrary::MediaPtr)mediaPtr
{
    return _media;
}

@end
