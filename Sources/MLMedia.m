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
#import "MLLabel+Init.h"
#import "MLMovie+Init.h"
#import "MLFile+Init.h"
#import "MLAlbumTrack+Init.h"
#import "MLShowEpisode+Init.h"
#import "MLMediaMetadata+Init.h"


@interface MLMedia ()
{
    medialibrary::MediaPtr _media;
}
@end

@implementation MLMedia

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

- (MLAlbumTrack *)albumTrack
{
    if (!_albumTrack) {
        _albumTrack = [[MLAlbumTrack alloc] initWithAlbumTrackPtr:_media->albumTrack()];
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

- (MLShowEpisode *)showEpisode
{
    if (!_showEpisode) {
        _showEpisode = [[MLShowEpisode alloc] initWithShowEpisodePtr:_media->showEpisode()];
    }
    return _showEpisode;
}

- (NSArray<MLFile *> *)files
{
    auto files = _media->files();
    NSMutableArray *result = [NSMutableArray array];

    for (const auto &file : files) {
        [result addObject:[[MLFile alloc] initWithFilePtr:file]];
    }
    return result;
}

- (MLFile *)addExternalMrl:(NSString *)mrl fileType:(MLFileType)type
{
    return [[MLFile alloc] initWithFilePtr:_media->addExternalMrl([mrl UTF8String], (medialibrary::IFile::Type)type)];
}

- (BOOL)isFavorite
{
    return _media->isFavorite();
}

- (BOOL)setFavorite:(BOOL)favorite
{
    return _media->setFavorite(favorite);
}

- (BOOL)addLabel:(MLLabel *)label
{
    return _media->addLabel([label labelPtr]);
}

- (BOOL)removeLabel:(MLLabel *)label
{
    return _media->removeLabel([label labelPtr]);
}

- (MLMovie *)movie
{
    if (!_movie) {
        _movie = [[MLMovie alloc] initWithMoviePtr:_media->movie()];
    }
    return _movie;
}

- (NSArray<MLLabel *> *)labels
{
    if (!_labels) {
        auto labels = _media->labels();
        NSMutableArray *result = [NSMutableArray array];

        for (const auto &label : labels) {
            [result addObject:[[MLLabel alloc] initWithLabelPtr:label]];
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

- (MLMediaMetadata *)metadataOfType:(MLMetadataType)type
{

    return [[MLMediaMetadata alloc] initWithMediaMetadata:_media->metadata((medialibrary::IMedia::MetadataType)type)];
}

- (BOOL)setMetadataOfType:(MLMetadataType)type stringValue:(NSString *)value
{
    return _media->setMetadata((medialibrary::IMedia::MetadataType)type , [value UTF8String]);
}

- (BOOL)setMetadataOfType:(MLMetadataType)type intValue:(int64_t)value
{
    return _media->setMetadata((medialibrary::IMedia::MetadataType)type, value);
}


@end

@implementation MLMedia (Internal)

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
