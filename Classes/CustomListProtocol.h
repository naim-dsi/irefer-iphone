//
//  CustomListProtocol.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CustomListProtocol

@required

-(NSString *) getSearchBarLabel;
-(NSString *) getInitUrl;
-(NSString *) getSearchUrl;
-(void) selectionTriggered: (NSDictionary *)rowDataSet;

@optional

-(void) additionalDealloc;

@end
