//
//  activationViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 12/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "activationViewController.h"


@implementation activationViewController

@synthesize email, code, dataSource, spinner, dao, spinnerBg;


- (void)loadView{
	[super loadView];
	dao = [[registrationDao alloc] init];
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
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

- (IBAction) backButtonClicked: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) emailDidEntered: (id) sender{
	[email resignFirstResponder];
}

- (IBAction) codeDidEntered: (id) sender{
	[code resignFirstResponder];
}

- (IBAction) backgroundClicked: (id) sender{
	[email resignFirstResponder];
	[code resignFirstResponder];
}

- (IBAction) activateBtnClicked: (id) sender{
	if ([[email text] length] == 0 ) {
		[utils showAlert:@"Warning !!" message:@"Please provide your email." delegate:self];
		return;
	}
	
	if ([[code text] length] == 0 ) {
		[utils showAlert:@"Warning !!" message:@"Please provide your activation code." delegate:self];
		return;
	}
	
	if (![utils performSelector:@selector(validateEmail:) withObject:[email text]]) {
		[utils showAlert:@"Warning !!" message:@"Please provide a valid email address." delegate:self];
		return;
	}
	
	NSString *url = [NSString stringWithString: [utils performSelector:@selector(getServerURL)]];
	url = [[[[url stringByAppendingString:@"user/activate?email="] stringByAppendingString:[email text]] stringByAppendingString:@"&code="] stringByAppendingString:[code text]];
	
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;
	
	adapter = [SBJsonStreamParserAdapter new];
	adapter.delegate = self;
	parser = [SBJsonStreamParser new];
	parser.delegate = adapter;
	parser.multi = YES;
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];//asynchronous call
	[[NSURLConnection alloc] initWithRequest:request delegate:self];

	
}

// methods for NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Connection didReceiveResponse: %@ - %@", response, [response MIMEType]);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"Connection didReceiveAuthenticationChallenge: %@", challenge);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Connection didReceiveData of length: %u", data.length);
	
	SBJsonStreamParserStatus status = [parser parse:data];
	
	if (status == SBJsonStreamParserError) {
		
		NSLog(@"Parser error: %@", parser.error);
		[self.spinner stopAnimating];
		self.spinner.hidden = YES;
		self.spinnerBg.hidden = YES;
		[utils showAlert:@"Warning !!" message:@"Activation Failed !! Please try again with correct credential." delegate:self];
		return;
		
	} else if (status == SBJsonStreamParserWaitingForData) {
		
		NSLog(@"Parser waiting for more data");
	
	}
	
	NSLog(@"row size : %u",[self.dataSource count]);
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	if([dao performSelector:@selector(activateUser:) withObject:self.dataSource]){
	
		// forward to another view;
		
		setupViewController *setupController = [[setupViewController alloc] initWithNibName:@"setupViewController" bundle:nil];
		setupController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:setupController animated:YES];
		[setupController release];
		
	}else {
		[utils showAlert:@"Warning !!" message:@"Activation Failed !! Please try again with correct credential." delegate:self];
	}

	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@",
          [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
    [connection release];
	[parser release];
	[adapter release];
	parser = nil;
	adapter = nil;
}


//methods for json parser protocol

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
	NSLog(@"inside foundArray %u", [array count]);
	if([array count] > 0){
		self.dataSource = [[NSMutableArray alloc] initWithObjects:nil];
		for (NSDictionary *dict in array) {
			[self.dataSource addObject:dict];
		}
	}
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
	NSLog(@"inside foundObject");
	self.dataSource = [[NSMutableArray alloc] initWithObjects:nil];
	[self.dataSource addObject:dict];
}


- (void)dealloc {
	[spinnerBg release];
	[dao release];
	[spinner release];
	[dataSource release];
	[email release];
	[code release];
    [super dealloc];
}


@end
