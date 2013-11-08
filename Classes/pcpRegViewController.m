//
//  pcpRegViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "pcpRegViewController.h"


@implementation pcpRegViewController

@synthesize model, practiceLabel, addressLabel, lastNameText, firstNameText, email, spinner, spinnerBg;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void) loadView {
	[super loadView];
	dao = [[registrationDao alloc] init];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;

	self.practiceLabel.text = [model valueForKey:@"prac_name"];
	UIFont* font = self.practiceLabel.font;			
	CGSize constraintSize = CGSizeMake(self.practiceLabel.frame.size.width, MAXFLOAT);
	CGSize labelSize = [self.practiceLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	CGFloat newY = (self.practiceLabel.frame.origin.y - (labelSize.height - self.practiceLabel.frame.size.height));
	self.practiceLabel.frame = CGRectMake(self.practiceLabel.frame.origin.x, newY, self.practiceLabel.frame.size.width, labelSize.height);
	
	self.addressLabel.text = [model valueForKey:@"add_line_1"];
	NSString *name = [model valueForKey:@"name"];
	NSArray *chunks = [name componentsSeparatedByString: @" "];
	if ([chunks count] > 0) {
		self.firstNameText.text = [chunks objectAtIndex:0];
		self.lastNameText.text = [chunks objectAtIndex:[chunks count]-1];
	}
	
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];
}
/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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

- (IBAction) pcpRegBackgroundClicked: (id) sender{
	[lastNameText resignFirstResponder];
	[firstNameText resignFirstResponder];
	[email resignFirstResponder];
}

- (IBAction) pcpRegBackBtnClicked: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) registerPCP: (id) sender{
	if([self.lastNameText.text length] == 0){
		[utils showAlert:@"Warning !!" message:@"Please provide your last name." delegate:self];
		return;
	}
	if([self.firstNameText.text length] == 0){
		[utils showAlert:@"Warning !!" message:@"Please provide your first name." delegate:self];
		return;
	}
	if([self.email.text length] == 0){
		[utils showAlert:@"Warning !!" message:@"Please provide your email address." delegate:self];
		return;
	}		
	if (![utils performSelector:@selector(validateEmail:) withObject:[email text]]) {
		[utils showAlert:@"Warning !!" message:@"Please provide a valid email address." delegate:self];
		return;
	}
	
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;
	
	NSString *url = [[[[[[[[[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] 
					   stringByAppendingString:@"user/register?last_name="] stringByAppendingString:self.lastNameText.text] stringByAppendingString:@"&first_name="] stringByAppendingString:self.firstNameText.text]
					  stringByAppendingString:@"&email="] stringByAppendingString:self.email.text] stringByAppendingString:@"&prac_id="] stringByAppendingString:[self.model objectForKey:@"prac_id"]];
	
	NSLog(@"called url : %@",url);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];//asynchronous call
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
	
}

// methods for NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Connection didReceiveResponse: %@ - %@", response, [response MIMEType]);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"Connection didReceiveAuthenticationChallenge: %@", challenge);
	[utils showAlert:@"Warning !!" message:@"Sorry couldn't connect to server. Please try again later." delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Connection didReceiveData of length: %u", data.length);
	
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;

	NSDictionary *user=[[NSDictionary alloc] initWithObjectsAndKeys: self.lastNameText.text, @"last_name", self.firstNameText.text, @"first_name", self.email.text, @"email", nil];
	NSDictionary *practice=[[NSDictionary alloc] initWithObjectsAndKeys:[model objectForKey:@"prac_id"], @"id", [model objectForKey:@"prac_name"], @"name", [model objectForKey:@"add_line_1"], @"add_line1", nil]; 
	NSMutableArray *dataSet = [[NSMutableArray alloc] initWithObjects:user, practice];
	
	if (![dao updatePCPUserRegistration:dataSet]) {
		[utils showAlert:@"Warning !!" message:@"Sorry couldn't save registration data. Please try again later." delegate:self];
	}
	[user release];
	[practice release];
	[dataSet release];
	//[self dismissModalViewControllerAnimated:YES];
		
	//do successmessage and forwarding
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Your registration request has been submitted. Please wait for activation notification email." delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Ok" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription]);
	[utils showAlert:@"Warning !!" message:@"Sorry couldn't connect to server. Please try again later." delegate:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
    [connection release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
	guestPageViewController *homeController = [[guestPageViewController alloc] initWithNibName:@"guestPageViewController" bundle:nil];
	homeController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:homeController animated:YES];
	[homeController release];
}

- (void)dealloc {
	[spinnerBg release];
	[spinner release];
	[dao release];
	[model release];
	[practiceLabel release];
	[addressLabel release];
	[lastNameText release];
	[firstNameText release];
	[email release];
    [super dealloc];
}


@end
