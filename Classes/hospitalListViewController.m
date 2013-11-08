//
//  hospitalListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "hospitalListViewController.h"


@implementation hospitalListViewController

-(NSString *) getSearchBarLabel{
	return @"Search Your Hospital";
}

-(NSString *) getInitUrl{
	return [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingString:@"hospital/json"];
}

-(NSString *) getSearchUrl{
	return [[[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingString:@"hospital/json&code="] stringByAppendingString:[self getSearchContent]];
}

- (void) selectionTriggered: (NSDictionary *)rowDataSet{
	
	hospitalistRegViewController *hosRegController = [[hospitalistRegViewController alloc] initWithNibName:@"hospitalistRegViewController" bundle:nil];
	hosRegController.hospital = rowDataSet;
	hosRegController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:hosRegController animated:YES];
	[hosRegController release];
}

@end
