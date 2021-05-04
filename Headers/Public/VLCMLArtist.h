/*****************************************************************************
 * VLCMLArtist.h
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

typedef NS_ENUM(NSUInteger, VLCMLSortingCriteria);
typedef NS_ENUM(NSUInteger, VLCMLThumbnailSizeType);
typedef NS_ENUM(NSUInteger, VLCMLThumbnailStatus);

@class VLCMLAlbum, VLCMLMedia;

NS_ASSUME_NONNULL_BEGIN

@interface VLCMLArtist : NSObject <VLCMLObject>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *shortBio;
@property (nonatomic, copy) NSString *musicBrainzId;


- (instancetype)init NS_UNAVAILABLE;

- (VLCMLIdentifier)identifier;


/**
 * @brief albumsCount
 * @return The number of albums *by* this artist. This doesn't include the
 *         albums an artist appears on.
 */
- (int)albumsCount;
- (int)tracksCount;

/**
 * @brief isArtworkGenerated Returns true is a thumbnail generation was
 *                             attempted for the provided size.
 *
 * @param type The targeted thumbnail size
 *
 * If the thumbnail generation failed, this will still return true, and the
 * associated thumbnail mrl will be empty.
 * \note By default this queries the thumbnail of type VLCMLThumbnailSizeTypeThumbnail
 */
- (VLCMLThumbnailStatus)isArtworkGeneratedForType:(VLCMLThumbnailSizeType)type;
- (VLCMLThumbnailStatus)isArtworkGenerated;

/**
 * \brief setThumbnailWithMRL Sets a thumbnail for the current media
 * \param mrl A mrl pointing the the thumbnail file.
 * \param type The targeted thumbnail size type
 * \return true in case the thumbnail was successfully stored to database
 *         false otherwise
 * This is intended to be used by applications that have their own way
 * of computing thumbnails.
 */
- (BOOL)setThumbnailWithMRL:(NSURL *)mrl ofType:(VLCMLThumbnailSizeType)type;

/**
 * \brief artworkMRL Returns the mrl of an artwork of the given size for an artist
 * \param type The targeted artwork size
 * \return An mrl, representing the absolute path to the artist artwork
 *         or nil, if the artwork generation failed
 *
 * \note By default this returns the mrl for VLCMLThumbnailSizeTypeThumbnail
 * \sa{isArtworkGenerated}
 */
- (nullable NSURL *)artworkMRLOfType:(VLCMLThumbnailSizeType)type;
- (nullable NSURL *)artworkMRL;

/**
 * @brief setThumbnail Assign a thumbnail to the artist
 * @param mrl An mrl pointing to the thumbnail
 * @return true in case of success, false otherwise
 *
 * @note The medialibrary does not take ownership of the thumbnail. It is
 * application responsibility to ensure that it will always be available
 * or that a later call will invalidate the thumbnail if it gets (re)moved
 */
- (BOOL)setArtworkWithMRL:(NSURL *)mrl ofType:(VLCMLThumbnailSizeType)type;

/**
 * Return all albums from the current artist.
 * \return a NSArray of VLCMLAlbum object.
 */
- (nullable NSArray<VLCMLAlbum *> *)albums;
- (nullable NSArray<VLCMLAlbum *> *)albumsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                         desc:(BOOL)desc;

/**
 * Return all medias from the current artist.
 * \return a NSArray of VLCMLMedia object.
 */
- (nullable NSArray<VLCMLMedia *> *)tracks;
- (nullable NSArray<VLCMLMedia *> *)tracksWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                desc:(BOOL)desc;

@end

NS_ASSUME_NONNULL_END
