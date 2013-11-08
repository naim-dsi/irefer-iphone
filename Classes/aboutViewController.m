//
//  aboutViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 12/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "aboutViewController.h"


@implementation aboutViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
//	UIImage *blueImage = [UIImage imageNamed:@"blueButton.png"];
//    UIImage *blueButtonImage = [blueImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
//    [backBtn setBackgroundImage:blueButtonImage forState:UIControlStateNormal];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

- (IBAction) goBack: (id)sender{
	[self dismissModalViewControllerAnimated:YES];
}


- (void)dealloc {
    [super dealloc];
}


@end
