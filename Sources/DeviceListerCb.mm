/*****************************************************************************
 * DeviceListerCb.mm
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

#import "DeviceListerCb.h"

medialibrary::DeviceListerCb::DeviceListerCb( VLCMediaLibrary *medialibrary, id<VLCMLDeviceListerDelegate> delegate )
    : m_medialibrary(medialibrary), m_delegate(delegate)
{
}

void medialibrary::DeviceListerCb::setDelegate( id<VLCMLDeviceListerDelegate> delegate )
{
    m_delegate = delegate;
}

void medialibrary::DeviceListerCb::onDeviceMounted( const std::string& uuid,
                                                    const std::string& mountpoint,
                                                    bool removable )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:deviceMountedWithUUID:withMountPoint:isRemovable:)]) {
        [m_delegate medialibrary:m_medialibrary
           deviceMountedWithUUID:[NSString stringWithUTF8String:uuid.c_str()]
                  withMountPoint:[NSString stringWithUTF8String:mountpoint.c_str()]
                     isRemovable:removable];
    }
}

void medialibrary::DeviceListerCb::onDeviceUnmounted( const std::string& uuid,
                                                      const std::string& mountpoint )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:deviceUnmountedWithUUID:withMountPoint:)]) {
        [m_delegate medialibrary:m_medialibrary
         deviceUnmountedWithUUID:[NSString stringWithUTF8String:uuid.c_str()]
                  withMountPoint:[NSString stringWithUTF8String:mountpoint.c_str()]];
    }
}
