/*****************************************************************************
 * VLCMLMedia.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2017-2022 VLC authors and VideoLAN
 *
 * Authors: Soomin Lee <bubu@mikan.io>
 *          Felix Paul Kühne <fkuehne # videolan.org>
 *          Carola Nitz <caro # videolan.org>
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

#import "VLCMLMedia.h"
#import "VLCMLMedia+Init.h"
#import "VLCMLLabel+Init.h"
#import "VLCMLMovie+Init.h"
#import "VLCMLFile+Init.h"
#import "VLCMLShowEpisode+Init.h"
#import "VLCMLMediaGroup+Init.h"
#import "VLCMLMetadata+Init.h"
#import "VLCMLAudioTrack+Init.h"
#import "VLCMLVideoTrack+Init.h"
#import "VLCMLSubtitleTrack+Init.h"
#import "VLCMLChapter+Init.h"
#import "VLCMLBookmark+Init.h"
#import "VLCMLArtist+Init.h"
#import "VLCMLGenre+Init.h"
#import "VLCMLAlbum+Init.h"
#import "VLCMLUtils.h"

@interface VLCMLMedia ()
{
    medialibrary::MediaPtr _media;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong, nullable) VLCMLShowEpisode *showEpisode;
@property (nonatomic, strong, nullable) VLCMLMovie *movie;

@property (nonatomic, copy) NSArray<VLCMLFile *> *files;
@property (nonatomic, copy, nullable) NSArray<VLCMLLabel *> *labels;
@property (nonatomic, copy, nullable) NSArray<VLCMLAudioTrack *> *audioTracks;
@property (nonatomic, copy, nullable) NSArray<VLCMLVideoTrack *> *videoTracks;
@property (nonatomic, copy, nullable) NSArray<VLCMLSubtitleTrack *> *subtitleTracks;
@property (nonatomic, copy, nullable) NSArray<VLCMLChapter *> *chapters;

@property (nonatomic, strong, nullable) VLCMLArtist *artist;
@property (nonatomic, strong, nullable) VLCMLGenre *genre;
@property (nonatomic, strong, nullable) VLCMLAlbum *album;
@property (nonatomic, strong, nullable) NSString *lyrics;
@end

@implementation VLCMLMedia

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, type: %hhu, title: %@",
            NSStringFromClass([self class]), self.identifier, self.type, self.title];
}

#pragma mark - Getters/Setters
- (float)progress
{
    VLCMLMetadata *progressMetadata = [self metadataOfType:VLCMLMetadataTypeProgress];
    if (!progressMetadata.str || [progressMetadata.str isEqualToString:@""]) {
        return 0.0;
    }

    return progressMetadata.str.floatValue;
}

- (void)setProgress:(float)progress
{
    [self setMetadataOfType:VLCMLMetadataTypeProgress stringValue:[NSString stringWithFormat: @"%f", progress]];
}

- (BOOL)isNew
{
    return _media->playCount() == 0;
}

- (void)setIsNew:(BOOL)isNew
{
    if (isNew) {
        _media->setPlayCount(0);
    } else {
        if (_media->playCount() == 0) {
            _media->setPlayCount(1);
        }
    }
}

- (SInt64)audioTrackIndex
{
    return [self metadataOfType:VLCMLMetadataTypeAudioTrack].integer;
}

- (void)setAudioTrackIndex:(SInt64)audioTrackIndex
{
    [self setMetadataOfType:VLCMLMetadataTypeAudioTrack intValue: audioTrackIndex];
}

- (SInt64)subtitleTrackIndex
{
    return [self metadataOfType:VLCMLMetadataTypeSubtitleTrack].integer;
}

- (void)setSubtitleTrackIndex:(SInt64)subtitleTrackIndex
{
    [self setMetadataOfType:VLCMLMetadataTypeSubtitleTrack intValue: subtitleTrackIndex];
}

- (SInt64)chapterIndex
{
    return [self metadataOfType:VLCMLMetadataTypeChapter].integer;
}

- (void)setTitleIndex:(SInt64)titleIndex
{
    [self setMetadataOfType:VLCMLMetadataTypeTitle intValue: titleIndex];
}

- (SInt64)titleIndex
{
    return [self metadataOfType:VLCMLMetadataTypeTitle].integer;
}

- (void)setChapterIndex:(SInt64)chapterIndex
{
    [self setMetadataOfType:VLCMLMetadataTypeChapter intValue: chapterIndex];
}

- (VLCMLIdentifier)identifier
{
    return _media->id();
}

- (VLCMLMediaType)type
{
    return (VLCMLMediaType)_media->type();
}

- (VLCMLMediaSubtype)subtype
{
    return (VLCMLMediaSubtype)_media->subType();
}

- (NSString *)title
{
    if (!_title) {
        _title = [[NSString alloc] initWithUTF8String:_media->title().c_str()];
    }
    return _title;
}

- (BOOL)updateTitle:(NSString *)title
{
    BOOL success = _media->setTitle([title UTF8String]);

    NSAssert(success, @"Failed to update title.");
    _title = title;
    return success;
}

- (SInt64)duration
{
    return _media->duration();
}

- (UInt32)playCount
{
    return _media->playCount();
}

- (BOOL)setPlayCount:(UInt32)playCount
{
    return _media->setPlayCount(playCount);
}

- (VLCMLShowEpisode *)showEpisode
{
    if (!_showEpisode) {
        _showEpisode = [[VLCMLShowEpisode alloc] initWithShowEpisodePtr:_media->showEpisode()];
    }
    return _showEpisode;
}

- (NSArray<VLCMLFile *> *)files
{
    if (!_files) {
        auto files = _media->files();
        NSMutableArray *result = [NSMutableArray array];

        for (const auto &file : files) {
            [result addObject:[[VLCMLFile alloc] initWithFilePtr:file]];
        }
        _files = [result copy];
    }
    return _files;
}

- (NSString *)fileName
{
    return [NSString stringWithUTF8String:_media->fileName().c_str()];
}

- (VLCMLFile *)mainFile
{
    if (!_files) {
        [self files];
    }
    for (VLCMLFile *file in _files) {
        if (file.isMain) {
            return file;
        }
    }
    return nil;
}

- (VLCMLFile *)addExternalMrl:(NSURL *)mrl fileType:(VLCMLFileType)type
{
    return [[VLCMLFile alloc] initWithFilePtr:_media->addExternalMrl([mrl.absoluteString UTF8String],
                                                                     (medialibrary::IFile::Type)type)];
}

- (BOOL)isFavorite
{
    return _media->isFavorite();
}

- (BOOL)setFavorite:(BOOL)favorite
{
    return _media->setFavorite(favorite);
}

- (BOOL)addLabel:(VLCMLLabel *)label
{
    return _media->addLabel([label labelPtr]);
}

- (BOOL)removeLabel:(VLCMLLabel *)label
{
    return _media->removeLabel([label labelPtr]);
}

- (VLCMLMovie *)movie
{
    if (!_movie) {
        _movie = [[VLCMLMovie alloc] initWithMoviePtr:_media->movie()];
    }
    return _movie;
}

- (NSArray<VLCMLLabel *> *)labels
{
    if (!_labels) {
        auto labels = _media->labels();

        if (!labels) {
            return nil;
        }

        NSMutableArray *result = [NSMutableArray array];

        for (const auto &label : labels->all()) {
            [result addObject:[[VLCMLLabel alloc] initWithLabelPtr:label]];
        }
        _labels = [result copy];
    }
    return _labels;
}

- (NSArray<VLCMLAudioTrack *> *)audioTracks
{
    if (!_audioTracks) {
        auto audioTracks = _media->audioTracks();

        if (!audioTracks) {
            return nil;
        }

        NSMutableArray *result = [NSMutableArray array];

        for (const auto &audioTrack : audioTracks->all()) {
            [result addObject:[[VLCMLAudioTrack alloc] initWithAudioTrackPtr:audioTrack]];
        }
        _audioTracks = [result copy];
    }
    return _audioTracks;
}

- (NSArray<VLCMLVideoTrack *> *)videoTracks
{
    if (!_videoTracks) {
        auto videoTracks = _media->videoTracks();

        if (!videoTracks) {
            return nil;
        }

        NSMutableArray *result = [NSMutableArray array];

        for (const auto &videoTrack : videoTracks->all()) {
            [result addObject:[[VLCMLVideoTrack alloc] initWithVideoTrackPtr:videoTrack]];
        }
        _videoTracks = [result copy];
    }
    return _videoTracks;
}

- (NSArray<VLCMLSubtitleTrack *> *)subtitleTracks
{
    if (!_subtitleTracks) {
        auto subtitleTracks = _media->subtitleTracks();

        if (!subtitleTracks) {
            return nil;
        }

        NSMutableArray *result = [NSMutableArray array];

        for (const auto &subtitleTrack : subtitleTracks->all()) {
            [result addObject:[[VLCMLSubtitleTrack alloc] initWithSubtitleTrackPtr:subtitleTrack]];
        }
        _subtitleTracks = [result copy];
    }
    return _subtitleTracks;
}

- (NSArray<VLCMLChapter *> *)chapters
{
    if (!_chapters) {
        auto chapters = _media->chapters()->all();
        NSMutableArray *result = [NSMutableArray array];

        for (medialibrary::ChapterPtr const& chapter : chapters) {
            [result addObject:[[VLCMLChapter alloc] initWithChapterPointer:chapter]];
        }
        _chapters = [result copy];
    }
    return _chapters;
}

- (NSArray<VLCMLBookmark *> *)bookmarks
{
    auto bookmarks = _media->bookmarks()->all();
    NSMutableArray *result = [NSMutableArray array];

    for (medialibrary::BookmarkPtr const& bookmark : bookmarks) {
        [result addObject:[[VLCMLBookmark alloc] initWithBookmarkPointer:bookmark]];
    }
    return [result copy];
}

- (NSURL *)thumbnail
{
    return [self thumbnailOfType:VLCMLThumbnailSizeType(medialibrary::ThumbnailSizeType::Thumbnail)];
}

- (NSURL *)thumbnailOfType:(VLCMLThumbnailSizeType)type
{
    auto mrl = _media->thumbnailMrl((medialibrary::ThumbnailSizeType)type);

    if ( mrl.empty() ) {
        return nil;
    }

    return  [[NSURL alloc] initWithString:[NSString stringWithUTF8String:mrl.c_str()]];
}

- (VLCMLThumbnailStatus)thumbnailStatus
{
    return [self thumbnailStatusOfType:VLCMLThumbnailSizeType(medialibrary::ThumbnailSizeType::Thumbnail)];
}

- (VLCMLThumbnailStatus)thumbnailStatusOfType:(VLCMLThumbnailSizeType)type
{
    return (VLCMLThumbnailStatus)_media->thumbnailStatus((medialibrary::ThumbnailSizeType)type);
}

- (BOOL)setThumbnailWithMRL:(NSURL *)mrl ofType:(VLCMLThumbnailSizeType)type
{
    return _media->setThumbnail([mrl.absoluteString UTF8String],
                                (medialibrary::ThumbnailSizeType)type);
}

- (BOOL)requestThumbnailOfType:(VLCMLThumbnailSizeType)type
                  desiredWidth:(NSUInteger)width
                 desiredHeight:(NSUInteger)height
                    atPosition:(float)position
{
    return _media->requestThumbnail((medialibrary::ThumbnailSizeType)type,
                                    (int)width, (int)height, position);
}

- (NSDate *)insertionDate
{
    return [NSDate dateWithTimeIntervalSince1970:_media->insertionDate()];
}

- (NSDate *)releaseDate
{
    return [NSDate dateWithTimeIntervalSince1970:_media->releaseDate()];
}

- (NSDate *)lastPlayedDate
{
    return [NSDate dateWithTimeIntervalSince1970:_media->lastPlayedDate()];
}

- (VLCMLMetadata *)metadataOfType:(VLCMLMetadataType)type
{
    return [[VLCMLMetadata alloc] initWithMetadata:_media->metadata((medialibrary::IMedia::MetadataType)type)];
}

- (BOOL)setMetadataOfType:(VLCMLMetadataType)type stringValue:(NSString *)value
{
    return _media->setMetadata((medialibrary::IMedia::MetadataType)type , [value UTF8String]);
}

- (BOOL)setMetadataOfType:(VLCMLMetadataType)type intValue:(SInt64)value
{
    return _media->setMetadata((medialibrary::IMedia::MetadataType)type, value);
}

#pragma mark -

- (BOOL)removeFromHistory
{
    return _media->removeFromHistory();
}

- (BOOL)isDiscoveredMedia
{
    return _media->isDiscoveredMedia();
}

- (BOOL)isExternalMedia
{
    return _media->isExternalMedia();
}

- (BOOL)isStream
{
    return _media->isStream();
}

#pragma mark - Groups

- (BOOL)addToGroup:(VLCMLMediaGroup *)group
{
    return _media->addToGroup(*group.mediaGroupPtr);
}

- (BOOL)addToGroupWithIdentifier:(VLCMLIdentifier)identifier
{
    return _media->addToGroup(identifier);
}

- (BOOL)removeFromGroup
{
    return _media->removeFromGroup();
}

- (VLCMLIdentifier)groupIdentifier
{
    return _media->groupId();
}

- (nullable VLCMLMediaGroup *)group
{
    return [[VLCMLMediaGroup alloc] initWithMediaGroupPtr:_media->group()];
}

- (BOOL)regroup
{
    return _media->regroup();
}

#pragma mark - bookmarks

- (VLCMLBookmark *)addBookmarkAtTime:(SInt64)time
{
    medialibrary::BookmarkPtr bookmark = _media->addBookmark(time);
    VLCMLBookmark *mlBookmark = [[VLCMLBookmark alloc] initWithBookmarkPointer:bookmark];
    return mlBookmark;
}

- (VLCMLBookmark *)bookmarkAtTime:(SInt64)time
{
    medialibrary::BookmarkPtr bookmark = _media->bookmark(time);
    VLCMLBookmark *mlBookmark = [[VLCMLBookmark alloc] initWithBookmarkPointer:bookmark];
    return mlBookmark;
}

- (BOOL)removeBookmarkAtTime:(SInt64)time
{
    return _media->removeBookmark(time);
}

- (BOOL)removeAllBookmarks
{
    return _media->removeAllBookmarks();
}

#pragma mark - album track

- (VLCMLArtist *)artist
{
    if (!_artist) {
        _artist = [[VLCMLArtist alloc] initWithArtistPtr:_media->artist()];
    }
    return _artist;
}

- (VLCMLGenre *)genre
{
    if (!_genre) {
        _genre = [[VLCMLGenre alloc] initWithGenrePtr:_media->genre()];
    }
    return _genre;
}

- (VLCMLAlbum *)album
{
    if (!_album) {
        _album = [[VLCMLAlbum alloc] initWithAlbumPtr:_media->album()];
    }
    return _album;
}

- (uint)trackNumber
{
    return _media->trackNumber();
}

- (uint)discNumber
{
    return _media->discNumber();
}

- (NSString *)lyrics
{
    if (!_lyrics) {
        if (!_media->lyrics().empty()) {
            _lyrics = [NSString stringWithUTF8String:_media->lyrics().c_str()];
        }
    }
    return _lyrics;
}

@end

@implementation VLCMLMedia (Internal)

- (instancetype)initWithMediaPtr:(medialibrary::MediaPtr)mediaPtr
{
    if (mediaPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _media = std::move(mediaPtr);
    }
    return self;
}

- (medialibrary::MediaPtr)mediaPtr
{
    return _media;
}

@end
