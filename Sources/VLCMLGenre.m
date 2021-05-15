/*****************************************************************************
 * VLCMLGenre.m
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

#import "VLCMLGenre.h"
#import "VLCMLGenre+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLGenre ()
{
    medialibrary::GenrePtr _genre;
}

@property (nonatomic, copy) NSString *name;
@end

@implementation VLCMLGenre

- (VLCMLIdentifier)identifier
{
    return _genre->id();
}

- (NSString *)name
{
    if (!_name) {
        _name = [[NSString alloc] initWithUTF8String:_genre->name().c_str()];
    }
    return _name;
}

- (UInt32)numberOfTracks
{
    return _genre->nbTracks();
}

#pragma mark - Thumbnail

- (NSString *)thumbnailMRLWithType:(VLCMLThumbnailSizeType)type
{
    return [NSString
            stringWithUTF8String:_genre->thumbnailMrl((medialibrary::ThumbnailSizeType)type).c_str()];
}

- (BOOL)hasThumbnailOfType:(VLCMLThumbnailSizeType)type
{
    return _genre->hasThumbnail((medialibrary::ThumbnailSizeType)type);
}

- (BOOL)setThumbnailWithMRL:(NSURL *)mrl
                   sizeType:(VLCMLThumbnailSizeType)type
              takeOwnership:(BOOL)takeOwnership
{
    return _genre->setThumbnail([mrl.absoluteString UTF8String],
                                (medialibrary::ThumbnailSizeType)type, takeOwnership);
}

#pragma mark -

- (NSArray<VLCMLArtist *> *)artists
{
    return [VLCMLUtils arrayFromArtistQuery:_genre->artists()];
}

- (NSArray<VLCMLArtist *> *)artistWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                 desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromArtistQuery:_genre->artists(&param)];
}

- (NSArray<VLCMLMedia *> *)tracks
{
    return [VLCMLUtils arrayFromMediaQuery:_genre->tracks(medialibrary::IGenre::TracksIncluded::All)];
}

- (NSArray<VLCMLMedia *> *)tracksWithThumbnails:(BOOL)thumbnails
{
    return [VLCMLUtils arrayFromMediaQuery:_genre->tracks(medialibrary::IGenre::TracksIncluded::WithThumbnailOnly)];
}

- (NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_genre->tracks(medialibrary::IGenre::TracksIncluded::All,
                                                          &param)];
}

- (NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc
                                          thumbnails:(BOOL)thumbnails
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_genre->tracks(medialibrary::IGenre::TracksIncluded::WithThumbnailOnly,
                                                          &param)];
}

- (NSArray<VLCMLAlbum *> *)albums
{
    return [VLCMLUtils arrayFromAlbumQuery:_genre->albums()];
}

- (NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromAlbumQuery:_genre->albums(&param)];
}

@end

@implementation VLCMLGenre (Internal)

- (instancetype)initWithGenrePtr:(medialibrary::GenrePtr)genrePtr
{
    if (genrePtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _genre = genrePtr;
    }
    return self;
}

- (medialibrary::GenrePtr)genrePtr
{
    return _genre;
}

@end
