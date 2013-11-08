//
//  RatingWidget.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RatingWidget : UIAlertView {
	int rank;
	NSMutableArray *rankBtnList;
	UIImage *unRankedImage;
	UIImage *rankedImage;
	UIActivityIndicatorView *spinner;
	BOOL busy;
}

@property(nonatomic, assign) int rank;
@property(nonatomic, assign) BOOL busy;
@property(nonatomic, retain) NSMutableArray *rankBtnList;
@property(nonatomic, retain) UIImage *unRankedImage;
@property(nonatomic, retain) UIImage *rankedImage;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;


- (id) initRatingWidget:(NSString *)title delegate:(UIViewController *)controller;

- (int)getRank;

- (void) isWorking:(BOOL)status;

- (void) dismissWidget;

@end
