//
//  doctorDetailViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "doctorDetailViewController.h"


@implementation doctorDetailViewController
@synthesize delegate;
@synthesize name, speciality, degree, gender, spinner, phone, dId, dataSource, isSearchFromOnline, scrollView, basicView, rankbutton,inactiveBtn;

@synthesize spView, pracView, hosView, noteView, pracInfo, hosInfo, noteInfo, urankView, uprankView, alert, spinnerBg, reportBar, isReportChangeCalled;

@synthesize qualityView, costView, reportText, reportOptView, reportTextBtn, rankText, pexpView, avgRankInfo;
@synthesize referBar,referText,referTextBtn,initialTextField,patientEmailTextField,referOptView,rank,paRank, rankBtnList, unRankedImage, rankedImage, busy;

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
    [self.dataSource setValue:[dao getReportListByDoctor:[self.dataSource objectForKey:@"id"]] forKey:@"report_list"];
	NSLog(@"After dao calll.......");
	[self.dataSource setValue:[dao getReportListByDoctor:self.dId] forKey:@"report_list"];
	NSLog(@"After dao calll.......1111");
	[self reloadView];		
	NSLog(@"After dao calll.......2222");
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	self.inactiveBtn.hidden = YES;
}


- (void) triggerAsyncronousRequest: (NSString *)url {
	
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;
    self.inactiveBtn.hidden = NO;
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
    self.inactiveBtn.hidden = YES;
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
    BOOL isEmpty = ([[self.dataSource objectForKey:@"report_list"] count] == 0);
	if ([self.dataSource objectForKey:@"report_list"] != nil && !isEmpty) {
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
		//NSArray *pracRanks = [[self.dataSource objectForKey:@"up_rank"] componentsSeparatedByString:@"|"];
		UILabel *pracLabel;
		if ([pracNames count] > 1) {
			self.pracInfo.text = @"Practices:";
		}
		for(int i = 0; i<[pracNames count]; i++){

			NSString *pracName = [pracNames objectAtIndex:i];
            NSString *pracAddr = @"";
            if(i<[pracAddrs count]){
                pracAddr = [pracAddrs objectAtIndex:i];
			}
            //NSString *pracRank = [pracRanks objectAtIndex:i];
			
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
			//if( pracRank != [NSNull null] && ![pracRank isEqual:@""]){
				//[self.scrollView addSubview: [self createContentLabel:[NSString stringWithFormat:@"PA Rank: %@",pracRank] ypos:&newY]];
				//newY += heightDiff;
			//}
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
			//NSString *sp = [seePatients objectAtIndex:i];
			//if ([sp isEqual:@"1"]) {
			//	hosName = [hosName stringByAppendingFormat:@" (Y)"];
			//}else {
			//	hosName = [hosName stringByAppendingFormat:@" (N)"];
			//}
			
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
	
	//rankBar = [[NewRatingWidget alloc] initNewRatingWidget:self.name.text delegate:self];
	//[rankBar show];
    NSString *docPARank =  [self.dataSource objectForKey:@"pa_rank"];
    NSMutableDictionary *docDic = [NSMutableDictionary dictionary];
    [docDic setValue:self.name.text forKey:@"docName"];
    [docDic setValue:self.rankText.text forKey:@"docRank"];
    [docDic setValue:docPARank forKey:@"docPARank"];
	[self launchDialog:docDic];
	

}
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if ([alertView isKindOfClass:[NewRatingWidget class]] && !rankBar.busy) {
		if( buttonIndex == 0 ){
			[rankBar dismissWidget];
		}else{
			[rankBar isWorking:YES];
			[NSThread detachNewThreadSelector:@selector(rankUpdateReqThread) toTarget:self withObject:nil];
		}
	}
    
}
*/
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
    if ([alertView isKindOfClass:[CustomIOS7AlertView class]] && !self.busy) {
		if( buttonIndex == 0 ){
			[alertView close];
            [alert release];
		}else{
			self.busy = YES;
			[NSThread detachNewThreadSelector:@selector(rankUpdateReqThread) toTarget:self withObject:nil];
            [alert close];
            [alert release];
		}
	}
    //NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    
    
    
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


- (void) rankUpdateReqThread{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary *user = [dao getCurrentUser];
    if([[user objectForKey:@"allow_pa_rank"] integerValue]==0){
    
        if(self.isSearchFromOnline){
            NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"userDocRank/rank?doc_id=%@&user_id=%@&rank=%d",[self.dataSource objectForKey:@"id"], [user objectForKey:@"id"], self.rank];
            NSLog(@"url :%@",serverUrl);
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
            
            NSLog(@"response : %@",responseString);
            
            if ([responseString isEqual:@"saved"] || [responseString isEqual:@"rank updated"]) {
                [self updateDataSource:self.rank];
                [utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
            }else{
                [utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];
            }
        }else {
            if( [dao updateDoctorRank:[[self.dataSource objectForKey:@"id"] intValue] rank:self.rank] ){
                [self updateDataSource:self.rank];
                [utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
            }else {
                [utils showAlert:@"Warning !!" message:@"Couldn't update rank, please try again later." delegate:self];	
            }	
            
        }
    }
    else{
        int docId = [[self.dataSource objectForKey:@"id"] integerValue];
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
                [self updatePARankInDataSource:self.paRank];
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
                [self updateDataSource:self.rank];
                
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
                [self updatePARankInDataSource:self.paRank];
                //[utils showAlert:@"Confirmation!!" message:@"Rank has been updated." delegate:self];
            }else {
                err=1;
                //[utils showAlert:@"Warning !!" message:@"Couldn't update PA rank, please try again later." delegate:self];
            }
            
            if( [dao updateDoctorRank:docId rank:self.rank] ){
                [self updateDataSource:self.rank];
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
    
    [pool release];
}

- (void) updateDataSource:(int)rankValue{
	
    [self.dataSource setValue:[NSString stringWithFormat:@"%d", rankValue] forKey:@"u_rank"];
	self.rankText.text = [NSString stringWithFormat:@"%d", rankValue];
}

- (void) updatePARankInDataSource:(int)rankValue{
	//[self.dataSource objectForKey:@"pa_rank"]
    [self.dataSource setValue:[NSString stringWithFormat:@"%d", rankValue] forKey:@"pa_rank"];
	//self.rankText.text = [NSString stringWithFormat:@"%d", rankValue];
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
    if([self.delegate respondsToSelector:@selector(doctorDetailViewControllerDismissed:)])
    {
        NSString *docPARank =  [self.dataSource objectForKey:@"pa_rank"];
        NSMutableDictionary *docDic = [NSMutableDictionary dictionary];
        [docDic setValue:self.dId forKey:@"docId"];
        [docDic setValue:self.rankText.text forKey:@"docRank"];
        [docDic setValue:docPARank forKey:@"docPARank"];
        [docDic setValue:@"0" forKey:@"closeList"];
        [self.delegate doctorDetailViewControllerDismissed:docDic];
    }
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) callDoctor: (id)sender{
	[utils dialANumber:self.phone view:self.view];
}


- (IBAction) searchAgainClicked: (id)sender{
	/*
     if ([self.parentViewController.parentViewController isKindOfClass:[filterViewController class]]) {
		[self.parentViewController.parentViewController dismissModalViewControllerAnimated:YES];
	}else {
       // [self dismissModalViewControllerAnimated:YES];
		[self.parentViewController.parentViewController.parentViewController dismissModalViewControllerAnimated:YES];
	}
     */
    if([self.delegate respondsToSelector:@selector(doctorDetailViewControllerDismissed:)])
    {
        NSString *docPARank =  [self.dataSource objectForKey:@"pa_rank"];
        NSMutableDictionary *docDic = [NSMutableDictionary dictionary];
        [docDic setValue:self.dId forKey:@"docId"];
        [docDic setValue:self.rankText.text forKey:@"docRank"];
        [docDic setValue:docPARank forKey:@"docPARank"];
        [docDic setValue:@"1" forKey:@"closeList"];
        [self.delegate doctorDetailViewControllerDismissed:docDic];
    }
    [self dismissModalViewControllerAnimated:NO];
}

- (IBAction) changeReferBtnClicked: (id)sender{
	NSLog(@"Change refer button clicked");
	
	self.referBar.hidden = NO;
	self.referText.text = @"";
	NSArray *elements = [self.referOptView subviews];
	
	UIImageView *imgView = (UIImageView *)[elements objectAtIndex:2];
    imgView.tag = 0;
    [imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_not_ticked" ofType:@"png"]]];
}

- (IBAction) changeReportBtnClicked: (id)sender{
	NSLog(@"Change report button clicked");
	//self.inactiveBtn.hidden = NO;
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

- (IBAction) closeReferPopup: (id)sender{
	self.referTextBtn.hidden = YES;
    self.initialTextField.text = @"";
    self.patientEmailTextField.text = @"";
	[self.referText resignFirstResponder];
	self.referBar.hidden = YES;
    [self hideReferPopupWithKeyboard];
}

- (IBAction) saveAndCloseReportPopup: (id)sender{

	[self performSelectorInBackground:@selector(viewLoadingScreen) withObject:nil];
	NSDictionary *user = [dao getCurrentUser];
	
	NSString *content = [self getReportContent];
	
	if(![content isEqual:@""] && content != NULL){
		if (![dao updateDoctorChangeReport:[self.dataSource objectForKey:@"id"] userId:[user objectForKey:@"id"] content:content]) {
			NSLog(@"Unable to store change report for doctor %@",[self.dataSource objectForKey:@"id"]);
		}
        /*@try{
            NSString *str = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"doctor/report?ref_doc_id=%@&doc_id=%@&report=%@&time=%@", [self.dataSource objectForKey:@"id"], [user objectForKey:@"id"], content, [utils getFormatedStringFromDate:[NSDate date]]];
            NSString * encodedParam = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:encodedParam];
            NSLog(str);
            NSLog(encodedParam);
            str=[self stringWithUrl:url];
            NSLog(str);
            if(![str isEqual:@"saved"]){
                NSLog(@"Unable to store change report for doctor %@ at server",[self.dataSource objectForKey:@"id"]);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        */ 
		[self.dataSource setValue:[dao getReportListByDoctor:[self.dataSource objectForKey:@"id"]] forKey:@"report_list"];
	}
	
	[self reloadView];
	
	[self closeReportPopup:nil];
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
    self.inactiveBtn.hidden = YES;
	//[NSThread detachNewThreadSelector:@selector() toTarget:self withObject:nil];	
}

- (IBAction) saveAndCloseReferPopup: (id)sender{
    
	[self performSelectorInBackground:@selector(viewLoadingScreen) withObject:nil];
	NSDictionary *user = [dao getCurrentUser];
	
	NSString *content = [self getReferContent];
	
	if(![content isEqual:@""] && content != NULL){
		@try{
            NSString *str = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"doctor/referral2?doc_id=%@&ref_doc_id=%@&%@", [user objectForKey:@"doc_id"], [self.dataSource objectForKey:@"id"], content];
            NSString * encodedParam = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:encodedParam];
            NSLog(str);
            NSLog(encodedParam);
            str=[self stringWithUrl:url];
            NSLog(str);
            if(![str isEqual:@"saved"]||[str isEqual:@""]){
                [utils showAlert:@"Error !!" message:@"Unable to store referal data." delegate:self];
                NSLog(@"Unable to store referal data for doctor %@ at server",[self.dataSource objectForKey:@"id"]);
                [self.view endEditing:YES];
                [self.spinner stopAnimating];
                self.spinner.hidden = YES;
                self.spinnerBg.hidden = YES;
                self.inactiveBtn.hidden = YES;
                return;
            }
            else{
                [utils showAlert:@"Success !!" message:@"Successfully referred." delegate:self];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
		
	}
	else{
        [self.view endEditing:YES];
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
        self.spinnerBg.hidden = YES;
        self.inactiveBtn.hidden = YES;
        return;
    }
    [self hideReferPopupWithKeyboard];
	[self reloadView];
	[self.view endEditing:YES];
	[self closeReferPopup:nil];
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
    self.inactiveBtn.hidden = YES;
	//[NSThread detachNewThreadSelector:@selector() toTarget:self withObject:nil];
}

- (NSString *)stringWithUrl:(NSURL *)url
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:30];
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    
    // Construct a String around the Data from the response
    return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
	NSLog(@"textViewDidBeginEditing");
	self.reportTextBtn.hidden = NO;
    //self.referTextBtn.hidden = NO;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
	
    self.referTextBtn.hidden = NO;
    return YES;
}
- (BOOL)hideReferPopupWithKeyboard{
    [self.view endEditing:YES];
    [self.initialTextField resignFirstResponder];
    [self.patientEmailTextField resignFirstResponder];
	//[self.referText resignFirstResponder];
	self.referTextBtn.hidden = YES;
}

- (IBAction) hideReportPopupKeyboard: (id)sender{

	[self.reportText resignFirstResponder];
	self.reportTextBtn.hidden = YES;
}

- (IBAction) hideReferPopupKeyboard: (id)sender{
    
	[self.initialTextField resignFirstResponder];
    [self.patientEmailTextField resignFirstResponder];
	//[self.referText resignFirstResponder];
	self.referTextBtn.hidden = YES;
}


- (NSString *)getReferContent{
    
	NSString *content = @"";
    NSArray *elements = [self.referOptView subviews];
    if ([(UIImageView *)[elements objectAtIndex:2] tag] == 1) {
        if ([content isEqual:@""]) {
            content = @"insurance=1";
        }else {
            content = [content stringByAppendingFormat:@"&%@",@"insurance=1"];
        }
        
    }
    else{
        if ([content isEqual:@""]) {
            content = @"insurance=0";
        }else {
            content = [content stringByAppendingFormat:@"&%@",@"insurance=0"];
        }
    }
    
    self.initialTextField.text = [self.initialTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.patientEmailTextField.text = [self.patientEmailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (self.initialTextField.text != NULL && ![self.initialTextField.text isEqual:@""] ) {
		if ([content isEqual:@""]) {
			content = [content stringByAppendingFormat:@"initial=%@",self.initialTextField.text];
		}else {
			content = [content stringByAppendingFormat:@"&initial=%@",self.initialTextField.text];
		}
	}
    else{
        [utils showAlert:@"Error !!" message:@"No initial given." delegate:self];
        return @"";
    }
    if (self.patientEmailTextField.text != NULL && ![self.patientEmailTextField.text isEqual:@""] ) {
        if (![utils performSelector:@selector(validateEmail:) withObject:self.patientEmailTextField.text]) {
            [utils showAlert:@"Error !!" message:@"Please provide a valid email address." delegate:self];
            return @"";
        }
		if ([content isEqual:@""]) {
			content = [content stringByAppendingFormat:@"email=%@",self.patientEmailTextField.text];
		}else {
			content = [content stringByAppendingFormat:@"&email=%@",self.patientEmailTextField.text];
		}
	}
    else{
        //[utils showAlert:@"Error !!" message:@"No patient email given." delegate:self];
        if ([content isEqual:@""]) {
			content = [content stringByAppendingFormat:@"email=%@",@""];
		}else {
			content = [content stringByAppendingFormat:@"&email=%@",@""];
		}
        return content;
    }
    
	return content;
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
- (IBAction) referOptionClicked: (id)sender{
	UIButton *button = (UIButton *)sender;
	
	NSArray *elements = [self.referOptView subviews];
	UIImageView *imgView = (UIImageView *)[elements objectAtIndex:2];
	if( imgView.tag == 0 ){
		imgView.tag = 1;
		[imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_ticked" ofType:@"png"]]];
	}else {
		imgView.tag = 0;
		[imgView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"checkbox_not_ticked" ofType:@"png"]]];
	}
    
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
    self.inactiveBtn.hidden = NO;
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
    [referOptView release];
    [initialTextField release];
    [patientEmailTextField release];
	[reportTextBtn release];
    [referTextBtn release];
	[reportOptView release];
	[reportText release];
    [referText release];
	[qualityView release];
	[costView release];
	[rankbutton release];
	[basicView release];
	[reportBar release];
    [referBar release];
	[spinnerBg release];
	[alert release];
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
    [rankedImage release];
	[unRankedImage release];
	[rankBtnList release];
    [super dealloc];
}


@end
