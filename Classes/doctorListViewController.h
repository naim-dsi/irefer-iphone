//
//  doctorListViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "utils.h"
#import "searchDao.h"
#import "CustomDoctorCell.h"
#import "CustomIOS7AlertView.h"
#import "viewMoreCell.h"
#import "doctorDetailViewController.h"

@interface doctorListViewController : UIViewController<doctorDetailViewControllerDetailViweDelegate,UITableViewDelegate, UITableViewDataSource, SBJsonStreamParserAdapterDelegate, UIActionSheetDelegate,CustomIOS7AlertViewDelegate> {
	SBJsonStreamParser *parser;
	SBJsonStreamParserAdapter *adapter;
	NSMutableArray *dataSource;
	searchDao *dao;
	NSDictionary *userData;
	int totalCount;
	int currentLimit;

	IBOutlet UITextField *searchBar;
	IBOutlet UITableView *listTableView;
	IBOutlet UIScrollView *spinnerBg;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UILabel *countText;
	IBOutlet UIToolbar *sortToolBar;
	IBOutlet UISegmentedControl *sortOptions;
	IBOutlet UIBarButtonItem *sortButton;
	
	BOOL *isSearchFromOnline;
    BOOL *isResourceSearch;
    NSString *acoIds;
	NSString *insIds;
	NSString *hosIds;
	NSString *spIds;
	NSString *pracIds;
	NSString *countyIds;
	NSString *languages;
	NSString *inPatient;
	NSString *zipCode;
	NSString *officeHours;
	CustomIOS7AlertView *alert;
    int rank;
	NSMutableArray *rankBtnList;
	UIImage *unRankedImage;
	UIImage *rankedImage;
    int resourceFlag;
    BOOL busy;
}


@property(nonatomic, retain) UITextField *searchBar;
@property(nonatomic, retain) UITableView *listTableView;
@property(nonatomic, retain) UIScrollView *spinnerBg;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UILabel *countText;
@property(nonatomic, retain) UIToolbar *sortToolBar;
@property(nonatomic, retain) UISegmentedControl *sortOptions;
@property(nonatomic, retain) UIBarButtonItem *sortButton;
@property(nonatomic, assign) int totalCount;
@property(nonatomic, assign) int currentLimit;

@property(nonatomic, retain) NSMutableArray *dataSource;
@property(nonatomic, retain) NSDictionary *userData;

@property(nonatomic, retain) NSString *acoIds;
@property(nonatomic, retain) NSString *insIds;
@property(nonatomic, retain) NSString *hosIds;
@property(nonatomic, retain) NSString *spIds;
@property(nonatomic, retain) NSString *pracIds;
@property(nonatomic, retain) NSString *countyIds;
@property(nonatomic, retain) NSString *languages;
@property(nonatomic, retain) NSString *officeHours;
@property(nonatomic, retain) NSString *inPatient;
@property(nonatomic, retain) NSString *zipCode;
@property(nonatomic, assign) BOOL *isSearchFromOnline;
@property(nonatomic, assign) BOOL *isResourceSearch;
@property(nonatomic, retain) CustomIOS7AlertView *alert;
@property(nonatomic, assign) int rank;
@property(nonatomic, assign) int paRank;
@property(nonatomic, assign) BOOL busy;
@property(nonatomic, retain) NSMutableArray *rankBtnList;
@property(nonatomic, retain) UIImage *unRankedImage;
@property(nonatomic, retain) UIImage *rankedImage;
@property (nonatomic) int resourceFlag;

- (IBAction) rankUpdate: (id)sender;
- (IBAction) hideKeyboard: (id) sender;
- (IBAction) searchContentChanged: (id) sender;
- (IBAction) backToFilterPage: (id) sender;
- (IBAction) callDoctor:(id) sender;
- (IBAction) sortMethodChanged:(id) sender;
- (IBAction) sortButtonClicked:(id) sender;

@end
