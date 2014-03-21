/*****************************************************************************
 * MLFile.h
 * Lunettes
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2010-2013 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Pierre d'Herbemont <pdherbemont # videolan.org>
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

#import <CoreData/CoreData.h>

@class MLShowEpisode;
@class MLAlbumTrack;

extern NSString *kMLFileTypeMovie;
extern NSString *kMLFileTypeClip;
extern NSString *kMLFileTypeTVShowEpisode;
extern NSString *kMLFileTypeAudio;

@interface MLFile :  NSManagedObject

+ (NSArray *)allFiles;
+ (NSArray *)fileForURL:(NSString *)url;

- (BOOL)isKindOfType:(NSString *)type;
- (BOOL)isMovie;
- (BOOL)isClip;
- (BOOL)isShowEpisode;
- (BOOL)isAlbumTrack;
- (BOOL)isSupportedAudioFile;

@property (nonatomic, retain) NSNumber *seasonNumber;
@property (nonatomic, retain) NSNumber *remainingTime;
@property (nonatomic, retain) NSString *releaseYear;
@property (nonatomic, retain) NSNumber *lastPosition;
@property (nonatomic, retain) NSNumber *lastSubtitleTrack;
@property (nonatomic, retain) NSNumber *lastAudioTrack;
@property (nonatomic, retain) NSNumber *playCount;
@property (nonatomic, retain) NSString *artworkURL;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *shortSummary;
@property (nonatomic, retain) NSNumber *currentlyWatching;
@property (nonatomic, retain) NSNumber *episodeNumber;
@property (nonatomic, retain) NSNumber *unread;
@property (nonatomic, retain) NSNumber *hasFetchedInfo;
@property (nonatomic, retain) NSNumber *noOnlineMetaData;
@property (nonatomic, retain) MLShowEpisode *showEpisode;
@property (nonatomic, retain) NSSet *labels;
@property (nonatomic, retain) NSSet *tracks;
@property (nonatomic, retain) NSNumber *isOnDisk;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *album;
@property (nonatomic, retain) NSNumber *albumTrackNumber;
@property (nonatomic, retain) NSNumber *folderTrackNumber;
@property (nonatomic, retain) NSString *genre;
@property (nonatomic, retain) MLAlbumTrack *albumTrack;

@property (nonatomic, retain) UIImage *computedThumbnail;
@property (nonatomic, assign) BOOL isSafe;
@property (nonatomic, assign) BOOL isBeingParsed;
@property (nonatomic, assign) BOOL thumbnailTimeouted;

/**
 * the data in this object are about to be put on screen
 *
 * If multiple MLFile object are processed, this
 * increase the priority of the processing for this MLFile.
 */
- (void)willDisplay;

/**
 * We don't display the data of this object on screen.
 *
 * This put back the eventually increased priority for this MLFile,
 * to a default one.
 * \see willDisplay
 */
- (void)didHide;

/**
 * do not rely on this path unless you are a MLKit object */
- (NSString *)thumbnailPath;

/**
 * Shortcuts to the videoTracks.
 */
- (NSManagedObject *)videoTrack;

- (size_t)fileSizeInBytes;

@end


@interface MLFile (CoreDataGeneratedAccessors)
- (void)addLabelsObject:(NSManagedObject *)value;
- (void)removeLabelsObject:(NSManagedObject *)value;
- (void)addLabels:(NSSet *)value;
- (void)removeLabels:(NSSet *)value;

- (void)addTracksObject:(NSManagedObject *)value;
- (void)removeTracksObject:(NSManagedObject *)value;
- (void)addTracks:(NSSet *)value;
- (void)removeTracks:(NSSet *)value;
@end

