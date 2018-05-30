/*****************************************************************************
 * VLCMLShowEpisode.m
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

#import "VLCMLShowEpisode.h"
#import "VLCMLShow+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLShowEpisode ()
{
    medialibrary::ShowEpisodePtr _showEpisode;
}
@end

@implementation VLCMLShowEpisode


- (VLCMLIdentifier)identifier
{
    return _showEpisode->id();
}

- (NSString *)artworkMrl
{
    if (!_artworkMrl) {
        _artworkMrl = [[NSString alloc] initWithUTF8String:_showEpisode->artworkMrl().c_str()];
    }
    return _artworkMrl;
}

- (uint)episodeNumber
{
    return _showEpisode->episodeNumber();
}

- (NSString *)name
{
    if (!_name) {
        _name = [[NSString alloc] initWithUTF8String:_showEpisode->name().c_str()];
    }
    return _name;
}

- (uint)seasonNumber
{
    return _showEpisode->seasonNumber();
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

- (NSArray<VLCMLMedia *> *)files
{
    if (!_files) {
        _files = [VLCMLUtils arrayFromMediaPtrVector:_showEpisode->media()->all()];
    }
    return _files;
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
        _showEpisode = showEpisodePtr;
    }
    return self;
}

@end
