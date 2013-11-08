//
//  DeleteListViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "utils.h"
#import "customDeleteCell.h"
#import "setupDao.h"
#import "DeleteListProtocol.h"
#import "pracActivationViewController.h"

@interface DeleteListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	
	NSMutableArray *dataSource;
	NSString *defaultElemId;
	IBOutlet UITextField *searchBar;
	IBOutlet UITableView *listTableView;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIScrollView *spinnerBg;
	IBOutlet UILabel *countText;
	
	BOOL showDeleteBtn;
	BOOL showActivationModal;
	setupDao *dao;
	UIViewController<DeleteListProtocol> *delegate;
}

@property(nonatomic, retain) UITextField *searchBar;
@property(nonatomic, retain) UITableView *listTableView;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIScrollView *spinnerBg;
@property(nonatomic, retain) UILabel *countText;
@property(nonatomic, retain) NSMutableArray *dataSource;
@property(nonatomic, retain) NSString *defaultElemId;
@property(nonatomic, retain) UIViewController<DeleteListProtocol> *delegate;
@property(nonatomic, assign) BOOL showDeleteBtn;
@property(nonatomic, assign) BOOL showActivationModal;


- (IBAction) disMissDeleteListView:(id)sender;
- (IBAction) searchContentChanged: (id) sender;
- (IBAction) hideKeyboard: (id) sender;
- (IBAction) delBtnClicked:(id)sender;

- (void) loadDataSource:(NSString *)name;

@end
