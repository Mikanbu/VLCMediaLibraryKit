/*****************************************************************************
 * VLCMLChapter.m
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

#import "VLCMLChapter.h"
#import "VLCMLChapter+Init.h"
#include <medialibrary/IChapter.h>

@interface VLCMLChapter ()
{
    medialibrary::ChapterPtr _chapter;
    NSString *_name;
}
@end

@implementation VLCMLChapter

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — name: %@",
            NSStringFromClass([self class]), self.name];
}

- (NSString *)name
{
    if (!_name) {
        _name = [[NSString alloc] initWithUTF8String:_chapter->name().c_str()];
    }
    return _name;
}

- (SInt64)offset
{
    return _chapter->offset();
}

- (SInt64)duration
{
    return _chapter->duration();
}

@end

@implementation VLCMLChapter (Internal)

- (instancetype)initWithChapterPointer:(medialibrary::ChapterPtr)ChapterPtr
{
    if (ChapterPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _chapter = std::move(ChapterPtr);
    }
    return self;
}

@end

