/*****************************************************************************
 * VLCMLFolder.m
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2021 VLC authors and VideoLAN
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
#import "VLCMLUtils.h"

@interface VLCMLFolder ()
{
    medialibrary::FolderPtr _folder;
}

@property (nonatomic, copy) NSURL *mrl;
@property (nonatomic, copy) NSString *name;
@end

@implementation VLCMLFolder

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — ID: %lli, name: %@, mrl: %@, nbMedia: %u",
            NSStringFromClass([self class]), self.identifier, self.name, self.mrl, self.nbMedia];
}

- (VLCMLIdentifier)identifier
{
    return _folder->id();
}

- (NSURL *)mrl
{
    if (!_mrl) {
        _mrl = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:_folder->mrl().c_str()]];
    }
    return _mrl;
}

- (NSString *)name
{
    if (_name) {
        _name = [NSString stringWithUTF8String:_folder->name().c_str()];
    }
    return _name;
}

- (BOOL)isPresent
{
    return _folder->isPresent();
}

- (BOOL)isRemovable
{
    return _folder->isRemovable();
}

- (BOOL)isBanned
{
    return _folder->isBanned();
}

- (NSArray<VLCMLMedia *> *)mediaOfType:(VLCMLMediaType)type
                       sortingCriteria:(VLCMLSortingCriteria)criteria
                                  desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromMediaQuery:_folder->media((medialibrary::IMedia::Type)type, &param)];
}

- (NSArray<VLCMLFolder *> *)subfoldersWithSortingCriteria:(VLCMLSortingCriteria)criteria
                                                     desc:(BOOL)desc
{
    medialibrary::QueryParameters param = [VLCMLUtils queryParamatersFromSort:criteria desc:desc];

    return [VLCMLUtils arrayFromFolderQuery:_folder->subfolders(&param)];
}

- (UInt32)nbVideo
{
    return _folder->nbVideo();
}

- (UInt32)nbAudio
{
    return _folder->nbAudio();
}

- (UInt32)nbMedia
{
    return _folder->nbMedia();
}

@end

@implementation VLCMLFolder (Internal)

- (instancetype)initWithFolderPtr:(medialibrary::FolderPtr)folderPtr
{
    if (folderPtr == nullptr) {
        return NULL;
    }

    self = [super init];
    if (self) {
        _folder = folderPtr;
    }
    return self;
}

@end
