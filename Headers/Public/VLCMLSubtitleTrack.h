/*****************************************************************************
 * VLCMLSubtitleTrack.h
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

#import <Foundation/Foundation.h>
#import "VLCMLObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface VLCMLSubtitleTrack : NSObject <VLCMLObject>

@property (nonatomic, copy, readonly) NSString *codec;
@property (nonatomic, copy, readonly) NSString *language;
@property (nonatomic, copy, readonly) NSString *trackDescription;
@property (nonatomic, copy, readonly) NSString *encoding;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;

@end

NS_ASSUME_NONNULL_END
