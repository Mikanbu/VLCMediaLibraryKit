/*****************************************************************************
 * VLCMLBookmark.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2021 VLC authors and VideoLAN
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

#import "VLCMLBookmark.h"
#import "VLCMLBookmark+Init.h"
#include <medialibrary/IBookmark.h>

@interface VLCMLBookmark()
{
    medialibrary::BookmarkPtr _bookmark;
}
@end

@implementation VLCMLBookmark

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, name: %@",
            NSStringFromClass([self class]), self.identifier, self.name];
}

- (VLCMLIdentifier)identifier
{
    return _bookmark->id();
}

- (SInt64)time
{
    return _bookmark->time();
}

- (void)setTime:(SInt64)time
{
    _bookmark->move(time);
}

- (NSString *)name
{
    return [[NSString alloc] initWithUTF8String:_bookmark->name().c_str()];
}

- (void)setName:(NSString *)name
{
    if (!name) {
        return;
    }

    std::string cppName(name.UTF8String);
    _bookmark->setName(cppName);
}

- (NSDate *)creationDate
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:_bookmark->creationDate()];
}

- (NSString *)bookmarkDescription
{
    return [[NSString alloc] initWithUTF8String:_bookmark->description().c_str()];
}

- (void)setBookmarkDescription:(NSString *)bookmarkDescription
{
    if (!bookmarkDescription) {
        return;
    }

    std::string cppDescription(bookmarkDescription.UTF8String);
    _bookmark->setDescription(cppDescription);
}

@end


@implementation VLCMLBookmark (Internal)

- (nullable instancetype)initWithBookmarkPointer:(medialibrary::BookmarkPtr)BookmarkPtr
{
    if (BookmarkPtr == nullptr) {
        return nil;
    }

    self = [super init];
    if (self) {
        _bookmark = std::move(BookmarkPtr);
    }
    return self;
}

@end

