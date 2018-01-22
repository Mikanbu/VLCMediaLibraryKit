/*****************************************************************************
 * VLCHistoryEntry.m
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

#import "VLCHistoryEntry.h"
#import "VLCHistoryEntry+Init.h"
#import "VLCMedia+Init.h"

@interface VLCHistoryEntry ()
{
    medialibrary::HistoryPtr _historyEntry;
}
@end

@implementation VLCHistoryEntry

- (uint)insertionDate
{
    return _historyEntry->insertionDate();
}

@end

@implementation VLCHistoryEntry (Internal)

- (instancetype)initWithHistoryPtr:(medialibrary::HistoryPtr)historyPtr
{
    self = [super init];
    if (self) {
        _historyEntry = historyPtr;
        _media = [[VLCMedia alloc] initWithMediaPtr:_historyEntry->media()];
    }
    return self;
}

@end
