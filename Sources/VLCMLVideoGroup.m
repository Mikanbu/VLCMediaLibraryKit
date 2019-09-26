/*****************************************************************************
* VLCMLVideoGroup.m
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

#import "VLCMLVideoGroup.h"
#import "VLCMLVideoGroup+Init.h"

#import "VLCMLUtils.h"
#import "VLCMediaLibrary.h"

@interface VLCMLVideoGroup ()
{
    medialibrary::VideoGroupPtr _videoGroup;
}
@end

@implementation VLCMLVideoGroup

- (NSString *)name
{
    return [NSString stringWithUTF8String:_videoGroup->name().c_str()];
}

- (UInt64)count
{
    return _videoGroup->count();
}

- (nullable NSArray<VLCMLMedia *> *)media
{
    return [self mediaWithSortingCriteria:VLCMLSortingCriteriaDefault desc:NO];
}

- (nullable NSArray<VLCMLMedia *> *)mediaWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                        desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_videoGroup->media(&param)];
}

- (nullable NSArray<VLCMLMedia *> *)searchMediaWithPattern:(NSString *)pattern
{
    return [self searchMediaWithPattern:pattern
                                   sort:VLCMLSortingCriteriaDefault desc:NO];
}

- (nullable NSArray<VLCMLMedia *> *)searchMediaWithPattern:(NSString *)pattern
                                                      sort:(VLCMLSortingCriteria)criteria
                                                      desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria
                                                                         desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_videoGroup->searchMedia([pattern UTF8String],
                                                                    &param)];
}

@end


@implementation VLCMLVideoGroup (Internal)

- (instancetype)initWithVideoGroupPtr:(medialibrary::VideoGroupPtr)videoGroupPtr
{
    if (videoGroupPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _videoGroup = videoGroupPtr;
    }
    return self;
}

@end
