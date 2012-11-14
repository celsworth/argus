//
//  ArgusChannelLogo.m
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusChannelLogo.h"

#import "Argus.h"
#import "DeviceDetection.h"

// responsible for all logo handling; returning UIImage objects, fetching, saving to disk

@implementation ArgusChannelLogo

-(id)initWithChannelId:(NSString *)incomingChannelId
{
	self = [super init];
	if (self)
	{
		_ChannelId = incomingChannelId;
		
		// this will do for now but it's not really right. If logos are copied from one
		// device to another this could well be wrong on the new device.
		// work out what scale images we want, 1.0 on SD, 2.0 on Retina displays
		// if we ever want bigger ones on iPad this'll need to change to store sizes as well?
		switch([DeviceDetection deviceType])
		{
			case ArgusDeviceTypeiPadSD:
			case ArgusDeviceTypeiPhoneSD:
				_scale = 1.0;
				break;
				
			case ArgusDeviceTypeiPadRetina:
			case ArgusDeviceTypeiPhoneRetina:
				_scale = 2.0;
				break;
		}
	}
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__); // spammy
	// ensure we don't leave any orphaned notification observers lying about! very important!
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIImage *)image
{
	// if entry on disk, return it
	UIImage *tmp = [self loadLogo];
	if (tmp)
	{
		// return the image we have
		// but also check for a newer one if the one we have is more than two hours old?
		NSDate *mTime = [self logoModTime];
		if ([[NSDate date] timeIntervalSinceDate:mTime] > 7200)
		{
			//[self performSelectorInBackground:@selector(fetchLogoIfNewerThan:) withObject:mTime];
			[self fetchLogoIfNewerThan:mTime];
		}
		return tmp;
	}
	
	// no entry on disk, OR file is invalid?
	[self deleteLogo];
	
	// if no entry on disk, trigger request to go fetch it
	// this will post a notification when done
	//[self performSelectorInBackground:@selector(fetchLogoIfNewerThan:) withObject:nil];
	[self fetchLogoIfNewerThan:nil];

	return nil; // no logo to return yet
}

-(BOOL)fetchLogoIfNewerThan:(NSDate *)modTime
{
	//NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, ChannelId, modTime);
	
	NSString *modTimeStr;
	// need to take modTime into account, convert to YYYY-MM-DD
	if (modTime)
	{
		time_t modTimeT = [modTime timeIntervalSince1970];
		struct tm timeStruct;
		char buffer[80];
		
		localtime_r(&modTimeT, &timeStruct);
		strftime(buffer, 80, "%Y-%m-%dT%H:%M:%S", &timeStruct);
		modTimeStr = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
	}
	else
	{
		modTimeStr = @"1970-01-01T00:00:00";
	}
	
	// work out what channel logo size we'd like
	NSString *logoSize;
	if (self.scale == 1.0)
		logoSize = @"48";
	else
		logoSize = @"96";
	
	// trigger NSURLRequest for logo for this ChannelId, using an ArgusConnection
	NSString *url = [NSString stringWithFormat:@"Scheduler/ChannelLogo/%@/%@/%@/true/%@", self.ChannelId, logoSize, logoSize, modTimeStr];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:YES lowPriority:YES];
	
	// we need to be told when the request is done (or fails)
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(logoFetchDone:)
												 name:kArgusConnectionDone
											   object:c];

	return TRUE;
}
-(void)logoFetchDone:(NSNotification *)notify
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	ArgusConnection *c = [notify object];
	
	// check if logo response was 200 or 304 to see if we have a new(er) one to save
	NSInteger statusCode = [[c httpresponse] statusCode];
	if (statusCode == 204)
	{
		// no logo
		return;
	}
	if (statusCode == 304)
	{
		// nothing newer
		
		// update mtime of what we have
		[self touchLogo];
		return;
	}
	
	// logo is in here
	NSData *data = [[notify userInfo] objectForKey:@"data"];

	UIImage *image = [[UIImage alloc] initWithData:data];
	if (!image)
	{
		NSLog(@"%s: image is nil!", __PRETTY_FUNCTION__);
		
		NSLog(@"%s: notify: %@", __PRETTY_FUNCTION__, notify);
		
		NSLog(@"%s: headers: %@", __PRETTY_FUNCTION__, [[c httpresponse] allHeaderFields]);

		assert(image); // force crash
	}
	
	[self saveLogoWithContents:data];
	
	// post a notification!
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusChannelLogoDone object:self];
}


#pragma mark - Disk Handling

-(BOOL)createBasePath
{
	NSString *path = [self basePath];
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSError *error;
	return [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];	
}

-(NSString *)basePath
{
	return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
			stringByAppendingPathComponent:@"ChannelLogos"];
}
-(NSString *)absoluteFileForLogo
{
	return [[self basePath] stringByAppendingPathComponent:self.ChannelId];
}


-(NSDictionary *)statLogo
{
	NSString *fileName = [self absoluteFileForLogo];
	NSFileManager *fm = [[NSFileManager alloc] init];
	
	if (![fm fileExistsAtPath:fileName])
		return nil;
	
	return [fm attributesOfItemAtPath:fileName error:nil];
}
-(NSDate *)logoModTime
{
	NSDictionary *stat = [self statLogo];
	return [stat fileModificationDate];
}

-(void)touchLogo
{
	NSFileManager *fm = [[NSFileManager alloc] init];

	[fm setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate]
		 ofItemAtPath:[self absoluteFileForLogo]
				error:nil];
}

-(void)deleteLogo
{
	if ([self createBasePath])
	{
		NSString *fileName = [self absoluteFileForLogo];
		NSFileManager *fm = [[NSFileManager alloc] init];
		[fm removeItemAtPath:fileName error:nil];
	}
}

-(BOOL)saveLogoWithContents:(NSData *)data
{
	if ([self createBasePath])
	{
		NSString *fileName = [self absoluteFileForLogo];
		NSFileManager *fm = [[NSFileManager alloc] init];
		//NSLog(@"Saved Channel Logo %@", ChannelId);
		return [fm createFileAtPath:fileName contents:data attributes:nil];
	}
	return NO;
}
-(UIImage *)loadLogo
{
	NSString *fileName = [self absoluteFileForLogo];
	NSFileManager *fm = [[NSFileManager alloc] init];
	if ([fm fileExistsAtPath:fileName])
	{
		//return [UIImage imageWithContentsOfFile:[self absoluteFileForLogo]];
		
		// retain the UIImage in a property to stop CG crashing
		self.imageWhichStopsUsCrashing = [UIImage imageWithContentsOfFile:fileName];
		CGImageRef cg = [self.imageWhichStopsUsCrashing CGImage];
		UIImage *ret = [UIImage imageWithCGImage:cg scale:self.scale orientation:UIImageOrientationUp];
		return ret;
	}
	return nil;
}


@end
