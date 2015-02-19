/*****************************************************************************
 * MLMediaLibrary.h
 * MobileMediaLibraryKit
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2010-2014 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Pierre d'Herbemont <pdherbemont # videolan.org>
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

#import <CoreData/CoreData.h>

@interface MLMediaLibrary : NSObject

@property (readonly) BOOL libraryNeedsUpgrade;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSURL *persistentStoreURL;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedMediaLibrary;

- (void)addFilePaths:(NSArray *)filepaths;
- (void)upgradeLibrary;
- (void)updateMediaDatabase;

// May be internal
- (NSFetchRequest *)fetchRequestForEntity:(NSString *)entity;
- (id)createObjectForEntity:(NSString *)entity;
- (void)removeObject:(NSManagedObject *)object;
- (NSString *)thumbnailFolderPath;
- (NSString *)documentFolderPath;

- (void)applicationWillStart;
- (void)applicationWillExit;

- (void)save;
- (void)libraryDidDisappear;
- (void)libraryDidAppear;
@end

@protocol MLMediaLibrary <NSObject>

@optional
- (void)libraryUpgradeComplete;

@end