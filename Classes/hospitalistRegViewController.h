//
//  hospitalistRegViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utils.h"
#import "registrationDao.h"
#import "guestPageViewController.h"

@interface hospitalistRegViewController : UIViewController {

	IBOutlet UILabel *hosName;
	IBOutlet UITextField *lastName;
	IBOutlet UITextField *firstName;
	IBOutlet UITextField *email;
	IBOutlet UIActivityIndicatorView *spinner;	
	IBOutlet UIScrollView *spinnerBg;

	registrationDao *dao;		
	NSDictionary *hospital;
	
}

@property(nonatomic, retain) UILabel *hosName;
@property(nonatomic, retain) UITextField *lastName;
@property(nonatomic, retain) UITextField *firstName;
@property(nonatomic, retain) UITextField *email;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIScrollView *spinnerBg;
@property(nonatomic, retain) NSDictionary *hospital;

- (IBAction) backToHospitalList: (id) sender;
- (IBAction) registerHospitalist: (id) sender;
- (IBAction) hideKeyboard: (id) sender;


@end
