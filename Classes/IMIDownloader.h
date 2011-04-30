//
//  IMIDownloader.h

//
//  Created by Travis Worm (i@imi.im) on 10-11-4.
//  Copyright 2009-2010 imi.im. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* DataPath(NSString* name, NSString* folder);
BOOL IsFileExistAt(NSString *filepath);

@class IMIDownloader;
@protocol IMIDownloaderDelegate
-(void)onFinishDownload:(IMIDownloader*)aDownloader;

@optional
-(void)onDownloaderReceivedData:(IMIDownloader*)aDownloader;
@end

@class IMIDownloadManager;
@interface IMIDownloader : NSObject{
	NSString *targetURL;
	NSString *uuid;
	NSString *name;
	
	BOOL isDownloading;
	float progress;
	
	NSUInteger loadedBytes;
	NSUInteger totalBytes;
	
	NSURLConnection *connection;
	NSMutableData *data;
	
	IMIDownloadManager *manager;
	
	NSString *path;
	
	NSUInteger memoryCacheSize;
}

@property (nonatomic, assign) NSUInteger memoryCacheSize;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) IMIDownloadManager *manager;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) NSUInteger loadedBytes;
@property (nonatomic, assign) NSUInteger totalBytes;
@property (nonatomic, readonly) float progress;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, copy) NSString *targetURL;
@property (nonatomic, copy) NSString *uuid;

- (id) initWithInfo:(NSDictionary*)info;
-(NSDictionary*)info;


@end
