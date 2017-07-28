/*****************************************************************************
 * MLMedia.h
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

@class MLAlbum, MLAlbumTrack, MLShowEpisode, MLMediaMetadata;

typedef NS_ENUM(uint8_t, MLMediaType) {
    MLMediaTypeUnknown,
    MLMediaTypeVideo,
    MLMediaTypeAudio
};

typedef NS_ENUM(uint8_t, MLMediaSubType) {
    MLMediaSubTypeUnknown,
    MLMediaSubTypeShowEpisode,
    MLMediaSubTypeMovie,
    MLMediaSubTypeAlbumTrack
};

typedef NS_ENUM(uint32_t, MLMetadataType) {
    MLMetadataTypeRating = 1,

    // Playback
    MLMetadataTypeProgress = 50,
    MLMetadataTypeSpeed,
    MLMetadataTypeTitle,
    MLMetadataTypeChapter,
    MLMetadataTypeProgram,
    MLMetadataTypeSeen,

    // Video:
    MLMetadataTypeVideoTrack = 100,
    MLMetadataTypeAspectRatio,
    MLMetadataTypeZoom,
    MLMetadataTypeCrop,
    MLMetadataTypeDeinterlace,
    MLMetadataTypeVideoFilter,

    // Audio
    MLMetadataTypeAudioTrack = 150,
    MLMetadataTypeGain,
    MLMetadataTypeAudioDelay,

    // Spu
    MLMetadataTypeSubtitleTrack = 200,
    MLMetadataTypeSubtitleDelay,

    // Various
    MLMetadataTypeApplicationSpecific = 250,
};

struct mediaImpl;

@interface MLMedia : NSObject

@property (nonatomic, readonly, strong) NSString *title;
@property (nonatomic, readonly, strong) NSString *thumbnail;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithIdentifier:(int64_t)identifier;

#pragma mark - Getters/Setters

- (int64_t)identifier;

- (MLMediaType)type;
- (MLMediaSubType)subType;

- (BOOL)updateTitle:(NSString *)title;
- (int64_t)duration;
- (int)playCount;
- (BOOL)increasePlayCount;

- (BOOL)isFavorite;
- (BOOL)setFavorite:(BOOL)favorite;

- (uint)insertionDate;
- (uint)releaseDate;

#pragma mark - Metadata
- (MLMediaMetadata *)metadataOfType:(MLMetadataType)type;

@end

