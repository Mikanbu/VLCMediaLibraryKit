/*****************************************************************************
 * VLCMLChapter.h
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2021 VLC authors and VideoLAN
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

#import <Foundation/Foundation.h>
#import "VLCMLObject.h"

@interface VLCMLChapter : NSObject

/**
 * @brief name returns the name of the chapter
 */
@property (readonly, copy, nullable) NSString *name;

/**
 * @brief offset returns the offset from the start of the media in seconds
 */
@property (readonly) SInt64 offset;

/**
 * @brief duration the duration of this chapter in seconds
 */
@property (readonly) SInt64 duration;

@end

