//
//  IMIDownloadManager.m

//
//  Created by Travis Worm (i@imi.im) on 10-11-4.
//  Copyright 2009-2010 imi.im. All rights reserved.
//

#import "IMIDownloadManager.h"


@implementation IMIDownloadManager

@synthesize downloaders;
@synthesize delegate;

static IMIDownloadManager *sharedIMIDownloadManager=nil;
+(IMIDownloadManager*)shared{
	if (sharedIMIDownloadManager==nil) {
		sharedIMIDownloadManager=[IMIDownloadManager new];
	}
	return sharedIMIDownloadManager;
}


-(void)stop{
	if (self.downloaders==nil) {
		return;
	}
	NSMutableArray *infos=[NSMutableArray array];
	for (NSString *uuid in downloaders) {
		IMIDownloader *downloader=[downloaders objectForKey:uuid];
		[downloader performSelector:@selector(pause)];
		[infos addObject:[downloader info]];
	}
	[infos writeToFile:DataPath(@"DownloadManager.plist", @"") atomically:YES];
	self.downloaders=nil;
}
-(BOOL)resume{
	if (self.downloaders!=nil) {
		for (NSString *uuid in downloaders) {
			IMIDownloader *downloader=[downloaders objectForKey:uuid];
			[downloader performSelector:@selector(start) withObject:nil afterDelay:0.1];
		}
		return YES;
	}else if (IsFileExistAt(DataPath(@"DownloadManager.plist", @""))) {
		NSArray *infos=[NSArray arrayWithContentsOfFile:DataPath(@"DownloadManager.plist", @"")];
		for (NSDictionary *info in infos) {
			IMIDownloader *downloader=[[IMIDownloader alloc] initWithInfo:info];
			[self addDownloader:downloader];
			[downloader release];
		}
		if ([infos count]>0) {
			return YES;
		}
	}
	return NO;
}

-(void)addDownloader:(IMIDownloader*)aDownloader{
	if (self.downloaders==nil) {
		self.downloaders=[[NSMutableDictionary new]autorelease];
	}
	[downloaders setObject:aDownloader forKey:aDownloader.uuid];
	aDownloader.manager=self;
	[aDownloader performSelector:@selector(start) withObject:nil afterDelay:0.1];
}
-(void)pauseDownloaderWithID:(NSString*)downloaderID{
	IMIDownloader *downloader=[downloaders objectForKey:downloaderID];
	[downloader performSelector:@selector(pause)];
	[downloaders removeObjectForKey:downloaderID];
	
	NSMutableArray *infos=[NSMutableArray array];
	for (NSString *uuid in downloaders) {
		IMIDownloader *downloader=[downloaders objectForKey:uuid];
		[infos addObject:[downloader info]];
	}
	[infos writeToFile:DataPath(@"DownloadManager.plist", @"") atomically:YES];
}

-(void)onDownloaderReceivedData:(IMIDownloader*)aDownloader{
	if ([(NSObject*)delegate respondsToSelector:@selector(onDownloaderReceivedData:)]) {
		[delegate onDownloaderReceivedData:aDownloader];
	}
}
-(void)onFinishDownload:(IMIDownloader*)aDownloader{
	[self pauseDownloaderWithID:aDownloader.uuid];
	if (delegate) {
		[delegate onFinishDownload:aDownloader];
	}
}
- (void)dealloc
{
	[self stop];
	[super dealloc];
}

@end
