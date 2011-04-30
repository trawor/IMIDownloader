//
//  IMIDownloadManager.h

//
//  Created by Travis Worm (i@imi.im) on 10-11-4.
//  Copyright 2009-2010 imi.im. All rights reserved.
//

#import "IMIDownloader.h"

@interface IMIDownloadManager : NSObject<IMIDownloaderDelegate>{
	NSMutableDictionary *downloaders;
	id<IMIDownloaderDelegate> delegate;
}

@property (nonatomic, retain) NSMutableDictionary *downloaders;
@property(nonatomic,assign) id<IMIDownloaderDelegate> delegate;

+(IMIDownloadManager*)shared;
-(void)addDownloader:(IMIDownloader*)aDownloader;
-(void)pauseDownloaderWithID:(NSString*)downloaderID;

-(BOOL)resume;
-(void)stop;

@end
