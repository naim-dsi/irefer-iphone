//
//  CustomListViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
#import "utils.h"
#import "CustomListProtocol.h"
#import "viewMoreCell.h"

@interface CustomListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SBJsonStreamParserAdapterDelegate, CustomListProtocol> {

	
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
@property(nonatomic, retain) UIScrollView *spinnerBg;
@property(nonatomic, retain) NSMutableArray *dataSource;
@property(nonatomic, assign) int totalCount;
@property(nonatomic, assign) int currentLimit;

- (IBAction) goHome: (id) sender;
- (IBAction) hideKeyboard: (id) sender;
- (IBAction) searchContentChanged: (id) sender;

- (NSString *) getSearchContent;

@end
