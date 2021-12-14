/*****************************************************************************
 * VLCMLShowEpisode.m
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

#import "VLCMLShowEpisode.h"
#import "VLCMLShow+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLShowEpisode ()
{
    medialibrary::ShowEpisodePtr _showEpisode;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shortSummary;
@property (nonatomic, copy) NSString *tvdbId;
@property (nonatomic, strong, nullable) VLCMLShow *show;
@end

@implementation VLCMLShowEpisode

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, title: %@",
            NSStringFromClass([self class]), self.identifier, self.title];
}

- (VLCMLIdentifier)identifier
{
    return _showEpisode->id();
}

- (uint)episodeID
{
    return _showEpisode->episodeId();
}

- (uint)seasonID
{
    return _showEpisode->seasonId();
}

- (NSString *)title
{
    return [NSString stringWithUTF8String:_showEpisode->title().c_str()];
}

- (NSString *)shortSummary
{
    if (!_shortSummary) {
        _shortSummary = [[NSString alloc] initWithUTF8String:_showEpisode->shortSummary().c_str()];
    }
    return _shortSummary;
}

- (NSString *)tvdbId
{
    if (!_tvdbId) {
        _tvdbId = [[NSString alloc] initWithUTF8String:_showEpisode->tvdbId().c_str()];
    }
    return _tvdbId;
}

- (VLCMLShow *)show
{
    if (!_show) {
        _show = [[VLCMLShow alloc] initWithShowPtr:_showEpisode->show()];
    }
    return _show;
}

@end

@implementation VLCMLShowEpisode (Internal)

- (instancetype)initWithShowEpisodePtr:(medialibrary::ShowEpisodePtr)showEpisodePtr
{
    if (showEpisodePtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _showEpisode = std::move(showEpisodePtr);
    }
    return self;
}

@end
