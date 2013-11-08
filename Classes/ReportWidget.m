    //
//  ReportWidget.m
//  irefer2
//
//  Created by Mushraful Hoque on 2/9/12.
//  Copyright 2012 Dynamic Solution Innovators Limited. All rights reserved.
//

#import "ReportWidget.h"


@implementation ReportWidget

@synthesize spinner, commentBox, busy;

- (id) initReportWidget:(UIViewController *)controller{
	if (self = [super initWithTitle:@"Report Error in data" message:@"\n\n\n\n" delegate:controller cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil]) {		
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		if (version < 4.0){
			self.transform = CGAffineTransformTranslate(self.transform, 0.0, 60.0);
		}
		self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.spinner.center = CGPointMake(144, 82);
		[self.spinner hidesWhenStopped];
		
		self.commentBox = [[UITextView alloc] initWithFrame:CGRectMake(20, 60, 245, 50)];
		[self.commentBox setBackgroundColor:[UIColor whiteColor]];
		self.commentBox.font = [UIFont systemFontOfSize:14.0f];
		[self.commentBox setKeyboardAppearance:UIKeyboardAppearanceAlert];
		
		[self addSubview:self.commentBox];
		
		[self addSubview:self.spinner];		
		
	}
	return self;
}

- (void) isWorking:(BOOL)status{
	self.busy = status;
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	[self.spinner startAnimating];
	[self.commentBox resignFirstResponder];
	return;
}

- (void) dismissWidget{
	[self.commentBox resignFirstResponder];
	[super dismissWithClickedButtonIndex:0 animated:YES];
}

- (NSString *) getMessage{
	return self.commentBox.text;
}


- (void)dealloc {
	[spinner release];
	[commentBox release];
	[super dealloc];
}

@end
