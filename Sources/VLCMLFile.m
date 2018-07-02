/*****************************************************************************
 * VLCMLFile.m
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

#import "VLCMLFile.h"
#import "VLCMLFile+Init.h"

@interface VLCMLFile ()
{
    medialibrary::FilePtr _file;
}
@end

@implementation VLCMLFile

- (VLCMLIdentifier)identifier
{
    return _file->id();
}

- (NSURL *)mrl
{
    if (!_mrl) {
        _mrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:_file->mrl().c_str()]];
    }
    return _mrl;
}

- (VLCMLFileType)type
{
    return (VLCMLFileType)_file->type();
}

- (uint)lastModificationDate
{
    return _file->lastModificationDate();
}

- (uint)size
{
    return _file->size();
}

- (BOOL)isExternal
{
    return _file->isExternal();
}

@end

@implementation VLCMLFile (Internal)

- (instancetype)initWithFilePtr:(medialibrary::FilePtr)filePtr
{
    if (filePtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _file = filePtr;
    }
    return self;
}

@end
