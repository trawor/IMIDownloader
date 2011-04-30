//
//  IMIDownloader.m

//
//  Created by Travis Worm (i@imi.im) on 10-11-4.
//  Copyright 2009-2010 imi.im. All rights reserved.
//

#import "IMIDownloader.h"
#import "IMIDownloadManager.h"

NSString* DataPath(NSString* name, NSString* folder){
	NSArray	*documentPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *doc=[documentPaths  objectAtIndex:0];
	NSString *folderPath=[doc stringByAppendingPathComponent:folder];
	return [folderPath stringByAppendingPathComponent:name];
}
BOOL IsFileExistAt(NSString *filepath)
{
	if(filepath==nil)return NO;
	return [[NSFileManager defaultManager] fileExistsAtPath:filepath];
}

@implementation IMIDownloader

@synthesize memoryCacheSize;
@synthesize path;
@synthesize name;
@synthesize manager;
@synthesize data;
@synthesize connection;
@synthesize loadedBytes;
@synthesize totalBytes;
@synthesize progress;
@synthesize isDownloading;
@synthesize targetURL;
@synthesize uuid;


- (id) init
{
	self = [super init];
	if (self != nil) {
		self.loadedBytes=0;
		self.totalBytes=0;
		self.path=nil;
		self.memoryCacheSize=100;
	}
	return self;
}

- (id) initWithInfo:(NSDictionary*)info
{
	self = [self init];
	if (self != nil) {
		self.loadedBytes=[[info objectForKey:@"loadedBytes"] longValue];
		self.totalBytes=[[info objectForKey:@"totalBytes"] longValue];
		self.uuid=[info objectForKey:@"uuid"];
		self.targetURL=[info objectForKey:@"targetURL"];
		self.name=[info objectForKey:@"name"];
		self.path=[info objectForKey:@"path"];
	}
	return self;
}
- (float)progress{
	if (self.totalBytes>0) {
		return self.loadedBytes*1.0f/self.totalBytes;
	}
	return 0;
}
-(void)guessFileName{
	if (self.name) {
		return;
	}
	NSString *last=[self.targetURL lastPathComponent];
	NSInteger loc=[last rangeOfString:@"?"].location;
	if (loc!=NSNotFound) {
		last=[last substringToIndex:loc];
	}
	if ([last length]>4) {
		self.name=last;
	}else {
		self.name=[self.uuid stringByAppendingString:last];
	}
}
-(void)writeCache{
	if ([self.data length]>0) {
		NSFileHandle *file=[NSFileHandle fileHandleForWritingAtPath:self.path];
		if (file) {
			[file seekToEndOfFile];
			[file writeData:self.data];
			[file closeFile];	
		}else {
			[self.data writeToFile:self.path atomically:NO];
		}

		//NSLog(@"%@\t\tWrite Data Length:%ld",self.name,[self.data length]);
		
		[self.data setLength:0];
		
	}
}
-(void)start{
	if(isDownloading)return;
	if (self.targetURL==nil) {
		return;
	}
	if (self.loadedBytes==self.totalBytes && self.totalBytes!=0) {
		return;
	}
	
	
	NSMutableURLRequest *req=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.targetURL] 
														  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData 
													  timeoutInterval:10];
	[req setHTTPMethod:@"GET"];
	
	if(loadedBytes>0){
		[req addValue:[NSString stringWithFormat:@"bytes=%ld-",self.loadedBytes] 
   forHTTPHeaderField:@"Range"];
	}else {
		[self guessFileName];
		
		//NSLog(@"Start Download %@",self.name);
		if (self.path==nil) {
			self.path=DataPath(self.name, @"Cache");
		}
		NSString *parentFolder=[self.path stringByDeletingLastPathComponent];
		if (!IsFileExistAt(parentFolder)) {
			[[NSFileManager defaultManager] createDirectoryAtPath:parentFolder
									  withIntermediateDirectories:YES
													   attributes:nil error:NULL];
		}else {
			[[NSFileManager defaultManager] removeItemAtPath:self.path error:NULL];
		}
	}

	
	self.connection=[[[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES] autorelease];
	[req release];
	isDownloading=YES;
}

-(void)pause{
	[self writeCache];
	[self.connection cancel];
	self.connection=nil;
	isDownloading=NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)res
{
	// Get response code.
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)res;
	
    NSInteger statusCode = [resp statusCode];
    
	if(self.totalBytes==0)self.totalBytes= [[[resp allHeaderFields] objectForKey:@"Content-Length"] intValue];
    
	NSString *r=[[resp allHeaderFields] objectForKey:@"Content-Range"];
	//NSLog(@"Conn: %@ Code:%i Length: %i From:%@",self.uuid,statusCode,self.totalBytes,r);
	self.data=[NSMutableData data];

}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)dt
{
	[self.data appendData:dt];
	self.loadedBytes+=[dt length];
	
	if ([self.data length]>self.memoryCacheSize*1024) {
		[self writeCache];
	}
	if ([(NSObject*)manager respondsToSelector:@selector(onDownloaderReceivedData:)]) {
		[self.manager onDownloaderReceivedData:self];
	}
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"Error: %@",[error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self writeCache];
	isDownloading=NO;
	//NSLog(@"%@ Finished! TotalSize:%ld",self.name,self.loadedBytes);
	if (self.manager) {
		[self.manager onFinishDownload:self];
	}
}

-(NSDictionary*)info{
	NSDictionary *info=[NSDictionary dictionaryWithObjectsAndKeys:
						self.uuid,@"uuid",
						self.targetURL,@"targetURL",
						[NSNumber numberWithLong:self.loadedBytes],@"loadedBytes",
						[NSNumber numberWithLong:self.totalBytes],@"totalBytes",
						self.name,@"name",
						self.path,@"path",
						nil];
	return info;
}

- (void)dealloc
{
	[self writeCache];
	[uuid release];
	uuid = nil;
	
	[targetURL release];
	targetURL = nil;
	
	[connection release];
	connection = nil;
	
	[data release];
	data = nil;
	
	manager = nil;

	[name release];
	name = nil;

	[path release];
	path = nil;

	isDownloading=NO;

	[super dealloc];
}
@end
