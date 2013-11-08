    //
//  stpHosDelListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "stpHosDelListViewController.h"


@implementation stpHosDelListViewController

- (NSString *) getSearchBarTitle{
	return @"Search Hospital";
}

- (void) loadDataSource:(NSString *)name{
	self.dataSource = [dao getTableRowList:IreferConstraints.hospitalTableName searchValue:name]; ; 
}

- (BOOL) deleteListRow:(int)rid {
	if( [dao deleteTableRow:IreferConstraints.hospitalTableName columnName:@"hos_id" rowIndex:rid] ){
		
		for( NSDictionary *dict in self.dataSource ){
			if( [[dict objectForKey:@"id"] intValue] == rid ){
				[self.dataSource removeObject:dict];
				return YES;
			}
		}
	}
	return NO;
}


@end
