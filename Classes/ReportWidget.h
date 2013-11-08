//
//  ReportWidget.h
//  irefer2
//
//  Created by Mushraful Hoque on 2/9/12.
//  Copyright 2012 Dynamic Solution Innovators Limited. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReportWidget : UIAlertView {
	UIActivityIndicatorView *spinner;
	UITextView *commentBox;
	BOOL busy;
}
@property(nonatomic, assign) BOOL busy;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UITextView *commentBox;

- (id) initReportWidget:(UIViewController *)controller;
- (NSString *) getMessage;
- (void) dismissWidget;
- (void) isWorking:(BOOL)status;

@end
