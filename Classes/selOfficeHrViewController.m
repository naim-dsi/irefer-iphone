//
//  selOfficeHrViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 2/23/12.
//  Copyright 2012 Dynamic Solution Innovators Limited. All rights reserved.
//

#import "selOfficeHrViewController.h"


@implementation selOfficeHrViewController

@synthesize scrollView, selectedValues;

- (void) viewDidLoad{
	
	[self processSelectedValues];
	[self drawBlocks];
	
//	CGFloat scrollHeight = self.noteInfo.frame.origin.y+self.noteInfo.frame.size.height+30.0f;
	[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+20.0f)];

}

- (void) processSelectedValues {
	NSArray *values = [self.selectedValues componentsSeparatedByString:@","];
	NSArray *elements = [self.scrollView subviews];

	for(NSString *val in values){
		if ([val isEqual:@"st"]) {
			[[elements objectAtIndex:2] performSelector:@selector(setTag:) withObject:1];
		}else if([val isEqual:@"mn"]) {
			[[elements objectAtIndex:6] performSelector:@selector(setTag:) withObject:1];
		}
	}
}

- (IBAction) goBackToFilterViewController:(id) sender{
	if( [self.parentViewController isKindOfClass:[filterViewController class]] ){
		filterViewController *parentController = (filterViewController *)self.parentViewController;
		parentController.selectedOfficehours = [self getSelectedContents];
		[parentController setOfficeText:[self getSelectedText]];
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) checkedBtnClicked:(id) sender{
	UIButton *button = (UIButton *)sender;
	
	NSLog(@"button tag %d",button.tag);
	NSArray *elements = [self.scrollView subviews];
	
	UIImageView *imgView = (UIImageView *)[elements objectAtIndex:button.tag];	
	if (imgView.tag == 0) {
		imgView.tag = 1;
	}else {
		imgView.tag = 0;
	}
	
	[self drawBlocks];	
}

-(void) drawBlocks{
	NSArray *elements = [self.scrollView subviews];
	
	UIImageView *img = (UIImageView *)[elements objectAtIndex:2];
	if (img.tag == 0) {
		[img performSelector:@selector(setImage:) withObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_not_ticked" ofType:@"png"]]];		
	}else {
		[img performSelector:@selector(setImage:) withObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_ticked" ofType:@"png"]]];		
	}
	img = (UIImageView *)[elements objectAtIndex:6];
	if (img.tag == 0) {
		[img performSelector:@selector(setImage:) withObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_not_ticked" ofType:@"png"]]];		
	}else {
		[img performSelector:@selector(setImage:) withObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_ticked" ofType:@"png"]]];		
	}
}


- (NSString *) getSelectedContents{
	
	NSArray *elements = [self.scrollView subviews];
	NSArray *imgIndexs = [[NSArray alloc] initWithObjects:@"2",@"6",nil];
	NSString *contents = @"";
	
	for( NSString *index in imgIndexs ){
		if( [[elements objectAtIndex:[index intValue]] performSelector:@selector(tag)] == 1 ){
			if ([contents isEqual:@""]) {
				contents = [self getOfficeHourShortCode:[index intValue]];
			}else {
				contents = [contents stringByAppendingFormat:@",%@",[self getOfficeHourShortCode:[index intValue]]];
			}

		}
	}
	return contents;
}

- (NSString *) getSelectedText{
	NSArray *elements = [self.scrollView subviews];
	NSString *content = @"";
	
	if ([[elements objectAtIndex:2] performSelector:@selector(tag)] == 1) {
		if ([content isEqual:@""]) {
			content = @"Weekend Hours";
		}else {
			content = [content stringByAppendingFormat:@", Weekend Hours"];
		}
	}
	if ([[elements objectAtIndex:6] performSelector:@selector(tag)] == 1) {
		if ([content isEqual:@""]) {
			content = @"Evening Hours";
		}else {
			content = [content stringByAppendingFormat:@", Evening Hours"];
		}
	}
	
	if ([content isEqual:@""]) {
		content = @"All";
	}
	return content;
}

- (NSString *) getOfficeHourShortCode:(int)index{

	switch (index) {
		case 2:
			return @"st,sn";
			break;
		case 6:
			return @"mn,tu,wd,th,fd";
			break;
		default:
			return @"";
			break;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[selectedValues release];
	[scrollView release];
    [super dealloc];
}


@end
