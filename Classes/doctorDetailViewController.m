//
//  doctorDetailViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "doctorDetailViewController.h"


@implementation doctorDetailViewController

@synthesize name, speciality, degree, gender, spinner, phone, dId, dataSource, isSearchFromOnline, scrollView, basicView, rankbutton;

@synthesize spView, pracView, hosView, noteView, pracInfo, hosInfo, noteInfo, urankView, uprankView, rankBar, spinnerBg, reportBar, isReportChangeCalled;

@synthesize qualityView, costView, reportText, reportOptView, reportTextBtn, rankText, pexpView, avgRankInfo;

- (void)viewDidLoad {
	dao = [[searchDao alloc] init];
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];
	NSDictionary *userData = [dao getCurrentUserPracticeOrHospital];
	
	if (self.isSearchFromOnline) {
		NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"doctor/docJson?doc_id=%@&user_id=%@", self.dId, [userData objectForKey:@"uid"]];
		NSLog(serverUrl);
		[self performSelector:@selector(triggerAsyncronousRequest:) withObject: serverUrl];
		
	}else{
		
		
		[self performSelectorInBackground:@selector(viewLoadingScreen) withObject:nil];

		[self performSelector:@selector(doOfflineloading) withObject:nil];
	}
	
}

- (void) doOfflineloading{
	NSLog(@"before the dao call......");
	self.dataSource = [dao getDoctorDetails:self.dId];
	NSLog(@"After dao calll.......");
	[self.dataSource setValue:[dao getReportListByDoctor:self.dId] forKey:@"report_list"];
	NSLog(@"After dao calll.......1111");
	[self reloadView];		
	NSLog(@"After dao calll.......2222");
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	
}


- (void) triggerAsyncronousRequest: (NSString *)url {
	
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
		
	} else if (status == SBJsonStreamParserWaitingForData) {
		NSLog(@"Parser waiting for more data");
	}
	NSLog(@"row size : %u",[self.dataSource count]);
	[self.dataSource setValue:[dao getReportListByDoctor:self.dId] forKey:@"report_list"];
	float avgRank = [[self.dataSource valueForKey:@"avg_rank"] floatValue];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setMaximumFractionDigits:1];
	[formatter setRoundingMode: NSNumberFormatterRoundDown];
	NSString *roundedAvgRank = [formatter stringFromNumber:[NSNumber numberWithFloat:avgRank]];
	[formatter release];
	
	[self.dataSource setValue:roundedAvgRank forKey:@"avg_rank"];
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	[self reloadView];
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@",
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
		self.dataSource = [array objectAtIndex:0];
	}
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
	NSLog(@"inside foundObject");
	//self.dataSource = [[NSMutableArray alloc] initWithObjects:nil];
	self.dataSource = dict;
}

- (void) reloadView{
	
	NSArray *elements = [self.scrollView subviews];
	for (int i=11; i<[elements count]; i++) {
		[[elements objectAtIndex:i] performSelector:@selector(removeFromSuperview)];
	}

	((UIView *)[elements objectAtIndex:0]).frame = CGRectMake(8, 2, 302, 49);
	((UIView *)[elements objectAtIndex:2]).frame = CGRectMake(8, 2, 302, 49);
	((UIView *)[elements objectAtIndex:4]).frame = CGRectMake(8, 59, 302, 49);
	((UIView *)[elements objectAtIndex:6]).frame = CGRectMake(8, 116, 302, 49);
	((UIView *)[elements objectAtIndex:8]).frame = CGRectMake(8, 173, 302, 49);
	
	
	if( [self.dataSource objectForKey:@"first_name"] != [NSNull null] && ![[self.dataSource objectForKey:@"first_name"] isEqual:@"<null>"] && ![[self.dataSource objectForKey:@"first_name"] isEqual:@""]){
		self.name.text =  [self.dataSource objectForKey:@"first_name"];
	}
	if( [self.dataSource objectForKey:@"mid_name"] != [NSNull null]  && ![[self.dataSource objectForKey:@"mid_name"] isEqual:@"<null>"]  && ![[self.dataSource objectForKey:@"mid_name"] isEqual:@""]){
		if( [self.name.text length] > 0 ){
			self.name.text = [self.name.text stringByAppendingFormat:@" %@", [self.dataSource objectForKey:@"mid_name"]];
		}else{
			self.name.text =  [self.dataSource objectForKey:@"mid_name"];
		}
	}
	if( [self.dataSource objectForKey:@"last_name"] != [NSNull null]  && ![[self.dataSource objectForKey:@"last_name"] isEqual:@"<null>"] && ![[self.dataSource objectForKey:@"last_name"] isEqual:@""]){
		if( [self.name.text length] > 0 ){
			self.name.text = [self.name.text stringByAppendingFormat:@" %@", [self.dataSource objectForKey:@"last_name"]];
		}else{
			self.name.text =  [self.dataSource objectForKey:@"last_name"];
		}
	}
	if( [self.dataSource objectForKey:@"degree"] != [NSNull null]  && ![[self.dataSource objectForKey:@"degree"] isEqual:@"<null>"]){
		self.name.text = [self.name.text stringByAppendingFormat:@", %@", [self.dataSource objectForKey:@"degree"]];
	}
    if( [self.dataSource objectForKey:@"spec_name"] != [NSNull null]  && ![[self.dataSource objectForKey:@"spec_name"] isEqual:@"<null>"]){
		self.speciality.text = [NSString stringWithFormat:@"%@",[self.dataSource objectForKey:@"spec_name"]];
	}
	else{
        self.speciality.text = [NSString stringWithFormat:@"%@",@""];
    }
	if( [self.dataSource objectForKey:@"insu_name"] != [NSNull null]  && ![[self.dataSource objectForKey:@"insu_name"] isEqual:@"<null>"]){
		self.gender.text = [NSString stringWithFormat:@"%@",[self.dataSource objectForKey:@"insu_name"]];
	}
	else{
        self.gender.text = [NSString stringWithFormat:@"%@",@""];
    }
    
	//self.gender.text = [NSString stringWithFormat:@"%@",[self.dataSource objectForKey:@"insu_name"]];
	NSLog(@"rank %@",[self.dataSource objectForKey:@"u_rank"]);
	//[self.rankbutton setTitle:[NSString stringWithFormat:@"Rank: %@",] forState:UIControlStateNormal];
	self.rankText.text = [self.dataSource objectForKey:@"u_rank"];
	
	[utils generateLargeRatingBar:self.urankView value:[self.dataSource objectForKey:@"grade"]];
	[utils generateQualityBar:self.qualityView value:[self.dataSource objectForKey:@"quality"]];
	[utils generateCostBar:self.costView value:[self.dataSource objectForKey:@"cost"]];
	[utils generatePatientExpBar:self.pexpView value:[NSString stringWithFormat:@"%d",[utils getRandomNumber:2 :4]]];

	self.avgRankInfo.text = [NSString stringWithFormat:@"Avg Rank: %@ based on %@ PCP votes",[self.dataSource objectForKey:@"avg_rank"],[self.dataSource objectForKey:@"rank_user_number"]];
	
	CGFloat heightDiff = 20.0f;
	//	//[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+100)]; 

	//specialist's details:
	CGFloat newY = 0.0f; 
//	NSArray *elements = [self.scrollView subviews];
	UILabel *spInfoLabel = (UILabel *)[elements objectAtIndex:3];
	if ([self.dataSource objectForKey:@"report_list"] != nil && [[self.dataSource objectForKey:@"report_list"] count] > 0) {
		UIView *reportView = (UIView *)[elements objectAtIndex:0];
		UILabel *reportLabel = (UILabel *)[elements objectAtIndex:1];
	
		reportView.hidden = NO;
		reportLabel.hidden = NO;

		NSArray *reportList = [self.dataSource objectForKey:@"report_list"];
		NSLog(@"report list count %d",[reportList count]);

		for(NSDictionary *dict in reportList){
			if ([dict objectForKey:@"rtime"] != [NSNull null] && ![[dict objectForKey:@"rtime"] isEqual:@"<null>"] && ![[dict objectForKey:@"rtime"] isEqual:@""]) {
				[self.scrollView addSubview: [self createContentLabel:[NSString stringWithFormat:@"%@",[dict objectForKey:@"rtime"]] ypos:&newY]];
				newY += heightDiff;
			}
			if ([dict objectForKey:@"text"] != [NSNull null] && ![[dict objectForKey:@"text"] isEqual:@"<null>"] && ![[dict objectForKey:@"text"] isEqual:@""]) {
				UILabel *lagLabel = [self createContentLabel:[NSString stringWithFormat:@"%@",[dict objectForKey:@"text"]] ypos:&newY];
				lagLabel.numberOfLines = 10; 
				UIFont* font = lagLabel.font;			
				CGSize constraintSize = CGSizeMake(lagLabel.frame.size.width, MAXFLOAT);
				CGSize labelSize = [lagLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
				lagLabel.frame = CGRectMake(lagLabel.frame.origin.x, lagLabel.frame.origin.y, lagLabel.frame.size.width, labelSize.height);
				newY += labelSize.height;
				[self.scrollView addSubview: lagLabel];
			}
			
		}
		reportView.frame = CGRectMake(reportView.frame.origin.x, reportView.frame.origin.y, reportView.frame.size.width, reportView.frame.size.height+newY);
		//[self.scrollView sendSubviewToBack:reportView];

		newY = reportView.frame.origin.y + reportView.frame.size.height + 8.0f;
		NSLog(@"after report %f",newY);
	}	
	CGFloat spviewY = newY;
	NSString *genderTxt = @"Female";
	if([[self.dataSource objectForKey:@"gender"] isEqual:@"1"]){
		genderTxt = @"Male";
	}
	[self.scrollView addSubview: [self createContentLabel:[NSString stringWithFormat:@"Sex: %@",genderTxt] ypos:&newY]];
	newY += heightDiff;

	if( [self.dataSource objectForKey:@"npi"] != [NSNull null] && ![[self.dataSource objectForKey:@"npi"] isEqual:@"<null>"] && ![[self.dataSource objectForKey:@"npi"] isEqual:@""]){
		[self.scrollView addSubview: [self createContentLabel:[NSString stringWithFormat:@"NPI: %@",[self.dataSource objectForKey:@"npi"]] ypos:&newY]];
		newY += heightDiff;
	}
	if( ![[self.dataSource objectForKey:@"language"] isEqual:@"English"] && [self.dataSource objectForKey:@"language"] != [NSNull null] && ![[self.dataSource objectForKey:@"language"] isEqual:@"<null>"] && ![[self.dataSource objectForKey:@"language"] isEqual:@""]){
		UILabel *lagLabel = [self createContentLabel:[NSString stringWithFormat:@"Language: %@",[self.dataSource objectForKey:@"language"]] ypos:&newY];
		lagLabel.numberOfLines = 2; 
		UIFont* font = lagLabel.font;			
		CGSize constraintSize = CGSizeMake(lagLabel.frame.size.width, MAXFLOAT);
		CGSize labelSize = [lagLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		lagLabel.frame = CGRectMake(lagLabel.frame.origin.x, lagLabel.frame.origin.y, lagLabel.frame.size.width, labelSize.height);
		newY += labelSize.height;
		[self.scrollView addSubview: lagLabel];
	}
	if( [self.dataSource objectForKey:@"doc_phone"] != [NSNull null] && ![[self.dataSource objectForKey:@"doc_phone"] isEqual:@"<null>"] && ![[self.dataSource objectForKey:@"doc_phone"] isEqual:@""]){
		[self.scrollView addSubview: [self createContentLabel:[NSString stringWithFormat:@"Phone: %@",[self.dataSource objectForKey:@"doc_phone"]] ypos:&newY]];
		newY += heightDiff;
		self.phone = [self.dataSource objectForKey:@"doc_phone"];
	}
	if( [self.dataSource objectForKey:@"doc_fax"] != [NSNull null] && ![[self.dataSource objectForKey:@"doc_fax"] isEqual:@"<null>"] && ![[self.dataSource objectForKey:@"doc_fax"] isEqual:@""]){
		[self.scrollView addSubview: [self createContentLabel:[NSString stringWithFormat:@"FAX: %@",[self.dataSource objectForKey:@"doc_fax"]] ypos:&newY]];
		newY += heightDiff;
	}
	if( [self.dataSource objectForKey:@"office_hour"] != [NSNull null] && ![[self.dataSource objectForKey:@"office_hour"] isEqual:@"<null>"] && ![[self.dataSource objectForKey:@"office_hour"] isEqual:@""]){
		UILabel *lagLabel = [self createContentLabel:[NSString stringWithFormat:@"Additional Office Hours: %@",[self processOfficeHour:[self.dataSource objectForKey:@"office_hour"]]] ypos:&newY];
		lagLabel.numberOfLines = 10; 
		UIFont* font = lagLabel.font;			
		CGSize constraintSize = CGSizeMake(lagLabel.frame.size.width, MAXFLOAT);
		CGSize labelSize = [lagLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		lagLabel.frame = CGRectMake(lagLabel.frame.origin.x, lagLabel.frame.origin.y, lagLabel.frame.size.width, labelSize.height);
		newY += labelSize.height;
		[self.scrollView addSubview: lagLabel];
	}	
	/*if( ![[self.dataSource objectForKey:@"rank_user_number"] isEqual:@"0"] && ![[self.dataSource objectForKey:@"avg_rank"] isEqual:@"0"]){
		[self.scrollView addSubview: [self createContentLabel:[NSString stringWithFormat:@"Average Ranking: %@ based on %@ PCP",[self.dataSource objectForKey:@"avg_rank"],[self.dataSource objectForKey:@"rank_user_number"]] ypos:&newY]];
		newY += heightDiff;
	}*/
	/*
	if( [[self.dataSource objectForKey:@"see_patient"]  isEqual:@"1"] ){
		[self.spView addSubview: [self createContentLabel:[NSString stringWithFormat:@"Sees in Patient"] ypos:&newY]];
		heightDiff += 20.0f;
		newY += heightDiff;
	}*/
	self.spView.frame = CGRectMake(self.spView.frame.origin.x, spviewY, self.spView.frame.size.width, self.spView.frame.size.height+(newY-spviewY));
	spInfoLabel.frame = CGRectMake(spInfoLabel.frame.origin.x, spviewY+4.0f, spInfoLabel.frame.size.width, spInfoLabel.frame.size.height);
	//[self.scrollView sendSubviewToBack:self.spView];
	//scrollHeight += newY;
	
	CGFloat nextViewY = self.spView.frame.origin.y+self.spView.frame.size.height+8.0f;
	self.pracInfo.frame = CGRectMake(self.pracInfo.frame.origin.x, nextViewY+4.0f, self.pracInfo.frame.size.width, self.pracInfo.frame.size.height);
	//self.uprankView.frame = CGRectMake(self.uprankView.frame.origin.x, nextViewY+30.0f, self.uprankView.frame.size.width, self.uprankView.frame.size.height);
	//[utils generateRatingBar:self.uprankView value:[self.dataSource objectForKey:@"up_rank"]];
	newY = nextViewY;
	if( [self.dataSource objectForKey:@"prac_name"] != [NSNull null] && ![[self.dataSource objectForKey:@"prac_name"] isEqual:@"<null>"] && ![[self.dataSource objectForKey:@"prac_name"] isEqual:@""]){
		
		NSArray *pracNames = [[self.dataSource objectForKey:@"prac_name"] componentsSeparatedByString:@"|"];
		NSArray *pracAddrs = [[self.dataSource objectForKey:@"add_line_1"] componentsSeparatedByString:@"|"];
		NSArray *pracRanks = [[self.dataSource objectForKey:@"up_rank"] componentsSeparatedByString:@"|"];
		UILabel *pracLabel;
		if ([pracNames count] > 1) {
			self.pracInfo.text = @"Practices:";
		}
		for(int i = 0; i<[pracNames count]; i++){

			NSString *pracName = [pracNames objectAtIndex:i];
			NSString *pracAddr = [pracAddrs objectAtIndex:i];
			NSString *pracRank = [pracRanks objectAtIndex:i];
			
			if( i == 0){
				pracLabel = [self createContentLabel:[NSString stringWithFormat:@"%@",pracName] ypos:&newY];
			}else {
				pracLabel = [self createContentLabel:[NSString stringWithFormat:@"\n%@",pracName] ypos:&newY];				
			}
			pracLabel.numberOfLines = 10;
			[self.scrollView addSubview: pracLabel];
			UIFont* font = pracLabel.font;			
			CGSize constraintSize = CGSizeMake(pracLabel.frame.size.width, MAXFLOAT);
			CGSize labelSize = [pracLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
			pracLabel.frame = CGRectMake(pracLabel.frame.origin.x, pracLabel.frame.origin.y, pracLabel.frame.size.width, labelSize.height);
			newY += labelSize.height;

			if( pracAddr != [NSNull null] && ![pracAddr isEqual:@""]){
				pracLabel = [self createContentLabel:[NSString stringWithFormat:@"%@",pracAddr] ypos:&newY];
				pracLabel.numberOfLines = 10;
				[self.scrollView addSubview: pracLabel];
				UIFont* font = pracLabel.font;			
				CGSize constraintSize = CGSizeMake(pracLabel.frame.size.width, MAXFLOAT);
				CGSize labelSize = [pracLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
				pracLabel.frame = CGRectMake(pracLabel.frame.origin.x, pracLabel.frame.origin.y, pracLabel.frame.size.width, labelSize.height);
				newY += labelSize.height;
			}
			if( pracRank != [NSNull null] && ![pracRank isEqual:@""]){
				[self.scrollView addSubview: [self createContentLabel:[NSString stringWithFormat:@"PA Rank: %@",pracRank] ypos:&newY]];
				newY += heightDiff;
			}
		}	
		
	}
	self.pracView.frame = CGRectMake(self.pracView.frame.origin.x, nextViewY, self.pracView.frame.size.width, self.pracView.frame.size.height+(newY - nextViewY));
	//[self.scrollView sendSubviewToBack:self.pracView];

	nextViewY = self.pracView.frame.origin.y+self.pracView.frame.size.height+8.0f;
	self.hosInfo.frame = CGRectMake(self.hosInfo.frame.origin.x, nextViewY+4.0f, self.hosInfo.frame.size.width, self.hosInfo.frame.size.height);
	newY = nextViewY;
	if( [self.dataSource objectForKey:@"hosp_name"] != [NSNull null] && ![[self.dataSource objectForKey:@"hosp_name"] isEqual:@""]){
		NSArray *hosNames = [[self.dataSource objectForKey:@"hosp_name"] componentsSeparatedByString:@"|"];
		NSArray *seePatients = [[self.dataSource objectForKey:@"see_patient"] componentsSeparatedByString:@"|"];
		
		if ([hosNames count] > 1) {
			self.hosInfo.text = @"Hospitals (Sees inpatients):";
		}
		for(int i=0; i<[hosNames count]; i++){
			NSString *hosName = [hosNames objectAtIndex:i];
			NSString *sp = [seePatients objectAtIndex:i];
			if ([sp isEqual:@"1"]) {
				hosName = [hosName stringByAppendingFormat:@" (Y)"];
			}else {
				hosName = [hosName stringByAppendingFormat:@" (N)"];
			}
			
			UILabel *hosLabel = [self createContentLabel:[NSString stringWithFormat:@"%@",hosName] ypos:&newY];
			hosLabel.numberOfLines = 10;
			[self.scrollView addSubview: hosLabel];
			UIFont* font = hosLabel.font;			
			CGSize constraintSize = CGSizeMake(hosLabel.frame.size.width, MAXFLOAT);
			CGSize labelSize = [hosLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
			hosLabel.frame = CGRectMake(hosLabel.frame.origin.x, hosLabel.frame.origin.y, hosLabel.frame.size.width, labelSize.height);
			newY += labelSize.height;
		}	
	}
	self.hosView.frame = CGRectMake(self.hosView.frame.origin.x, nextViewY, self.hosView.frame.size.width, self.hosView.frame.size.height+(newY - nextViewY));
	//[self.scrollView sendSubviewToBack:self.hosView];

	nextViewY = self.hosView.frame.origin.y+self.hosView.frame.size.height+8.0f;
	self.noteInfo.frame = CGRectMake(self.noteInfo.frame.origin.x, nextViewY+4.0f, self.noteInfo.frame.size.width, self.noteInfo.frame.size.height);
	newY = nextViewY;
	if( [self.dataSource objectForKey:@"note"] != [NSNull null] && ![[self.dataSource objectForKey:@"note"] isEqual:@""]){
		[self.scrollView addSubview: [self createContentLabel:[NSString stringWithFormat:@"%@",[self.dataSource objectForKey:@"note"]] ypos:&newY]];
		newY += heightDiff;
	}
	self.noteView.frame = CGRectMake(self.noteView.frame.origin.x, nextViewY, self.noteView.frame.size.width, self.noteView.frame.size.height+(newY - nextViewY));
	//[self.scrollView sendSubviewToBack:self.noteView];
	
	CGFloat scrollHeight = self.noteInfo.frame.origin.y+self.noteInfo.frame.size.height+30.0f;
	[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, scrollHeight)];
	
	if (self.isReportChangeCalled) {
		[self changeReportBtnClicked:nil];
	}
}

-(UILabel *)createContentLabel:(NSString *)labelString ypos:(CGFloat *)yVal {
	
	UILabel *label = [[[UILabel alloc] init] autorelease];
	NSLog(@"newY ... %f",*yVal);
	label.frame = CGRectMake(17, (30.0f + *yVal), 283, 20);
    label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    label.text = labelString;
	return label;
}

- (IBAction) rankButtonClicked: (id)sender{
	
	rankBar = [[RatingWidget alloc] initRatingWidget:self.name.text delegate:self];
	[rankBar show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if ([alertView isKindOfClass:[RatingWidget class]] && !rankBar.busy) {
		if( buttonIndex == rankBar.cancelButtonIndex ){
			[rankBar dismissWidget];
		}else{
			[rankBar isWorking:YES];
			[NSThread detachNewThreadSelector:@selector(rankUpdateReqThread) toTarget:self withObject:nil];
		}
	}
    
}


- (void) rankUpdateReqThread{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
	
	NSDictionary *user = [dao getCurrentUser];
	
	if(self.isSearchFromOnline){
		NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"userDocRank/rank?doc_id=%@&user_id=%@&rank=%d",[self.dataSource objectForKey:@"id"], [user objectForKey:@"id"], [rankBar getRank]];
		NSLog(@"url :%@",serverUrl);
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
	
		NSLog(@"response : %@",responseString);
	
		if ([responseString isEqual:@"saved"] || [responseString isEqual:@"rank updated"]) {
			[self updateDataSource:[rankBar getRank]];
			[utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
		}else{
			[utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];
		}
	}else {
		if( [dao updateDoctorRank:[[self.dataSource objectForKey:@"id"] intValue] rank:[rankBar getRank]] ){
			[self updateDataSource:[rankBar getRank]];
			[utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
		}else {
			[utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];	
		}		
		
	}

	[rankBar isWorking:NO];
	[rankBar dismissWidget];
	[pool release];
}

- (void) updateDataSource:(int)rankValue{
	//[utils generateRatingBar:self.urankView value:[NSString stringWithFormat:@"%d",rankValue]];
//	[self.rankbutton setTitle:[NSString stringWithFormat:@"Rank: %d",rankValue] forState:UIControlStateNormal];
	self.rankText.text = [NSString stringWithFormat:@"%d", rankValue];
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

- (IBAction) backToDocList: (id)sender{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) callDoctor: (id)sender{
	[utils dialANumber:self.phone view:self.view];
}


- (IBAction) searchAgainClicked: (id)sender{
	if ([self.parentViewController.parentViewController isKindOfClass:[filterViewController class]]) {
		[self.parentViewController.parentViewController dismissModalViewControllerAnimated:YES];
	}else {
		[self.parentViewController.parentViewController.parentViewController dismissModalViewControllerAnimated:YES];	
	}
}

- (IBAction) changeReportBtnClicked: (id)sender{
	NSLog(@"Change report button clicked");
	
	self.reportBar.hidden = NO;
	self.reportText.text = @"";
	NSArray *elements = [self.reportOptView subviews];
	NSArray *indexes = [utils getReportOptionIndexes];
	for( NSString *indxStr in indexes ){
		UIImageView *imgView = (UIImageView *)[elements objectAtIndex:[indxStr intValue]];
		imgView.tag = 0;
		[imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_not_ticked" ofType:@"png"]]];	
	}		
}

- (IBAction) closeReportPopup: (id)sender{
	self.reportTextBtn.hidden = YES;
	[self.reportText resignFirstResponder];
	self.reportBar.hidden = YES;

}

- (IBAction) saveAndCloseReportPopup: (id)sender{

	[self performSelectorInBackground:@selector(viewLoadingScreen) withObject:nil];
	NSDictionary *user = [dao getCurrentUser];
	
	NSString *content = [self getReportContent];
	
	if(![content isEqual:@""] && content != NULL){
		if (![dao updateDoctorChangeReport:[self.dataSource objectForKey:@"id"] userId:[user objectForKey:@"id"] content:content]) {
			NSLog(@"unable to store change report for doctor %@",[self.dataSource objectForKey:@"id"]);
		}
		[self.dataSource setValue:[dao getReportListByDoctor:[self.dataSource objectForKey:@"id"]] forKey:@"report_list"];
	}
	
	[self reloadView];
	
	[self closeReportPopup:nil];
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	//[NSThread detachNewThreadSelector:@selector() toTarget:self withObject:nil];	
}


-(void)textViewDidBeginEditing:(UITextView *)textView{
	NSLog(@"textViewDidBeginEditing");
	self.reportTextBtn.hidden = NO;
}


- (IBAction) hideReportPopupKeyboard: (id)sender{

	[self.reportText resignFirstResponder];
	self.reportTextBtn.hidden = YES;
}

- (NSString *)getReportContent{

	NSString *content = @"";
	NSArray *elements = [self.reportOptView subviews];
	NSArray *indexes = [utils getReportOptionIndexes];
	for( NSString *indxStr in indexes ){
		int index = [indxStr intValue];
		if ([(UIImageView *)[elements objectAtIndex:index] tag] == 1) {
			if ([content isEqual:@""]) {
				content = [utils getReportOptionContent:index];
			}else {
				content = [content stringByAppendingFormat:@" \n%@",[utils getReportOptionContent:index]];
			}

		}
	}
	self.reportText.text = [self.reportText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (self.reportText.text != NULL && ![self.reportText.text isEqual:@""] ) {
		if ([content isEqual:@""]) {
			content = self.reportText.text;
		}else {
			content = [content stringByAppendingFormat:@" \n%@",self.reportText.text];
		}
	}
	return content;
}


- (IBAction) reportOptionClicked: (id)sender{
	UIButton *button = (UIButton *)sender;
	
	NSArray *elements = [self.reportOptView subviews];
	UIImageView *imgView = (UIImageView *)[elements objectAtIndex:button.tag];
	if( imgView.tag == 0 ){
		imgView.tag = 1;
		[imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_ticked" ofType:@"png"]]];
	}else {
		imgView.tag = 0;
		[imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_not_ticked" ofType:@"png"]]];		
	}

}


- (void) viewLoadingScreen{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;
	[pool drain];
}


- (NSString *) processOfficeHour:(NSString *)cvalue {
	NSArray *values = [cvalue componentsSeparatedByString:@","];
	NSString *weekendText = @"";
	NSString *eveningText = @"";
	
	for(NSString *val in values){
		if ([val isEqual:@"st"]) {
			if ([weekendText isEqual:@""]) {
				weekendText = @"Saturday";
			}else {
				weekendText = [weekendText stringByAppendingFormat:@", Saturday"];
			}
		}else if([val isEqual:@"sn"]) {
			if ([weekendText isEqual:@""]) {
				weekendText = @"Sunday";
			}else {
				weekendText = [weekendText stringByAppendingFormat:@", Sunday"];
			}
		}else if([val isEqual:@"mn"]) {
			if ([eveningText isEqual:@""]) {
				eveningText = @"Monday";
			}else {
				eveningText = [eveningText stringByAppendingFormat:@", Monday"];
			}
			
		}else if([val isEqual:@"tu"]) {

			if ([eveningText isEqual:@""]) {
				eveningText = @"Tuesday";
			}else {
				eveningText = [eveningText stringByAppendingFormat:@", Tuesday"];
			}
		}else if([val isEqual:@"wd"]) {
			if ([eveningText isEqual:@""]) {
				eveningText = @"Wednesday";
			}else {
				eveningText = [eveningText stringByAppendingFormat:@", Wednesday"];
			}
			
		}else if([val isEqual:@"th"]) {
			if ([eveningText isEqual:@""]) {
				eveningText = @"Thursday";
			}else {
				eveningText = [eveningText stringByAppendingFormat:@", Thursday"];
			}
			
		}else if([val isEqual:@"fd"]) {
			if ([eveningText isEqual:@""]) {
				eveningText = @"Friday";
			}else {
				eveningText = [eveningText stringByAppendingFormat:@", Friday"];
			}
		}
	}
	
	NSString *content = @"";
	
	if (![weekendText isEqual:@""]) {
		content = [NSString stringWithFormat:@"Weekend- %@.",weekendText];
	}
	if (![eveningText isEqual:@""]) {
		if (![content isEqual:@""]) {
			content = [content stringByAppendingFormat:@" Evening- %@.",eveningText];
		}else {
			content = [content stringByAppendingFormat:@"Evening- %@.",eveningText];			
		}
	}
	
	return content;
	
	
}


- (void)dealloc {
	[avgRankInfo release];
	[pexpView release];
	[rankText release];
	[reportTextBtn release];
	[reportOptView release];
	[reportText release];
	[qualityView release];
	[costView release];
	[rankbutton release];
	[basicView release];
	[reportBar release];
	[spinnerBg release];
	[rankBar release];
	[urankView release];
	[uprankView release];
	[pracInfo release];
	[hosInfo release];
	[noteInfo release];
	[spView release];
	[pracView release];
	[hosView release];
	[noteView release];
	[scrollView release];
	[spinner release];
	[dataSource release];
	[dId release];
	[phone release];
	[name release];
	[speciality release];
	[degree release];
	[gender release];
	[dao release];
    [super dealloc];
}


@end
