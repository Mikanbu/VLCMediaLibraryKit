//
//  MLTVShowInfoGrabber.m
//  Lunettes
//
//  Created by Pierre d'Herbemont on 5/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MLTVShowInfoGrabber.h"
#import "TheTVDBGrabber.h"

@interface MLTVShowInfoGrabber ()
@property (readwrite, retain) NSArray *results;
@end

@implementation MLTVShowInfoGrabber
@synthesize delegate=_delegate;
@synthesize results=_results;

static NSDate *gLastFetch = nil;
static NSNumber *gServerTime = nil;

+ (void)fetchUpdatesSinceServerTime:(NSNumber *)serverTime andExecuteBlock:(void (^)(NSArray *))block
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:TVDB_QUERY_UPDATES, TVDB_HOSTNAME, serverTime]];

    NSLog(@"Accessing %@", url);
#if HAVE_BLOCK
    [MLURLConnection runConnectionWithURL:url andBlock:^(MLURLConnection *connection, NSError *error) {
        if (error) {
            return;
        }
        NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithData:connection.data options:0 error:nil];
        NSNumber *serverTime = [[xmlDoc rootElement] numberValueForXPath:@"./Time"];

        [gServerTime release];
        [gLastFetch release];
        gServerTime = [serverTime retain];
        gLastFetch = [[NSDate dateWithTimeIntervalSinceNow:0] retain];

        NSArray *nodes = [xmlDoc nodesForXPath:@"./Items/Series" error:&error];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[nodes count]];
        for (NSXMLNode *node in nodes) {
            NSNumber *id = [node numberValueForXPath:@"."];
            [array addObject:id];
        }
        block(array);
    }];
#endif
}

+ (void)fetchServerTimeAndExecuteBlock:(void (^)(NSNumber *))block
{

    if (gLastFetch && gServerTime) {
        // Only fetch the serverTime every hour
        // FIXME: Have a default for that?
        NSDate *oneHourAgo = [NSDate dateWithTimeIntervalSinceNow:5 * 60 /* Every 5 mins */];
        if ([oneHourAgo earlierDate:gLastFetch] == gLastFetch) {
            block(gServerTime);
            return;
        }
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:TVDB_QUERY_SERVER_TIME, TVDB_HOSTNAME]];

#if HAVE_BLOCK
    [MLURLConnection runConnectionWithURL:url andBlock:^(MLURLConnection *connection, NSError *error) {
        if (error) {
            block(nil);
            return;
        }
        [gServerTime release];
        [gLastFetch release];
        NSData *data = connection.data;
        NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithData:connection.data options:0 error:nil];
        NSNumber *serverTime = [[xmlDoc rootElement] numberValueForXPath:@"./Time"];

        gServerTime = [serverTime retain];
        gLastFetch = [[NSDate dateWithTimeIntervalSinceNow:0] retain];

        block(gServerTime);
    }];
#endif
}

- (void)dealloc
{
    [_data release];
    [_connection release];
    [_results release];
    [super dealloc];
}

- (void)lookUpForTitle:(NSString *)title
{
    NSString *escapedString = [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:TVDB_QUERY_SEARCH, TVDB_HOSTNAME, escapedString]];
    NSLog(@"Accessing %@", url);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [_connection cancel];
    [_connection release];

    [_data release];
    _data = [[NSMutableData alloc] init];

    // Keep a reference to ourself while we are alive.
    [self retain];

    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [request release];
}

- (void)lookUpForShowID:(NSString *)showId
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:TVDB_QUERY_EPISODE_INFO, TVDB_HOSTNAME, TVDB_API_KEY, showId, TVDB_DEFAULT_LANGUAGE]];
    NSLog(@"Accessing %@", url);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [_connection cancel];
    [_connection release];

    [_data release];
    _data = [[NSMutableData alloc] init];

    // Keep a reference to ourself while we are alive.
    [self retain];

    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [request release];
}

#if HAVE_BLOCK
- (void)lookUpForTitle:(NSString *)title andExecuteBlock:(void (^)())block
{
    Block_release(_block);
    _block = Block_copy(block);
    [self lookUpForTitle:title];
}
#endif

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(movieInfoGrabber:didFailWithError:)])
        [_delegate tvShowInfoGrabber:self didFailWithError:error];

#if HAVE_BLOCK
    // Release the eventual block. This prevents ref cycle.
    if (_block) {
        Block_release(_block);
        _block = NULL;
    }
#endif

    // This balances the -retain in -lookupForTitle
    [self autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithData:_data options:0 error:nil];

    [_data release];
    _data = nil;

    NSError *error = nil;
    NSArray *nodes = [xmlDoc nodesForXPath:@"./Data/Series" error:&error];

    if ([nodes count] > 0 ) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[nodes count]];
        for (NSXMLNode *node in nodes) {
            NSString *id = [node stringValueForXPath:@"./seriesid"];
            if (!id)
                continue;
            NSString *title = [node stringValueForXPath:@"./SeriesName"];
            NSString *release = [node stringValueForXPath:@"./FirstAired"];
            NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
            [inputFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
            [outputFormatter setDateFormat:@"yyyy"];
            NSDate *releaseDate = [inputFormatter dateFromString:release];
            NSString *releaseYear = releaseDate ? [outputFormatter stringFromDate:releaseDate] : nil;

            NSString *artworkURL = [node stringValueForXPath:@"./banner"];
            NSString *shortSummary = [node stringValueForXPath:@"./Overview"];
            [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              title, @"title",
                              id, @"id",
                              shortSummary ?: @"", @"shortSummary",
                              releaseYear ?: @"", @"releaseYear",
                              [NSString stringWithFormat:TVDB_COVERS_URL, TVDB_IMAGES_HOSTNAME, artworkURL], @"banner",
                              nil]];
        }
        self.results = array;
    }
    else
        self.results = nil;

    [xmlDoc release];

#if HAVE_BLOCK
    if (_block) {
        _block();
        Block_release(_block);
        _block = NULL;
    }
#endif

    if ([_delegate respondsToSelector:@selector(movieInfoGrabberDidFinishGrabbing:)])
        [_delegate tvShowInfoGrabberDidFinishGrabbing:self];

    // This balances the -retain in -lookupForTitle
    [self autorelease];
}

@end
