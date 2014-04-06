//
//  NewAlertView.m
//  irefer2
//
//  Created by Nazmul Islam on 4/6/14.
//  Copyright (c) 2014 Dynamic Solution Innovators Limited. All rights reserved.
//

#import "NewRatingWidget.h"

@implementation NewRatingWidget

@synthesize rank, rankBtnList, unRankedImage, rankedImage, spinner, busy;

- (id)initNewRatingWidget:(NSString *)title delegate:(UIViewController *)controller
{
    self = [super initWithFrame:CGRectZero];
    //self = [super init];
   
    if (self) {
        
        [self setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Update", nil]];
        [self setUseMotionEffects:true];
        [self setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            //NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
            [self.spinner startAnimating];
            [alertView close];
        }];
        
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
        
        
        
        int yPosition = 10;
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, yPosition, view.frame.size.width, 0)];
        [label setText: title];
        [label setBackgroundColor: [UIColor clearColor]];
        [label setNumberOfLines: 0];
        [label sizeToFit];
        [label setCenter: CGPointMake(view.center.x, 20)];
        [view addSubview:label];
        
        
        
        
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
			[view addSubview:button];
			[self.rankBtnList addObject:button];
			x += 40.0f;
		}
		[view addSubview:self.spinner];
        
        
        [self setContainerView:view];
        
        // Initialization code
    }
    return self;
}

- (void)rankBtnClicked:(id)sender{
	UIButton *button = (UIButton *)sender;
	NSLog(@"rank enter %d", button.tag);
	self.rank = button.tag;
	for (int i=0; i < 5; i++) {
		UIButton *rankBtn = [self.rankBtnList objectAtIndex:i];
		if( i < button.tag ){
			//[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.rankedImage forState:UIControlStateNormal];
		}else {
			//[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
		}
        
	}
}

- (int)getRank{
	return self.rank;
}

- (void) isWorking:(BOOL)status{
	self.busy = status;
}


- (void)dealloc {
	[spinner release];
	[rankedImage release];
	[unRankedImage release];
	[rankBtnList release];
	[super dealloc];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
