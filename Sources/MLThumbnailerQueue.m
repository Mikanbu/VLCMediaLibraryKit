/*****************************************************************************
 * MLThumbnailerQueue.m
 * MobileMediaLibraryKit
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

#import "MLThumbnailerQueue.h"
#import "MLFile.h"
#import "MLCrashPreventer.h"

@interface ThumbnailOperation : NSOperation <VLCMediaThumbnailerDelegate>
{
    MLFile *_file;
    VLCMedia *_media;
    VLCLibrary *_internalLibrary;
}
@property (retain,readwrite) MLFile *file;
@end

@interface MLThumbnailerQueue ()
{
    VLCLibrary *_internalLibrary;
}
- (void)didFinishOperation:(ThumbnailOperation *)op;
@end

@implementation ThumbnailOperation
@synthesize file=_file;
- (id)initWithFile:(MLFile *)file andVLCLibrary:(VLCLibrary *)library;
{
    if (!(self = [super init]))
        return nil;
    self.file = file;
    _internalLibrary = library;
    return self;
}

- (void)dealloc
{
    [_media release];
    [_file release];
    [super dealloc];
}

- (void)fetchThumbnail
{
    APLog(@"Starting THUMB %@", self.file);

    [[MLCrashPreventer sharedPreventer] willParseFile:self.file];

    _media = [[VLCMedia mediaWithURL:[NSURL URLWithString:self.file.url]] retain];
    VLCMediaThumbnailer *thumbnailer = [VLCMediaThumbnailer thumbnailerWithMedia:_media delegate:self andVLCLibrary:_internalLibrary];
    /* optimize thumbnails for the device */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([UIScreen mainScreen].scale==2.0) {
            thumbnailer.thumbnailWidth = 540.;
            thumbnailer.thumbnailHeight = 405.;
        } else {
            thumbnailer.thumbnailWidth = 272.;
            thumbnailer.thumbnailHeight = 204.;
        }
    } else {
        if (SYSTEM_RUNS_IOS7) {
            thumbnailer.thumbnailWidth = 480.;
            thumbnailer.thumbnailHeight = 270.;
        } else {
            if ([UIScreen mainScreen].scale==2.0) {
                thumbnailer.thumbnailWidth = 480.;
                thumbnailer.thumbnailHeight = 270.;
            } else {
                thumbnailer.thumbnailWidth = 240.;
                thumbnailer.thumbnailHeight = 135.;
            }
        }
    }
    [thumbnailer fetchThumbnail];
    [[MLThumbnailerQueue sharedThumbnailerQueue].queue setSuspended:YES]; // Balanced in -mediaThumbnailer:didFinishThumbnail
    [self retain]; // Balanced in -mediaThumbnailer:didFinishThumbnail:
}
- (void)main
{
    [self performSelectorOnMainThread:@selector(fetchThumbnail) withObject:nil waitUntilDone:YES];
}

- (void)endThumbnailing
{
    [[MLCrashPreventer sharedPreventer] didParseFile:self.file];
    MLThumbnailerQueue *thumbnailer = [MLThumbnailerQueue sharedThumbnailerQueue];
    [thumbnailer.queue setSuspended:NO];
    [thumbnailer didFinishOperation:self];
    [self release];
}
- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail
{
    mediaThumbnailer.delegate = nil;
    APLog(@"Finished thumbnail for %@", self.file.title);
    self.file.computedThumbnail = [UIImage imageWithCGImage:thumbnail];

    [self endThumbnailing];
}

- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer
{
    self.file.thumbnailTimeouted = YES;
    [self endThumbnailing];
}
@end

@implementation MLThumbnailerQueue
@synthesize queue=_queue;
+ (MLThumbnailerQueue *)sharedThumbnailerQueue
{
    static MLThumbnailerQueue *shared = nil;
    if (!shared) {
        shared = [[MLThumbnailerQueue alloc] init];
    }
    return shared;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _internalLibrary = [[VLCLibrary alloc] initWithOptions:@[@"--avcodec-threads=1", @"--avcodec-skip-frame=4", @"--avcodec-skip-idct=4", @"--deinterlace=-1", @"--avcodec-skiploopfilter=3"]];
        _fileDescriptionToOperation = [[NSMutableDictionary alloc] init];
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)dealloc
{
    [_internalLibrary release];
    [_queue release];
    [_fileDescriptionToOperation release];
    [super dealloc];
}


static inline NSString *hashFromFile(MLFile *file)
{
    return [NSString stringWithFormat:@"%p", [[file objectID] URIRepresentation]];
}

- (void)didFinishOperation:(ThumbnailOperation *)op
{
    [_fileDescriptionToOperation setValue:nil forKey:hashFromFile(op.file)];
}

- (void)addFile:(MLFile *)file
{
    if (_fileDescriptionToOperation[hashFromFile(file)])
        return;
    if (![[MLCrashPreventer sharedPreventer] isFileSafe:file]) {
        APLog(@"'%@' is unsafe and will crash, ignoring", file.title);
        return;
    }
    if ([file isAlbumTrack]) {
        APLog(@"'%@' is an audio file, ignoring", file.title);
        return;
    }
    ThumbnailOperation *op = [[ThumbnailOperation alloc] initWithFile:file andVLCLibrary:_internalLibrary];
    [_fileDescriptionToOperation setValue:op forKey:hashFromFile(file)];
    [self.queue addOperation:op];
    [op autorelease];
}

- (void)stop
{
    [_queue setMaxConcurrentOperationCount:0];
}

- (void)resume
{
    [_queue setMaxConcurrentOperationCount:1];
}

- (void)setHighPriorityForFile:(MLFile *)file
{
    ThumbnailOperation *op = _fileDescriptionToOperation[hashFromFile(file)];
    [op setQueuePriority:NSOperationQueuePriorityHigh];
}

- (void)setDefaultPriorityForFile:(MLFile *)file
{
    ThumbnailOperation *op = _fileDescriptionToOperation[hashFromFile(file)];
    [op setQueuePriority:NSOperationQueuePriorityNormal];
}
@end
