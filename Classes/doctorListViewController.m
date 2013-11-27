//
//  doctorListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "doctorListViewController.h"
#import "doctorDetailViewController.h"


@implementation doctorListViewController

@synthesize dataSource, searchBar, listTableView, spinner, countText, insIds, hosIds, spIds, inPatient, zipCode, isSearchFromOnline, alert;

@synthesize pracIds, acoIds, countyIds, languages, userData, sortToolBar, sortOptions, sortButton, spinnerBg, totalCount, currentLimit, officeHours;

int docId,rankVal;

- (NSString *) getDoctorSearchUrl{
	NSString *url = [NSString stringWithFormat:@"%@doctor/search?prac_ids=%@&insu_ids=%@&spec_ids=%@&hosp_ids=%@&zip=%@&see_patient=%@&user_id=%@&cnty_ids=%@&limit=%d&lang=%@&office_hour=%@&aco_ids=%@",[utils getServerURL], pracIds, insIds, spIds, hosIds, zipCode, inPatient, [self.userData objectForKey:@"id"],countyIds, self.currentLimit, languages, officeHours, acoIds];
	return url;
}

- (void)viewDidLoad {
	dao = [[searchDao alloc] init];
	[dao updateSearchCount:1];
	self.currentLimit = 50;
	adapter = [SBJsonStreamParserAdapter new];
	adapter.delegate = self;
	parser = [SBJsonStreamParser new];
	parser.delegate = adapter;
	parser.multi = YES;
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];
	
	if (self.isSearchFromOnline) {
		
		self.userData = [dao getCurrentUser];
		[self.listTableView setHidden:YES];
		NSString *serverUrl = [[self getDoctorSearchUrl] stringByAppendingFormat:@"&order=0"];
		[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];
		
	}else {
		
		[self.listTableView setHidden:YES];
		[self.spinner startAnimating];
		self.spinner.hidden = NO;
		self.spinnerBg.hidden = NO;
	
		[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"empty"] forKey:@"doc_prev_search_content"];

		[NSThread detachNewThreadSelector:@selector(doctorListThread) toTarget:self withObject:nil];
	}
	
}

- (IBAction) searchContentChanged: (id) sender{
	
	NSLog(@"inside searchContentChanged......");
	self.currentLimit = 50;

	if (self.isSearchFromOnline) {
		
		NSString *serverUrl = [[self getDoctorSearchUrl] stringByAppendingFormat:@"&doc_name=%@&order=%d", self.searchBar.text, self.sortOptions.selectedSegmentIndex];
		[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];	
		
	}else {
		
		[self.spinner startAnimating];
		self.spinner.hidden = NO;
		self.spinnerBg.hidden = NO;
		
		[NSThread detachNewThreadSelector:@selector(doctorListThread) toTarget:self withObject:nil];
		
	}
	
}

- (void) doctorListThread{
    
	@synchronized(self) {
        
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  

		NSString *prevContent = [[NSUserDefaults standardUserDefaults] stringForKey:@"doc_prev_search_content"];
		NSString *currentContent = self.searchBar.text;
		
		if( ![prevContent isEqual:currentContent] ){

				//if(!self.spinner.hidden){
				[self.spinner startAnimating];
				self.spinner.hidden = NO;
				self.spinnerBg.hidden = NO;
			//}

			self.dataSource = [dao getDoctorList:self.searchBar.text insIds:insIds acoIds:acoIds hosIds:hosIds spIds:spIds pracIds:pracIds countyIds:countyIds languages:languages officeHours:officeHours zip:zipCode inPatient:inPatient order:self.sortOptions.selectedSegmentIndex limit:self.currentLimit];
			NSDictionary *countData = [self.dataSource objectAtIndex:0];
			self.totalCount = [[countData objectForKey:@"count"] intValue];
			NSLog(@"total count %d",self.totalCount);
			[self.dataSource removeObjectAtIndex:0];
			if ([self.dataSource count] < self.totalCount) {
				[self.dataSource addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"Showing %d out of %d",self.currentLimit,self.totalCount],@"count",nil] autorelease] ];		
			}
			[self.dataSource addObject:[[[NSDictionary alloc] init] autorelease] ];//empty allocation in-order to able to select the last element		
			[self.listTableView reloadData];
			if ([self.dataSource count] <= 1) {
                NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
                [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Warning !!",@"title",nil] ];
                [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"Sorry, no result found. Please search again.",@"message",nil] ];
                [self performSelectorOnMainThread:@selector(showAlert:) withObject:array waitUntilDone:NO];
				//[utils showAlert:@"Warning !!" message:@"Sorry, no result found. Please search again." delegate:nil];
			}
			[self.spinner stopAnimating];
			self.spinner.hidden = YES;
			self.spinnerBg.hidden = YES;
			[self.listTableView setHidden:NO];
			[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",currentContent] forKey:@"doc_prev_search_content"];

			
		}	
		
		[pool release];

	}
}
- (void) showAlert: (NSObject *)obj {
    NSDictionary *objData = [obj objectAtIndex:0];
    NSString *title = [objData objectForKey:@"title"] ;
    objData = [obj objectAtIndex:1];
    NSString *message = [objData objectForKey:@"message"] ;
    [utils showAlert:title message:message delegate:nil];
}
- (void) triggerAsyncronousRequest: (NSString *)url {
	
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;
	NSLog(@"%@",url);

	url = [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];	
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
	//self.countText.text = [NSString stringWithFormat:@"%d item found", [self.dataSource count]];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	if ([self.dataSource count] <= 1) {
		[utils showAlert:@"Warning !!" message:@"Sorry, no result found. Please search again." delegate:self];
	}	
    [connection release];
}


//methods for json parser protocol

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
	NSLog(@"inside foundArray %u", [array count]);
	if([array count] > 0){
		self.dataSource = [[NSMutableArray alloc] initWithObjects:nil];
		for (NSDictionary *dict in array) {
			if( [[dict objectForKey:@"id"] intValue] > 0 ){ 
				[self.dataSource addObject:[[NSDictionary alloc] initWithObjectsAndKeys: [dict objectForKey:@"id"], @"id",
											[dict objectForKey:@"c1"], @"last_name", [dict objectForKey:@"c2"], @"first_name",
											[dict objectForKey:@"c3"], @"mid_name", [dict objectForKey:@"c4"], @"degree",
											[dict objectForKey:@"c5"], @"doc_phone", [dict objectForKey:@"c6"], @"language",
											[dict objectForKey:@"c7"], @"grade",[dict objectForKey:@"u_rank"], @"u_rank",
											[dict objectForKey:@"c8"], @"prac_name", nil]];
			}else if ([dict objectForKey:@"count"] != NULL && ![[dict objectForKey:@"count"] isEqual:@""]) {
				
				[self.dataSource addObject:[[NSDictionary alloc] initWithObjectsAndKeys: [dict objectForKey:@"count"], @"count", nil]];
			}

		}
	}
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
	NSLog(@"inside foundObject");
	self.dataSource = [[NSMutableArray alloc] initWithObjects:nil];
	if ([dict objectForKey:@"count"] != NULL && ![[dict objectForKey:@"count"] isEqual:@""]) {
		[self.dataSource addObject:[[NSDictionary alloc] initWithObjectsAndKeys: [dict objectForKey:@"count"], @"count", nil]];
	}else{
		[self.dataSource addObject:[[NSDictionary alloc] initWithObjectsAndKeys: [dict objectForKey:@"id"], @"id",
								[dict objectForKey:@"c1"], @"last_name", [dict objectForKey:@"c2"], @"first_name",
								[dict objectForKey:@"c3"], @"mid_name", [dict objectForKey:@"c4"], @"degree",
								[dict objectForKey:@"c5"], @"doc_phone", [dict objectForKey:@"c6"], @"language",
								[dict objectForKey:@"c7"], @"grade", [dict objectForKey:@"u_rank"], @"u_rank",
								[dict objectForKey:@"c8"], @"prac_name", nil]];
	}
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
		
	}else if( [[rowData objectForKey:@"id"] intValue] > 0 ){		
		
		static NSString *cellTableIdentifier = @"CustomDoctorCellIdentifier";
		
		CustomDoctorCell *cell = (CustomDoctorCell *)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomDoctorCell" owner:self options:nil];
			cell = [nib objectAtIndex:0];
			cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
			[cell.selectedBackgroundView setBackgroundColor:[UIColor orangeColor]];
			UILongPressGestureRecognizer *longPressGesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressActivity:)] autorelease];
			[cell addGestureRecognizer:longPressGesture];
		}
		if( [rowData objectForKey:@"first_name"] != [NSNull null] && ![[rowData objectForKey:@"first_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"first_name"] isEqual:@""]){
			cell.name.text =  [rowData objectForKey:@"first_name"];
		}
		if( [rowData objectForKey:@"mid_name"] != [NSNull null] && ![[rowData objectForKey:@"mid_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"mid_name"] isEqual:@""]){
			if( [cell.name.text length] > 0 ){
				cell.name.text = [cell.name.text stringByAppendingFormat:@" %@", [rowData objectForKey:@"mid_name"]];
			}else{
				cell.name.text =  [rowData objectForKey:@"mid_name"];
			}
		}
		if( [rowData objectForKey:@"last_name"] != [NSNull null] && ![[rowData objectForKey:@"last_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"last_name"] isEqual:@""]){
			if( [cell.name.text length] > 0 ){
				cell.name.text = [cell.name.text stringByAppendingFormat:@" %@", [rowData objectForKey:@"last_name"]];
			}else{
				cell.name.text =  [rowData objectForKey:@"last_name"];
			}
		}
		if( [rowData objectForKey:@"degree"] != [NSNull null] && ![[rowData objectForKey:@"degree"] isEqual:@"<null>"] && ![[rowData objectForKey:@"degree"] isEqual:@""]){
			cell.name.text = [cell.name.text stringByAppendingFormat:@", %@", [rowData objectForKey:@"degree"]];
		}	
		if( [rowData objectForKey:@"prac_name"] != [NSNull null] && ![[rowData objectForKey:@"prac_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"prac_name"] isEqual:@""]){
			cell.pracName.text = [rowData objectForKey:@"prac_name"];
			//NSLog([rowData objectForKey:@"prac_name"]);
		}
		NSString *phoneNumber = @"None";
		if( [rowData objectForKey:@"doc_phone"] != [NSNull null] && ![[rowData objectForKey:@"doc_phone"] isEqual:@"<null>"] && ![[rowData objectForKey:@"doc_phone"] isEqual:@""]){
			phoneNumber = [rowData objectForKey:@"doc_phone"];
		}
		cell.phone.text = [NSString stringWithFormat:@"Phone: %@", phoneNumber];
		//NSLog(@"grade %@",);
		cell.rankBtn.tag = row;
		cell.rankLabel.text = [rowData objectForKey:@"u_rank"];
		//[cell.rankBtn setTitle:[rowData objectForKey:@"u_rank"] forState:UIControlStateNormal];
		cell.callBtn.tag = row;
		[utils generateRatingBar:cell.ratingView value:[rowData objectForKey:@"grade"]];
		return cell;
	}else {
		static NSString *cellTableIdentifier = @"SimpleTableIdentifier";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellTableIdentifier] autorelease];
			cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
			[cell.selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
		}
		
		return cell;
		
	}

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSUInteger row = [indexPath row];
	NSDictionary *rowData = [self.dataSource objectAtIndex:row];
	if ([rowData objectForKey:@"count"] != NULL && ![[rowData objectForKey:@"count"] isEqual:@""] ) {
		return 55.0f;
	}else if ([[rowData objectForKey:@"id"] intValue] > 0) {
		return 85.0f;
	}else {
		return 50.0f;
	}

	
}

// event handler after selecting a table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSUInteger row = [indexPath row];
	[self hideKeyboard:nil];
	NSDictionary *rowData = [self.dataSource objectAtIndex:row];
	if ([rowData objectForKey:@"count"] != NULL && ![[rowData objectForKey:@"count"] isEqual:@""] ) {
		viewMoreCell *cell = (viewMoreCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell setUserInteractionEnabled:NO];
		self.currentLimit += 50;
		
		if (self.isSearchFromOnline) {
			
			NSString *serverUrl = [[self getDoctorSearchUrl] stringByAppendingFormat:@"&doc_name=%@&order=%d", self.searchBar.text, self.sortOptions.selectedSegmentIndex];
			[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];
			
		}else {
			
			[self.spinner startAnimating];
			self.spinner.hidden = NO;
			self.spinnerBg.hidden = NO;
			
			[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"empty"] forKey:@"doc_prev_search_content"];
			[NSThread detachNewThreadSelector:@selector(doctorListThread) toTarget:self withObject:nil];
		}
		
	}else if ([[rowData objectForKey:@"id"] intValue] > 0 ) {
		doctorDetailViewController *docDetailController = [[doctorDetailViewController alloc] initWithNibName:@"doctorDetailViewController" bundle:nil];
		docDetailController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		docDetailController.isSearchFromOnline = self.isSearchFromOnline;
		docDetailController.dId = [rowData objectForKey:@"id"];
		[self presentModalViewController:docDetailController animated:YES];
		[docDetailController release];
	}
}

- (void) longPressActivity:(UILongPressGestureRecognizer *)gesture{
	if (gesture.state == UIGestureRecognizerStateBegan) {
		
		NSIndexPath *indxPath = [self.listTableView indexPathForCell:(UITableViewCell *)[gesture view]];
		NSDictionary *rowData = [self.dataSource objectAtIndex:[indxPath row]];
		NSString *docName = @"";
		
		if( [rowData objectForKey:@"first_name"] != [NSNull null] && ![[rowData objectForKey:@"first_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"first_name"] isEqual:@""]){
			docName =  [rowData objectForKey:@"first_name"];
		}
		if( [rowData objectForKey:@"mid_name"] != [NSNull null] && ![[rowData objectForKey:@"mid_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"mid_name"] isEqual:@""]){
			if( [docName length] > 0 ){
				docName = [docName stringByAppendingFormat:@" %@", [rowData objectForKey:@"mid_name"]];
			}else{
				docName =  [rowData objectForKey:@"mid_name"];
			}
		}
		if( [rowData objectForKey:@"last_name"] != [NSNull null] && ![[rowData objectForKey:@"last_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"last_name"] isEqual:@""]){
			if( [docName length] > 0 ){
				docName = [docName stringByAppendingFormat:@" %@", [rowData objectForKey:@"last_name"]];
			}else{
				docName =  [rowData objectForKey:@"last_name"];
			}
		}
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:docName delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Report an Error",@"Rank Change",@"Cancel", nil];
		[actionSheet showInView:self.view];
		[actionSheet release];	
		docId = [indxPath row];
		
		NSLog(@"id %@",[rowData objectForKey:@"id"]);
	}
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{

	NSLog(@"button Index %d",buttonIndex);
	if (buttonIndex == 0) {
		NSDictionary *rowData = [self.dataSource objectAtIndex:docId];
		doctorDetailViewController *docDetailController = [[doctorDetailViewController alloc] initWithNibName:@"doctorDetailViewController" bundle:nil];
		docDetailController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		docDetailController.isSearchFromOnline = self.isSearchFromOnline;
		docDetailController.isReportChangeCalled = YES;
		docDetailController.dId = [rowData objectForKey:@"id"];
		[self presentModalViewController:docDetailController animated:YES];
		[docDetailController release];
	}else if (buttonIndex == 1) {
		UIButton *button = [[UIButton alloc] init];
		button.tag = docId;
		[self rankUpdate:button];
	}
}

- (IBAction) hideKeyboard: (id) sender{
	[self.searchBar resignFirstResponder];
}

- (IBAction) backToFilterPage: (id) sender{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) rankUpdate: (id)sender{
	UIButton *button = (UIButton *)sender;
	NSDictionary *rowData = [self.dataSource objectAtIndex:button.tag];
	NSString *docName = @"";
	if( [rowData objectForKey:@"first_name"] != [NSNull null] && ![[rowData objectForKey:@"first_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"first_name"] isEqual:@""]){
		docName =  [rowData objectForKey:@"first_name"];
	}
	if( [rowData objectForKey:@"mid_name"] != [NSNull null] && ![[rowData objectForKey:@"mid_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"mid_name"] isEqual:@""]){
		if( [docName length] > 0 ){
			docName = [docName stringByAppendingFormat:@" %@", [rowData objectForKey:@"mid_name"]];
		}else{
			docName =  [rowData objectForKey:@"mid_name"];
		}
	}
	if( [rowData objectForKey:@"last_name"] != [NSNull null] && ![[rowData objectForKey:@"last_name"] isEqual:@"<null>"] && ![[rowData objectForKey:@"last_name"] isEqual:@""]){
		if( [docName length] > 0 ){
			docName = [docName stringByAppendingFormat:@" %@", [rowData objectForKey:@"last_name"]];
		}else{
			docName =  [rowData objectForKey:@"last_name"];
		}
	}
	
	alert = [[RatingWidget alloc] initRatingWidget:docName delegate:self];
	[alert show];
	docId = [[rowData objectForKey:@"id"] intValue];
	NSLog(@"rank update for %d",button.tag);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if ([alertView isKindOfClass:[RatingWidget class]] && !alert.busy) {
		if( buttonIndex != alertView.cancelButtonIndex ){
			[alert isWorking:YES];
			[NSThread detachNewThreadSelector:@selector(rankUpdateReqThread) toTarget:self withObject:nil];
		}else {
			[alert dismissWidget];
		}
	
	}else if(![alertView isKindOfClass:[RatingWidget class]] && [self.dataSource count] == 1){
		
		[self dismissModalViewControllerAnimated:YES];
		
	}else if(![alertView isKindOfClass:[RatingWidget class]]){
		[self.listTableView reloadData];
	}
    
}

- (void) rankUpdateReqThread{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  

	NSDictionary *user = [dao getCurrentUser];
	
	if(self.isSearchFromOnline){
		NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"userDocRank/rank?doc_id=%d&user_id=%@&rank=%d",docId, [user objectForKey:@"id"], [alert getRank]];
		NSLog(@"url :%@",serverUrl);
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
		
		NSLog(@"response : %@",responseString);
		
		if ([responseString isEqual:@"saved"] || [responseString isEqual:@"rank updated"]) {
			[dao updateDoctorRank:docId rank:[alert getRank]];
			[self updateDataSource:docId rank:[alert getRank]];
			[utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
		}else{
			[utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];
		}
	}else {
		if( [dao updateDoctorRank:docId rank:[alert getRank]] ){
			[self updateDataSource:docId rank:[alert getRank]];
			[utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
		}else {
			[utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];	
		}		
		
	}
	
	
	[alert isWorking:NO];
	[alert dismissWidget];
	[alert release];
			 
	[pool release];
}

- (void) updateDataSource:(int)docId rank:(int)rankValue{
	for (int i=0; i<[self.dataSource count]; i++) {
		NSDictionary *row = (NSDictionary *)[self.dataSource objectAtIndex:i];
		if ([[row objectForKey:@"id"] intValue] == docId) {
			NSMutableDictionary *newRow = [row mutableCopy];
			[newRow setObject:[NSString stringWithFormat:@"%d",rankValue] forKey:@"u_rank"];
			[self.dataSource replaceObjectAtIndex:i withObject:newRow];
			return;
		}
	}
}

-(IBAction) callDoctor:(id) sender{
	UIButton *button = (UIButton *)sender;
	//NSLog("row id %d",button.tag);
	NSDictionary *rowData = [self.dataSource objectAtIndex:[button tag]];
	
	[utils dialANumber:[rowData objectForKey:@"doc_phone"] view:self.view];
}

- (IBAction) sortMethodChanged:(id) sender{
	NSLog(@"inside sortMethodChanged:");
//	self.currentLimit = 50;
	
	if (self.sortOptions.selectedSegmentIndex == 0) {
		
		self.sortButton.title = @"Sort By Rank";
		
	}else if (self.sortOptions.selectedSegmentIndex == 1) {
		
		self.sortButton.title = @"Sort By Value";
		
	}else if (self.sortOptions.selectedSegmentIndex == 2) {
		
		self.sortButton.title = @"Sort By First Name";
		
	}else if (self.sortOptions.selectedSegmentIndex == 3) {
		
		self.sortButton.title = @"Sort By Last Name";
		
	}
	
	if( !self.isSearchFromOnline ){
			
		[self.spinner startAnimating];
		self.spinner.hidden = NO;
		self.spinnerBg.hidden = NO;
		[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"empty"] forKey:@"doc_prev_search_content"];
		[NSThread detachNewThreadSelector:@selector(doctorListThread) toTarget:self withObject:nil];
				
	}else {
		NSString *serverUrl = [[self getDoctorSearchUrl] stringByAppendingFormat:@"&doc_name=%@&order=%d", self.searchBar.text, self.sortOptions.selectedSegmentIndex];
		[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];	

	}

	self.sortToolBar.hidden = YES;
	self.sortOptions.hidden = YES;	
		
}

- (IBAction) sortButtonClicked:(id) sender{
	if (self.sortToolBar.hidden) {
		self.sortToolBar.hidden = NO;
		self.sortOptions.hidden = NO;
	}else {
		self.sortToolBar.hidden = YES;
		self.sortOptions.hidden = YES;
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
	[officeHours release];
	[spinnerBg release];
	[sortToolBar release];
	[sortOptions release];
	[sortButton release];
	[userData release];
	[pracIds release];
	[countyIds release];
	[languages release];
	[parser release];
	[adapter release];
	parser = nil;
	adapter = nil;	
	[dao release];
	[dataSource release];
	[searchBar release];
	[listTableView release];
	[spinner release];
	[countText release];
    [acoIds release];
	[insIds release];
	[hosIds release];
	[spIds release];
	[inPatient release];
	[zipCode release];
    [super dealloc];
}


@end
