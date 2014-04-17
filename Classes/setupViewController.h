//
//  setupViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "setupDao.h"
#import "JSON.h"
#import "filterViewController.h"
#import "SelectBoxProtocol.h"
#import "DeleteListProtocol.h"
#import "IreferConstraints.h"
#import "stpPracListViewController.h"
#import "stpPracDelListViewController.h"
#import "stpHosListViewController.h"
#import "stpHosDelListViewController.h"
#import "stpInsListViewController.h"
#import "stpInsDelListViewController.h"
#import "stpSpListViewController.h"
#import "stpSpDelListViewController.h"
#import "stpCntyListViewController.h"
#import "stpCntyDelListViewController.h"
#import "aboutViewController.h"
#import "advancedDocListViewController.h"
#import "SSZipArchive.h"
#import "BaseDao.h"

@interface setupViewController : UIViewController<SelectBoxProtocol,DeleteListProtocol,UIActionSheetDelegate> {

	SBJsonParser *parser;
	setupDao *dao;
	NSMutableDictionary *userData;
	NSTimer *autoTimer;
    NSString *dateString;
	IBOutlet UILabel *pname;
	IBOutlet UILabel *addr;
	IBOutlet UIButton *pracBtn;
	IBOutlet UIButton *hosBtn;
	IBOutlet UIButton *insBtn;
	IBOutlet UIButton *spBtn;
	IBOutlet UIButton *cntyBtn;
	IBOutlet UILabel *docCountText;
	IBOutlet UIButton *pracAddBtn;
	IBOutlet UIButton *hosAddBtn;
	IBOutlet UIActivityIndicatorView *spinner;	
	IBOutlet UIScrollView *spinnerBg;
	IBOutlet UILabel *spinnerText;
	IBOutlet UIButton *inactiveBtn;
	IBOutlet UIScrollView *scrollView;
    BaseDao *baseDao;
}
@property(nonatomic, retain) NSString *dateString;
@property(nonatomic, retain) UILabel *pname;
@property(nonatomic, retain) UILabel *addr;
@property(nonatomic, retain) UIButton *pracBtn;
@property(nonatomic, retain) UIButton *hosBtn;
@property(nonatomic, retain) UIButton *insBtn;
@property(nonatomic, retain) UIButton *spBtn;
@property(nonatomic, retain) UIButton *cntyBtn;
@property(nonatomic, retain) UILabel *docCountText;
@property(nonatomic, retain) UIButton *pracAddBtn;
@property(nonatomic, retain) UIButton *hosAddBtn;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIScrollView *spinnerBg;
@property(nonatomic, retain) UILabel *spinnerText;
@property(nonatomic, retain) UIButton *inactiveBtn;
@property(nonatomic, retain) NSTimer *autoTimer;
@property(nonatomic, retain) NSDictionary *userData;
@property(nonatomic, retain) UIScrollView *scrollView;



- (IBAction) aboutBtnClicked:(id)sender;
- (IBAction) addBtnClicked:(id)sender;
- (IBAction) searchBtnClicked:(id)sender;
- (IBAction) listBtnClicked:(id)sender;
- (IBAction) resetAllBtnClicked:(id)sender;
- (IBAction) syncDoctorBtnClicked:(id)sender;
- (IBAction) advancedSearchBtnClicked:(id)sender;
- (IBAction) switchSettingModeClicked:(id)sender;

@end
