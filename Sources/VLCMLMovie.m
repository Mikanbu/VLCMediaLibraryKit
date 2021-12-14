/*****************************************************************************
 * VLCMLMovie.m
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

#import "VLCMLMovie.h"
#import "VLCMLMovie+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLMovie ()
{
    medialibrary::MoviePtr _movie;
}

@property (nonatomic, copy) NSString *shortSummary;
@property (nonatomic, copy) NSString *imdbId;
@end

@implementation VLCMLMovie

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, IMBD ID: %@",
            NSStringFromClass([self class]), self.identifier, self.imdbId];
}

- (VLCMLIdentifier)identifier
{
    return _movie->id();
}

- (NSString *)shortSummary
{
    if (!_shortSummary) {
        _shortSummary = [[NSString alloc] initWithUTF8String:_movie->shortSummary().c_str()];
    }
    return _shortSummary;
}

- (NSString *)imdbId
{
    if (!_imdbId) {
        _imdbId = [[NSString alloc] initWithUTF8String:_movie->imdbId().c_str()];
    }
    return _imdbId;
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
        _movie = std::move(moviePtr);
    }
    return self;
}

@end
