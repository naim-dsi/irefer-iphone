//
//  irefer2AppDelegate.h
//  irefer2
//
//  Created by Mushraful Hoque on 12/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseDao.h"
#import "guestPageViewController.h"
#import "filterViewController.h"
#import "setupViewController.h"
#import "IreferConstraints.h"
#import "utils.h"

@interface irefer2AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    guestPageViewController *viewController;
	filterViewController *filterController;
	setupViewController *setupController;
	BaseDao *dao;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet guestPageViewController *viewController;
@property (nonatomic, retain) IBOutlet filterViewController *filterController;
@property (nonatomic, retain) IBOutlet setupViewController *setupController;

@end

