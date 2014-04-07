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
#import "CustomIOS7AlertView.h"
#import "filterViewController.h"
#import "ReportWidget.h"

@protocol doctorDetailViewControllerDetailViweDelegate <NSObject>
-(void) doctorDetailViewControllerDismissed:(NSString *)stringForFirst;
@end

@interface doctorDetailViewController : UIViewController<SBJsonStreamParserAdapterDelegate, UITextViewDelegate,CustomIOS7AlertViewDelegate> {
    id <doctorDetailViewControllerDetailViweDelegate> delegate;
	SBJsonStreamParser *parser;
	SBJsonStreamParserAdapter *adapter;
	NSMutableDictionary *dataSource;
	searchDao *dao;
	
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
    IBOutlet UIScrollView *referBar;
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
    IBOutlet UITextView *referText;
	IBOutlet UIScrollView *reportOptView;
    IBOutlet UIScrollView *referOptView;
	IBOutlet UIToolbar *reportTextBtn;
    IBOutlet UIToolbar *referTextBtn;
	IBOutlet UILabel *avgRankInfo;
	IBOutlet UITextField *initialTextField;
    IBOutlet UITextField *patientEmailTextField;
    
	NSString *dId;
	NSString *phone;
	BOOL *isSearchFromOnline;
	BOOL *isReportChangeCalled;
    CustomIOS7AlertView *alert;
    int rank;
    int paRank;
	NSMutableArray *rankBtnList;
	UIImage *unRankedImage;
	UIImage *rankedImage;
    int resourceFlag;
    BOOL busy;
}
@property(weak,nonatomic) id<doctorDetailViewControllerDetailViweDelegate> delegate;
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

@property(nonatomic, retain) UIScrollView *reportBar;
@property(nonatomic, retain) UIScrollView *referBar;
@property(nonatomic, retain) UIScrollView *basicView;
@property(nonatomic, retain) UIButton *rankbutton;
@property(nonatomic, retain) UIView *qualityView;
@property(nonatomic, retain) UIView *costView;
@property(nonatomic, retain) UIView *pexpView;
@property(nonatomic, retain) UITextView *reportText;
@property(nonatomic, retain) UITextView *referText;
@property(nonatomic, retain) UIScrollView *reportOptView;
@property(nonatomic, retain) UIScrollView *referOptView;
@property(nonatomic, retain) UIToolbar *reportTextBtn;
@property(nonatomic, retain) UIToolbar *referTextBtn;
@property(nonatomic, retain) UILabel *avgRankInfo;
@property(nonatomic, retain) UITextField *initialTextField;
@property(nonatomic, retain) UITextField *patientEmailTextField;
@property(nonatomic, retain) CustomIOS7AlertView *alert;
@property(nonatomic, assign) int rank;
@property(nonatomic, assign) int paRank;
@property(nonatomic, assign) BOOL busy;
@property(nonatomic, retain) NSMutableArray *rankBtnList;
@property(nonatomic, retain) UIImage *unRankedImage;
@property(nonatomic, retain) UIImage *rankedImage;
@property (nonatomic) int resourceFlag;

- (IBAction) rankButtonClicked: (id)sender;
- (IBAction) backToDocList: (id)sender;
- (IBAction) callDoctor: (id)sender;
- (IBAction) searchAgainClicked: (id)sender;
- (IBAction) changeReportBtnClicked: (id)sender;
- (IBAction) closeReportPopup: (id)sender;
- (IBAction) closeReferPopup: (id)sender;
- (IBAction) saveAndCloseReportPopup: (id)sender;
- (IBAction) saveAndCloseReferPopup: (id)sender;
- (IBAction) hideReportPopupKeyboard: (id)sender;
- (IBAction) hideReferPopupKeyboard: (id)sender;
- (IBAction) reportOptionClicked: (id)sender;
- (IBAction) changeReferBtnClicked: (id)sender;
- (IBAction) referOptionClicked: (id)sender;

@end
