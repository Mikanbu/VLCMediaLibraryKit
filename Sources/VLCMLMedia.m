/*****************************************************************************
 * VLCMLMedia.m
 * VLCMediaLibraryKit
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

#import "VLCMLMedia.h"
#import "VLCMLMedia+Init.h"
#import "VLCMLLabel+Init.h"
#import "VLCMLMovie+Init.h"
#import "VLCMLFile+Init.h"
#import "VLCMLAlbumTrack+Init.h"
#import "VLCMLShowEpisode+Init.h"
#import "VLCMLMetadata+Init.h"
#import "VLCMLAudioTrack+Init.h"
#import "VLCMLVideoTrack+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLMedia ()
{
    medialibrary::MediaPtr _media;
}
@end

@implementation VLCMLMedia

#pragma mark - Getters/Setters

- (VLCMLIdentifier)identifier {
    return _media->id();
}

- (VLCMLMediaType)type
{
    return (VLCMLMediaType)_media->type();
}

- (VLCMLMediaSubtype)subtype
{
    return (VLCMLMediaSubtype)_media->subType();
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

- (VLCMLAlbumTrack *)albumTrack
{
    if (!_albumTrack) {
        _albumTrack = [[VLCMLAlbumTrack alloc] initWithAlbumTrackPtr:_media->albumTrack()];
    }
    return _albumTrack;
}

- (SInt64)duration
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

- (BOOL)setPlayCount:(UInt32)playCount
{
    return _media->setPlayCount(playCount);
}

- (VLCMLShowEpisode *)showEpisode
{
    if (!_showEpisode) {
        _showEpisode = [[VLCMLShowEpisode alloc] initWithShowEpisodePtr:_media->showEpisode()];
    }
    return _showEpisode;
}

- (NSArray<VLCMLFile *> *)files
{
    if (!_files) {
        auto files = _media->files();
        NSMutableArray *result = [NSMutableArray array];

        for (const auto &file : files) {
            [result addObject:[[VLCMLFile alloc] initWithFilePtr:file]];
        }
        _files = [result copy];
    }
    return _files;
}

- (VLCMLFile *)mainFile
{
    if (!_files) {
        [self files];
    }
    for (VLCMLFile *file in _files) {
        if (file.isMain) {
            return file;
        }
    }
    return nil;
}

- (VLCMLFile *)addExternalMrl:(NSURL *)mrl fileType:(VLCMLFileType)type
{
    return [[VLCMLFile alloc] initWithFilePtr:_media->addExternalMrl([mrl.absoluteString UTF8String],
                                                                     (medialibrary::IFile::Type)type)];
}

- (BOOL)isFavorite
{
    return _media->isFavorite();
}

- (BOOL)setFavorite:(BOOL)favorite
{
    return _media->setFavorite(favorite);
}

- (BOOL)addLabel:(VLCMLLabel *)label
{
    return _media->addLabel([label labelPtr]);
}

- (BOOL)removeLabel:(VLCMLLabel *)label
{
    return _media->removeLabel([label labelPtr]);
}

- (VLCMLMovie *)movie
{
    if (!_movie) {
        _movie = [[VLCMLMovie alloc] initWithMoviePtr:_media->movie()];
    }
    return _movie;
}

- (NSArray<VLCMLLabel *> *)labels
{
    if (!_labels) {
        auto labels = _media->labels();
        NSMutableArray *result = [NSMutableArray array];

        for (const auto &label : labels->all()) {
            [result addObject:[[VLCMLLabel alloc] initWithLabelPtr:label]];
        }
        _labels = [result copy];
    }
    return _labels;
}

- (NSArray<VLCMLAudioTrack *> *)audioTracks
{
    if (!_audioTracks) {
        auto audioTracks = _media->audioTracks();
        NSMutableArray *result = [NSMutableArray array];

        for (const auto &audioTrack : audioTracks->all()) {
            [result addObject:[[VLCMLAudioTrack alloc] initWithAudioTrackPtr:audioTrack]];
        }
        _audioTracks = [result copy];
    }
    return _audioTracks;
}

- (NSArray<VLCMLVideoTrack *> *)videoTracks
{
    if (!_videoTracks) {
        auto videoTracks = _media->videoTracks();
        NSMutableArray *result = [NSMutableArray array];

        for (const auto &videoTrack : videoTracks->all()) {
            [result addObject:[[VLCMLVideoTrack alloc] initWithVideoTrackPtr:videoTrack]];
        }
        _videoTracks = [result copy];
    }
    return _videoTracks;
}

- (NSURL *)thumbnail
{
    if (!_thumbnail) {
        _thumbnail = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:_media->thumbnail().c_str()]];
    }
    return _thumbnail;
}

- (BOOL)isThumbnailGenerated
{
    return _media->isThumbnailGenerated();
}

- (NSDate *)insertionDate
{
    return [NSDate dateWithTimeIntervalSince1970:_media->insertionDate()];
}

- (NSDate *)releaseDate
{
    return [NSDate dateWithTimeIntervalSince1970:_media->releaseDate()];
}

- (VLCMLMetadata *)metadataOfType:(VLCMLMetadataType)type
{
    return [[VLCMLMetadata alloc] initWithMetadata:_media->metadata((medialibrary::IMedia::MetadataType)type)];
}

- (BOOL)setMetadataOfType:(VLCMLMetadataType)type stringValue:(NSString *)value
{
    return _media->setMetadata((medialibrary::IMedia::MetadataType)type , [value UTF8String]);
}

- (BOOL)setMetadataOfType:(VLCMLMetadataType)type intValue:(SInt64)value
{
    return _media->setMetadata((medialibrary::IMedia::MetadataType)type, value);
}

@end

@implementation VLCMLMedia (Internal)

- (instancetype)initWithMediaPtr:(medialibrary::MediaPtr)mediaPtr
{
    if (mediaPtr == nullptr) {
        return NULL;
    }

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
