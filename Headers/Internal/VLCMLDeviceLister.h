/*****************************************************************************
 * VLCMLDeviceLister.h
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2017-2020 VLC authors and VideoLAN
 *
 * Author: Soomin Lee <bubu@mikan.io>
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

namespace medialibrary
{
namespace fs
{

class VLCMLDeviceLister : public IDeviceLister
{
    /**
     * @brief refresh Force a device refresh
     *
     * Implementation that solely rely on callback can implement this as a no-op
     * as long as they are guaranteed to invoke onDeviceMounted &
     * onDeviceUnmounted as soon as the information is available.
     */
    virtual void refresh();
    /**
     * @brief start Starts watching for new device
     * @param cb An IDeviceListerCb implementation to invoke upon device changes
     * @return true in case of success, false otherwise
     */
    virtual bool start( IDeviceListerCb* cb );
    /**
     * @brief stop Stop watching for new device
     */
    virtual void stop();

private:
    IDeviceListerCb *m_deviceListerCb;
};

}
}
