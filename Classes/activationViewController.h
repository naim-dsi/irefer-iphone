//
//  activationViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 12/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utils.h"
#import "JSON.h"
#import "registrationDao.h"
#import "setupViewController.h"


@interface activationViewController : UIViewController<SBJsonStreamParserAdapterDelegate> {

	SBJsonStreamParser *parser;
	SBJsonStreamParserAdapter *adapter;
	NSMutableArray *dataSource;
	registrationDao *dao;
	
	IBOutlet UITextField *email;
	IBOutlet UITextField *code;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIScrollView *spinnerBg;

}

@property(nonatomic, retain) UITextField *email;
@property(nonatomic, retain) UITextField *code;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIScrollView *spinnerBg;
@property(nonatomic, retain) NSMutableArray *dataSource;
@property(nonatomic, retain) registrationDao *dao;

- (IBAction) backButtonClicked: (id) sender;
- (IBAction) emailDidEntered: (id) sender;
- (IBAction) codeDidEntered: (id) sender;
- (IBAction) backgroundClicked: (id) sender;
- (IBAction) activateBtnClicked: (id) sender;


@end
