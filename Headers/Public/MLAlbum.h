/*****************************************************************************
 * MLAlbum.h
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

@class MLArtist;

struct albumImpl;

@interface MLAlbum : NSObject

//@property (nonatomic, readonly) NSString *title; conflict with foundation title variables.
@property (nonatomic, readonly) NSString *name;//is not title because fondation does not like title.
@property (nonatomic, readonly) NSString *shortsummary;
@property (nonatomic, readonly) NSString *artworkMRL;

@property (nonatomic) NSInteger releaseYear;
@property (nonatomic) NSString *albumArtist;
@property (nonatomic) long albumArtistId;
@property (nonatomic) NSInteger nbTracks;
@property (nonatomic) NSInteger duration;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithIdentifier:(int64_t)identifier;

- (int64_t)identifier;

/**
 * Returns an array of MLArtist object.
 */
- (NSArray *)artists;


@end
