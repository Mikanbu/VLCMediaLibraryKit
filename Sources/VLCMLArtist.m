/*****************************************************************************
 * VLCMLArtist.m
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

#import "VLCMLArtist.h"
#import "VLCMLArtist+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLArtist ()
{
    medialibrary::ArtistPtr _artist;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *shortBio;
@property (nonatomic, copy) NSString *musicBrainzId;
@end

@implementation VLCMLArtist

#pragma mark - Getters/Setters

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, name: %@",
            NSStringFromClass([self class]), self.identifier, self.name];
}

- (VLCMLIdentifier)identifier
{
    return _artist->id();
}

- (NSString *)name
{
    if (!_name) {
        _name = [NSString stringWithUTF8String:_artist->name().c_str()];
    }
    return _name;
}

- (NSString *)shortBio
{
    if (!_shortBio) {
        _shortBio = [NSString stringWithUTF8String:_artist->shortBio().c_str()];
    }
    return _shortBio;
}

- (int)albumsCount
{
    return _artist->nbAlbums();
}

- (int)tracksCount
{
    return _artist->nbTracks();
}

- (VLCMLThumbnailStatus)isArtworkGenerated
{
    return [self
            isArtworkGeneratedForType:((VLCMLThumbnailSizeType)medialibrary::ThumbnailSizeType::Thumbnail)];
}

- (VLCMLThumbnailStatus)isArtworkGeneratedForType:(VLCMLThumbnailSizeType)type
{
    return (VLCMLThumbnailStatus)_artist->thumbnailStatus((medialibrary::ThumbnailSizeType)type);
}

- (BOOL)setThumbnailWithMRL:(NSURL *)mrl ofType:(VLCMLThumbnailSizeType)type
{
    return _artist->setThumbnail([mrl.absoluteString UTF8String],
                                 (medialibrary::ThumbnailSizeType)type);
}

- (NSURL *)artworkMRL
{
    return [self artworkMRLOfType:(VLCMLThumbnailSizeType)medialibrary::ThumbnailSizeType::Thumbnail];
}

- (NSURL *)artworkMRLOfType:(VLCMLThumbnailSizeType)type
{
    auto mrl = _artist->thumbnailMrl((medialibrary::ThumbnailSizeType)type);

    if ( mrl.empty() ) {
        return nil;
    }

    return  [[NSURL alloc] initWithString:[NSString stringWithUTF8String:mrl.c_str()]];
}

- (BOOL)setArtworkWithMRL:(NSURL *)mrl ofType:(VLCMLThumbnailSizeType)type
{
    return _artist->setThumbnail([mrl.absoluteString UTF8String],
                                 (medialibrary::ThumbnailSizeType)type);
}

- (NSString *)musicBrainzId
{
    if (!_musicBrainzId) {
        _musicBrainzId = [NSString stringWithUTF8String:_artist->musicBrainzId().c_str()];
    }
    return _musicBrainzId;
}

- (NSArray<VLCMLAlbum *> *)albums
{
    return [VLCMLUtils arrayFromAlbumQuery:_artist->albums()];
}

- (NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromAlbumQuery:_artist->albums(&param)];
}

- (NSArray<VLCMLMedia *> *)tracks
{
    return [VLCMLUtils arrayFromMediaQuery:_artist->tracks()];
}

- (NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_artist->tracks(&param)];
}

@end

@implementation VLCMLArtist (Internal)

- (instancetype)initWithArtistPtr:(medialibrary::ArtistPtr)artistPtr
{
    if (artistPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _artist = artistPtr;
    }
    return self;
}

- (medialibrary::ArtistPtr)artistPtr
{
    return _artist;
}

@end
