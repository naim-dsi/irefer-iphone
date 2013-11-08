//
//  practiceListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "practiceListViewController.h"


@implementation practiceListViewController

-(NSString *) getSearchBarLabel{
	return @"Search Your Practice";
}

-(NSString *) getInitUrl{
	return [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingString:@"practice/json"];
}

-(NSString *) getSearchUrl{
	return [[[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingString:@"practice/json?code="] stringByAppendingString:[self getSearchContent]];
}

- (void) selectionTriggered: (NSDictionary *)rowDataSet{
	
	specialityListViewController *specialityController = [[specialityListViewController alloc] initWithNibName:@"CustomListViewController" bundle:nil];
	specialityController.practice = rowDataSet;
	specialityController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:specialityController animated:YES];
	[specialityController release];	
}

@end
