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

medialibrary::DeviceListerCb::DeviceListerCb( id<VLCMLDeviceListerDelegate> delegate )
    : m_delegate(delegate)
{
}

void medialibrary::DeviceListerCb::setDelegate( id<VLCMLDeviceListerDelegate> delegate )
{
    this->m_delegate = delegate;
}


bool medialibrary::DeviceListerCb::onDevicePlugged( const std::string& uuid, const std::string& mountpoint )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onDevicePluggedWithUuid:mountPoint:)]) {
        [this->m_delegate onDevicePluggedWithUuid:[[NSString alloc] initWithUTF8String:uuid.c_str()]
                                       mountPoint:[[NSString alloc] initWithUTF8String:mountpoint.c_str()]];
    }
    return false;
}

void medialibrary::DeviceListerCb::onDeviceUnplugged( const std::string& uuid )
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(onDeviceUnpluggedWithUuid:)]) {
        [this->m_delegate onDeviceUnpluggedWithUuid:[[NSString alloc] initWithUTF8String:uuid.c_str()]];
    }
}

bool medialibrary::DeviceListerCb::isDeviceKnown( const std::string& uuid ) const
{
    if (this->m_delegate && [this->m_delegate respondsToSelector:@selector(isDeviceKnown:)]) {
        [this->m_delegate isDeviceKnown:[[NSString alloc] initWithUTF8String:uuid.c_str()]];
    }
    return false;
}
