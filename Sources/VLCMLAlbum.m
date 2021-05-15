/*****************************************************************************
 * VLCMLAlbum.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2021 VLC authors and VideoLAN
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

#import "VLCMLAlbum.h"
#import "VLCMLAlbum+Init.h"
#import "VLCMLArtist+Init.h"
#import "VLCMLGenre+Init.h"
#import "VLCMLUtils.h"
#import "VLCMediaLibrary.h"

@interface VLCMLAlbum ()
{
    medialibrary::AlbumPtr _album;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shortSummary;
@property (nonatomic, copy, nullable) VLCMLArtist *albumArtist;

@end

@implementation VLCMLAlbum

#pragma mark - Getters/Setters

- (VLCMLIdentifier)identifier
{
    return _album->id();
}

- (NSString *)title
{
    if (!_title) {
        _title = [[NSString alloc] initWithUTF8String:_album->title().c_str()];
    }
    return _title;
}

- (NSArray<VLCMLMedia *> *)tracks
{
    return [VLCMLUtils arrayFromMediaQuery:_album->tracks()];
}

- (uint)releaseYear
{
    return _album->releaseYear();
}

- (NSString *)shortSummary
{
    if (!_shortSummary) {
        _shortSummary = [[NSString alloc] initWithUTF8String:_album->shortSummary().c_str()];
    }
    return _shortSummary;
}

- (VLCMLThumbnailStatus)isArtworkGenerated
{
    return [self isArtworkGeneratedForType:(VLCMLThumbnailSizeType)medialibrary::ThumbnailSizeType::Thumbnail];
}

- (VLCMLThumbnailStatus)isArtworkGeneratedForType:(VLCMLThumbnailSizeType)type
{
    return (VLCMLThumbnailStatus)_album->thumbnailStatus((medialibrary::ThumbnailSizeType)type);
}

- (NSURL *)artworkMRL
{
    return [self artworkMRLOfType:(VLCMLThumbnailSizeType)medialibrary::ThumbnailSizeType::Thumbnail];
}

- (NSURL *)artworkMRLOfType:(VLCMLThumbnailSizeType)type
{
    auto mrl = _album->thumbnailMrl((medialibrary::ThumbnailSizeType)type);

    if ( mrl.empty() ) {
        return nil;
    }

    return  [[NSURL alloc] initWithString:[NSString stringWithUTF8String:mrl.c_str()]];
}

- (VLCMLArtist *)albumArtist
{
    if (!_albumArtist) {
        _albumArtist =  [[VLCMLArtist alloc] initWithArtistPtr:_album->albumArtist()];
    }
    return _albumArtist;
}

- (NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_album->tracks(&param)];
}

- (NSArray<VLCMLMedia *> *)tracksByGenre:(VLCMLGenre *)genre
                         sortingCriteria:(VLCMLSortingCriteria)criteria
                                    desc:(BOOL)desc;
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_album->tracks([genre genrePtr], &param)];
}

- (NSArray<VLCMLArtist *> *)artists
{
    return [VLCMLUtils arrayFromArtistQuery:_album->artists()];
}

- (NSArray<VLCMLArtist *> *)artistWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                 desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromArtistQuery:_album->artists(&param)];
}

- (UInt32)numberOfTracks
{
    return _album->nbTracks();
}

- (UInt32)numberOfDiscs
{
    return _album->nbDiscs();
}

- (SInt64)duration
{
    return _album->duration();
}

- (BOOL)isUnknownAlbum
{
    return _album->isUnknownAlbum();
}

- (NSArray<VLCMLMedia *> *)searchTracks:(NSString *)pattern
{
    return [VLCMLUtils
            arrayFromMediaQuery:_album->searchTracks([pattern UTF8String])];
}

- (NSArray<VLCMLMedia *> *)searchTracks:(NSString *)pattern
                        sortingCriteria:(VLCMLSortingCriteria)criteria desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils
                                           queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_album->searchTracks([pattern UTF8String],
                                                                &param)];
}

@end

@implementation VLCMLAlbum (Internal)

- (instancetype)initWithAlbumPtr:(medialibrary::AlbumPtr)albumPtr
{
    if (albumPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _album = albumPtr;
    }
    return self;
}

@end
