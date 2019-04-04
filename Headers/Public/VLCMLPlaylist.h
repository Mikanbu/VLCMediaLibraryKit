/*****************************************************************************
 * VLCMLPlayst.h
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

#import "VLCMLObject.h"

typedef NS_ENUM(NSUInteger, VLCMLSortingCriteria);

@class VLCMLMedia;

@interface VLCMLPlaylist : NSObject <VLCMLObject>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<VLCMLMedia *> *media;

- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;
- (NSString *)name;
- (BOOL)updateName:(NSString *)name;

/**
 * @brief creationDate Returns the playlist creation date.
 *
 * For playlist that were analyzed based on a playlist file (as opposed to
 * created by the application) this will be the date when the playlist was
 * first discovered, not the playlist *file* creation/last modification date
 */
- (uint)creationDate;

/**
 * \brief artworkMrl An artwork for this playlist, if any.
 * \return An artwork, or an empty string if none is available.
 */
- (NSString *)artworkMrl;

/**
 * @brief media Returns the media contained in this playlist
 * @return An array representing the media in this playlist
 *
 * The media will always be sorted by their ascending position in the playlist.
 */
- (NSArray<VLCMLMedia *> *)media;

/**
 * @brief searchMedia Search some media in a playlist
 * @param pattern The search pattern. Minimal length is 3 characters
 * @param sort Sorting criteria. \see VLCMLSortingCriteria
 * @param desc Sorting order ascending or descending
 * @return An array of media, or empty in case of error or if the pattern is too short
 */
- (NSArray<VLCMLMedia *> *)searchMediaWithPattern:(NSString *)pattern
                                             sort:(VLCMLSortingCriteria)criteria
                                             desc:(BOOL)desc;

/**
 * @brief append Appends a media to a playlist
 *  The media will be the last element of a subsequent call to media()
 * @param media The media to add
 * @return true on success, false on failure.
 */
- (BOOL)appendMedia:(VLCMLMedia *)media;
- (BOOL)appendMediaWithIdentifier:(VLCMLIdentifier)identifier;

/**
 * @brief add Add a media to the playlist at the given position.
 * @param media The media to add
 * @param position The position of this new media, in the [0;size-1] range
 * @return true on success, false on failure
 *
 * If the position is greater than the playlist size, it will be interpreted
 * as a regular append operation, and the item position will be set to
 * <playlist size>
 * For instance, on the playlist [<B,0>, <A,1>, <C,2>], if add(D, 999)
 * gets called, the resulting playlist will be [<A,0>, <C,1>, <B,2>, <D,3>]
 */
- (BOOL)addMedia:(VLCMLMedia *)media atPosition:(uint32_t)position;
- (BOOL)addMediaWithIdentifier:(VLCMLIdentifier)identifier atPosition:(uint32_t)position;

/**
 * @brief move Change the position of a media
 * @param from The position of the item being moved
 * @param to The moved item target position
 *
 * @return true on success, false on failure
 *
 * In case there is already an item at the given position, it will be placed before
 * the media being moved. This will cascade to any media placed afterward.
 * For instance, a playlist with <media,position> like
 * [<A,0>, <B,1>, <C,2>] on which move(0, 1) is called will result in the
 * playlist being changed to
 * [<B,0>, <A,1>, <C,2>]
 * If the target position is out of range (ie greater than the playlist size)
 * the target position will be interpreted as the playlist size (prior to insertion).
 * For instance, on the playlist [<B,0>, <A,1>, <C,2>], if move(0, 999)
 * gets called, the resulting playlist will be [<A,0>, <C,1>, <B,2>]
 */
- (BOOL)moveMediaFromPosition:(uint32_t)position toDestination:(uint32_t)destination;

/**
 * @brief move Change the position of a media
 * @param from The position of the item being moved
 * @param to The moved item target position
 *
 * @return true on success, false on failure
 *
 * In case there is already an item at the given position, it will be placed before
 * the media being moved. This will cascade to any media placed afterward.
 * For instance, a playlist with <media,position> like
 * [<A,0>, <B,1>, <C,2>] on which move(0, 1) is called will result in the
 * playlist being changed to
 * [<B,0>, <A,1>, <C,2>]
 * If the target position is out of range (ie greater than the playlist size)
 * the target position will be interpreted as the playlist size (prior to insertion).
 * For instance, on the playlist [<B,0>, <A,1>, <C,2>], if move(0, 999)
 * gets called, the resulting playlist will be [<A,0>, <C,1>, <B,2>]
 */
- (BOOL)removeMediaFromPosition:(uint32_t)position;

@end
