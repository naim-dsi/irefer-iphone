    //
//  stpPracListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "stpPracListViewController.h"


@implementation stpPracListViewController

- (NSString *) getSearchBarTitle{
	return @"Search Practice";
}

- (void)viewDidLoad {
	self.isSearchFromOnline = YES;
	if([self.selectedDataSource count] == 0){
		selectedDataSource = [[NSMutableArray alloc] initWithObjects:nil];
	}
	
	
	[self.listTableView setHidden:YES];
	NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"practice/json&limit=%d",self.currentLimit];
	[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];

}

- (IBAction) searchContentChanged: (id) sender{
	
	NSLog(@"inside searchContentChanged......");
	self.currentLimit = 50;
	
	NSString *serverUrl = [[NSString stringWithString: [self getSearchURL]] stringByAppendingFormat:@"&limit=%d", self.currentLimit];
	[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];	
	
}

- (NSString *)getSearchURL{
	
	NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"practice/json&code=%@", self.searchBar.text];
	return serverUrl;
}

@end
