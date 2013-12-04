//
//  doctorDetailViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "utils.h"
#import "searchDao.h"
#import "RatingWidget.h"
#import "filterViewController.h"
#import "ReportWidget.h"

@interface doctorDetailViewController : UIViewController<SBJsonStreamParserAdapterDelegate, UITextViewDelegate> {
	SBJsonStreamParser *parser;
	SBJsonStreamParserAdapter *adapter;
	NSMutableDictionary *dataSource;
	searchDao *dao;
	RatingWidget *rankBar;
	UIScrollView *basicView;
	
	IBOutlet UILabel *name;
	IBOutlet UILabel *speciality;
	IBOutlet UILabel *degree;
	IBOutlet UILabel *gender;
	IBOutlet UILabel *rankText;
	IBOutlet UIView *qualityView;
	IBOutlet UIView *costView;
	IBOutlet UIView *pexpView;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIScrollView *spinnerBg;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIScrollView *reportBar;
	IBOutlet UIView *spView;
	IBOutlet UIView *pracView;
	IBOutlet UIView *hosView;
	IBOutlet UIView *noteView;
	IBOutlet UILabel *pracInfo;
	IBOutlet UILabel *hosInfo;
	IBOutlet UILabel *noteInfo;
	IBOutlet UIView *urankView;
	IBOutlet UIView *uprankView;
	IBOutlet UIButton *rankbutton;
	IBOutlet UITextView *reportText;
	IBOutlet UIScrollView *reportOptView;
	IBOutlet UIToolbar *reportTextBtn;
	IBOutlet UILabel *avgRankInfo;
	
	NSString *dId;
	NSString *phone;
	BOOL *isSearchFromOnline;
	BOOL *isReportChangeCalled;
}

@property(nonatomic, retain) UILabel *name;
@property(nonatomic, retain) UILabel *speciality;
@property(nonatomic, retain) UILabel *degree;
@property(nonatomic, retain) UILabel *rankText;
@property(nonatomic, retain) UILabel *gender;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIScrollView *spinnerBg;
@property(nonatomic, retain) NSString *phone;
@property(nonatomic, retain) NSString *dId;
@property(nonatomic, retain) NSMutableDictionary *dataSource;
@property(nonatomic, assign) BOOL *isSearchFromOnline;
@property(nonatomic, assign) BOOL *isReportChangeCalled;
@property(nonatomic, retain) UIScrollView *scrollView;
@property(nonatomic, retain) UIView *spView;
@property(nonatomic, retain) UIView *pracView;
@property(nonatomic, retain) UIView *hosView;
@property(nonatomic, retain) UIView *noteView;
@property(nonatomic, retain) UILabel *pracInfo;
@property(nonatomic, retain) UILabel *hosInfo;
@property(nonatomic, retain) UILabel *noteInfo;
@property(nonatomic, retain) UIView *urankView;
@property(nonatomic, retain) UIView *uprankView;
@property(nonatomic, retain) RatingWidget *rankBar;
@property(nonatomic, retain) UIScrollView *reportBar;
@property(nonatomic, retain) UIScrollView *basicView;
@property(nonatomic, retain) UIButton *rankbutton;
@property(nonatomic, retain) UIView *qualityView;
@property(nonatomic, retain) UIView *costView;
@property(nonatomic, retain) UIView *pexpView;
@property(nonatomic, retain) UITextView *reportText;
@property(nonatomic, retain) UIScrollView *reportOptView;
@property(nonatomic, retain) UIToolbar *reportTextBtn;
@property(nonatomic, retain) UILabel *avgRankInfo;




- (IBAction) rankButtonClicked: (id)sender;
- (IBAction) backToDocList: (id)sender;
- (IBAction) callDoctor: (id)sender;
- (IBAction) searchAgainClicked: (id)sender;
- (IBAction) changeReportBtnClicked: (id)sender;
- (IBAction) closeReportPopup: (id)sender;
- (IBAction) saveAndCloseReportPopup: (id)sender;
- (IBAction) hideReportPopupKeyboard: (id)sender;
- (IBAction) showReportPopupKeyboard: (id)sender;
- (IBAction) reportOptionClicked: (id)sender;


@end
