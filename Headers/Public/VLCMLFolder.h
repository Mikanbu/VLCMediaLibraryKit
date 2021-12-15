/*****************************************************************************
 * VLCMLFolder.h
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2017-2021 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Felix Paul Kühne <fkuehne # videolan.org>
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
#import "VLCMLMedia.h"

typedef NS_ENUM(NSUInteger, VLCMLSortingCriteria);

NS_ASSUME_NONNULL_BEGIN

@interface VLCMLFolder : NSObject <VLCMLObject>

/**
 * @brief mrl Returns the full mrl for this folder.
 * Caller is responsible for checking isPresent() beforehand, as we
 * can't compute an for a folder that is/was present on a removable storage
 * or network share that has been unplugged
 * @return The folder's mrl
 */
@property (nonatomic, copy, readonly) NSURL *mrl;
@property (nonatomic, copy, readonly) NSString *name;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;

- (BOOL)isPresent;
- (BOOL)isRemovable;

/**
 * @brief isBanned Will return true if the folder was explicitely banned
 * from being discovered.
 */
- (BOOL)isBanned;

/**
 * @brief media Returns the media contained by this folder.
 * @param type The media type, or VLCMLMediaTypeUnknown for all types
 * @param criteria A VLCMLSortingCriteria to sort the result
 * @param desc Sort by asc or desc
 * @return An array of VLCMLMedia objects found
 *
 * This function will only return the media contained in the folder, not
 * the media contained in subfolders.
 * A media is considered to be in a directory when the main file representing
 * it is part of the directory.
 * For instance, in this file hierarchy:
 * .
 * ├── a
 * │   ├── c
 * │   │   └── NakedMoleRat.asf
 * │   └── seaotter_themovie.srt
 * └── b
 *     └── seaotter_themovie.mkv
 * Media of 'a' would be empty (since the only file is a subtitle file and
 *                              not the actual media, and NakedMoleRat.asf
 *                              is in a subfolder)
 * Media of 'c' would contain NakedMoleRat.asf
 * Media of 'b' would contain seaotter_themovie.mkv
 */
- (nullable NSArray<VLCMLMedia *> *)mediaOfType:(VLCMLMediaType)type
                                sortingCriteria:(VLCMLSortingCriteria)criteria
                                           desc:(BOOL)desc;


/**
 * @brief subfolders Returns the subfolders contained folder
 * @param criteria A VLCMLSortingCriteria to sort the result
 * @param desc Sort by asc or desc
 * @return An array of VLCMLFolder objects found
 *
 * all of the folder subfolders, regardless of the folder content.
 * For instance, in this hierarchy:
 * ├── a
 * │   └── w
 * │       └── x
 * a->subfolders() would return w; w->subfolders would return x, even though
 * x is empty.
 * This is done for optimization purposes, as keeping track of the entire
 * folder hierarchy would be quite heavy.
 * As an alternative, it is possible to use IMediaLibrary::folders to return
 * a flattened list of all folders that contain media.
 */
- (nullable NSArray<VLCMLFolder *> *)subfoldersWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                              desc:(BOOL)desc;

/**
* @brief nbVideo Returns the number of video (present or not ) media in this folder
*/
- (UInt32)nbVideo;

/**
* @brief nbAudio Returns the number of audio media in this folder
*/
- (UInt32)nbAudio;

/**
* @brief nbUnknown Returns the number of media in this folder
*/
- (UInt32)nbMedia;

@end

NS_ASSUME_NONNULL_END
