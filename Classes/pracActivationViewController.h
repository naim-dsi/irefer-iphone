//
//  pracActivationViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "setupDao.h"
#import "utils.h"


@interface pracActivationViewController : UIViewController {

	setupDao *dao;
	IBOutlet UILabel *pname;
	IBOutlet UITextField *actText;
	IBOutlet UIActivityIndicatorView *spinner;
	
	NSDictionary *practice;
}

@property(nonatomic, retain) UILabel *pname;
@property(nonatomic, retain) UITextField *actText;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) NSDictionary *practice;

- (IBAction) backToPracList:(id)sender;
- (IBAction) hideKeyBoard:(id)sender;
- (IBAction) activateBtnClicked:(id)sender;


@end
