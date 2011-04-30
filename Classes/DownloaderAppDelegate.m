//
//  DownloaderAppDelegate.m
//  Downloader
//
//  Created by Travis Worm (i@imi.im) on 10-11-19.
//  Copyright 2010 imi.im. All rights reserved.
//

#import "DownloaderAppDelegate.h"
#import "IMIDownloadManager.h"
@implementation DownloaderAppDelegate

@synthesize window;

-(void)onDownloaderReceivedData:(IMIDownloader*)aDownloader{
	//NSLog(@"%@\t\tProgress: %.2f%%",aDownloader.uuid,aDownloader.progress*100.0);
	UIProgressView *p=(UIProgressView *)[window viewWithTag:[aDownloader.uuid intValue]];
	p.progress=aDownloader.progress;
}

-(void)onFinishDownload:(IMIDownloader*)aDownloader{
	NSLog(@"%@\t\tFinish: %@",aDownloader.uuid,aDownloader.name);
}

-(void)testDownloader{
	IMIDownloadManager *dm=[IMIDownloadManager shared];
	dm.delegate=(id<IMIDownloaderDelegate>)self;
	if (![dm resume]) {
		IMIDownloader *dl=[IMIDownloader new];
		
		//memory size (KB) of the downloading cache, default value is 100KB
		dl.memoryCacheSize=80;
		
		//uuid can be any string, but here I use an int to give tag for UIProgressView
		//that can easy trac back to update the progress
		dl.uuid=@"102";	
		
		//give me a name, or I will guess my name
		dl.name=@"pic1.jpg";	
		
		//customize the file, leave it blank, I can give a path
		//dl.path=@"/CUSTOMIZE/YOUR/FILE/PATH";
		
		dl.targetURL=@"http://www.deskcity.com/picture/image_url/82209/SDCQ_001017.jpg?1289586079";
		
		[dm addDownloader:[dl autorelease]];	//downloader will start by itself
		
		
		
		
		IMIDownloader *dl2=[IMIDownloader new];
		dl2.uuid=@"4322";
		dl2.name=@"pic2.jpg";
		dl2.targetURL=@"http://www.deskcity.com/picture/image_url/82212/SDCQ_001020.jpg?1289586086";
		[dm addDownloader:[dl2 autorelease]];
		
	}else {
		NSLog(@"Resume Downloading!");
	}
	
	NSArray *keys=[dm.downloaders allKeys];
	for (int i=0;i< [keys count];i++) {
		UIProgressView *p=[[UIProgressView alloc] initWithFrame:CGRectMake(0, 50*(i+1), 320, 20)];
		
		p.tag=[[keys objectAtIndex:i] intValue];
		p.progressViewStyle=UIProgressViewStyleBar;
		[window addSubview:p];
		[p autorelease];
	}
	
	UIButton *btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame=CGRectMake(20, 350, 100, 40);
	[btn setTitle:@"Resume" forState:UIControlStateNormal];
	
	[btn addTarget:dm action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
	[window addSubview:btn];
	
	btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame=CGRectMake(180, 350, 100, 40);
	[btn setTitle:@"Stop" forState:UIControlStateNormal];
	[btn addTarget:dm action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
	[window addSubview:btn];
}
#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
    [self testDownloader];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
