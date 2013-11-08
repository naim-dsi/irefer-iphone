//
//  newPcpRegViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utils.h"
#import "registrationDao.h"
#import "guestPageViewController.h"

@interface newPcpRegViewController : UIViewController<UIActionSheetDelegate> {
	
	IBOutlet UILabel *spName;
	IBOutlet UILabel *address;
	IBOutlet UITextField *lastName;
	IBOutlet UITextField *firstName;
	IBOutlet UITextField *email;
	IBOutlet UIActivityIndicatorView *spinner;	
	IBOutlet UIScrollView *spinnerBg;
	
	registrationDao *dao;	
	NSDictionary *practice;
	NSDictionary *speciality;
}

@property(nonatomic, retain) UILabel *spName;
@property(nonatomic, retain) UILabel *address;
@property(nonatomic, retain) UITextField *lastName;
@property(nonatomic, retain) UITextField *firstName;
@property(nonatomic, retain) UITextField *email;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIScrollView *spinnerBg;

@property(nonatomic, retain) NSDictionary *practice;
@property(nonatomic, retain) NSDictionary *speciality;

- (IBAction) backToSpecialistList: (id) sender;
- (IBAction) registerNewPcp: (id) sender;
- (IBAction) hideKeyboard: (id) sender;


@end
