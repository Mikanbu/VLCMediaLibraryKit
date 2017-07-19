/*****************************************************************************
 * MLArtist.h
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

@class MLAlbum;

@interface MLArtist : NSObject

@property (nonatomic) long artistId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *shortBio;
@property (nonatomic) NSString *artworkMRL;
@property (nonatomic) NSString *musicBrainzId;

- (instancetype)initWithId:(long)artistId
            name:(NSString *)name
        shortBio:(NSString *)shortBio
      artworkMRL:(NSString *)artworkMRL
   musicBrainzId:(NSString *)musicBrainzId;


/**
 * Return all albums from the current artist.
 * \return a NSArray of MLAlbum object.
 */
- (NSArray *)albums;

@end
