//
//  doctorListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "doctorListViewController.h"
#import "doctorDetailViewController.h"

@interface doctorListViewController ()

@end

@implementation doctorListViewController

@synthesize dataSource, searchBar, listTableView, spinner, countText, insIds, hosIds, spIds, inPatient, zipCode, isSearchFromOnline, alert;

@synthesize pracIds, acoIds, countyIds, languages, userData, sortToolBar, sortOptions, sortButton, spinnerBg, totalCount, currentLimit, officeHours,isResourceSearch,resourceFlag,rank, rankBtnList, unRankedImage, rankedImage, busy, paRank;

int docId,rankVal;

- (NSString *) getDoctorSearchUrl{
	NSString *url = [NSString stringWithFormat:@"%@doctor/search?prac_ids=%@&insu_ids=%@&spec_ids=%@&hosp_ids=%@&zip=%@&see_patient=%@&user_id=%@&cnty_ids=%@&limit=%d&lang=%@&office_hour=%@&aco_ids=%@&resourceFlag=%d",[utils getServerURL], pracIds, insIds, spIds, hosIds, zipCode, inPatient, [self.userData objectForKey:@"id"],countyIds, self.currentLimit, languages, officeHours, acoIds, resourceFlag];
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
	if (self.isResourceSearch){
        resourceFlag = 1;
    }
    else{
        resourceFlag = 0;
    }
    
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
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:10], UITextAttributeFont,
                                [UIColor whiteColor], UITextAttributeTextColor,
                                nil];
    [sortOptions setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [sortOptions setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    [sortOptions setTintColor:[UIColor colorWithRed:0.61176f green:0.61176f  blue:0.61176f  alpha:1.0f]];
    
    sortOptions.segmentedControlStyle = UISegmentedControlStyleBar;
    
    //[[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
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

			self.dataSource = [dao getDoctorList:self.searchBar.text insIds:insIds acoIds:acoIds hosIds:hosIds spIds:spIds pracIds:pracIds countyIds:countyIds languages:languages officeHours:officeHours zip:zipCode inPatient:inPatient order:self.sortOptions.selectedSegmentIndex limit:self.currentLimit resourceFlag:self.resourceFlag];
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
	NSMutableURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:300];
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
    [self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	[self.listTableView setHidden:YES];
    NSLog(@"Connection failed! Error - %@ ",
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
											[dict objectForKey:@"up_rank"], @"up_rank", [dict objectForKey:@"c8"], @"prac_name", nil]];
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
								[dict objectForKey:@"up_rank"], @"up_rank", [dict objectForKey:@"c8"], @"prac_name", nil]];
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
        docDetailController.delegate=self;
		docDetailController.isSearchFromOnline = self.isSearchFromOnline;
        //docId = [rowData objectForKey:@"id"];
		docDetailController.dId = [rowData objectForKey:@"id"];
		[self presentModalViewController:docDetailController animated:YES];
		[docDetailController release];
	}
}
- (void)doctorDetailViewControllerDismissed:(NSMutableDictionary *)docDic
{
    if([[docDic objectForKey: @"closeList"] isEqual:@"1"]){
        //[self backToFilterPage:nil];
        [self performSelectorOnMainThread:@selector(backToFilterPage:) withObject:nil waitUntilDone:NO];
        //[self.spinner startAnimating];
        //self.spinner.hidden = YES;
        //self.spinnerBg.hidden = YES;
        //[self performSelector:@selector(backToFilterPage:) withObject:nil afterDelay:1];
        //[self dismissModalViewControllerAnimated:YES];
        return;
    }
    else{
        NSString *docId = [docDic objectForKey: @"docId"];
        NSString *docRank = [docDic objectForKey: @"docRank"];
        NSString *docPARank = [docDic objectForKey: @"docPARank"];
        [self updateDataSource:[docId integerValue] rank:[docRank integerValue]];
        [self updatePARankInDataSource:[docId integerValue] rank:[docPARank integerValue]];
    }
    //NSString *thisIsTheDesiredString = stringForFirst;
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
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
    self.spinnerBg.hidden = YES;
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
    NSString *docRank =  [rowData objectForKey:@"u_rank"];
	NSString *docPARank =  [rowData objectForKey:@"up_rank"];
	//alert = [[NewRatingWidget alloc] initNewRatingWidget:docName delegate:self];
    //[alert show];
    //[self performSelector:@selector(alertShow) withObject:self afterDelay:3.0 ];
    NSMutableDictionary *docDic = [NSMutableDictionary dictionary];
    @try{
        [docDic setValue:docName forKey:@"docName"];
        [docDic setValue:docRank forKey:@"docRank"];
        [docDic setValue:docPARank forKey:@"docPARank"];
        [self launchDialog:docDic];
        docId = [[rowData objectForKey:@"id"] intValue];
        NSLog(@"rank update for %ld",(long)button.tag);
    }
    @catch(NSException *ex){
        NSLog(@"%@", ex.reason);
    }
}
- (void) alertShow{
    [alert show];
}
//- (NSMutableArray*)getBusStops:(NSString*)busStop forTime:(NSSTimeInterval*)timeInterval;
- (void)launchDialog:(NSMutableDictionary *)docDic
{
    
    alert = [[CustomIOS7AlertView alloc] initWithFrame:CGRectZero];
    
    [alert setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"Update", nil]];
    [alert setContainerView:[self createAlertView:docDic]];
    [alert setDelegate:self];
    
    
        
    [alert setUseMotionEffects:true];
    
    [alert show];
}


- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    //NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    if ([alertView isKindOfClass:[CustomIOS7AlertView class]] && !self.busy) {
		if( buttonIndex != 0 ){
			self.busy=YES;
			[NSThread detachNewThreadSelector:@selector(rankUpdateReqThread) toTarget:self withObject:nil];
		}else {
			[alertView close];
		}
        
	}else if(![alertView isKindOfClass:[CustomIOS7AlertView class]] && [self.dataSource count] == 1){
		
		[self dismissModalViewControllerAnimated:YES];
		
	}else if(![alertView isKindOfClass:[CustomIOS7AlertView class]]){
		[self.listTableView reloadData];
	}
    
    
}

- (UIView *)createAlertView:(NSMutableDictionary *)docDic
{
    NSString *docName = [docDic objectForKey: @"docName"];
    NSString *docRank = [docDic objectForKey: @"docRank"];
    NSString *docPARank = [docDic objectForKey: @"docPARank"];
    NSDictionary *user = [dao getCurrentUser];
    if([[user objectForKey:@"allow_pa_rank"] integerValue]==0){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
        int yPosition = 10;
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, yPosition, view.frame.size.width, 0)];
        [label setText: docName];
        [label setBackgroundColor: [UIColor clearColor]];
        [label setNumberOfLines: 0];
        [label sizeToFit];
        [label setCenter: CGPointMake(view.center.x, 20)];
        [view addSubview:label];
        
        
        
        
        self.rank =[docRank integerValue];
        
        
        [self.spinner hidesWhenStopped];
        
        self.unRankedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rank_silver" ofType:@"png"]];
        self.rankedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rank_orange" ofType:@"png"]];
        self.rankBtnList = [[NSMutableArray alloc] initWithCapacity:5];
        
        CGFloat x=45.0f;
        
        for (int i=0; i<5; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i+1;
            [button addTarget:self action:@selector(rankBtnClicked:) forControlEvents:UIControlEventTouchDown];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%d",button.tag] forState:UIControlStateNormal];
            [button setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
            button.frame = CGRectMake(x , 50.0, 30.0, 30.0);
            [view addSubview:button];
            [self.rankBtnList addObject:button];
            x += 40.0f;
        }
        [self preSetRank];
        //[view addSubview:self.spinner];
        return view;
    }
    else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 190)];
        int yPosition = 10;
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, yPosition, view.frame.size.width, 0)];
        [label setText: docName];
        [label setBackgroundColor: [UIColor clearColor]];
        [label setNumberOfLines: 0];
        [label sizeToFit];
        [label setCenter: CGPointMake(view.center.x, 20)];
        [view addSubview:label];
        
        
       
        UILabel *labelPA = [[UILabel alloc] initWithFrame: CGRectMake(0, 40, view.frame.size.width, 0)];
        [labelPA setText: @"PA Rank"];
        [labelPA setBackgroundColor: [UIColor clearColor]];
        [labelPA setNumberOfLines: 0];
        [labelPA sizeToFit];
        [labelPA setCenter: CGPointMake(view.center.x, 50)];
        [view addSubview:labelPA];
        
        UILabel *labelMY = [[UILabel alloc] initWithFrame: CGRectMake(0, 40, view.frame.size.width, 0)];
        [labelMY setText: @"MY Rank"];
        [labelMY setBackgroundColor: [UIColor clearColor]];
        [labelMY setNumberOfLines: 0];
        [labelMY sizeToFit];
        [labelMY setCenter: CGPointMake(view.center.x, 120)];
        [view addSubview:labelMY];
        
        
        self.rank =[docRank integerValue];
        self.paRank =[docPARank integerValue];
        [self.spinner hidesWhenStopped];
        
        self.unRankedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rank_silver" ofType:@"png"]];
        self.rankedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rank_orange" ofType:@"png"]];
        self.rankBtnList = [[NSMutableArray alloc] initWithCapacity:5];
        
        CGFloat x=45.0f;
        for (int i=0; i<5; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i+1;
            [button addTarget:self action:@selector(rankBtnClicked:) forControlEvents:UIControlEventTouchDown];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%d",button.tag] forState:UIControlStateNormal];
            [button setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
            button.frame = CGRectMake(x , 140.0, 30.0, 30.0);
            [view addSubview:button];
            [self.rankBtnList addObject:button];
            x += 40.0f;
        }
        x=45.0f;
        for (int i=0; i<5; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i+5+1;
            [button addTarget:self action:@selector(paRankBtnClicked:) forControlEvents:UIControlEventTouchDown];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%d",button.tag-5] forState:UIControlStateNormal];
            [button setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
            button.frame = CGRectMake(x , 70.0, 30.0, 30.0);
            [view addSubview:button];
            [self.rankBtnList addObject:button];
            x += 40.0f;
        }
        [self preSetRank];
        [self preSetPARank];
        
        //[view addSubview:self.spinner];
        return view;
    }
}

- (void)preSetPARank{
	//UIButton *button = (UIButton *)sender;
	//NSLog(@"rank enter %d", button.tag);
	//self.rank = button.tag;
	for (int i=0; i < 5; i++) {
		UIButton *rankBtn = [self.rankBtnList objectAtIndex:i+5];
		if( i < self.paRank ){
			//[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.rankedImage forState:UIControlStateNormal];
		}else {
			//[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
		}
        
	}
}

- (void)preSetRank{
	//UIButton *button = (UIButton *)sender;
	//NSLog(@"rank enter %d", button.tag);
	//self.rank = button.tag;
	for (int i=0; i < 5; i++) {
		UIButton *rankBtn = [self.rankBtnList objectAtIndex:i];
		if( i < self.rank ){
			//[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.rankedImage forState:UIControlStateNormal];
		}else {
			//[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
		}
        
	}
}

- (void)paRankBtnClicked:(id)sender{
	UIButton *button = (UIButton *)sender;
	NSLog(@"rank enter %d", button.tag);
	self.paRank = button.tag-5;
	for (int i=0; i < 5; i++) {
		UIButton *rankBtn = [self.rankBtnList objectAtIndex:i+5];
		if( i+5 < button.tag ){
			//[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.rankedImage forState:UIControlStateNormal];
		}else {
			//[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
		}
        
	}
}

- (void)rankBtnClicked:(id)sender{
	UIButton *button = (UIButton *)sender;
	NSLog(@"rank enter %d", button.tag);
	self.rank = button.tag;
	for (int i=0; i < 5; i++) {
		UIButton *rankBtn = [self.rankBtnList objectAtIndex:i];
		if( i < button.tag ){
			//[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.rankedImage forState:UIControlStateNormal];
		}else {
			//[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[rankBtn setBackgroundImage:self.unRankedImage forState:UIControlStateNormal];
		}
        
	}
}


/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if ([alertView isKindOfClass:[NewRatingWidget class]] && !alert.busy) {
		if( buttonIndex != alertView.cancelButtonIndex ){
			[alert isWorking:YES];
			[NSThread detachNewThreadSelector:@selector(rankUpdateReqThread) toTarget:self withObject:nil];
		}else {
			[alert dismissWidget];
		}
	
	}else if(![alertView isKindOfClass:[NewRatingWidget class]] && [self.dataSource count] == 1){
		
		[self dismissModalViewControllerAnimated:YES];
		
	}else if(![alertView isKindOfClass:[NewRatingWidget class]]){
		[self.listTableView reloadData];
	}
    
}
*/
- (void) rankUpdateReqThread{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary *user = [dao getCurrentUser];
    if([[user objectForKey:@"allow_pa_rank"] integerValue]==0){
        if(self.isSearchFromOnline){
            NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"userDocRank/rank&doc_id=%d&user_id=%@&rank=%d",docId, [user objectForKey:@"id"], self.rank];
            NSLog(@"url :%@",serverUrl);
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
            
            NSLog(@"response : %@",responseString);
            
            if ([responseString isEqual:@"saved"] || [responseString isEqual:@"rank updated"]) {
                [dao updateDoctorRank:docId rank:self.rank];
                [self updateDataSource:docId rank:self.rank];
                [utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
            }else{
                [utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];
            }
        }else {
            if( [dao updateDoctorRank:docId rank:self.rank] ){
                [self updateDataSource:docId rank:self.rank];
                [utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
            }else {
                [utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];	
            }	
            
        }
    }
    else{
        if(self.isSearchFromOnline){
            NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"userDocRank/paRank?doc_id=%d&user_id=%@&rank=%d",docId, [user objectForKey:@"id"], self.paRank];
            NSLog(@"url :%@",serverUrl);
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
            
            NSLog(@"response : %@",responseString);
            int err=0;
            int err2=0;
            if ([responseString isEqual:@"saved"] || [responseString isEqual:@"rank updated"]) {
                [dao updateDoctorPARank:docId rank:self.paRank];
                [self updatePARankInDataSource:docId rank:self.paRank];
                //[utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
            }else{
                err=1;
                //[utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];
            }
            
            serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"userDocRank/rank?doc_id=%d&user_id=%@&rank=%d",docId, [user objectForKey:@"id"], self.rank];
            NSLog(@"url :%@",serverUrl);
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
            response = nil;
            error = nil;
            newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
            
            NSLog(@"response : %@",responseString);
            
            if ([responseString isEqual:@"saved"] || [responseString isEqual:@"rank updated"]) {
                [dao updateDoctorRank:docId rank:self.rank];
                [self updateDataSource:docId rank:self.rank];
                
            }else{
                err2=1;
                
            }
            if(err==0){
                [utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
                
            }
            if(err==1){
                [utils showAlert:@"Warning !!" message:@"Couldn't update PA rank, please try again later." delegate:self];
            }
            if(err2==1){
                [utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];
            }
        }else {
            int err=0;
            int err2=0;
            if( [dao updateDoctorPARank:docId rank:self.paRank] ){
                [self updatePARankInDataSource:docId rank:self.paRank];
                //[utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
            }else {
                err=1;
                //[utils showAlert:@"Warning !!" message:@"Couldn't update PA rank, please try again later." delegate:self];
            }
            
            if( [dao updateDoctorRank:docId rank:self.rank] ){
                [self updateDataSource:docId rank:self.rank];
                //[utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
            }else {
                //[utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];
                err2=1;
            }
            if(err==0){
                [utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
                
            }
            if(err==1){
                [utils showAlert:@"Warning !!" message:@"Couldn't update PA rank, please try again later." delegate:self];
            }
            if(err2==1){
                [utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];
            }
        }
    }
    
    self.busy = NO;
    [alert close];
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
            [self.listTableView reloadData];
            
            [self.spinner stopAnimating];
            self.spinner.hidden = YES;
            self.spinnerBg.hidden = YES;
            [self.listTableView setHidden:NO];
			return;
		}
	}
}

- (void) updatePARankInDataSource:(int)docId rank:(int)rankValue{
	for (int i=0; i<[self.dataSource count]; i++) {
		NSDictionary *row = (NSDictionary *)[self.dataSource objectAtIndex:i];
		if ([[row objectForKey:@"id"] intValue] == docId) {
			NSMutableDictionary *newRow = [row mutableCopy];
			[newRow setObject:[NSString stringWithFormat:@"%d",rankValue] forKey:@"up_rank"];
			[self.dataSource replaceObjectAtIndex:i withObject:newRow];
            [self.listTableView reloadData];
            
            [self.spinner stopAnimating];
            self.spinner.hidden = YES;
            self.spinnerBg.hidden = YES;
            [self.listTableView setHidden:NO];
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
    [rankedImage release];
	[unRankedImage release];
	[rankBtnList release];
    //[isResourceSearch release];
    //[resourceFlag release];
    [super dealloc];
}


@end
