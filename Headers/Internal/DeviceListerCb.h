/*****************************************************************************
 * DeviceLister.h
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

#import "VLCMediaLibrary.h"

namespace medialibrary
{

class DeviceListerCb : public IDeviceListerCb
{
public:
    DeviceListerCb( VLCMediaLibrary *medialibrary, id<VLCMLDeviceListerDelegate> delegate );
    void setDelegate( id<VLCMLDeviceListerDelegate> delegate );

    /**
     * @brief onDevicePlugged Shall be invoked when a known device gets plugged
     * @param uuid The device UUID
     * @param mountpoint The device new mountpoint
     * @return true is the device was unknown. false otherwise
     */
    virtual bool onDeviceMounted( const std::string& uuid, const std::string& mountpoint );
    /**
     * @brief onDeviceUnplugged Shall be invoked when a known device gets unplugged
     * @param uuid The device UUID
     */
    virtual void onDeviceUnmounted( const std::string& uuid, const std::string& mountpoint );
    /**
     * @brief isDeviceKnown Returns true is the provided device is already known to the media library
     *
     * @note This doesn't reflect the plugged/unplugged state of the device. This is merely an
     * indication that the device has been seen at least once by the media library
     * @param uuid The device UUID
     */
    virtual bool isDeviceKnown( const std::string& uuid ) const;

private:
    id<VLCMLDeviceListerDelegate> m_delegate;
    VLCMediaLibrary *m_medialibrary;
};

}
