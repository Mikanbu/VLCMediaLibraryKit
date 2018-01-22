/*****************************************************************************
 * VLCMedia.h
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

@class VLCAlbum, VLCAlbumTrack, VLCShowEpisode, VLCMediaMetadata, VLCLabel, VLCShowEpisode, VLCMovie, VLCFile;

typedef NS_ENUM(NSInteger, VLCFileType);

typedef NS_ENUM(uint8_t, VLCMediaType) {
    VLCMediaTypeUnknown,
    VLCMediaTypeVideo,
    VLCMediaTypeAudio
};

typedef NS_ENUM(uint8_t, VLCMediaSubType) {
    VLCMediaSubTypeUnknown,
    VLCMediaSubTypeShowEpisode,
    VLCMediaSubTypeMovie,
    VLCMediaSubTypeAlbumTrack
};

typedef NS_ENUM(uint32_t, VLCMetadataType) {
    VLCMetadataTypeRating = 1,

    // Playback
    VLCMetadataTypeProgress = 50,
    VLCMetadataTypeSpeed,
    VLCMetadataTypeTitle,
    VLCMetadataTypeChapter,
    VLCMetadataTypeProgram,
    VLCMetadataTypeSeen,

    // Video:
    VLCMetadataTypeVideoTrack = 100,
    VLCMetadataTypeAspectRatio,
    VLCMetadataTypeZoom,
    VLCMetadataTypeCrop,
    VLCMetadataTypeDeinterlace,
    VLCMetadataTypeVideoFilter,

    // Audio
    VLCMetadataTypeAudioTrack = 150,
    VLCMetadataTypeGain,
    VLCMetadataTypeAudioDelay,

    // Spu
    VLCMetadataTypeSubtitleTrack = 200,
    VLCMetadataTypeSubtitleDelay,

    // Various
    VLCMetadataTypeApplicationSpecific = 250,
};

@interface VLCMedia : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, strong) VLCAlbumTrack *albumTrack;
@property (nonatomic, strong) VLCShowEpisode *showEpisode;
@property (nonatomic, strong) VLCMovie *movie;
@property (nonatomic, copy) NSArray<VLCLabel *> *labels;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Getters/Setters

- (int64_t)identifier;

- (VLCMediaType)type;
- (VLCMediaSubType)subType;

- (NSString *)title;
- (BOOL)updateTitle:(NSString *)title;
- (VLCAlbumTrack *)albumTrack;
- (int64_t)duration;
- (int)playCount;
- (BOOL)increasePlayCount;
- (VLCShowEpisode *)showEpisode;

- (NSArray<VLCFile *> *)files;
- (VLCFile *)addExternalMrl:(NSString *)mrl fileType:(VLCFileType)type;

- (BOOL)isFavorite;
- (BOOL)setFavorite:(BOOL)favorite;

- (BOOL)addLabel:(VLCLabel *)label;
- (BOOL)removeLabel:(VLCLabel *)label;
- (VLCMovie *)movie;
- (NSArray<VLCLabel *> *)labels;

- (NSString *)thumbnail;
- (uint)insertionDate;
- (uint)releaseDate;

#pragma mark - Metadata
- (VLCMediaMetadata *)metadataOfType:(VLCMetadataType)type;
- (BOOL)setMetadataOfType:(VLCMetadataType)type stringValue:(NSString *)value;
- (BOOL)setMetadataOfType:(VLCMetadataType)type intValue:(int64_t)value;

@end

