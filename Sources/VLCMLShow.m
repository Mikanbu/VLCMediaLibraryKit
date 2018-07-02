/*****************************************************************************
 * VLCMLShow.m
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

#import "VLCMLShow.h"
#import "VLCMLShowEpisode+Init.h"

@interface VLCMLShow ()
{
    medialibrary::ShowPtr _show;
}
@end

@implementation VLCMLShow

- (VLCMLIdentifier)identifier
{
    return _show->id();
}

- (NSString *)name
{
    if (!_name) {
        _name = [[NSString alloc] initWithUTF8String:_show->name().c_str()];
    }
    return _name;
}

- (NSDate *)releaseDate
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:_show->releaseDate()];
}

- (NSString *)shortSummary
{
    if (!_shortSummary) {
        _shortSummary = [[NSString alloc] initWithUTF8String:_show->shortSummary().c_str()];
    }
    return _shortSummary;
}

- (NSURL *)artworkMrl
{
    if (!_artworkMrl) {
        _artworkMrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:_show->artworkMrl().c_str()]];
    }
    return _artworkMrl;
}

- (NSString *)tvdbId
{
    if (!_tvdbId) {
        _tvdbId = [[NSString alloc] initWithUTF8String:_show->tvdbId().c_str()];
    }
    return _tvdbId;
}

- (NSArray<VLCMLShowEpisode *> *)episodes
{
    if (!_episodes) {
        auto episodes = _show->episodes();
        NSMutableArray *result = [NSMutableArray array];

        for (const auto &episode : episodes->all()) {
            [result addObject:[[VLCMLShowEpisode alloc] initWithShowEpisodePtr:episode]];
        }
        _episodes = result;
    }
    return _episodes;
}

@end

@implementation VLCMLShow (Internal)

- (instancetype)initWithShowPtr:(medialibrary::ShowPtr)showPtr
{
    if (showPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _show = showPtr;
    }
    return self;
}

- (medialibrary::ShowPtr)showPtr
{
    return _show;
}

@end
