//
//  selOfficeHrViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 2/23/12.
//  Copyright 2012 Dynamic Solution Innovators Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "filterViewController.h"

@interface selOfficeHrViewController : UIViewController {

	IBOutlet UIScrollView *scrollView;
	
	NSString *selectedValues;

}

@property(nonatomic, retain) UIScrollView *scrollView;
@property(nonatomic, retain) NSString *selectedValues;

- (IBAction) goBackToFilterViewController:(id) sender;
- (IBAction) checkedBtnClicked:(id) sender;

@end
