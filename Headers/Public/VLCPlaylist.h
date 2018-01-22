/*****************************************************************************
 * VLCPlayst.h
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

@class VLCMedia;

@interface VLCPlaylist : NSObject

@property(nonatomic, copy) NSString *name;

- (instancetype)init NS_UNAVAILABLE;

- (int64_t)identifier;
- (NSString *)name;
- (BOOL)updateName:(NSString *)name;
- (uint)creationDate;
- (NSArray<VLCMedia *> *)media;

- (BOOL)appendMediaWithIdentifier:(int64_t)identifier;
- (BOOL)addMediaWithIdentifier:(int64_t)identifier at:(uint)position;
- (BOOL)moveMediaWithIdentifier:(int64_t)identifier at:(uint)position;
- (BOOL)removeMediaWithIdentifier:(int64_t)identifier;

@end
