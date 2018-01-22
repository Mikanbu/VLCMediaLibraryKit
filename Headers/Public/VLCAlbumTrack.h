/*****************************************************************************
 * VLCAlbumTrack.h
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

@class VLCArtist, VLCGenre, VLCAlbum, VLCMedia;

@interface VLCAlbumTrack : NSObject

@property (nonatomic, strong) VLCArtist *artist;
@property (nonatomic, strong) VLCGenre *genre;
@property (nonatomic, strong) VLCAlbum *album;
@property (nonatomic, strong) VLCMedia *media;

- (instancetype)init NS_UNAVAILABLE;

- (int64_t)identifier;
/**
 * @brief Returns the artist, as tagged in the media.
 * This can be different from the associated media's artist.
 * For instance, in case of a featuring, Media::artist() might return
 * "Artist 1", while IAlbumTrack::artist() might return something like
 * "Artist 1 featuring Artist 2 and also artist 3 and a whole bunch of people"
 * @return A pointer to a VLCArtist instance.
 */
- (VLCArtist *)artist;
- (VLCGenre *)genre;
- (uint)trackNumber;
- (VLCAlbum *)album;
- (VLCMedia *)media;

/**
 * @return Which disc this tracks appears on (or 0 if unspecified)
 */
- (uint)discNumber;

@end
