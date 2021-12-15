/*****************************************************************************
 * VLCMLShow.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2021 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Felix Paul Kühne <fkuehne # videolan.org>
 *          Pierre d'Herbemont <pdherbemont # videolan.org>
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
#import "VLCMLUtils.h"

@interface VLCMLShow ()
{
    medialibrary::ShowPtr _show;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSDate *releaseDate;
@property (nonatomic, copy) NSString *shortSummary;
@property (nonatomic, copy) NSURL *artworkMrl;
@property (nonatomic, copy) NSString *tvdbId;
@property (nonatomic, copy, nullable) NSArray<VLCMLMedia *> *episodes;
@end

@implementation VLCMLShow

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, title: %@",
            NSStringFromClass([self class]), self.identifier, self.title];
}

- (VLCMLIdentifier)identifier
{
    return _show->id();
}

- (NSString *)title
{
    if (!_title) {
        _title = [[NSString alloc] initWithUTF8String:_show->title().c_str()];
    }
    return _title;
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
        _artworkMrl = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:_show->artworkMrl().c_str()]];
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

- (NSArray<VLCMLMedia *> *)episodes
{
    if (!_episodes) {
        _episodes = [VLCMLUtils arrayFromMediaQuery:_show->episodes()];
    }
    return _episodes;
}

- (NSArray<VLCMLMedia *> *)episodesWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                  desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_show->episodes(&param)];
}

- (NSArray<VLCMLMedia *> *)searchEpisodesWithPattern:(NSString *)pattern
                                                sort:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_show->searchEpisodes([pattern UTF8String],
                                                                 &param)];
}

- (UInt32)numberOfSeasons {
    return _show->nbSeasons();
}

- (UInt32)numberOfEpisodes {
    return _show->nbEpisodes();
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
        _show = std::move(showPtr);
    }
    return self;
}

- (medialibrary::ShowPtr)showPtr
{
    return _show;
}

@end
