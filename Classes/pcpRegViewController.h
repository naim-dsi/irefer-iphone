//
//  pcpRegViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utils.h"
#import "registrationDao.h"
#import "guestPageViewController.h"

@interface pcpRegViewController : UIViewController {

	NSDictionary *model;	
	registrationDao *dao;
	
	IBOutlet UILabel *practiceLabel;
	IBOutlet UILabel *addressLabel;
	IBOutlet UITextField *lastNameText;
	IBOutlet UITextField *firstNameText;
	IBOutlet UITextField *email;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIScrollView *spinnerBg;
}

@property(nonatomic, retain) NSDictionary *model;
@property(nonatomic, retain) UILabel *practiceLabel;
@property(nonatomic, retain) UILabel *addressLabel;
@property(nonatomic, retain) UITextField *lastNameText;
@property(nonatomic, retain) UITextField *firstNameText;
@property(nonatomic, retain) UITextField *email;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIScrollView *spinnerBg;


- (IBAction) pcpRegBackgroundClicked: (id) sender;
- (IBAction) pcpRegBackBtnClicked: (id) sender;
- (IBAction) registerPCP: (id) sender;

@end
