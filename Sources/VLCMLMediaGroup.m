/*****************************************************************************
* VLCMLMediaGroup.m
* VLCMediaLibraryKit
*****************************************************************************
* Copyright (C) 2010-2019 VLC authors and VideoLAN
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

#import "VLCMLMediaGroup.h"
#import "VLCMLMediaGroup+Init.h"

#import "VLCMLMedia.h"
#import "VLCMLMedia+Init.h"
#import "VLCMLUtils.h"
#import "VLCMediaLibrary.h"

@interface VLCMLMediaGroup ()
{
    medialibrary::MediaGroupPtr _mediaGroup;
}
@end

@implementation VLCMLMediaGroup

- (VLCMLIdentifier)identifier
{
    return _mediaGroup->id();
}

- (NSString *)name
{
    return [NSString stringWithUTF8String:_mediaGroup->name().c_str()];
}

- (UInt32)nbTotalMedia
{
    return _mediaGroup->nbTotalMedia();
}

- (UInt32)nbPresentMedia
{
    return _mediaGroup->nbPresentMedia();
}

- (UInt32)nbPresentVideo
{
    return _mediaGroup->nbPresentVideo();
}

- (UInt32)nbPresentAudio
{
    return _mediaGroup->nbPresentAudio();
}

- (UInt32)nbPresentUnknown
{
    return _mediaGroup->nbPresentUnknown();
}

- (UInt32)nbVideo
{
    return _mediaGroup->nbVideo();
}

- (UInt32)nbAudio
{
    return _mediaGroup->nbAudio();
}

- (UInt32)nbUnknown
{
    return _mediaGroup->nbUnknown();
}

- (UInt64)duration
{
    return _mediaGroup->duration();
}

- (NSDate *)createDate
{
    return [NSDate
            dateWithTimeIntervalSince1970:_mediaGroup->creationDate()];
}

- (NSDate *)lastModificationDate
{
    return [NSDate
            dateWithTimeIntervalSince1970:_mediaGroup->lastModificationDate()];
}

- (BOOL)userInteracted
{
    return _mediaGroup->userInteracted();
}

- (BOOL)addMedia:(VLCMLMedia *)media
{
    return _mediaGroup->add(*media.mediaPtr);
}

- (BOOL)addMediaWithIdentifier:(VLCMLIdentifier)identifier
{
    return _mediaGroup->add(identifier);
}

- (BOOL)removeMedia:(VLCMLMedia *)media
{
    return _mediaGroup->remove(*media.mediaPtr);
}

- (BOOL)removeMediaWithIdentifier:(VLCMLIdentifier)identifier
{
    return _mediaGroup->remove(identifier);
}

- (BOOL)renameWithName:(NSString *)name
{
    return _mediaGroup->rename([name UTF8String]);
}

- (BOOL)destroy
{
    return _mediaGroup->destroy();
}

- (nullable NSArray<VLCMLMedia *> *)mediaOfType:(VLCMLMediaType)type
{
    return [self mediaOfType:type sort:VLCMLSortingCriteriaDefault desc:NO];
}

- (nullable NSArray<VLCMLMedia *> *)mediaOfType:(VLCMLMediaType)type
                                           sort:(VLCMLSortingCriteria)criteria
                                           desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils
            arrayFromMediaQuery:_mediaGroup->media((medialibrary::IMedia::Type)type,
                                                   &param)];
}

- (nullable NSArray<VLCMLMedia *> *)searchMediaWithPattern:(NSString *)pattern
                                                      type:(VLCMLMediaType)type
{
    return [self searchMediaWithPattern:pattern type:type
                                   sort:VLCMLSortingCriteriaDefault desc:NO];
}

- (nullable NSArray<VLCMLMedia *> *)searchMediaWithPattern:(NSString *)pattern
                                                      type:(VLCMLMediaType)type
                                                      sort:(VLCMLSortingCriteria)criteria
                                                      desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_mediaGroup->searchMedia([pattern UTF8String],
                                                                    (medialibrary::IMedia::Type)type,
                                                                    &param)];
}

@end

@implementation VLCMLMediaGroup (Internal)

- (instancetype)initWithMediaGroupPtr:(medialibrary::MediaGroupPtr)mediaGroupPtr
{
    if (mediaGroupPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _mediaGroup = mediaGroupPtr;
    }
    return self;
}

- (medialibrary::MediaGroupPtr)mediaGroupPtr
{
    return _mediaGroup;
}

@end
