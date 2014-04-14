//
//  insuranceListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectListViewController.h"


@implementation SelectListViewController

@synthesize dataSource, searchBar, listTableView, spinner, countText, filterView, isSearchFromOnline, selectedDataSource, spinnerBg, defaultElemId, maxSelectionLimit, totalCount, currentLimit;

- (void)loadView{
	[super loadView];
	dao = [[searchDao alloc] init];
	self.searchBar.placeholder = [self getSearchBarTitle];
	self.currentLimit = 50;
	adapter = [SBJsonStreamParserAdapter new];
	adapter.delegate = self;
	parser = [SBJsonStreamParser new];
	parser.delegate = adapter;
	parser.multi = YES;
    self.searchBar.text = @"*";
    self.searchBar.text = @"";
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];

}

- (void) triggerAsyncronousRequest: (NSString *)url {
	
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;

	url = [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:900];
	//NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];//asynchronous call
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
    NSString *jsonStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"NI::String sent from server %@",jsonStr);
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    SBJsonStreamParserStatus status = [parser parse:data];
    
    if (status == SBJsonStreamParserError) {
        NSLog(@"Parser error: %@", parser.error);
        
    } else if (status == SBJsonStreamParserWaitingForData) {
        NSLog(@"Parser waiting for more data");
    }
    NSLog(@"row size : %u",[self.dataSource count]);
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
	[self.listTableView setHidden:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ ",
          [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
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
		
		static NSString *cellTableIdentifier = @"CustomSelectCellIdentifier";
	
		customSelectCell *cell = (customSelectCell *)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customSelectCell" owner:self options:nil];
			cell = [nib objectAtIndex:0];
			cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
			[cell.selectedBackgroundView setBackgroundColor:[UIColor orangeColor]];
		}
		cell.name.text = [rowData objectForKey:@"name"];
		cell.checked.hidden = NO;
		if ([utils isRowExistsOnList:selectedDataSource row:rowData]) {
			cell.isSelected = YES;
			[cell.checked setImage:[UIImage imageNamed:@"checkbox_ticked.png"]];
		}else if(cell.name.text != NULL && ![cell.name.text isEqual:@""]){
			cell.isSelected = NO;
			[cell.checked setImage:[UIImage imageNamed:@"checkbox_not_ticked.png"]];
		}else {
			cell.checked.hidden = YES;
		}

		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSUInteger row = [indexPath row];
	NSDictionary *rowData = [self.dataSource objectAtIndex:row];
	if ([rowData objectForKey:@"count"] != NULL && ![[rowData objectForKey:@"count"] isEqual:@""] ) {
		return 55.0f;
	}else {
		return 50.0f;
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
		if (self.isSearchFromOnline) {
			NSString *serverUrl = [self getSearchURL];
			serverUrl = [serverUrl stringByAppendingFormat:@"&limit=%d",self.currentLimit];
			[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];
		}else {
			
			[NSThread detachNewThreadSelector:@selector(loadLocalRows) toTarget:self withObject:nil];
		}

		
		
	}else if ([rowData objectForKey:@"name"] != NULL && ![[rowData objectForKey:@"name"] isEqual:@""] ) {

		NSLog(@"option selected on select list");
		if( self.defaultElemId != nil && [self.defaultElemId isEqual:[rowData objectForKey:@"id"]]){
			[utils showAlert:@"Warning !!" message:@"Default option can't be removed." delegate:nil];
			return;
		}
		customSelectCell *cell = (customSelectCell *)[tableView cellForRowAtIndexPath:indexPath];
		if (!cell.isSelected) {
			if (self.maxSelectionLimit > 0 && [selectedDataSource count] >= self.maxSelectionLimit) {
				[utils showAlert:@"Warning !!" message:@"Maximum selection limit exceeded." delegate:nil];
				return;
			}
			[selectedDataSource addObject:rowData];
			cell.isSelected = YES;
			[cell.checked setImage:[UIImage imageNamed:@"checkbox_ticked.png"]];
		
		}else {
			[utils deleteRowFromList:selectedDataSource row:rowData];
			cell.isSelected = NO;
			[cell.checked setImage:[UIImage imageNamed:@"checkbox_not_ticked.png"]];
		}
	}
	[self hideKeyboard:nil];
}

- (IBAction) hideKeyboard: (id) sender{
	[searchBar resignFirstResponder];
}

- (IBAction) clearAllBtnClicked: (id) sender{
	NSDictionary *defaultElem = nil;
	
	if(self.defaultElemId != nil){
		for( NSDictionary *dict in self.selectedDataSource ){
			if([self.defaultElemId isEqual:[dict objectForKey:@"id"]]){
				defaultElem = [dict copyWithZone:nil];
				break;
			}
		}
	}
	
	[self.selectedDataSource removeAllObjects];
	if( defaultElem != nil )
		[self.selectedDataSource addObject:defaultElem];
	
	[self.listTableView reloadData];
}

- (IBAction) selectionDone: (id) sender{
	[self.filterView setSelectedOption:selectedDataSource delegate:self];
}

- (NSString *) getSearchBarTitle{
	return @"Search";
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
	[defaultElemId release];
	[parser release];
	[adapter release];
	parser = nil;
	adapter = nil;
	[spinnerBg release];
	[dao release];
	[selectedDataSource release];
	[filterView release];
	[countText release];
	[spinner release];
	[listTableView release];
	[dataSource release];
	[searchBar release];
    [super dealloc];
}


@end
