//
//  countyListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "countyListViewController.h"


@implementation countyListViewController

- (NSString *) getSearchBarTitle{
	return @"Search County";
}

- (void)viewDidLoad {
	if([self.selectedDataSource count] == 0){
		selectedDataSource = [[NSMutableArray alloc] initWithObjects:nil];
	}
	
	if (self.isSearchFromOnline) {
		
		[self.listTableView setHidden:YES];
		NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"county/json&limit=%d",self.currentLimit];
		[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];
		
	}else{
		
		[NSThread detachNewThreadSelector:@selector(loadLocalRows) toTarget:self withObject:nil];	
	}
	
}

- (IBAction) searchContentChanged: (id) sender{
	
	NSLog(@"inside searchContentChanged......");
	self.currentLimit = 50;

	if (self.isSearchFromOnline) {
		
		NSString *serverUrl = [[NSString stringWithString: [self getSearchURL]] stringByAppendingFormat:@"&limit=%d", self.currentLimit];
		[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];	
		
	}else {
		
		[NSThread detachNewThreadSelector:@selector(loadLocalRows) toTarget:self withObject:nil];
		
	}
	
}

- (NSString *)getSearchURL{
	
	NSString *serverUrl = [[[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingString:@"county/json&code="] stringByAppendingString:[self.searchBar text]];
	return serverUrl;
}

- (void)loadLocalRows{
	@synchronized(self){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
		
		[self.listTableView setHidden:YES];
		[self.spinner startAnimating];
		self.spinner.hidden = NO;
		self.spinnerBg.hidden = NO;
		
		self.totalCount = [dao getTableRowCount:IreferConstraints.countyTableName searchValue:self.searchBar.text];
		
		self.dataSource = [dao getTableRowList:IreferConstraints.countyTableName searchValue:self.searchBar.text limit:self.currentLimit];
		if ([self.dataSource count] < self.totalCount && [self.dataSource count] > 0) {
			[self.dataSource addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"Showing %d out of %d",[self.dataSource count], self.totalCount],@"count",nil] autorelease]];
		}
		[self.dataSource addObject:[[[NSDictionary alloc] init] autorelease]];
		[self.listTableView reloadData];
		
		[self.spinner stopAnimating];
		self.spinner.hidden = YES;
		self.spinnerBg.hidden = YES;
		[self.listTableView setHidden:NO];
		
		[pool drain];
	}
}



@end
