    //
//  advancedDocListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "advancedDocListViewController.h"


@implementation advancedDocListViewController


- (void)viewDidLoad {
	dao = [[searchDao alloc] init];
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];
	self.isSearchFromOnline = NO;
	self.currentLimit = 50;
	
	[self.listTableView setHidden:YES];
	//[self.spinner startAnimating];
	//self.spinner.hidden = NO;
	//self.spinnerBg.hidden = NO;
	
	//[self performSelectorOnMainThread: @selector(advDoctorListThread) withObject: nil waitUntilDone: NO];	
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"empty"] forKey:@"doc_prev_search_content"];
	[NSThread detachNewThreadSelector:@selector(doctorListThread) toTarget:self withObject:nil];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:10], UITextAttributeFont,
                                [UIColor whiteColor], UITextAttributeTextColor,
                                nil];
    [sortOptions setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [sortOptions setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    [sortOptions setTintColor:[UIColor colorWithRed:0.61176f green:0.61176f  blue:0.61176f  alpha:1.0f]];
    
    sortOptions.segmentedControlStyle = UISegmentedControlStyleBar;
    

}

- (IBAction) searchContentChanged: (id) sender{
	
	NSLog(@"inside searchContentChanged......");
	self.currentLimit = 50;
	
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;
	self.inactiveBtn.hidden = NO;
	[NSThread detachNewThreadSelector:@selector(doctorListThread) toTarget:self withObject:nil];

}

- (void) doctorListThread{

	@synchronized(self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
		
		NSString *prevContent = [[NSUserDefaults standardUserDefaults] stringForKey:@"doc_prev_search_content"];
		NSLog(@"ddd %@",prevContent);
		NSString *currentContent = self.searchBar.text;
		
		if( ![prevContent isEqual:currentContent] || prevContent == NULL ){


	//	if(!self.spinner.hidden){
			[self.spinner startAnimating];
			self.spinner.hidden = NO;
			self.spinnerBg.hidden = NO;
            self.inactiveBtn.hidden = NO;
	//	}
		
		self.dataSource = [dao getAdvDoctorList:currentContent order:self.sortOptions.selectedSegmentIndex limit:self.currentLimit];
		NSDictionary *countData = [self.dataSource objectAtIndex:0];
		self.totalCount = [[countData objectForKey:@"count"] intValue];
		NSLog(@"total count %d",self.totalCount);
		[self.dataSource removeObjectAtIndex:0];
		if ([self.dataSource count] < self.totalCount) {
			[self.dataSource addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"Showing %d out of %d",self.currentLimit,self.totalCount],@"count",nil] autorelease] ];		
		}
		[self.dataSource addObject:[[[NSDictionary alloc] init] autorelease] ];//empty allocation in-order to able to select the last element
		[self.listTableView reloadData];
		
		[self.spinner stopAnimating];
		self.spinner.hidden = YES;
		self.spinnerBg.hidden = YES;
        self.inactiveBtn.hidden = YES;
		[self.listTableView setHidden:NO];
			NSLog(@"saved prev content %@",prevContent);
			NSLog(@"saved current content %@",currentContent);
			[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",currentContent] forKey:@"doc_prev_search_content"];

		}else {
			NSLog(@"prev content %@",prevContent);
			NSLog(@"current content %@",self.searchBar.text);
		}


		[pool release];

	}
		
	
}

@end
