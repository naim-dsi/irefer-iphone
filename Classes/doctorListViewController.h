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
#import "RatingWidget.h"
#import "viewMoreCell.h"

@interface doctorListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SBJsonStreamParserAdapterDelegate, UIActionSheetDelegate> {
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
	NSString *insIds;
	NSString *hosIds;
	NSString *spIds;
	NSString *pracIds;
	NSString *countyIds;
	NSString *languages;
	NSString *inPatient;
	NSString *zipCode;
	NSString *officeHours;
	RatingWidget *alert;

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
@property(nonatomic, retain) RatingWidget *alert;


- (IBAction) rankUpdate: (id)sender;
- (IBAction) hideKeyboard: (id) sender;
- (IBAction) searchContentChanged: (id) sender;
- (IBAction) backToFilterPage: (id) sender;
- (IBAction) callDoctor:(id) sender;
- (IBAction) sortMethodChanged:(id) sender;
- (IBAction) sortButtonClicked:(id) sender;

@end
