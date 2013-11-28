    //
//  stpInsDelListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "stpInsDelListViewController.h"


@implementation stpInsDelListViewController

- (NSString *) getSearchBarTitle{
	return @"Search Insurance";
}

- (void) loadDataSource:(NSString *)name{
	self.dataSource = [dao getTableRowList:IreferConstraints.insuranceTableName searchValue:name];
    int a = 1;
}

- (BOOL) deleteListRow:(int)rid {
	if( [dao deleteTableRow:IreferConstraints.insuranceTableName columnName:@"ins_id" rowIndex:rid] ){
		
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
