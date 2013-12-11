/*****************************************************************************
 * MLTitleDecrapifier.m
 * Lunettes
 *****************************************************************************
 * Copyright (C) 2010 Pierre d'Herbemont
 * Copyright (C) 2010-2013 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Pierre d'Herbemont <pdherbemont # videolan.org>
 *          Felix Paul Kühne <fkuehne # videolan.org>
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

#import "MLTitleDecrapifier.h"

@implementation MLTitleDecrapifier
+ (NSString *)decrapify:(NSString *)string
{
    static NSArray *ignoredWords = nil;
    if (!ignoredWords)
        ignoredWords = [[NSArray alloc] initWithObjects:
                        @"xvid", @"h264", @"dvd", @"rip", @"divx", @"[fr]", @"720p", @"1080i", @"1080p", @"x264", @"hdtv", @"aac", @"bluray", nil];

    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    for (NSString *word in ignoredWords)
        [mutableString replaceOccurrencesOfString:word withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableString length])];
    [mutableString replaceOccurrencesOfString:@"." withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableString length])];
    [mutableString replaceOccurrencesOfString:@"_" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableString length])];
    [mutableString replaceOccurrencesOfString:@"+" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableString length])];
    [mutableString replaceOccurrencesOfString:@"-" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableString length])];

    NSString *staticString = [NSString stringWithString:mutableString];
    mutableString = nil;

    while ([staticString rangeOfString:@"  "].location != NSNotFound)
        staticString = [staticString stringByReplacingOccurrencesOfString:@"  " withString:@" "];

    if (staticString.length > 2) {
        @try {
            if ([staticString characterAtIndex:0] == 0x20)
                staticString = [staticString substringFromIndex:1];
        }
        @catch (NSException *exception) {
        }
    }

    return staticString;
}

static inline BOOL isDigit(char c)
{
    return c >= '0' && c <= '9';
}

// Shortcut to ease reading
static inline unichar c(NSString *string, unsigned index)
{
    @try {
        return [string characterAtIndex:index];
    }
    @catch (NSException *exception) {
        return 0x00;
    }
}


+ (BOOL)isTVShowEpisodeTitle:(NSString *)string
{
    NSString *str = [string lowercaseString];

    // Search for s01e10.
    for (int i = 0; i < (int)[str length] - 5; i++) {
        if (c(str, i) == 's' &&
            isDigit(c(str, i+1)) &&
            isDigit(c(str, i+2)) &&
            c(str, i+3) == 'e' &&
            isDigit(c(str, i+4)) &&
            isDigit(c(str, i+5)))
        {
            return YES;
        }
    }
    return NO;
}

static inline int intFromChar(char n)
{
    return n - '0';
}

static inline NSNumber *numberFromTwoChars(char high, char low)
{
    return @(intFromChar(high) * 10 + intFromChar(low));
}

static inline NSNumber *numberFromThreeChars(char high, char mid, char low)
{
    return @(intFromChar(high) * 100 + intFromChar(mid) * 10 + intFromChar(low));
}

+ (NSDictionary *)tvShowEpisodeInfoFromString:(NSString *)string
{
    if (!string)
        return nil;
    NSString *str = [string lowercaseString];
    BOOL successfulSearch = NO;
    NSMutableDictionary *mutableDict;
    NSUInteger stringLength = [str length];

    if (stringLength < 6)
        return nil;

    // Search for s01e10.
    for (NSUInteger i = 0; i < stringLength - 5; i++) {
        if (c(str, i) == 's' &&
            isDigit(c(str, i+1)) &&
            isDigit(c(str, i+2)) &&
            c(str, i+3) == 'e' &&
            isDigit(c(str, i+4)) &&
            isDigit(c(str, i+5)))
        {
            NSNumber *season = numberFromTwoChars(c(str,i+1), c(str,i+2));
            NSNumber *episode;
            if (isDigit(c(str, i+6)))
                episode = numberFromThreeChars(c(str,i+4), c(str,i+5), c(str,i+6));
            else
                episode = numberFromTwoChars(c(str,i+4), c(str,i+5));
            NSString *tvShowName = i > 0 ? [str substringToIndex:i-1] : nil;
            tvShowName = tvShowName ? [[MLTitleDecrapifier decrapify:tvShowName] capitalizedString] : nil;
            NSString *episodeName = stringLength > i + 4 ? [str substringFromIndex:i+6] : nil;

            NSArray *components = [episodeName componentsSeparatedByString:@" "];
            NSUInteger componentsCount = components.count;

            episodeName = episodeName ? [MLTitleDecrapifier decrapify:episodeName] : nil;

            /* episode name is optional */
            if ([episodeName isEqualToString:components[componentsCount - 1]])
                episodeName = nil;

            mutableDict = [[NSMutableDictionary alloc] initWithCapacity:4];
            if (season)
                [mutableDict setObject:season forKey:@"season"];
            if (episode)
                [mutableDict setObject:episode forKey:@"episode"];
            if (tvShowName && ![tvShowName isEqualToString:@" "])
                [mutableDict setObject:tvShowName forKey:@"tvShowName"];
            if (episodeName.length > 0 && ![episodeName isEqualToString:@" "])
                [mutableDict setObject:[episodeName capitalizedString] forKey:@"tvEpisodeName"];
            successfulSearch = YES;
        }
    }

    // search for 0x00
    if (!successfulSearch) {
        for (NSUInteger i = 0; i < stringLength - 4; i++) {
            if (isDigit(c(str, i)) &&
                c(str, i+1) == 'x' &&
                isDigit(c(str, i+2)) &&
                isDigit(c(str, i+3)))
            {
                NSNumber *season = [NSNumber numberWithInt:intFromChar(c(str,i))];
                NSNumber *episode = numberFromTwoChars(c(str,i+2), c(str,i+3));
                NSString *tvShowName = i > 0 ? [str substringToIndex:i-1] : nil;
                tvShowName = tvShowName ? [[MLTitleDecrapifier decrapify:tvShowName] capitalizedString] : nil;

                NSString *episodeName = stringLength > i + 4 ? [str substringFromIndex:i+4] : nil;

                NSArray *components = [episodeName componentsSeparatedByString:@" "];
                NSUInteger componentsCount = components.count;

                episodeName = episodeName ? [MLTitleDecrapifier decrapify:episodeName] : nil;

                /* episode name is optional */
                if ([episodeName isEqualToString:components[componentsCount - 1]])
                    episodeName = nil;

                mutableDict = [[NSMutableDictionary alloc] initWithCapacity:3];
                if (season)
                    [mutableDict setObject:season forKey:@"season"];
                if (episode)
                    [mutableDict setObject:episode forKey:@"episode"];
                if (tvShowName && ![tvShowName isEqualToString:@" "])
                    [mutableDict setObject:tvShowName forKey:@"tvShowName"];
                if (episodeName.length > 0 && ![episodeName isEqualToString:@" "])
                    [mutableDict setObject:[episodeName capitalizedString] forKey:@"tvEpisodeName"];
                successfulSearch = YES;
            }
        }
    }

    if (successfulSearch) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:mutableDict];
        [mutableDict release];
        return dict;
    }

    return nil;
}

+ (NSDictionary *)audioContentInfoFromFile:(MLFile *)file
{
    if (!file)
        return nil;

    NSString *title = file.title;
    NSArray *components = [title componentsSeparatedByString:@" "];
    if (components.count > 0) {
        if ([components[0] intValue] > 0)
            title = [self decrapify:[title stringByReplacingOccurrencesOfString:components[0] withString:@""]];
    } else
        title = [self decrapify:title];

    return [NSDictionary dictionaryWithObject:title forKey:VLCMetaInformationTitle];
}

@end
