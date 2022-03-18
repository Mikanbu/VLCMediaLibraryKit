/*****************************************************************************
 * VLCMLFile.h
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

#import <Foundation/Foundation.h>
#import "VLCMLObject.h"

typedef NS_ENUM(NSInteger, VLCMLFileType) {
    /// Unknown type, so far
    VLCMLFileTypeUnknown,
    /// The main file of a media.
    VLCMLFileTypeMain,
    /// A part of a media (for instance, the first half of a movie)
    VLCMLFileTypePart,
    /// External soundtrack
    VLCMLFileTypeSoundtrack,
    /// External subtitles
    VLCMLFileTypeSubtitles,
    /// A playlist File
    VLCMLFileTypePlaylist,
    /// A disc file. Also considered to be a "main" file
    VLCMLFileTypeDisc
};

NS_ASSUME_NONNULL_BEGIN

@interface VLCMLFile : NSObject <VLCMLObject>

@property (nonatomic, copy, readonly) NSURL *mrl;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;
- (VLCMLFileType)type;
- (time_t)lastModificationDate;
- (int64_t)size;

- (BOOL)isRemovable;

/**
 * @brief isExternal returns true if this stream isn't managed by the medialibrary
 */
- (BOOL)isExternal;

/**
 * @brief isNetwork returns true if this file is on a network location
 *
 * If the file is external, this is a best guess effort.
 */
- (BOOL)isNetwork;

/**
 * @brief isMain Returns true if this file is the main file of a media
 *
 * This can be used to have a Disc file considered as the main file
 */
- (BOOL)isMain;

/**
 * @brief this deletes the file represented by this class
 *
 * This is performed on a background thread avoiding blocking the main thread
 * and there-by avoid to have the app killed by the watch dog because it is
 * assumed to be unresponsive.
 */
- (void)deleteFile;

@end

NS_ASSUME_NONNULL_END
