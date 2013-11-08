//
//  CustomListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomListViewController.h"


@implementation CustomListViewController

@synthesize dataSource, searchBar, listTableView, spinner, spinnerBg, totalCount, currentLimit;

- (void) loadView{
	[super loadView];
	self.currentLimit = 50;
}

- (void)viewDidLoad {
	adapter = [SBJsonStreamParserAdapter new];
	adapter.delegate = self;
	parser = [SBJsonStreamParser new];
	parser.delegate = adapter;
	parser.multi = YES;
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];

	[self.listTableView setHidden:YES];
	self.searchBar.placeholder = [self getSearchBarLabel];
	NSString *serverUrl = [self getInitUrl];
	serverUrl = [serverUrl stringByAppendingFormat:@"&limit=%d",self.currentLimit];
	[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];
	
}

- (IBAction) searchContentChanged: (id) sender{
	
	NSLog(@"inside searchContentChanged......");
	self.currentLimit = 50;
	NSString *serverUrl = [self getSearchUrl];
	serverUrl = [serverUrl stringByAppendingFormat:@"&limit=%d",self.currentLimit];
	serverUrl = [serverUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];	

}

- (void) triggerAsyncronousRequest: (NSString *)url {
	
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;
		
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
		
	} else if (status == SBJsonStreamParserWaitingForData) {
		NSLog(@"Parser waiting for more data");
	}
	NSLog(@"row size : %u",[self.dataSource count]);
	NSDictionary *countData = [self.dataSource objectAtIndex:0];
	self.totalCount = [[countData objectForKey:@"count"] intValue];
	[self.dataSource removeObjectAtIndex:0];
	if ([self.dataSource count] < self.totalCount) {
		[self.dataSource addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"Showing %d out of %d",self.currentLimit,self.totalCount],@"count",nil] autorelease] ];		
	}
	[self.dataSource addObject:[[[NSDictionary alloc] init] autorelease] ];//empty allocation in-order to able to select the last element
	[self.listTableView reloadData];
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	[self.listTableView setHidden:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSLog(@"ConnectionDidFinishedLoading.......");
	[connection release];
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

// methods for tableview protocols

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSUInteger row = [indexPath row];	
	NSDictionary *rowData = [self.dataSource objectAtIndex:row];
	
	if ([rowData objectForKey:@"count"] != NULL && ![[rowData objectForKey:@"count"] isEqual:@""] ) {
		
		static NSString *cellTableIdentifier = @"viewMoreCell";
		
		viewMoreCell *cell = (viewMoreCell *)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"viewMoreCell" owner:self options:nil];
			cell = [nib objectAtIndex:0];
			cell.backgroundView =  [[[UIView alloc] init] autorelease];
			cell.backgroundView.backgroundColor = [UIColor blackColor];
			[cell.backgroundView setAlpha:0.60f];
			cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
			[cell.selectedBackgroundView setBackgroundColor:[UIColor orangeColor]];
		}
		cell.showMessage.text = [rowData objectForKey:@"count"];
		if ((self.totalCount - self.currentLimit) > 50 || (self.totalCount - self.currentLimit) < 0) {
			cell.moreCountMessage.text = @"Show 50 More";
		}else {
			cell.moreCountMessage.text = [NSString stringWithFormat:@"Show %d More",(self.totalCount - self.currentLimit)];
		}
		[cell setUserInteractionEnabled:YES];
		return cell;
		
	}else {		
	
		static NSString *cellTableIdentifier = @"SimpleTableIdentifier";
	
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellTableIdentifier] autorelease];
			cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
			[cell.selectedBackgroundView setBackgroundColor:[UIColor orangeColor]];
		}
		cell.text = [rowData objectForKey:@"name"];
		//cell.selectionStyle = UITableViewCellSelectionStyleGray;	
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
		cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.numberOfLines = 2;  // 0 means no max.
		return cell;
	}
}


// event handler after selecting a table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSUInteger row = [indexPath row];
	NSDictionary *rowData = [self.dataSource objectAtIndex:row];
	if ([rowData objectForKey:@"count"] != NULL && ![[rowData objectForKey:@"count"] isEqual:@""] ) {
		viewMoreCell *cell = (viewMoreCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell setUserInteractionEnabled:NO];
		self.currentLimit += 50;
		NSString *serverUrl = [self getSearchUrl];
		serverUrl = [serverUrl stringByAppendingFormat:@"&limit=%d",self.currentLimit];
		serverUrl = [serverUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];
		
	}else if ([rowData objectForKey:@"name"] != NULL && ![[rowData objectForKey:@"name"] isEqual:@""] ) {
		
		[self selectionTriggered:rowData];
	
	}		
	//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	//[ cell.selectedBackgroundView setBackgroundColor:[UIColor clearColor] ];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSUInteger row = [indexPath row];
	NSDictionary *rowData = [self.dataSource objectAtIndex:row];
	if ([rowData objectForKey:@"count"] != NULL && ![[rowData objectForKey:@"count"] isEqual:@""] ) {
		return 55.0f;
	}else {
		return 44.0f;
	}

}

- (IBAction) hideKeyboard: (id) sender{
	[searchBar resignFirstResponder];
}


- (IBAction) goHome: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}

- (NSString *) getSearchContent{
	return self.searchBar.text;
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


- (void)dealloc {
	[parser release];
	[adapter release];
	parser = nil;
	adapter = nil;
	
	if([self respondsToSelector:@selector(additionalDealloc)]){
		[self additionalDealloc];
	}
	[spinner release];
	[spinnerBg release];
	[listTableView release];
	[dataSource release];
	[searchBar release];
    [super dealloc];
}

@end
