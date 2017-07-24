/*****************************************************************************
 * MLArtist.m
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


#import "MLArtist.h"
#import "MLMediaLibrary.h"

@interface MLArtist()
{
    medialibrary::ArtistPtr _artist;
    medialibrary::IMediaLibrary *_ml;
}
@end

@implementation MLArtist

//- (instancetype)initWithId:(long)artistId name:(NSString *)name shortBio:(NSString *)shortBio artworkMRL:(NSString *)artworkMRL musicBrainzId:(NSString *)musicBrainzId
//{
//    self.artistId = artistId;
//    self.name = name;
//    self.shortBio = shortBio;
//    self.artworkMRL = artworkMRL;
//    self.musicBrainzId = musicBrainzId;
//
//    _ml = (medialibrary::IMediaLibrary *)[MLMediaLibrary sharedInstance];
//    return self;
//}

- (instancetype)initWithId:(int64_t)identifier
{
    self = [super init];
    if (self) {
        _ml = (medialibrary::IMediaLibrary *)[MLMediaLibrary sharedInstance];

        if ((_artist = _ml->artist(identifier))) {
            _identifier = _artist->id();
            _name = [NSString stringWithUTF8String:_artist->name().c_str()];
            _shortBio = [NSString stringWithUTF8String:_artist->shortBio().c_str()];
            _artworkMRL = [NSString stringWithUTF8String:_artist->artworkMrl().c_str()];
            _musicBrainzId = [NSString stringWithUTF8String:_artist->musicBrainzId().c_str()];
        }
        NSAssert(_artist, @"Failed to init Artist with identifier: %lld", identifier);
    }
    return self;
}

#pragma mark - Getters/Setters

- (NSArray *)albums
{
    //need mlalbum object
    return NULL;
}

- (NSArray *)media
{
    auto media = _artist->media();
    return nil;
}

@end
