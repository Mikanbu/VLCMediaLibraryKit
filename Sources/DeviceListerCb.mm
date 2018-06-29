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

bool medialibrary::DeviceListerCb::onDevicePlugged( const std::string& uuid, const std::string& mountpoint )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:devicePluggedWithUUID:withMountPoint:)]) {
        return [m_delegate medialibrary:m_medialibrary
                        devicePluggedWithUUID:[NSString stringWithUTF8String:uuid.c_str()]
                               withMountPoint:[NSString stringWithUTF8String:mountpoint.c_str()]];
    }
    return false;
}

void medialibrary::DeviceListerCb::onDeviceUnplugged( const std::string& uuid )
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:deviceUnPluggedWithUUID:)]) {
        [m_delegate medialibrary:m_medialibrary
               deviceUnPluggedWithUUID:[NSString stringWithUTF8String:uuid.c_str()]];
    }
}

bool medialibrary::DeviceListerCb::isDeviceKnown( const std::string& uuid ) const
{
    if (m_delegate && [m_delegate respondsToSelector:@selector(medialibrary:isDeviceKnownWithUUID:)]) {
        return [m_delegate medialibrary:m_medialibrary
                        isDeviceKnownWithUUID:[NSString stringWithUTF8String:uuid.c_str()]];
    }
    return false;
}
