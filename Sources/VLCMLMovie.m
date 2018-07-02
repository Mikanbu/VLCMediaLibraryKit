/*****************************************************************************
 * VLCMLMovie.m
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

#import "VLCMLMovie.h"
#import "VLCMLMovie+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLMovie ()
{
    medialibrary::MoviePtr _movie;
}
@end

@implementation VLCMLMovie

- (VLCMLIdentifier)identifier
{
    return _movie->id();
}

- (NSString *)title
{
    if (!_title) {
        _title = [[NSString alloc] initWithUTF8String:_movie->title().c_str()];
    }
    return _title;
}

- (NSString *)shortSummary
{
    if (!_shortSummary) {
        _shortSummary = [[NSString alloc] initWithUTF8String:_movie->shortSummary().c_str()];
    }
    return _shortSummary;
}

- (NSURL *)artworkMrl
{
    if (!_artworkMrl) {
        _artworkMrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:_movie->artworkMrl().c_str()]];
    }
    return _artworkMrl;
}

- (NSString *)imdbId
{
    if (!_imdbId) {
        _imdbId = [[NSString alloc] initWithUTF8String:_movie->imdbId().c_str()];
    }
    return _imdbId;
}

- (NSArray<VLCMLMedia *> *)files
{
    if (!_files) {
        _files = [VLCMLUtils arrayFromMediaPtrVector:_movie->media()->all()];
    }
    return _files;
}

@end

@implementation VLCMLMovie (Internal)

- (instancetype)initWithMoviePtr:(medialibrary::MoviePtr)moviePtr
{
    if (moviePtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _movie = moviePtr;
    }
    return self;
}

@end
