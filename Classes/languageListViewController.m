    //
//  languageListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 2/2/12.
//  Copyright 2012 Dynamic Solution Innovators Limited. All rights reserved.
//

#import "languageListViewController.h"


@implementation languageListViewController

- (NSString *) getSearchBarTitle{
	return @"Search Language";
}

- (void)viewDidLoad {
	if([self.selectedDataSource count] == 0){
		selectedDataSource = [[NSMutableArray alloc] initWithObjects:nil];
	}
	self.isSearchFromOnline = FALSE; //need to remove it once we got the url
	if (self.isSearchFromOnline) {
		/*
		[self.listTableView setHidden:YES];
		NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingString:@"county/json"];
		[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];
		*/
	}else{
		
		[self.listTableView setHidden:YES];
		[self.spinner startAnimating];
		self.spinner.hidden = NO;
		self.spinnerBg.hidden = NO;
		
		self.dataSource = [utils getLanguageList:nil];
		[self.listTableView reloadData];
		
		[self.spinner stopAnimating];
		self.spinner.hidden = YES;
		self.spinnerBg.hidden = YES;
		[self.listTableView setHidden:NO];	
	}
	
}

- (IBAction) searchContentChanged: (id) sender{
	
	NSLog(@"inside searchContentChanged......");
	self.isSearchFromOnline = FALSE; //need to remove it once we got the url
	
	if (self.isSearchFromOnline) {
		/*
		NSString *serverUrl = [[[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingString:@"county/json&code="] stringByAppendingString:[self.searchBar text]];
		[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];	
		*/
	}else {
		
		[self.spinner startAnimating];
		self.spinner.hidden = NO;
		self.spinnerBg.hidden = NO;
		
		self.dataSource = [utils getLanguageList:self.searchBar.text];
		[self.listTableView reloadData];
		
		[self.spinner stopAnimating];
		self.spinner.hidden = YES;
		self.spinnerBg.hidden = YES;
		
	}
	
}

@end
