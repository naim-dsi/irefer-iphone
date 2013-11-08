    //
//  stpHosListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "stpHosListViewController.h"


@implementation stpHosListViewController

- (NSString *) getSearchBarTitle{
	return @"Search Hospital";
}

- (void)viewDidLoad {
	self.isSearchFromOnline = YES;
	if([self.selectedDataSource count] == 0){
		selectedDataSource = [[NSMutableArray alloc] initWithObjects:nil];
	}
	
	[self.listTableView setHidden:YES];
	NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"hospital/json?limit=%d",self.currentLimit];
	[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];
	
}

- (IBAction) searchContentChanged: (id) sender{
	
	NSLog(@"inside searchContentChanged......");
	self.currentLimit = 50;
	NSString *serverUrl = [[NSString stringWithString: [self getSearchURL]] stringByAppendingFormat:@"&limit=%d", self.currentLimit];
	[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];	
	
}

- (NSString *)getSearchURL{

	NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"hospital/json?code=%@", self.searchBar.text];
	return serverUrl;
}

@end
