//
//  irefer2AppDelegate.m
//  irefer2
//
//  Created by Mushraful Hoque on 12/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "irefer2AppDelegate.h"

@implementation irefer2AppDelegate

@synthesize window;
@synthesize viewController, filterController, setupController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	//initializing tables on database
	dao = [[BaseDao alloc] init];
	[dao initializeTables];
	
	if ([dao isUserAlreadyActivated]) {
		if ([dao getTableRowCount:IreferConstraints.doctorTableName] <= 0) {
			[window addSubview:setupController.view];
		}else {
			[window addSubview:filterController.view];	
		}
	}else{
		[window addSubview:viewController.view];
	}
	[window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	NSLog(@"applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	NSLog(@"applicationDidEnterBackground");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	NSLog(@"applicationWillEnterForeground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	NSLog(@"applicationDidBecomeActive");
	[NSThread detachNewThreadSelector:@selector(startupSyncThread) toTarget:self withObject:nil];

}

-(void) startupSyncThread{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  

	NSDictionary *userData = [dao getCurrentUserPracticeOrHospital];
	
	//uploading abuse reports
	NSArray *reports = [dao getSyncronizableReports];
	NSLog(@"uploadable report count %d",[reports count]);
	BOOL *isFirst = YES;
	NSString *content = @"";
	for(NSDictionary *report in reports){
		if (isFirst) {
			isFirst = NO;
			content = [content stringByAppendingFormat:@"%@,%@",[report objectForKey:@"docId"],[report objectForKey:@"text"]];
		}else {
			content = [content stringByAppendingFormat:@"|%@,%@",[report objectForKey:@"docId"],[report objectForKey:@"text"]];
		}
	}
	NSLog(content);
	NSString *url = @"";
	NSString *responseStr = @"";
	
	if(![content isEqual:@""]){
		url = [NSString stringWithFormat:@"%@doctorComment/comment2&user_id=%@&var=%@",[utils getServerURL], [userData objectForKey:@"uid"], content];
		responseStr = [utils getStringFromSyncronousURLCall:url];
		[dao updateSyncronizableReports];
	}
	//uploading ranks
	NSArray *ranks = [dao getSyncronizableRanks];
	NSLog(@"uploadable rank count %d",[ranks count]);
	isFirst = YES;
	content = @"";
	for(NSDictionary *rank in ranks){
		if (isFirst) {
			isFirst = NO;
			content = [content stringByAppendingFormat:@"%@,%@",[rank objectForKey:@"docId"],[rank objectForKey:@"rank"]];
		}else {
			content = [content stringByAppendingFormat:@"|%@,%@",[rank objectForKey:@"docId"],[rank objectForKey:@"rank"]];
		}
	}
	NSLog(content);
	if(![content isEqual:@""]){
		url = [NSString stringWithFormat:@"%@userDocRank/bulkRank&user_id=%@&val=%@",[utils getServerURL], [userData objectForKey:@"uid"], content];
		NSLog(url);
		responseStr = [utils getStringFromSyncronousURLCall:url];
		NSLog(@"response for rank update %@",responseStr);
		[dao updateSyncronizableRanks];
	}
	
	//uploading search count
	int count = [dao getSearchCount:1];
	NSLog(@"uploadable search count %d",count);
	if( count > 0 ){
		url = [NSString stringWithFormat:@"%@searchStatistics/setCount&user_id=%@&count=%d",[utils getServerURL], [userData objectForKey:@"uid"], count];
		NSLog(url);
		responseStr = [utils getStringFromSyncronousURLCall:url];
		NSLog(@"response for statistics upload %@",responseStr);
	}
	
	//downloading profile
	NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"user/json&user_id=%@",[userData objectForKey:@"uid"]];
	NSLog(serverUrl);
	NSMutableArray *profileList = [utils getDataFromSyncronousURLCall:serverUrl];
	if (profileList != NULL && [profileList count] > 0) {
		NSDictionary *profile = [profileList objectAtIndex:0];
		NSDictionary *hosPrac = [profileList objectAtIndex:1];
		NSDictionary *county = [profileList objectAtIndex:2];
		NSDictionary *state = [profileList objectAtIndex:3];
		
		NSMutableDictionary *newUserData = [[NSMutableDictionary alloc] init];
		[newUserData setObject:[profile objectForKey:@"id"] forKey:@"user_id"];
		[newUserData setObject:[profile objectForKey:@"first_name"] forKey:@"first_name"];
		[newUserData setObject:[profile objectForKey:@"last_name"] forKey:@"last_name"];
		
		if ([profile objectForKey:@"prac_id"] != [NSNull null] && ![[profile objectForKey:@"prac_id"] isEqual:@"<null>"] && ![[profile objectForKey:@"prac_id"] isEqual:@""] ) {
			
			[newUserData setObject:hosPrac forKey:@"practice"];
			
		}else if ([profile objectForKey:@"hosp_id"] != [NSNull null] && ![[profile objectForKey:@"hosp_id"] isEqual:@"<null>"] && ![[profile objectForKey:@"hosp_id"] isEqual:@""] ) {

			[newUserData setObject:hosPrac forKey:@"hospital"];
			
		}

		[newUserData setObject:county forKey:@"county"];
		[newUserData setObject:state forKey:@"state"];
		
		NSLog(@"before dao....");
		[dao updateProfile:newUserData];
		
		 filterController.pname.text = [NSString stringWithFormat:@"%@ %@", [profile objectForKey:@"last_name"], [profile objectForKey:@"first_name"]];
		 NSString *addText = [hosPrac objectForKey:@"name"];
		 
		 if (![[county objectForKey:@"name"] isEqual:@""]) {
		 addText = [addText stringByAppendingFormat:@", %@", [county objectForKey:@"name"]];
		 }
		 
		 if (![[state objectForKey:@"state_code"] isEqual:@""]) {
		 addText = [addText stringByAppendingFormat:@" %@", [state objectForKey:@"state_code"]];
		 }
		 filterController.address.text = addText;
		 
		 
		int countDoc = [dao getTableRowCount:IreferConstraints.doctorTableName colName:@"doc_id"];

		if( countDoc > 0 ){
			if (![[userData objectForKey:@"last_sync_time"] isEqual:[profile objectForKey:@"user_notify_date"]] ||
				![[userData objectForKey:@"last_admin_sync_time"] isEqual:[profile objectForKey:@"admin_notify_date"]]) {
				
				if (![[userData objectForKey:@"last_admin_sync_time"] isEqual:[profile objectForKey:@"admin_notify_date"]]) {

					NSDate *currentModDate = [utils getDateFromFormatedString:[userData objectForKey:@"last_admin_sync_time"] format:@"yyyy-MM-dd HH:mm:ss"];
					NSDate *recentModDate = [utils getDateFromFormatedString:[profile objectForKey:@"admin_notify_date"] format:@"yyyy-MM-dd HH:mm:ss"];
					NSLog(@"CURRENT sync date %@",currentModDate);
					NSLog(@"RECENT sync date %@",recentModDate);
					
					if ([currentModDate compare:recentModDate] == NSOrderedAscending) {
						NSLog(@"inside admin notification");
						[dao updateUserSyncFlag:@"1"];
						[utils showAlert:@"Notification !!!" message:@"Online database has been changed by Admin. Please syncronize your app." delegate:nil];
					}
				}else if (![[userData objectForKey:@"last_sync_time"] isEqual:[profile objectForKey:@"user_notify_date"]]) {
					NSDate *currentModDate = [utils getDateFromFormatedString:[userData objectForKey:@"last_sync_time"] format:@"yyyy-MM-dd HH:mm:ss"];
					NSDate *recentModDate = [utils getDateFromFormatedString:[profile objectForKey:@"user_notify_date"] format:@"yyyy-MM-dd HH:mm:ss"];
					NSLog(@"CURRENT sync date %@",currentModDate);
					NSLog(@"RECENT sync date %@",recentModDate);
					
					if ([currentModDate compare:recentModDate] == NSOrderedAscending) {
						NSLog(@"inside user notification");
						[dao updateUserSyncFlag:@"1"];
						[utils showAlert:@"Notification !!!" message:@"Online database has been changed by you. Please syncronize your app." delegate:nil];
					}
				}
			}
		}
		
	}
	//[utils showAlert:@"Notification !!!" message:@"test" delegate:nil];
	[pool drain];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	NSLog(@"applicationWillTerminate");
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[dao release];
	[setupController release];
	[filterController release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
