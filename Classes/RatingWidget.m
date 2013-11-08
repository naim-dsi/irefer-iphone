//
//  RatingWidget.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RatingWidget.h"


@implementation RatingWidget

@synthesize rank, rankBtnList, unRankedImage, rankedImage, spinner, busy;

- (id) initRatingWidget:(NSString *)title delegate:(UIViewController *)controller{
	if (self = [super initWithTitle:title message:@"\n\n" delegate:controller cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil]) {
		self.rank =0;
		self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.spinner.center = CGPointMake(144, 82);
		[self.spinner hidesWhenStopped];
		
		self.unRankedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rank_silver" ofType:@"png"]];
		self.rankedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rank_orange" ofType:@"png"]];
		self.rankBtnList = [[NSMutableArray alloc] initWithCapacity:5];
		
		CGFloat x=45.0f;
		
		for (int i=0; i<5; i++) {
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.tag = i+1;
			[button addTarget:self action:@selector(rankBtnClicked:) forControlEvents:UIControlEventTouchDown];
			[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[button setTitle:[NSString stringWithFormat:@"%d",button.tag] forState:UIControlStateNormal];
			[button setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
			button.frame = CGRectMake(x , 50.0, 30.0, 30.0);
			[self addSubview:button];
			[self.rankBtnList addObject:button];
			x += 40.0f;						  
		}
		[self addSubview:self.spinner];		
	
	}
	return self;
}

- (void)rankBtnClicked:(id)sender{
	UIButton *button = (UIButton *)sender;
	NSLog(@"rank enter %d", button.tag);
	self.rank = button.tag;
	for (int i=0; i < 5; i++) {
		UIButton *rankBtn = [self.rankBtnList objectAtIndex:i];
		if( i == button.tag-1 ){
			//[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.rankedImage forState:UIControlStateNormal];
		}else {
			//[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
		}

	}
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	[self.spinner startAnimating];
	return;
}

- (int)getRank{
	return self.rank;
}

- (void) isWorking:(BOOL)status{
	self.busy = status;
}

- (void) dismissWidget{
	[super dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)dealloc {
	[spinner release];
	[rankedImage release];
	[unRankedImage release];
	[rankBtnList release];
	[super dealloc];
}

@end
