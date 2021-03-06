//
//  setupViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "setupViewController.h"


@implementation setupViewController

@synthesize pname, addr, pracBtn, hosBtn, insBtn, spBtn, cntyBtn, docCountText, pracAddBtn, hosAddBtn, spinner, userData, inactiveBtn, scrollView, spinnerBg, spinnerText,autoTimer,dateString;

int actionSheetType = 0;

- (void)loadView{
	[super loadView];
	dao = [[setupDao alloc] init];
    baseDao = [[BaseDao alloc] init];
    [NSThread detachNewThreadSelector:@selector(startupSyncThread) toTarget:self withObject:nil];
	self.userData = [dao getCurrentUserPracticeOrHospital];
	if( self.userData != nil ){
		
		self.pname.text = [NSString stringWithFormat:@"%@ %@", [self.userData objectForKey:@"last_name"], [self.userData objectForKey:@"first_name"]];
		
		/*
		 UIFont* font = self.pname.font;			
		 CGSize constraintSize = CGSizeMake(self.pname.frame.size.width, MAXFLOAT);
		 CGSize labelSize = [self.pname.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		 //CGFloat heightDiff = (labelSize.height - self.pname.frame.size.height);
		 self.pname.frame = CGRectMake(self.pname.frame.origin.x, self.pname.frame.origin.y, self.pname.frame.size.width, labelSize.height);
		 */
		
		NSString *addText = [self.userData objectForKey:@"prac_name"];
		
		if (![[self.userData objectForKey:@"county_name"] isEqual:@""]) {
			addText = [addText stringByAppendingFormat:@", %@", [self.userData objectForKey:@"county_name"]];
		}
		if (![[self.userData objectForKey:@"state_code"] isEqual:@""]) {
			addText = [addText stringByAppendingFormat:@" %@", [self.userData objectForKey:@"state_code"]];
		}
		
		self.addr.text = addText;
		
		UIFont* font = self.addr.font;			
		CGSize constraintSize = CGSizeMake(self.addr.frame.size.width, MAXFLOAT);
		CGSize labelSize = [self.addr.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		CGFloat heightDiff = (labelSize.height - self.addr.frame.size.height);
		self.pname.frame = CGRectMake(self.pname.frame.origin.x, self.pname.frame.origin.y-heightDiff, self.pname.frame.size.width, self.pname.frame.size.height);
		self.addr.frame = CGRectMake(self.addr.frame.origin.x, self.addr.frame.origin.y-heightDiff, self.addr.frame.size.width, labelSize.height);
		
		
		
	}
	[self updateRowCounts];
	
	[self basicMode];
	
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];

}


- (IBAction) switchSettingModeClicked:(id)sender{
	
	NSArray *elements = [self.scrollView subviews];
	UILabel *labelBlock = (UILabel *)[elements objectAtIndex:25];
	UIButton *cbtnBlock = (UIButton *)[elements objectAtIndex:24];
	
	if ([cbtnBlock.titleLabel.text isEqual:@">"]) {
		
		cbtnBlock.titleLabel.text = @"<";
		labelBlock.text = @"Switch to Basic Settings";
		
		[self advanceMode];
		
	}else {

		cbtnBlock.titleLabel.text = @">";
		labelBlock.text = @"Switch to Advance Settings";
		
		[self basicMode];
		
	}

}

- (void) advanceMode{
	
	NSArray *elements = [self.scrollView subviews];
	//NSLog(@"%d",[elements count]);
	[[elements objectAtIndex:27] performSelector:@selector(setHidden:) withObject:YES];
	[[elements objectAtIndex:28] performSelector:@selector(setHidden:) withObject:YES];
	[[elements objectAtIndex:29] performSelector:@selector(setHidden:) withObject:YES];
	[[elements objectAtIndex:30] performSelector:@selector(setHidden:) withObject:YES];
	
	for (int i=0; i<12; i++) {
		[[elements objectAtIndex:i] performSelector:@selector(setHidden:) withObject:NO];
	}
	
	if ([[self.userData objectForKey:@"is_PCP"] intValue]) {
		
		self.pracAddBtn.hidden = YES;
		
	}else {
		UIView *pracView = (UIView *)[elements objectAtIndex:0];
		UIView *hosView = (UIView *)[elements objectAtIndex:3];
		self.hosAddBtn.hidden = YES;
		//CGFloat pracX = self.hosBtn.frame.origin.x;
		//CGFloat pracY = self.hosBtn.frame.origin.y;		
		pracView.frame = CGRectMake(pracView.frame.origin.x, 50, pracView.frame.size.width, pracView.frame.size.height);
		self.pracBtn.frame = CGRectMake(self.pracBtn.frame.origin.x, 50, self.pracBtn.frame.size.width, self.pracBtn.frame.size.height);
		self.pracAddBtn.frame = CGRectMake(self.hosAddBtn.frame.origin.x, self.hosAddBtn.frame.origin.y, self.pracAddBtn.frame.size.width, self.pracAddBtn.frame.size.height);
		hosView.frame = CGRectMake(hosView.frame.origin.x, 7, hosView.frame.size.width, hosView.frame.size.height);
		self.hosBtn.frame = CGRectMake(self.hosBtn.frame.origin.x, 7, self.hosBtn.frame.size.width, self.hosBtn.frame.size.height);
	}
	
	UIView *rootBlock = (UIView *)[elements objectAtIndex:9];
	CGFloat newY = rootBlock.frame.origin.y + rootBlock.frame.size.height + 5;

	
	UIView *viewBlock = (UIView *)[elements objectAtIndex:12];
	UIButton *cbtnBlock = (UIButton *)[elements objectAtIndex:13];
	UIButton *btnBlock = (UIButton *)[elements objectAtIndex:14];
	
	viewBlock.frame = CGRectMake(viewBlock.frame.origin.x, newY, viewBlock.frame.size.width, viewBlock.frame.size.height);
	cbtnBlock.frame = CGRectMake(cbtnBlock.frame.origin.x, viewBlock.frame.origin.y, cbtnBlock.frame.size.width, cbtnBlock.frame.size.height);
	btnBlock.frame = CGRectMake(btnBlock.frame.origin.x, viewBlock.frame.origin.y, btnBlock.frame.size.width, btnBlock.frame.size.height);
	newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 5;
	
	viewBlock = (UIView *)[elements objectAtIndex:15];
	UILabel *labelBlock = (UILabel *)[elements objectAtIndex:16];
	cbtnBlock = (UIButton *)[elements objectAtIndex:18];
	btnBlock = (UIButton *)[elements objectAtIndex:17];
	
	viewBlock.frame = CGRectMake(viewBlock.frame.origin.x, newY, viewBlock.frame.size.width, viewBlock.frame.size.height);
	labelBlock.frame = CGRectMake(labelBlock.frame.origin.x, viewBlock.frame.origin.y+9, labelBlock.frame.size.width, labelBlock.frame.size.height);
	cbtnBlock.frame = CGRectMake(cbtnBlock.frame.origin.x, viewBlock.frame.origin.y+8, cbtnBlock.frame.size.width, cbtnBlock.frame.size.height);
	btnBlock.frame = CGRectMake(viewBlock.frame.origin.x, viewBlock.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
	newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 10;
	
	viewBlock = (UIView *)[elements objectAtIndex:23];
	labelBlock = (UILabel *)[elements objectAtIndex:25];
	cbtnBlock = (UIButton *)[elements objectAtIndex:24];
	btnBlock = (UIButton *)[elements objectAtIndex:26];
	
	viewBlock.frame = CGRectMake(viewBlock.frame.origin.x, newY, viewBlock.frame.size.width, viewBlock.frame.size.height);
	labelBlock.frame = CGRectMake(labelBlock.frame.origin.x, viewBlock.frame.origin.y+9, labelBlock.frame.size.width, labelBlock.frame.size.height);
	cbtnBlock.frame = CGRectMake(cbtnBlock.frame.origin.x, viewBlock.frame.origin.y+8, cbtnBlock.frame.size.width, cbtnBlock.frame.size.height);
	btnBlock.frame = CGRectMake(viewBlock.frame.origin.x, viewBlock.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
	newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 15;
	
	viewBlock = (UIView *)[elements objectAtIndex:19];
	labelBlock = (UILabel *)[elements objectAtIndex:20];
	UIImageView *imgView = (UIImageView *)[elements objectAtIndex:21];
	btnBlock = (UIButton *)[elements objectAtIndex:22];
	
	viewBlock.frame = CGRectMake(viewBlock.frame.origin.x, newY, viewBlock.frame.size.width, viewBlock.frame.size.height);
	labelBlock.frame = CGRectMake(labelBlock.frame.origin.x, viewBlock.frame.origin.y+5, labelBlock.frame.size.width, labelBlock.frame.size.height);
	imgView.frame = CGRectMake(imgView.frame.origin.x, viewBlock.frame.origin.y+5, imgView.frame.size.width, imgView.frame.size.height);
	btnBlock.frame = CGRectMake(viewBlock.frame.origin.x, viewBlock.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
	
	[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, viewBlock.frame.origin.y + viewBlock.frame.size.height + 30)];
	
}

- (void) basicMode{
	
	NSArray *elements = [self.scrollView subviews];
	NSLog(@"%d",[elements count]);
	for (int i=0; i<12; i++) {
		[[elements objectAtIndex:i] performSelector:@selector(setHidden:) withObject:TRUE];
	}
	
//	[[elements objectAtIndex:27] performSelector:@selector(setHidden:) withObject:NO];
//	[[elements objectAtIndex:28] performSelector:@selector(setHidden:) withObject:NO];
	UIView *messageView = (UIView *)[elements objectAtIndex:27];
	UILabel *msgLabel = (UILabel *)[elements objectAtIndex:28];
	if( [utils hasConnectivity] ){
		msgLabel.text = [NSString stringWithFormat:@"'%@' is your default county. If you would like to search for providers from other counties, please select additional counties now (Max is 4).", [self.userData objectForKey:@"county_name"]];
		messageView.frame = CGRectMake(messageView.frame.origin.x, messageView.frame.origin.y, messageView.frame.size.width, 162);
		UILabel *secondLabel = (UILabel *)[elements objectAtIndex:29];
		msgLabel.textColor = secondLabel.textColor;
		secondLabel.hidden = NO;
		[[elements objectAtIndex:30] performSelector:@selector(setHidden:) withObject:NO];
	}else {
		msgLabel.text = [NSString stringWithFormat:@"You need to have internet connectivity to Sync & Setup the application. Once you are done, you can search Offline."];
		msgLabel.textColor = [UIColor redColor];
		messageView.frame = CGRectMake(messageView.frame.origin.x, messageView.frame.origin.y, messageView.frame.size.width, 100);
		[[elements objectAtIndex:29] performSelector:@selector(setHidden:) withObject:YES];
		[[elements objectAtIndex:30] performSelector:@selector(setHidden:) withObject:YES];
	}

	messageView.hidden = NO;
	msgLabel.hidden = NO;
	
	CGFloat newY = messageView.frame.origin.y + messageView.frame.size.height + 10;

	UIView *viewBlock = (UIView *)[elements objectAtIndex:12];
	UIButton *cbtnBlock = (UIButton *)[elements objectAtIndex:13];
	UIButton *btnBlock = (UIButton *)[elements objectAtIndex:14];

	viewBlock.frame = CGRectMake(viewBlock.frame.origin.x, newY, viewBlock.frame.size.width, viewBlock.frame.size.height);
	cbtnBlock.frame = CGRectMake(cbtnBlock.frame.origin.x, viewBlock.frame.origin.y, cbtnBlock.frame.size.width, cbtnBlock.frame.size.height);
	btnBlock.frame = CGRectMake(btnBlock.frame.origin.x, viewBlock.frame.origin.y, btnBlock.frame.size.width, btnBlock.frame.size.height);
	newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 10;
	
	viewBlock = (UIView *)[elements objectAtIndex:15];
	UILabel *labelBlock = (UILabel *)[elements objectAtIndex:16];
	cbtnBlock = (UIButton *)[elements objectAtIndex:18];
	btnBlock = (UIButton *)[elements objectAtIndex:17];
	
	viewBlock.frame = CGRectMake(viewBlock.frame.origin.x, newY, viewBlock.frame.size.width, viewBlock.frame.size.height);
	labelBlock.frame = CGRectMake(labelBlock.frame.origin.x, viewBlock.frame.origin.y+9, labelBlock.frame.size.width, labelBlock.frame.size.height);
	cbtnBlock.frame = CGRectMake(cbtnBlock.frame.origin.x, viewBlock.frame.origin.y+8, cbtnBlock.frame.size.width, cbtnBlock.frame.size.height);
	btnBlock.frame = CGRectMake(viewBlock.frame.origin.x, viewBlock.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
	newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 10;
	
	viewBlock = (UIView *)[elements objectAtIndex:23];
	labelBlock = (UILabel *)[elements objectAtIndex:25];
	cbtnBlock = (UIButton *)[elements objectAtIndex:24];
	btnBlock = (UIButton *)[elements objectAtIndex:26];
	
	viewBlock.frame = CGRectMake(viewBlock.frame.origin.x, newY, viewBlock.frame.size.width, viewBlock.frame.size.height);
	labelBlock.frame = CGRectMake(labelBlock.frame.origin.x, viewBlock.frame.origin.y+9, labelBlock.frame.size.width, labelBlock.frame.size.height);
	cbtnBlock.frame = CGRectMake(cbtnBlock.frame.origin.x, viewBlock.frame.origin.y+8, cbtnBlock.frame.size.width, cbtnBlock.frame.size.height);
	btnBlock.frame = CGRectMake(viewBlock.frame.origin.x, viewBlock.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
	newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 15;
	
	viewBlock = (UIView *)[elements objectAtIndex:19];
	labelBlock = (UILabel *)[elements objectAtIndex:20];
	UIImageView *imgView = (UIImageView *)[elements objectAtIndex:21];
	btnBlock = (UIButton *)[elements objectAtIndex:22];
	
	viewBlock.frame = CGRectMake(viewBlock.frame.origin.x, newY, viewBlock.frame.size.width, viewBlock.frame.size.height);
	labelBlock.frame = CGRectMake(labelBlock.frame.origin.x, viewBlock.frame.origin.y+5, labelBlock.frame.size.width, labelBlock.frame.size.height);
	imgView.frame = CGRectMake(imgView.frame.origin.x, viewBlock.frame.origin.y+5, imgView.frame.size.width, imgView.frame.size.height);
	btnBlock.frame = CGRectMake(viewBlock.frame.origin.x, viewBlock.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
		
	[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, viewBlock.frame.origin.y + viewBlock.frame.size.height + 30)];
}

- (void)updateRowCounts{

	int count = [dao getTableRowCount:IreferConstraints.practiceTableName];
	NSString *suffix = @"Practice";
	if (count > 1) {
		suffix = @"Practices";
	}
	[self.pracBtn setTitle:[NSString stringWithFormat:@"%d %@", count,suffix] forState:UIControlStateNormal];
	count = [dao getTableRowCount:IreferConstraints.specialityTableName];
	suffix = @"Speciality";
	if (count > 1) {
		suffix = @"Specialities";
	}
	[self.spBtn setTitle:[NSString stringWithFormat:@"%d %@", count, suffix] forState:UIControlStateNormal];
	count = [dao getTableRowCount:IreferConstraints.hospitalTableName];
	suffix = @"Hospital";
	if (count > 1) {
		suffix = @"Hospitals";
	}
	[self.hosBtn setTitle:[NSString stringWithFormat:@"%d %@", count, suffix] forState:UIControlStateNormal];
	count = [dao getTableRowCount:IreferConstraints.insuranceTableName];
	suffix = @"Insurance";
	if (count > 1) {
		suffix = @"Insurances";
	}
	[self.insBtn setTitle:[NSString stringWithFormat:@"%d %@", count, suffix] forState:UIControlStateNormal];
	count = [dao getTableRowCount:IreferConstraints.countyTableName];
	if (count == 1) {
		[self.cntyBtn setTitle:[NSString stringWithFormat:@"%@",[self.userData objectForKey:@"county_name"]] forState:UIControlStateNormal];
		
	}else {
		[self.cntyBtn setTitle:[NSString stringWithFormat:@"%d Counties",count] forState:UIControlStateNormal];
		
	}
	
	int countDoc = [dao getTableRowCount:IreferConstraints.doctorTableName colName:@"doc_id"];
	if(countDoc > 0){
		if ([[self.userData objectForKey:@"need_to_sync"] isEqual:@"1"]) {
			self.docCountText.textColor = [UIColor redColor];
		}else {
			self.docCountText.textColor = [UIColor whiteColor];
		}
		self.docCountText.text = [NSString stringWithFormat:@"%d Doctor Synced",countDoc];
	}else{
		self.docCountText.textColor = [UIColor redColor];
		self.docCountText.text = @"Please sync doctor database";
	}
	
}

- (IBAction) addBtnClicked:(id)sender{
	UIButton *button = (UIButton *)sender;
	
	if([button tag] == 1){
		
		NSMutableArray *selectedList = [dao getTableRowList:IreferConstraints.practiceTableName searchValue:nil];
		stpPracListViewController *pracController = [[stpPracListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		if(selectedList != nil)
			pracController.selectedDataSource = selectedList;
		pracController.filterView = self;
		pracController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:pracController animated:YES];
		[pracController release];
		
	}else if([button tag] == 2){
		
		NSMutableArray *selectedList = [dao getTableRowList:IreferConstraints.hospitalTableName searchValue:nil];
		stpHosListViewController *hosController = [[stpHosListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		if(selectedList != nil)
			hosController.selectedDataSource = selectedList;
		hosController.filterView = self;
		hosController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:hosController animated:YES];
		[hosController release];
		

	}else if([button tag] == 3){
		
		NSMutableArray *selectedList = [dao getTableRowList:IreferConstraints.insuranceTableName searchValue:nil];
		stpInsListViewController *insController = [[stpInsListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		if(selectedList != nil)
			insController.selectedDataSource = selectedList;
		insController.filterView = self;
		insController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:insController animated:YES];
		[insController release];
		
		
	}else if([button tag] == 4){
		
		NSMutableArray *selectedList = [dao getTableRowList:IreferConstraints.specialityTableName searchValue:nil];
		stpSpListViewController *spController = [[stpSpListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		if(selectedList != nil)
			spController.selectedDataSource = selectedList;
		spController.filterView = self;
		spController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:spController animated:YES];
		[spController release];
		
		
	}else if([button tag] == 5){
		
		NSMutableArray *selectedList = [dao getTableRowList:IreferConstraints.countyTableName searchValue:nil];
		stpCntyListViewController *cntyController = [[stpCntyListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		if(selectedList != nil)
			cntyController.selectedDataSource = selectedList;
		cntyController.filterView = self;
		cntyController.defaultElemId = [self.userData objectForKey:@"county_id"];
		cntyController.maxSelectionLimit = 4;
		cntyController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:cntyController animated:YES];
		[cntyController release];
		
		
	}
}

- (IBAction) listBtnClicked:(id)sender{
	UIButton *button = (UIButton *)sender;
	
	if([button tag] == 1){
		
		stpPracDelListViewController *pracDelController = [[stpPracDelListViewController alloc] initWithNibName:@"DeleteListViewController" bundle:nil];
		if ([[self.userData objectForKey:@"is_PCP"] intValue]) {
			pracDelController.showDeleteBtn = NO;
		}else {
			pracDelController.showDeleteBtn = YES;
			pracDelController.showActivationModal = YES;
		}

		pracDelController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		pracDelController.delegate = self;
		[self presentModalViewController:pracDelController animated:YES];
		[pracDelController release];
	
	}else if([button tag] == 2){
		
		stpHosDelListViewController *hosDelController = [[stpHosDelListViewController alloc] initWithNibName:@"DeleteListViewController" bundle:nil];
		hosDelController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		hosDelController.delegate = self;
		if ([[self.userData objectForKey:@"is_PCP"] intValue]) {
			hosDelController.showDeleteBtn = YES;
		}else {
			hosDelController.showDeleteBtn = NO;
		}		[self presentModalViewController:hosDelController animated:YES];
		[hosDelController release];
		
		
	}else if([button tag] == 3){
		
		stpInsDelListViewController *insDelController = [[stpInsDelListViewController alloc] initWithNibName:@"DeleteListViewController" bundle:nil];
		insDelController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		insDelController.delegate = self;
		insDelController.showDeleteBtn = YES;
		[self presentModalViewController:insDelController animated:YES];
		[insDelController release];
		
	}else if([button tag] == 4){
		
		stpSpDelListViewController *spDelController = [[stpSpDelListViewController alloc] initWithNibName:@"DeleteListViewController" bundle:nil];
		spDelController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		spDelController.delegate = self;
		spDelController.showDeleteBtn = YES;
		[self presentModalViewController:spDelController animated:YES];
		[spDelController release];
		
		
	}else if([button tag] == 5){
		
		stpCntyDelListViewController *cntyDelController = [[stpCntyDelListViewController alloc] initWithNibName:@"DeleteListViewController" bundle:nil];
		cntyDelController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		cntyDelController.delegate = self;
		cntyDelController.showDeleteBtn = YES;
		cntyDelController.defaultElemId = [self.userData objectForKey:@"county_id"];
		[self presentModalViewController:cntyDelController animated:YES];
		[cntyDelController release];
	}
	
}

- (IBAction) searchBtnClicked:(id)sender{
	
	if([self.parentViewController isKindOfClass:[filterViewController class]]){
	
		NSLog(@"dismissing setup view to show parent filter view");
		[self dismissModalViewControllerAnimated:YES];

	}else{

		NSLog(@"creating new filter view as no parent filter view found");
		
		filterViewController *filterController = [[filterViewController alloc] initWithNibName:@"filterViewController" bundle:nil];
		filterController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:filterController animated:YES];
		[filterController release];
	}
}

- (IBAction) aboutBtnClicked:(id)sender{
	aboutViewController *abtController = [[aboutViewController alloc] initWithNibName:@"aboutViewController" bundle:nil];
	abtController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:abtController animated:YES];
	[abtController release];
}


- (void) setSelectedOption:(NSMutableArray *)dataSet delegate:(UIViewController *)controller{
	NSLog(@"inside setSelectedOption ........");
	BOOL changedFlag = NO;
	
	if ([controller isKindOfClass: [stpPracListViewController class]] ) {
		
		if ([dao getTableRowCount:IreferConstraints.practiceTableName] != [dataSet count]) {
			changedFlag = YES;
		}
		if([dao savePractices:dataSet]){
			int count = [dataSet count];
			NSString *suffix = @"Practice";
			if (count > 1) {
				suffix = @"Practices";
			}			
			[self.pracBtn setTitle:[NSString stringWithFormat:@"%d %@", count, suffix] forState:UIControlStateNormal];
		}
	}else if ([controller isKindOfClass: [stpHosListViewController class]] ) {
		
		if ([dao getTableRowCount:IreferConstraints.hospitalTableName] != [dataSet count]) {
			changedFlag = YES;
		}
		if([dao saveHospitals:dataSet]){
			int count = [dataSet count];
			NSString *suffix = @"Hospital";
			if (count > 1) {
				suffix = @"Hospitals";
			}			
			[self.hosBtn setTitle:[NSString stringWithFormat:@"%d %@", count, suffix] forState:UIControlStateNormal];
		}
		
	}else if ([controller isKindOfClass: [stpInsListViewController class]] ) {
	
		if ([dao getTableRowCount:IreferConstraints.insuranceTableName] != [dataSet count]) {
			changedFlag = YES;
		}
		if([dao saveInsurances:dataSet]){
			int count = [dataSet count];
			NSString *suffix = @"Insurance";
			if (count > 1) {
				suffix = @"Insurances";
			}	
			[self.insBtn setTitle:[NSString stringWithFormat:@"%d %@", count, suffix] forState:UIControlStateNormal];
		}
		
	}else if ([controller isKindOfClass: [stpSpListViewController class]] ) {
	
		if ([dao getTableRowCount:IreferConstraints.specialityTableName] != [dataSet count]) {
			changedFlag = YES;
		}
		if([dao saveSpecialities:dataSet]){
			int count = [dataSet count];
			NSString *suffix = @"Speciality";
			if (count > 1) {
				suffix = @"Specialities";
			}
			[self.spBtn setTitle:[NSString stringWithFormat:@"%d %@", count, suffix] forState:UIControlStateNormal];
		}
		
	}else if ([controller isKindOfClass: [stpCntyListViewController class]] ) {
	
		if ([self.parentViewController isKindOfClass:[filterViewController class]]) {
			[self.parentViewController setDefaultCounty:dataSet];
		}
		if ([dao getTableRowCount:IreferConstraints.countyTableName] != [dataSet count]) {
			changedFlag = YES;
		}
		for(NSDictionary *dict in dataSet){
			NSLog(@"%@ %@",[dict objectForKey:@"name"],[dict objectForKey:@"state_code"]);
		}
		if([dao saveCounties:dataSet]){
			if ([dataSet count] == 1) {
				[self.cntyBtn setTitle:[NSString stringWithFormat:@"%@",[self.userData objectForKey:@"county_name"]] forState:UIControlStateNormal];
				
			}else {
				[self.cntyBtn setTitle:[NSString stringWithFormat:@"%d Counties",[dataSet count]] forState:UIControlStateNormal];
				
			}
		}
		
	}
	
	if (changedFlag) {
		self.docCountText.textColor = [UIColor redColor];
		[dao updateUserSyncFlag:@"1"];
	}
	
	[controller dismissModalViewControllerAnimated:YES];
}

- (void) doneWithDeletion:(NSUInteger *)count delegate:(UIViewController *)controller{
	NSLog(@"inside doneWithDeletion ........");
	BOOL changedFlag = NO;

	if ([controller isKindOfClass: [stpPracDelListViewController class]] ) {
		NSString *suffix = @"Practice";
		if (count > 1) {
			suffix = @"Practices";
		}
		if (![self.pracBtn.titleLabel.text isEqual:[NSString stringWithFormat:@"%d %@", count,suffix]]) {
			changedFlag = YES;
		}
		[self.pracBtn setTitle:[NSString stringWithFormat:@"%d %@", count,suffix] forState:UIControlStateNormal];
		
	}else if ([controller isKindOfClass: [stpHosDelListViewController class]] ) {
	
		NSString *suffix = @"Hospital";
		if (count > 1) {
			suffix = @"Hospitals";
		}
		if (![self.hosBtn.titleLabel.text isEqual:[NSString stringWithFormat:@"%d %@", count,suffix]]) {
			changedFlag = YES;
		}
		[self.hosBtn setTitle:[NSString stringWithFormat:@"%d %@", count,suffix] forState:UIControlStateNormal];
				
	}else if ([controller isKindOfClass: [stpInsDelListViewController class]] ) {
		
		NSString *suffix = @"Insurance";
		if (count > 1) {
			suffix = @"Insurances";
		}
		if (![self.insBtn.titleLabel.text isEqual:[NSString stringWithFormat:@"%d %@", count,suffix]]) {
			changedFlag = YES;
		}
		[self.insBtn setTitle:[NSString stringWithFormat:@"%d %@", count,suffix] forState:UIControlStateNormal];
		
	}else if ([controller isKindOfClass: [stpSpDelListViewController class]] ) {
		
		NSString *suffix = @"Speciality";
		if (count > 1) {
			suffix = @"Specialities";
		}
		if (![self.spBtn.titleLabel.text isEqual:[NSString stringWithFormat:@"%d %@", count,suffix]]) {
			changedFlag = YES;
		}
		[self.spBtn setTitle:[NSString stringWithFormat:@"%d %@", count,suffix] forState:UIControlStateNormal];
		
	}else if ([controller isKindOfClass: [stpCntyDelListViewController class]] ) {
		
		if ([self.parentViewController isKindOfClass:[filterViewController class]]) {
			[self.parentViewController setDefaultCounty:[dao getTableRowList:IreferConstraints.countyTableName searchValue:nil]];
		}
		if (count == 1) {
			if (![self.cntyBtn.titleLabel.text isEqual:[NSString stringWithFormat:@"%@",[self.userData objectForKey:@"county_name"]]]) {
				changedFlag = YES;
			}
			[self.cntyBtn setTitle:[NSString stringWithFormat:@"%@",[self.userData objectForKey:@"county_name"]] forState:UIControlStateNormal];
			
		}else {
			if (![self.cntyBtn.titleLabel.text isEqual:[NSString stringWithFormat:@"%d Counties", count]]) {
				changedFlag = YES;
			}
			[self.cntyBtn setTitle:[NSString stringWithFormat:@"%d Counties",count] forState:UIControlStateNormal];
			
		}
		
	}
	
	if (changedFlag) {
		self.docCountText.textColor = [UIColor redColor];
		[dao updateUserSyncFlag:@"1"];
	}
	
	[controller dismissModalViewControllerAnimated:YES];
}

- (IBAction) resetAllBtnClicked:(id)sender{
	actionSheetType = 1;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"'Reset All' is going to delete your current settings and download basic settings. Do you still want to carry on ?" delegate:self cancelButtonTitle:@"Yeah! go ahead." destructiveButtonTitle:@"Nope. May be later." otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];	
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	if(actionSheetType == 1){
		if( buttonIndex == [actionSheet cancelButtonIndex]){
			[self processTemplateSyncronization];
		}
	}else if(actionSheetType == 3){
		if( !buttonIndex == [actionSheet cancelButtonIndex]){
			[self processDoctorSyncronization];
		}		
	}
}

- (void) processTemplateSyncronization{
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.inactiveBtn.hidden = NO;
	if ([[self.userData objectForKey:@"is_PCP"] intValue])
		self.spinnerText.text = @"Clearing Practices..";
	else 
		self.spinnerText.text = @"Clearing Hospitals..";		
	self.spinnerBg.hidden = NO;
	NSLog(@"before thread");
	[NSThread detachNewThreadSelector:@selector(templateProcessThread) toTarget:self withObject:nil];
}

- (void)templateProcessThread {  
	NSLog(@"inside thread");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
	parser = [[SBJsonParser alloc] init];
	
	if ([[self.userData objectForKey:@"is_PCP"] intValue]) {
        /*
		NSLog(@"inside pcp");
		
		if (![dao clearPractices]) {
			NSLog(@"unable to clear practice table");
		}
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading Hospitals.." waitUntilDone:NO];
		
		//for hospital
		NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"hospital/jsonTmpl?prac_id=%@",[self.userData objectForKey:@"id"]];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
		
		NSArray *dataList = [parser objectWithString:responseString error:NULL];
	
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Saving Hospitals.." waitUntilDone:NO];

		if(![dao saveHospitals:dataList]){
			NSLog(@"unable to save hospital template data");
		}
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading Insurances.." waitUntilDone:NO];
		//for insurance
		serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"insurance/jsonTmpl?prac_id=%@",[self.userData objectForKey:@"id"]];
		request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
		
		dataList = [parser objectWithString:responseString error:NULL];

		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Saving Insurances.." waitUntilDone:NO];

		if(![dao saveInsurances:dataList]){
			NSLog(@"unable to save insurance template data");
		}

		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading Counties.." waitUntilDone:NO];
		//for county
		serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"county/jsonTmpl?prac_id=%@",[self.userData objectForKey:@"id"]];
		request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
		
		dataList = [parser objectWithString:responseString error:NULL];
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Saving Counties.." waitUntilDone:NO];
		
		if(![dao saveCounties:dataList]){
			NSLog(@"unable to save county template data");
		}
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading Specialities.." waitUntilDone:NO];

		//for speciality
		serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"speciality/jsonTmpl?prac_id=%@",[self.userData objectForKey:@"id"]];
		request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
		
		dataList = [parser objectWithString:responseString error:NULL];
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Saving Specialities.." waitUntilDone:NO];

		if(![dao saveSpecialities:dataList]){
			NSLog(@"unable to save speciality template data");
		}
		*/
        if (![dao clearPracticesAndAll]) {
            NSLog(@"unable to clear Hospitals And All");
        }

	}else {
		/*
		NSLog(@"inside hospitalist");
		
		if (![dao clearHospitals]) {
			NSLog(@"unable to clear hospital table");
		}
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading Practices.." waitUntilDone:NO];

		//for hospital
		NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"practice/jsonTmpl?hosp_id=%@",[self.userData objectForKey:@"id"]];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
		
		NSArray *dataList = [parser objectWithString:responseString error:NULL];
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Saving Practices.." waitUntilDone:NO];

		if(![dao savePractices:dataList]){
			NSLog(@"unable to save practice template data");
		}
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading Insurances.." waitUntilDone:NO];

		//for insurance
		serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"insurance/jsonTmpl?hosp_id=%@",[self.userData objectForKey:@"id"]];
		request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
		
		dataList = [parser objectWithString:responseString error:NULL];
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Saving Insurances.." waitUntilDone:NO];

		if(![dao saveInsurances:dataList]){
			NSLog(@"unable to save insurance template data");
		}
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading Counties.." waitUntilDone:NO];

		//for county
		serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"county/jsonTmpl?hosp_id=%@",[self.userData objectForKey:@"id"]];
		request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
		
		dataList = [parser objectWithString:responseString error:NULL];
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Saving Counties.." waitUntilDone:NO];

		if(![dao saveCounties:dataList]){
			NSLog(@"unable to save county template data");
		}
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading Specialities.." waitUntilDone:NO];

		//for speciality
		serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"speciality/jsonTmpl?hosp_id=%@",[self.userData objectForKey:@"id"]];
		request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
		newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
		
		dataList = [parser objectWithString:responseString error:NULL];
		
		[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Saving Specialities.." waitUntilDone:NO];

		if(![dao saveSpecialities:dataList]){
			NSLog(@"unable to save speciality template data");
		}
         */
        
        if (![dao clearHospitalsAndAll]) {
            NSLog(@"unable to clear Hospitals And All");
        }
	}
	
	[self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Clearing Doctors.." waitUntilDone:NO];

	if (![dao clearDoctors]) {
		NSLog(@"unable to clear doctors for template sync");
	}
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;	
	self.inactiveBtn.hidden = YES;
	self.spinnerBg.hidden = YES;
	[self updateRowCounts];
	[parser release];
	[pool release];  
	
}  

- (IBAction) syncDoctorBtnClicked:(id)sender{
	actionSheetType = 3;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Depending on the number of counties you selected and your internet connection speed, this download may take at least several minutes. Should we proceed ?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void) processDoctorSyncronization{
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.inactiveBtn.hidden = NO;
	self.spinnerBg.hidden = NO;
	self.spinnerText.text = @"Preparing database...";
	NSLog(@"before doctor thread");
	[self doctorProcessThread];
	//[self performSelectorInBackground:@selector(doctorProcessThread) withObject:nil];
}
-(void) startupSyncThread{
    if(![self connectedToInternet]){
        NSLog(@"No Internet");
        return;
    }
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSDictionary *userData = [baseDao getCurrentUserPracticeOrHospital];
	
	//uploading abuse reports
	NSArray *reports = [baseDao getSyncronizableReports];
	NSLog(@"uploadable report count %d",[reports count]);
	BOOL *isFirst = YES;
	NSString *content = @"";
	for(NSDictionary *report in reports){
		if (isFirst) {
			isFirst = NO;
			content = [content stringByAppendingFormat:@"%@,%@",[report objectForKey:@"docId"],[report objectForKey:@"text"]];
		}else {
			content = [content stringByAppendingFormat:@"|%@,%@",[report objectForKey:@"docId"],[report objectForKey:@"text"]];
		}
	}
	//NSLog(content);
	NSString *url = @"";
	NSString *responseStr = @"";
	
	if(![content isEqual:@""]){
		url = [NSString stringWithFormat:@"%@doctorComment/comment2?user_id=%@&var=%@",[utils getServerURL], [userData objectForKey:@"uid"], content];
		responseStr = [utils getStringFromSyncronousURLCall:url];
		[baseDao updateSyncronizableReports];
	}
	//uploading ranks
	NSArray *ranks = [baseDao getSyncronizableRanks];
	NSLog(@"uploadable rank count %d",[ranks count]);
	isFirst = YES;
	content = @"";
	for(NSDictionary *rank in ranks){
		if (isFirst) {
			isFirst = NO;
			content = [content stringByAppendingFormat:@"%@,%@,%@",[rank objectForKey:@"docId"],[rank objectForKey:@"rank"],[rank objectForKey:@"up_rank"]];
		}else {
			content = [content stringByAppendingFormat:@"|%@,%@,%@",[rank objectForKey:@"docId"],[rank objectForKey:@"rank"],[rank objectForKey:@"up_rank"]];
		}
	}
	//NSLog(content);
	if(![content isEqual:@""]){
		url = [NSString stringWithFormat:@"%@userDocRank/bulkRank?user_id=%@&val=%@",[utils getServerURL], [userData objectForKey:@"uid"], content];
		NSLog(url);
		responseStr = [utils getStringFromSyncronousURLCall:url];
		NSLog(@"response for rank update %@",responseStr);
		[baseDao updateSyncronizableRanks];
	}
	
	//uploading search count
	int count = [baseDao getSearchCount:1];
	NSLog(@"uploadable search count %d",count);
	if( count > 0 ){
		url = [NSString stringWithFormat:@"%@searchStatistics/setCount?user_id=%@&count=%d",[utils getServerURL], [userData objectForKey:@"uid"], count];
		NSLog(url);
		responseStr = [utils getStringFromSyncronousURLCall:url];
		NSLog(@"response for statistics upload %@",responseStr);
	}
	//[utils showAlert:@"Notification !!!" message:@"test" delegate:nil];
	[pool drain];
}


-(BOOL) connectedToInternet

{
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"]];
    
    return ( URLString != NULL ) ? YES : NO;
    
}


- (void)doctorProcessThread {  
	NSLog(@"inside doctor thread");
    
    if(![self connectedToInternet]){
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
        self.inactiveBtn.hidden = YES;
        self.spinnerBg.hidden = YES;
        [utils showAlert:@"Warning !!" message:@"Sorry can not connect to the server." delegate:self];
        return;
    }
    
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
	
	NSDictionary *user = [dao getCurrentUser];
	
	NSString *cntyIds = [utils getIdsFromList:[dao getTableRowList:IreferConstraints.countyTableName searchValue:nil]];
	NSString *userId = [user objectForKey:@"id"];
	NSString *limit = @"0,100000";
    
	NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    self.dateString = [dateFormatter stringFromDate:currDate];
    NSLog(@"%@",self.dateString);
    //http://103.4.147.139/irefer-dsi/index.php/services/doctor/get_sync_data?prac_ids=1&cnty_ids=7&user_id=31&slimit=1000&limit=150&dlimit=0,15000&serverBDFileName=3120131125143545
	
	NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"doctor/get_sync_data_iphone?prac_ids=1&cnty_ids=%@&user_id=%@&slimit=1000&limit=1000&dlimit=%@&serverBDFileName=%@",cntyIds,userId,limit,self.dateString];
    
    NSLog(serverUrl);
        
   /*
    NSError *error;
   NSURL *dbUrl = [[NSURL alloc] initWithString:[serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSMutableURLRequest *urlRequest = [NSURLRequest requestWithURL:dbUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    //NSURLRequest * urlRequest = [NSURLRequest requestWithURL:dbUrl];
   
    NSURLResponse * response = nil;
    error = nil;
    [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    */
    
    
    NSURL *dbUrl = [[NSURL alloc] initWithString:
             [serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:dbUrl];
    [[NSURLConnection alloc] initWithRequest:request delegate:nil];
    
    //NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target: self selector: @selector(checkIfDBReady:) userInfo: nil repeats: YES];
    
    
    self.autoTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(checkIfDBReady) userInfo:nil repeats:YES];
    
    //[[NSRunLoop mainRunLoop] addTimer:self.autoTimer forMode:NSDefaultRunLoopMode];
    //[self checkIfDBReady];
    /*
    if (error != nil)
    {
        [utils showAlert:@"Error !!!" message:@"Sync process failed. Please try again later." delegate:nil];
        self.userData = [dao getCurrentUserPracticeOrHospital];
        
        [self updateRowCounts];
        
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
        self.inactiveBtn.hidden = YES;
        self.spinnerBg.hidden = YES;
        
        
        [pool drain];
        return;
    }
    NSString *responseString = [[NSString alloc] initWithData:dbFile encoding:NSUTF8StringEncoding];
    if (![responseString isEqualToString:@"1"]){
        [utils showAlert:@"Error !!!" message:@"Sync process failed. Please try again later." delegate:nil];
        self.userData = [dao getCurrentUserPracticeOrHospital];
        
        [self updateRowCounts];
        
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
        self.inactiveBtn.hidden = YES;
        self.spinnerBg.hidden = YES;
        
        
        [pool drain];
        return;
    }
    */
	
	
	[pool drain];  
	
}
-(void)checkIfDBReady{
    NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"doctor/get_db_status?serverBDFileName=%@",self.dateString];
    
    NSLog(serverUrl);
    
    
    NSError *error;
    NSURL *dbUrl = [[NSURL alloc] initWithString:[serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSMutableURLRequest *urlRequest = [NSURLRequest requestWithURL:dbUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    //NSURLRequest * urlRequest = [NSURLRequest requestWithURL:dbUrl];
    
    NSURLResponse * response = nil;
    error = nil;
    NSData *res = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
    if ([responseString isEqualToString:@"3"]){
        [self.autoTimer invalidate];
        self.autoTimer = nil;
        [self downloadAndReplaceDB];
    }
   
}
-(void) downloadAndReplaceDB{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSURL *dbUrl = nil;
    NSURLResponse * response = nil;
    NSError *error = nil;
    NSData * dbFile = nil;
    NSString *serverUrl = @"";
	NSString *responseStr = @"";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *datePath= [NSString stringWithFormat: @"/%@.zip",self.dateString];
    NSString *txtPath = [documentsDirectory stringByAppendingPathComponent:datePath];
    NSString *dbPath = [dao dataFilePath];
    serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getBaseURL)]] stringByAppendingFormat:@"dbzip/%@.zip",self.dateString];
    dbUrl = [[NSURL alloc] initWithString: [serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    dbFile = [[NSData alloc] initWithContentsOfURL:dbUrl];
    if ([fileManager fileExistsAtPath:txtPath] == NO) {
        [self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading database..." waitUntilDone:NO];
        [dbFile writeToFile:txtPath atomically:YES];
    }
    else if ([fileManager fileExistsAtPath:txtPath] == YES) {
        [self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading database..." waitUntilDone:NO];
        [fileManager removeItemAtPath:txtPath error:&error];
        [dbFile writeToFile:txtPath atomically:YES];
    }
    if ([fileManager fileExistsAtPath:txtPath] == NO) {
        [utils showAlert:@"Error !!!" message:@"Sync process failed. Please try again later." delegate:nil];
        self.userData = [dao getCurrentUserPracticeOrHospital];
        
        [self updateRowCounts];
        
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
        self.inactiveBtn.hidden = YES;
        self.spinnerBg.hidden = YES;
        
        
        [pool drain];
        return;
    }
    [self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Unzipping database..." waitUntilDone:NO];
    [dao release];
    //NSString *zipPath = @"path_to_your_zip_file";
    //NSString *destinationPath = @"path_to_the_folder_where_you_want_it_unzipped";
    if ([fileManager fileExistsAtPath:dbPath] == YES) {
        [fileManager removeItemAtPath:dbPath error:&error];
    }
    [SSZipArchive unzipFileAtPath:txtPath toDestination:documentsDirectory];
    NSString *unzipPath = [documentsDirectory stringByAppendingPathComponent:@"/irefer_db"];
    [self renameFileFrom:unzipPath to:dbPath];
    [self.spinnerText performSelectorOnMainThread:@selector(setText:) withObject:@"Reloading database..." waitUntilDone:NO];
    dao = [[setupDao alloc] init];
    if ([fileManager fileExistsAtPath:txtPath] == YES) {
        [fileManager removeItemAtPath:txtPath error:&error];
    }
    serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"doctor/deletedbfiles?serverBDFileName=%@",self.dateString];
    NSLog(serverUrl);
    dbUrl = [[NSURL alloc] initWithString:
             [serverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:dbUrl];
    [[NSURLConnection alloc] initWithRequest:request delegate:nil];
    
    
	self.userData = [dao getCurrentUserPracticeOrHospital];
	
	[self updateRowCounts];
	
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.inactiveBtn.hidden = YES;
	self.spinnerBg.hidden = YES;
    [pool drain];
}

- (BOOL)renameFileFrom:(NSString*)oldPath to:(NSString *)newPath
{
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask, YES) objectAtIndex:0];
    
    
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileMan moveItemAtPath:oldPath toPath:newPath error:&error])
    {
        NSLog(@"Failed to move '%@' to '%@': %@", oldPath, newPath, [error localizedDescription]);
        return NO;
    }
    return YES;
}
- (IBAction) advancedSearchBtnClicked:(id)sender{
	advancedDocListViewController *advancedDocList = [[advancedDocListViewController alloc] initWithNibName:@"doctorListViewController" bundle:nil];
	advancedDocList.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:advancedDocList animated:YES];
	[advancedDocList release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"inside memory warning...");
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[spinnerText release];
	[spinnerBg release];
	[scrollView release];
	[inactiveBtn release];
	[userData release];
	[spinner release];
	[pracAddBtn release];
	[hosAddBtn release];
	[docCountText release];
	[pracBtn release];
	[hosBtn release];
	[insBtn release];
	[spBtn release];
	[cntyBtn release];
	[pname release];
	[addr release];
	[dao release];
    [super dealloc];
}


@end
