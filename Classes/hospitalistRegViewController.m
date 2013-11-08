//
//  hospitalistRegViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "hospitalistRegViewController.h"


@implementation hospitalistRegViewController

@synthesize hosName, lastName, firstName, email, hospital, spinner, spinnerBg;

- (void) loadView {
	[super loadView];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	dao = [[registrationDao alloc] init];
	
	NSString *header = [NSString stringWithString:[hospital valueForKey:@"name"]];
	self.hosName.text = header;
	
	//code for dynamically resizable uilable
	UIFont* font = self.hosName.font;			
	CGSize constraintSize = CGSizeMake(self.hosName.frame.size.width, MAXFLOAT);
	CGSize labelSize = [self.hosName.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	CGFloat newY = (self.hosName.frame.origin.y - (labelSize.height - self.hosName.frame.size.height));
	self.hosName.frame = CGRectMake(self.hosName.frame.origin.x, newY, self.hosName.frame.size.width, labelSize.height);
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];

}


- (IBAction) backToHospitalList: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) hideKeyboard: (id) sender{
	[self.lastName resignFirstResponder];
	[self.firstName resignFirstResponder];
	[self.email resignFirstResponder];
}

- (IBAction) registerHospitalist: (id) sender{
	
	if([self.lastName.text length] == 0){
		[utils showAlert:@"Warning !!" message:@"Please provide your last name." delegate:self];
		return;
	}
	if([self.firstName.text length] == 0){
		[utils showAlert:@"Warning !!" message:@"Please provide your first name." delegate:self];
		return;
	}
	if([self.email.text length] == 0){
		[utils showAlert:@"Warning !!" message:@"Please provide your email address." delegate:self];
		return;
	}	
	if (![utils performSelector:@selector(validateEmail:) withObject:[self.email text]]) {
		[utils showAlert:@"Warning !!" message:@"Please provide a valid email address." delegate:self];
		return;
	}
	
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;
	
	NSString *url = [[[[[[[[[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] 
							stringByAppendingString:@"user/register&last_name="] stringByAppendingString:self.lastName.text] stringByAppendingString:@"&first_name="] stringByAppendingString:self.firstName.text]
						stringByAppendingString:@"&email="] stringByAppendingString:self.email.text] stringByAppendingString:@"&hosp_id="] stringByAppendingString:[self.hospital objectForKey:@"id"]];
	
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
	
	NSDictionary *user=[[NSDictionary alloc] initWithObjectsAndKeys: self.lastName.text, @"last_name", self.firstName.text, @"first_name", self.email.text, @"email", nil];
	NSMutableArray *dataSet = [[NSMutableArray alloc] initWithObjects:user, hospital];
	
	if (![dao updateHospitalistRegistration:dataSet]) {
		[utils showAlert:@"Warning !!" message:@"Sorry couldn't save registration data. Please try again later." delegate:self];
	}
	
	[user release];
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


- (void)dealloc {
	[spinnerBg release];
	[spinner release];
	[hosName release];
	[lastName release];
	[firstName release];
	[email release];
	[hospital release];
    [super dealloc];
}


@end
