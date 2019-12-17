/*****************************************************************************
 * VLCMLMediaGroup.h
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2019 VLC authors and VideoLAN
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

#import "VLCMLObject.h"

typedef NS_ENUM(NSUInteger, VLCMLSortingCriteria);
typedef NS_ENUM(UInt8, VLCMLMediaType);

@class VLCMLMedia;

NS_ASSUME_NONNULL_BEGIN

@interface VLCMLMediaGroup : NSObject

/**
 * @brief name Returns this group name
 */
- (NSString *)name;

/**
 * @brief nbMedia Returns the number of media in this group
 */
- (UInt32)nbMedia;

/**
 * @brief nbVideo returns the number of video media in this group
 */
- (UInt32)nbVideo;

/**
 * @brief nbAudio Returns the number of audio media in this group
 */
- (UInt32)nbAudio;

/**
 * @brief nbUnknown Returns the number of media of unknown type in this group
 */
- (UInt32)nbUnknown;

/**
 * @brief add Adds a media to this group.
 * @param media A reference to the media to add
 * @return true if the media was successfully added to the group, false otherwise
 *
 * The media will be automatically removed its previous group if it belonged
 * to one
 */
- (BOOL)addMedia:(VLCMLMedia *)media;

/**
 * @brief add Adds a media to this group
 * @param identifier The media to add's ID
 * @return true if the media was successfully added to the group, false otherwise
 *
 * The media will be automatically removed its previous group if it belonged
 * to one
 */
- (BOOL)addMediaWithIdentifier:(VLCMLIdentifier)identifier;

/**
 * @brief add Removes a media from this group.
 * @param media A reference to the media to remove
 * @return true if the media was successfully removed from the group, false otherwise
 */
- (BOOL)removeMedia:(VLCMLMedia *)media;

/**
 * @brief add Removes a media from this group
 * @param identifier The media to remove's ID
 * @return true if the media was successfully removed from the group, false otherwise
 */
- (BOOL)removeMediaWithIdentifier:(VLCMLIdentifier)identifier;

/**
 * @brief rename Rename a group
 * @param name The new name
 * @return true if the rename was successfull, false otherwise
 *
 * This will not change the group content, however, it will prevent further
 * media that matched the previous name to be automatically added to this
 * group when they are added to the media library.
 */
- (BOOL)renameWithName:(NSString *)name;

/**
 * @brief media List the media that belong to this group
 * @param type The type of media to return, or Unknown to return them all
 * @param criteria Some sorting criteria
 * @param desc Result by descending order
 * @return A NSArray object representing the results
 *
 */
- (nullable NSArray<VLCMLMedia *> *)mediaOfType:(VLCMLMediaType)type;
- (nullable NSArray<VLCMLMedia *> *)mediaOfType:(VLCMLMediaType)type
                                           sort:(VLCMLSortingCriteria)criteria
                                           desc:(BOOL)desc;

/**
 * @brief searchMedia Search amongst the media belonging to this group
 * @brief pattern The search pattern (3 characters minimum)
 * @param type The type of media to return, or Unknown to return them all
 * @param criteria Some sorting criteria
 * @param desc Result by descending order
 * @return A NSArray object representing the results
 *
 */
- (nullable NSArray<VLCMLMedia *> *)searchMediaWithPattern:(NSString *)pattern
                                                      type:(VLCMLMediaType)type;
- (nullable NSArray<VLCMLMedia *> *)searchMediaWithPattern:(NSString *)pattern
                                                      type:(VLCMLMediaType)type
                                                      sort:(VLCMLSortingCriteria)criteria
                                                      desc:(BOOL)desc;

#pragma mark - Sub groups

/**
 * @brief createSubgroup Create a subgroup
 * @param name This subgroup name
 * @return The newly created group, or nullptr in case of error
 *
 * Names are required to be unique for a given parent group.
 */
- (nullable VLCMLMediaGroup *)createSubgroupWithName:(NSString *)name;

/**
 * @brief subgroups Returns the subgroups for this group
 *
 * Supported sorting criteria are:
 * - Alpha (default)
 * - NbVideo
 * - NbAudio
 * - NbMedia
 */
- (nullable NSArray<VLCMLMediaGroup *> *)subgroups;
- (nullable NSArray<VLCMLMediaGroup *> *)subgroupsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                                 desc:(BOOL)desc;

- (BOOL)isSubGroup;

/**
 * @brief parent Returns this group's parent group, or nullptr if there are none
 */
- (nullable VLCMLMediaGroup *)parent;

/**
 * @brief path Returns a virtual path to this group
 *
 * This consists of <parent group 1>/<parent group 2>/.../<group>
 */
- (nullable NSString *)path;

@end

NS_ASSUME_NONNULL_END
