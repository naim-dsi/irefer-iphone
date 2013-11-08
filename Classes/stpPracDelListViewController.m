//
//  stpPracDelListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "stpPracDelListViewController.h"


@implementation stpPracDelListViewController

- (NSString *) getSearchBarTitle{
	return @"Search Practice";
}

- (void) loadDataSource:(NSString *)name{
	self.dataSource = [dao getTableRowList:IreferConstraints.practiceTableName searchValue:name]; 
}

- (BOOL) deleteListRow:(int)rid {
	if( [dao deleteTableRow:IreferConstraints.practiceTableName columnName:@"prac_id" rowIndex:rid] ){
		
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
