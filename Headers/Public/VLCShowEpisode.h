/*****************************************************************************
 * VLCShowEpisode.h
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

@class VLCShow, VLCMedia;

@interface VLCShowEpisode : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *shortSummary;
@property (nonatomic, copy) NSString *artworkMrl;
@property (nonatomic, copy) NSString *tvdbId;
@property (nonatomic, strong) VLCShow *show;
@property (nonatomic, copy) NSArray<VLCMedia *> *files;

- (instancetype)init NS_UNAVAILABLE;

- (int64_t)identifier;
- (NSString *)artworkMrl;
- (uint)episodeNumber;
- (NSString *)name;
- (uint)seasonNumber;
- (NSString *)shortSummary;
- (NSString *)tvdbId;
- (VLCShow *)show;
- (NSArray<VLCMedia *> *)files;

@end

