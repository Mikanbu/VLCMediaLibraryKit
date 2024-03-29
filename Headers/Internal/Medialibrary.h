/*****************************************************************************
 * Medialibrary.h
 * VLCMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2017-2018 VLC authors and VideoLAN
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


#ifndef Medialibrary_h
# define Medialibrary_h

// medialibrary
# include <medialibrary/IAlbum.h>
# include <medialibrary/IArtist.h>
# include <medialibrary/IAudioTrack.h>
# include <medialibrary/IBookmark.h>
# include <medialibrary/IChapter.h>
# include <medialibrary/IDeviceLister.h>
# include <medialibrary/IFile.h>
# include <medialibrary/IFolder.h>
# include <medialibrary/IGenre.h>
# include <medialibrary/ILabel.h>
# include <medialibrary/ILogger.h>
# include <medialibrary/IMedia.h>
# include <medialibrary/IMediaGroup.h>
# include <medialibrary/IMetadata.h>
# include <medialibrary/IMediaLibrary.h>
# include <medialibrary/IMovie.h>
# include <medialibrary/IPlaylist.h>
# include <medialibrary/IQuery.h>
# include <medialibrary/IShow.h>
# include <medialibrary/IShowEpisode.h>
# include <medialibrary/ISubtitleTrack.h>
# include <medialibrary/IThumbnailer.h>
# include <medialibrary/IVideoTrack.h>

// devicelister
# include <medialibrary/IDeviceLister.h>

// utils
# include <medialibrary/Types.h>

// file system
# include <medialibrary/filesystem/Errors.h>
# include <medialibrary/filesystem/IDirectory.h>
# include <medialibrary/filesystem/IFileSystemFactory.h>
# include <medialibrary/filesystem/IDevice.h>
# include <medialibrary/filesystem/IFile.h>

#endif /* Medialibrary_h */
