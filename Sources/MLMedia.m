/*****************************************************************************
 * MLMedia.m
 * MediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010-2017 VLC authors and VideoLAN
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

#import "MLMediaLibrary.h"
#import "MLMedia.h"
#import "MLMedia+Init.h"

@interface MLMedia ()
{
    medialibrary::MediaPtr _media;
    medialibrary::IMediaLibrary *_ml;
}
@end

@implementation MLMedia

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ml = (medialibrary::IMediaLibrary *)[MLMediaLibrary sharedInstance];
        if (_mrl)
            _media = _ml->addMedia([[_mrl absoluteString] UTF8String]);
    }
    return self;
}

- (instancetype)initWithMrl:(NSURL *)mrl
{
    _mrl = mrl;
    return [self init];
}

- (instancetype)initWithMrl:(NSURL *)mrl forTitle:(NSString *)title
{
    _title = title;
    return [self initWithMrl:mrl];
}

- (BOOL)isFavorite
{
    return _media->isFavorite();
}

- (BOOL)updateTitle:(NSString *)title
{
    BOOL success = _media->setTitle([title UTF8String]);

    if (success) {
        _title = title;
    }
    return success;
}

@implementation MLMedia (Internal)

- (instancetype)initWithMediaPtr:(struct mediaImpl *)impl
{
    self = [super init];
    _media = impl->implMedia;
    [self cacheFromCurrentMediaPtr];

    return self;
}

@end
