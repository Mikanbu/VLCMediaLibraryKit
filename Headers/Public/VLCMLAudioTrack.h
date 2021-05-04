/*****************************************************************************
 * VLCMLAduioTrack.h
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

#import <Foundation/Foundation.h>
#import "VLCMLObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface VLCMLAudioTrack : NSObject <VLCMLObject>

@property (nonatomic, copy) NSString *codec;
@property (nonatomic, copy) NSString *audioDescription;
@property (nonatomic, copy) NSString *language;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;
- (uint)bitrate;
- (uint)sampleRate;
- (uint)nbChannels;

@end

NS_ASSUME_NONNULL_END
