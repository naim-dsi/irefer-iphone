//
//  pcpListViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 12/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPCPCell.h"
#import "JSON.h"
#import "utils.h"
#import "pcpRegViewController.h"
#import "practiceListViewController.h"
#import "viewMoreCell.h"

@interface pcpListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SBJsonStreamParserAdapterDelegate> {
	
	SBJsonStreamParser *parser;
	SBJsonStreamParserAdapter *adapter;
	NSMutableArray *dataSource;
	int totalCount;
	int currentLimit;
	
	IBOutlet UITextField *searchBar;
	IBOutlet UITableView *listTableView;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIScrollView *spinnerBg;
}

@property(nonatomic, retain) UITextField *searchBar;
@property(nonatomic, retain) UITableView *listTableView;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) NSMutableArray *dataSource;
@property(nonatomic, retain) UIScrollView *spinnerBg;
@property(nonatomic, assign) int totalCount;
@property(nonatomic, assign) int currentLimit;

- (IBAction) hideKeyboard: (id) sender;
- (IBAction) goHome: (id) sender;
- (IBAction) searchContentChanged: (id) sender;
- (IBAction) createNewPCP: (id) sender;

@end
