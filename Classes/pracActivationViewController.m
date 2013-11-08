//
//  pracActivationViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "pracActivationViewController.h"


@implementation pracActivationViewController

@synthesize pname, actText, spinner, practice;

BOOL isActivated;

- (void)loadView{
	[super loadView];
	dao = [[setupDao alloc] init];
	self.pname.text = [practice objectForKey:@"name"];
	//code for dynamically resizable uilable
	UIFont* font = self.pname.font;			
	CGSize constraintSize = CGSizeMake(self.pname.frame.size.width, MAXFLOAT);
	CGSize labelSize = [self.pname.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	CGFloat newY = (self.pname.frame.origin.y - (labelSize.height - self.pname.frame.size.height));
	self.pname.frame = CGRectMake(self.pname.frame.origin.x, newY, self.pname.frame.size.width, labelSize.height);
}

- (IBAction) backToPracList:(id)sender{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) hideKeyBoard:(id)sender{
	[self.actText resignFirstResponder];
}

- (IBAction) activateBtnClicked:(id)sender{
	
	if ([self.actText.text isEqual:@""]) {
		[utils showAlert:@"Warning !!" message:@"Please provide activation code." delegate:self];
		return;
	}
	[self.spinner startAnimating];
	self.spinner.hidden = FALSE;
	[NSThread detachNewThreadSelector:@selector(practiceActivationReqThread) toTarget:self withObject:nil];
}

- (void) practiceActivationReqThread{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
	
	NSDictionary *user = [dao getCurrentUser];
	NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"paUser/activate?code=%@&user_id=%@&prac_id=%@",self.actText.text, [user objectForKey:@"id"], [practice objectForKey:@"id"]];
	NSLog(@"url :%@",serverUrl);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
	
	[self.spinner stopAnimating];
	self.spinner.hidden = TRUE;
	
	if ([responseString isEqual:@"activated"]) {
		isActivated = YES;
		[utils showAlert:@"Confirmation!!" message:@"Practice has been activated." delegate:self];
	}else if ([responseString isEqual:@"invalid request"]) {
		isActivated = NO;
		[utils showAlert:@"Warning !!" message:@"No activation request found for this practice. Please requst for activation first." delegate:self];
	}else if ([responseString isEqual:@"wrong code"]) {
		isActivated = NO;
		[utils showAlert:@"Warning !!" message:@"Invalid activation code. Please provide a valid activation code." delegate:self];
	}else {
		isActivated = NO;
		[utils showAlert:@"Warning !!" message:@"Couldn't activate the practice. Please try again later." delegate:self];
	}

	[pool release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (isActivated) {
		[self dismissModalViewControllerAnimated:YES];
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
	[dao release];
	[pname release];
	[actText release];
	[spinner release];
	[practice release];
    [super dealloc];
}


@end
