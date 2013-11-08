//
//  newPcpRegViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "newPcpRegViewController.h"


@implementation newPcpRegViewController

@synthesize spName, address, lastName, firstName, email, practice, speciality, spinner, spinnerBg;

- (void) loadView {
	[super loadView];
	dao = [[registrationDao alloc] init];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	
	NSString *header = [[[NSString stringWithString:[speciality valueForKey:@"name"]] stringByAppendingString:@"@"] stringByAppendingString:[practice valueForKey:@"name"]];
	self.spName.text = header;
	
	//code for dynamically resizable uilable
	UIFont* font = self.spName.font;			
	CGSize constraintSize = CGSizeMake(self.spName.frame.size.width, MAXFLOAT);
	CGSize labelSize = [self.spName.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	CGFloat newY = (self.spName.frame.origin.y - (labelSize.height - self.spName.frame.size.height));
	self.spName.frame = CGRectMake(self.spName.frame.origin.x, newY, self.spName.frame.size.width, labelSize.height);
	
	self.address.text = [practice valueForKey:@"add_line1"];
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];
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

- (IBAction) backToSpecialistList: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) hideKeyboard: (id) sender{
	[self.lastName resignFirstResponder];
	[self.firstName resignFirstResponder];
	[self.email resignFirstResponder];
}

- (IBAction) registerNewPcp: (id) sender{
	
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
	
	NSString *url = [[[[[[[[[[[NSString stringWithString:[utils performSelector:@selector(getServerURL)]]
					 stringByAppendingString:@"user/register?last_name="] stringByAppendingString:self.lastName.text] stringByAppendingString:@"&first_name="] stringByAppendingString:self.firstName.text]
					  stringByAppendingString:@"&email="] stringByAppendingString:self.email.text] stringByAppendingString:@"&prac_id="] stringByAppendingString:[self.practice objectForKey:@"id"]] 
					  stringByAppendingString:@"&spec_id="] stringByAppendingString:[self.speciality objectForKey:@"id"]];
	
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
	[utils showAlert:@"Warning !!" message:@"Sorry couldn't connect to server.Please try again later." delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Connection didReceiveData of length: %u", data.length);
	
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	
	NSDictionary *user=[[NSDictionary alloc] initWithObjectsAndKeys: self.lastName.text, @"last_name", self.firstName.text, @"first_name", self.email.text, @"email", nil];
	NSMutableArray *dataSet = [[NSMutableArray alloc] initWithObjects:user, practice];
	
	if (![dao updatePCPUserRegistration:dataSet]) {
		[utils showAlert:@"Warning !!" message:@"Sorry couldn't save registration data.Please try again later." delegate:self];
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
	[utils showAlert:@"Warning !!" message:@"Sorry couldn't connect to server.Please try again later." delegate:self];
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
	[spName release];
	[address release];
	[lastName release];
	[firstName release];
	[email release];
	[practice release];
	[speciality release];
    [super dealloc];
}

@end
