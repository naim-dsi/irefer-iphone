//
//  specialityListViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomListViewController.h"
#import "newPcpRegViewController.h"

@interface specialityListViewController : CustomListViewController {

	NSDictionary *practice;
}

@property(nonatomic, retain) NSDictionary *practice;

@end
