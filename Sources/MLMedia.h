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

@class MLAlbum, MLAlbumTrack, MLShowEpisode, MLMediaMetadata, MLLabel, MLShowEpisode, MLMovie;

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

@interface MLMedia : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) MLShowEpisode *showEpisode;
@property (nonatomic, strong) MLMovie *movie;
@property (nonatomic, strong) NSArray<MLLabel *> *labels;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Getters/Setters

- (int64_t)identifier;

- (MLMediaType)type;
- (MLMediaSubType)subType;

- (NSString *)title;
- (BOOL)updateTitle:(NSString *)title;
- (int64_t)duration;
- (int)playCount;
- (BOOL)increasePlayCount;
- (MLShowEpisode *)showEpisode;
- (BOOL)isFavorite;
- (BOOL)setFavorite:(BOOL)favorite;

- (BOOL)addLabel:(MLLabel *)label;
- (BOOL)removeLabel:(MLLabel *)label;
- (MLMovie *)movie;
- (NSArray<MLLabel *> *)labels;

- (NSString *)thumbnail;
- (uint)insertionDate;
- (uint)releaseDate;

#pragma mark - Metadata
- (MLMediaMetadata *)metadataOfType:(MLMetadataType)type;

@end

