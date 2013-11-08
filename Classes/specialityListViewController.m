//
//  specialityListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "specialityListViewController.h"


@implementation specialityListViewController

@synthesize practice;


-(NSString *) getSearchBarLabel{
	return @"Search Your Speciality";
}

-(NSString *) getInitUrl{
	return [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingString:@"speciality/jsonLite"];
}

-(NSString *) getSearchUrl{
	return [[[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingString:@"speciality/jsonLite&code="] stringByAppendingString:[self getSearchContent]];
}

-(void) selectionTriggered: (NSDictionary *)rowDataSet{
	
	newPcpRegViewController *nPcpRegController = [[newPcpRegViewController alloc] initWithNibName:@"newPcpRegViewController" bundle:nil];
	nPcpRegController.practice = self.practice;
	nPcpRegController.speciality = rowDataSet;
	nPcpRegController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:nPcpRegController animated:YES];
	[nPcpRegController release];	
}

-(void) additionalDealloc{
	NSLog(@"Inside additional dealloc");
	[practice release];
}

@end
