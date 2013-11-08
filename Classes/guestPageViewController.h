//
//  guestPageViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 12/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "aboutViewController.h"
#import "activationViewController.h"
#import "pcpListViewController.h"
#import "hospitalListViewController.h"
#import "registrationDao.h"

@interface guestPageViewController : UIViewController {
	
	IBOutlet UIButton *pcpBtn;
	IBOutlet UIButton *hosBtn;
	IBOutlet UIButton *regBtn;
	IBOutlet UIButton *abtBtn;
	
	IBOutlet UIView *pcpView;
	IBOutlet UIView *hosView;
	IBOutlet UIView *regView;
	IBOutlet UIView *abtView;
	
	IBOutlet UIImageView *pcpImg;
	IBOutlet UIImageView *hosImg;
	IBOutlet UIImageView *regImg;
	IBOutlet UIImageView *abtImg;
	
	IBOutlet UILabel *pcpLbl;
	IBOutlet UILabel *hosLbl;
	IBOutlet UILabel *regLbl;
	IBOutlet UILabel *abtLbl;
	
	IBOutlet UILabel *pname;
	IBOutlet UILabel *addrs;
	IBOutlet UILabel *actText;
	IBOutlet UIView *bgView;
	
	registrationDao *dao;
	
}

@property(nonatomic, retain) UIView *bgView;
@property(nonatomic, retain) UILabel *pname;
@property(nonatomic, retain) UILabel *addrs;
@property(nonatomic, retain) UILabel *actText;

@property(nonatomic, retain) UIButton *pcpBtn;
@property(nonatomic, retain) UIButton *hosBtn;
@property(nonatomic, retain) UIButton *regBtn;
@property(nonatomic, retain) UIButton *abtBtn;

@property(nonatomic, retain) UIView *pcpView;
@property(nonatomic, retain) UIView *hosView;
@property(nonatomic, retain) UIView *regView;
@property(nonatomic, retain) UIView *abtView;

@property(nonatomic, retain) UIImageView *pcpImg;
@property(nonatomic, retain) UIImageView *hosImg;
@property(nonatomic, retain) UIImageView *regImg;
@property(nonatomic, retain) UIImageView *abtImg;

@property(nonatomic, retain) UILabel *pcpLbl;
@property(nonatomic, retain) UILabel *hosLbl;
@property(nonatomic, retain) UILabel *regLbl;
@property(nonatomic, retain) UILabel *abtLbl;

- (IBAction) buttonClicked: (id)sender;

@end

