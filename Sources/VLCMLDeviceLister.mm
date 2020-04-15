/*****************************************************************************
 * VLCMLDeviceLister.mm
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

#import "VLCMLDeviceLister.h"

#define DEFAULT_UUID 4242

void medialibrary::fs::VLCMLDeviceLister::refresh()
{
}

bool medialibrary::fs::VLCMLDeviceLister::start(IDeviceListerCb *cb)
{
    m_deviceListerCb = cb;

    NSURL *documentDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                 inDomains:NSUserDomainMask] firstObject];

    if (documentDir == nil) {
        return false;
    }

    char realPath[PATH_MAX];

    if (realpath([documentDir.path UTF8String], realPath) == NULL) {
        return false;
    }

    NSURL *mrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:realPath]];

    m_deviceListerCb->onDeviceMounted([[NSString stringWithFormat:@"%d", DEFAULT_UUID] UTF8String],
                                      [mrl.absoluteString UTF8String],
                                      true );

    return true;
}

void medialibrary::fs::VLCMLDeviceLister::stop()
{
}
