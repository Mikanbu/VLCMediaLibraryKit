/*****************************************************************************
 * VLCMLFolder.m
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

#import "VLCMLFolder.h"
#import "VLCMLFolder+Init.h"

@interface VLCMLFolder ()
{
    medialibrary::FolderPtr _folder;
}
@end

@implementation VLCMLFolder

- (int64_t)identifier
{
    return _folder->id();
}

- (NSString *)mrl
{
    if (!_mrl) {
        _mrl = [[NSString alloc] initWithUTF8String:_folder->mrl().c_str()];
    }
    return _mrl;
}

- (BOOL)isPresent
{
    return _folder->isPresent();
}

@end

@implementation VLCMLFolder (Internal)

- (instancetype)initWithFolderPtr:(medialibrary::FolderPtr)folderPtr
{
    self = [super init];
    if (self) {
        _folder = folderPtr;
    }
    return self;
}

@end
