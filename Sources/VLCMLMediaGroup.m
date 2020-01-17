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

- (UInt32)nbMedia
{
    return _mediaGroup->nbMedia();
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

#pragma mark - Sub groups

- (nullable VLCMLMediaGroup *)createSubgroupWithName:(NSString *)name
{
    return [[VLCMLMediaGroup alloc]
            initWithMediaGroupPtr:_mediaGroup->createSubgroup([name UTF8String])];
}

- (nullable NSArray<VLCMLMediaGroup *> *)subgroups
{
    return [self subgroupsWithSortingCriteria:VLCMLSortingCriteriaDefault desc:NO];
}

- (nullable NSArray<VLCMLMediaGroup *> *)subgroupsWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                                 desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaGroupQuery:_mediaGroup->subgroups(&param)];
}

- (BOOL)isSubGroup
{
    return _mediaGroup->isSubgroup();
}

- (nullable VLCMLMediaGroup *)parent
{
    return [[VLCMLMediaGroup alloc] initWithMediaGroupPtr:_mediaGroup->parent()];
}

- (nullable NSString *)path
{
    return [NSString stringWithUTF8String:_mediaGroup->path().c_str()];
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

@end
