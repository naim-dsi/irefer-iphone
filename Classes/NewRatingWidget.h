//
//  NewAlertView.h
//  irefer2
//
//  Created by Nazmul Islam on 4/6/14.
//  Copyright (c) 2014 Dynamic Solution Innovators Limited. All rights reserved.
//

#import "CustomIOS7AlertView.h"

@interface NewRatingWidget : CustomIOS7AlertView {
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


- (id) initNewRatingWidget:(NSString *)title delegate:(UIViewController *)controller;

- (int)getRank;

- (void) isWorking:(BOOL)status;


@end
