//
//  filterViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "filterViewController.h"

#define INSURANCE 1;
#define SPECIALITY 2;
#define HOSPITAL 3;
#define COUNTY 4;
#define LANGUAGE 5;
#define OFFICE_HOUR 6;
#define PRACTICE 7;
#define ACO 8;

@implementation filterViewController

@synthesize aco, insurances, specialities, hospitals, counties, checkBox, searchFrom, searchType, includePatient, officeHourText;

@synthesize selectedInsurances, selectedSpecialities, selectedHospitals, selectedCounties, scrollView, selectedOfficehours, selectedLanguages, selectedPractices, selectedACO;

@synthesize countyLabel, countyButton, zipCodeLabel, zipCodeText, zipCntyToggleBtn, pname, address, zipToolBar, zipToolText, zipCodeValue, zipButton;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)loadView{
    [super loadView];
	dao = [[searchDao alloc] init];
	self.zipToolBar.hidden = YES;
	self.zipToolText.hidden = YES;
	
	NSDictionary *hosPracObj = [dao getCurrentUserPracticeOrHospital];
	if( hosPracObj != nil ){
		
		self.pname.text = [NSString stringWithFormat:@"%@ %@", [hosPracObj objectForKey:@"last_name"], [hosPracObj objectForKey:@"first_name"]];
		
		/*
		UIFont* font = self.pname.font;			
		CGSize constraintSize = CGSizeMake(self.pname.frame.size.width, MAXFLOAT);
		CGSize labelSize = [self.pname.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		//CGFloat heightDiff = (labelSize.height - self.pname.frame.size.height);
		self.pname.frame = CGRectMake(self.pname.frame.origin.x, self.pname.frame.origin.y, self.pname.frame.size.width, labelSize.height);
		*/
		
		NSString *addText = [hosPracObj objectForKey:@"prac_name"];
		
		if (![[hosPracObj objectForKey:@"county_name"] isEqual:@""]) {
			addText = [addText stringByAppendingFormat:@", %@", [hosPracObj objectForKey:@"county_name"]];
			[self setDefaultCounty:[dao getTableRowList:IreferConstraints.countyTableName searchValue:nil]];
		}
		
		if (![[hosPracObj objectForKey:@"state_code"] isEqual:@""]) {
			addText = [addText stringByAppendingFormat:@" %@", [hosPracObj objectForKey:@"state_code"]];
		}
		
		NSDictionary *language = [[utils getLanguageList:@"English"] objectAtIndex:0];
		((UILabel *)[[self.scrollView subviews] objectAtIndex:28]).text = [language objectForKey:@"name"];
		self.selectedLanguages = [[NSMutableArray alloc] initWithObjects:language, nil];
		self.address.text = addText;
		
		UIFont* font = self.address.font;			
		CGSize constraintSize = CGSizeMake(self.address.frame.size.width, MAXFLOAT);
		CGSize labelSize = [self.address.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		CGFloat heightDiff = (labelSize.height - self.address.frame.size.height);
		self.pname.frame = CGRectMake(self.pname.frame.origin.x, self.pname.frame.origin.y-heightDiff, self.pname.frame.size.width, self.pname.frame.size.height);
		self.address.frame = CGRectMake(self.address.frame.origin.x, self.address.frame.origin.y-heightDiff, self.address.frame.size.width, labelSize.height);
	
		if ([[hosPracObj objectForKey:@"is_PCP"] isEqual:@"0"]) {
			NSArray *elements = [self.scrollView subviews];
			
			UIView *advView = (UIView *)[elements objectAtIndex:22];
			UIButton *advButton = (UIButton *)[elements objectAtIndex:24];
			UILabel *advLabel = (UILabel *)[elements objectAtIndex:23];
			UIButton *advClickBtn = (UIButton *)[elements objectAtIndex:25]; 
			
			UIView *viewBlock = (UIView *)[elements objectAtIndex:34];
			UILabel *labelBlock = (UILabel *)[elements objectAtIndex:35];
			UILabel *valueBlock = (UILabel *)[elements objectAtIndex:36];
			UIButton *btnBlock = (UIButton *)[elements objectAtIndex:37];
			
			viewBlock.frame = CGRectMake(advView.frame.origin.x, advView.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
			btnBlock.frame = CGRectMake(viewBlock.frame.origin.x, viewBlock.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
			labelBlock.frame = CGRectMake(14, viewBlock.frame.origin.y+6, labelBlock.frame.size.width, labelBlock.frame.size.height);
			valueBlock.frame = CGRectMake(116, viewBlock.frame.origin.y+10, valueBlock.frame.size.width, valueBlock.frame.size.height);
			CGFloat newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 8;
			
			viewBlock.hidden = NO;
			labelBlock.hidden = NO;
			valueBlock.hidden = NO;
			btnBlock.hidden = NO;
			
			advView.frame = CGRectMake(advView.frame.origin.x, newY, advView.frame.size.width, advView.frame.size.height);
			advClickBtn.frame = CGRectMake(advView.frame.origin.x, advView.frame.origin.y, advView.frame.size.width, advView.frame.size.height);
			advButton.frame = CGRectMake(advButton.frame.origin.x, advView.frame.origin.y+5, advButton.frame.size.width, advButton.frame.size.height);
			advLabel.frame = CGRectMake(advLabel.frame.origin.x, advView.frame.origin.y+6, advLabel.frame.size.width, advLabel.frame.size.height);
			
			
			CGFloat scrollHeight = advView.frame.origin.y+advView.frame.size.height+10.0f;
			[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, scrollHeight)];
			self.includePatient = NO;
			//[self checkBoxClicked:nil];
			
		}else {
			[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 5)];
		}		
	
	}	
	//self.searchFrom.selectedSegmentIndex = 0;
	//self.searchType.selectedSegmentIndex = 0;
	[self setSegmentTextColor:self.searchFrom index:0];
	[self setSegmentTextColor:self.searchType index:0];

}

- (void) setDefaultCounty:(NSMutableArray *)datalist{
	self.selectedCounties = datalist;
	self.counties.text = @"";
	for( NSDictionary *dict in self.selectedCounties){
		self.counties.text = [[self.counties.text stringByAppendingString:[dict objectForKey:@"name"]] stringByAppendingString:@","];
	}
	if ([self.counties.text length] > 0) {
		self.counties.text = [self.counties.text substringToIndex:([self.counties.text length] - 1)];
	}		
}

- (void) setSelectedOption:(NSMutableArray *)dataSet delegate:(UIViewController *)controller{
	NSLog(@"inside setSelectedOption ........");
	NSString *content = @"";
		
	for( NSDictionary *dict in dataSet){
		content = [[content stringByAppendingString:[dict objectForKey:@"name"]] stringByAppendingString:@","];
	}
	if ([content length] > 0) {
		content = [content substringToIndex:([content length] - 1)];
	}
	
	if ([controller isKindOfClass: [insuranceListViewController class]] ) {
		self.selectedInsurances = dataSet;
		if ([content length] > 0){
		
			self.insurances.text = content;
		
		}else{
			self.insurances.text = @"All";
		
		}		
	}else if ([controller isKindOfClass: [acoListViewController class]] ) {
		self.selectedACO = dataSet;
		if ([content length] > 0){
            
			self.aco.text = content;
            
		}else{
			self.aco.text = @"All";
            
		}		
	}else if ([controller isKindOfClass: [sptListViewController class]] ) {
		self.selectedSpecialities = dataSet;
		if ([content length] > 0){
			
			self.specialities.text = content;
			
		}else{
			self.specialities.text = @"All";
			
		}		
	}else if ([controller isKindOfClass: [selHosListViewController class]] ) {
		self.selectedHospitals = dataSet;
		if ([content length] > 0){
			
			self.hospitals.text = content;
			
		}else{
			self.hospitals.text = @"All";
			
		}		
	}else if ([controller isKindOfClass: [countyListViewController class]] ) {
		self.selectedCounties = dataSet;
		if ([content length] > 0){
			
			self.counties.text = content;
			
		}else{
			self.counties.text = @"None";
			
		}		
	}else if ([controller isKindOfClass: [languageListViewController class]] ) {
		self.selectedLanguages = dataSet;
		UILabel *label = (UILabel *)[[self.scrollView subviews] objectAtIndex:28];
		if ([content length] > 0){
			
			label.text = content;
			
		}else{
			label.text = @"None";
			
		}		
	}else if ([controller isKindOfClass: [selOfficeHrViewController class]] ) {
/*		self.selectedLanguages = dataSet;
		UILabel *label = (UILabel *)[[self.scrollView subviews] objectAtIndex:32];
		if ([content length] > 0){
			
			label.text = content;
			
		}else{
			label.text = @"All";
			
		}		*/
	}else if ([controller isKindOfClass: [pracListViewController class]] ) {
		self.selectedPractices = dataSet;
		UILabel *label = (UILabel *)[[self.scrollView subviews] objectAtIndex:36];
		if ([content length] > 0){
			
			label.text = content;
			
		}else{
			label.text = @"None";
			
		}				
	}
	
	[controller dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"Getting memory warning................");
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction) dismissFilterPage: (id)sender{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) checkBoxClicked: (id)sender{
	if (!self.includePatient) {
		self.includePatient = YES;
		[self.checkBox setImage:[UIImage imageNamed:@"checkbox_ticked.png"] forState:UIControlStateNormal];
	}else {
		self.includePatient = NO;
		[self.checkBox setImage:[UIImage imageNamed:@"checkbox_not_ticked.png"] forState:UIControlStateNormal];
	}
}

- (IBAction) selectionOptionClicked: (id)sender{
	[self hideZipCodeKeyboard:nil];
	UIButton *button = (UIButton *)sender;
	BOOL searchOnline = NO;
	
	if ([self.searchFrom selectedSegmentIndex] == 1) {
		searchOnline = YES;
	}
    
    

	
	int insurancebtn = INSURANCE;
	int specialitybtn =  SPECIALITY;
	int hospitalbtn = HOSPITAL;
	int countybtn = COUNTY;
	int languagebtn = LANGUAGE;
	int officehourbtn = OFFICE_HOUR;
	int practicebtn = PRACTICE;
    int acobtn = ACO;
	
	if ([button tag] == insurancebtn) {
		insuranceListViewController *insController = [[insuranceListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		insController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		insController.isSearchFromOnline = searchOnline;
		insController.filterView = self;
		insController.maxSelectionLimit = 1;
		insController.selectedDataSource = self.selectedInsurances;
		[self presentModalViewController:insController animated:YES];
		[insController release];
	}else if ([button tag] == acobtn) {
		acoListViewController *sptController = [[acoListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		sptController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		sptController.isSearchFromOnline = searchOnline;
		sptController.filterView = self;
		sptController.maxSelectionLimit = 1;
		sptController.selectedDataSource = self.selectedACO;
		[self presentModalViewController:sptController animated:YES];
		[sptController release];
	}else if ([button tag] == specialitybtn) {
		sptListViewController *sptController = [[sptListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		sptController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		sptController.isSearchFromOnline = searchOnline;
		sptController.filterView = self;
		sptController.maxSelectionLimit = 1;
		sptController.selectedDataSource = self.selectedSpecialities;
		[self presentModalViewController:sptController animated:YES];
		[sptController release];
	}else if ([button tag] == hospitalbtn) {
		selHosListViewController *hosController = [[selHosListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		hosController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		hosController.isSearchFromOnline = searchOnline;
		hosController.filterView = self;
		hosController.maxSelectionLimit = 1;
		hosController.selectedDataSource = self.selectedHospitals;
		[self presentModalViewController:hosController animated:YES];
		[hosController release];
	}else if ([button tag] == countybtn) {
		countyListViewController *cntyController = [[countyListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		cntyController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		cntyController.isSearchFromOnline = searchOnline;
		cntyController.filterView = self;
		cntyController.selectedDataSource = self.selectedCounties;
		[self presentModalViewController:cntyController animated:YES];
		[cntyController release];
	}else if ([button tag] == languagebtn) {
		languageListViewController *langController = [[languageListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		langController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		langController.isSearchFromOnline = searchOnline;
		langController.filterView = self;
		langController.selectedDataSource = self.selectedLanguages;
		[self presentModalViewController:langController animated:YES];
		[langController release];
	}else if ([button tag] == officehourbtn) {
		selOfficeHrViewController *officeHrController = [[selOfficeHrViewController alloc] initWithNibName:@"selOfficeHrViewController" bundle:nil];
		officeHrController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		NSLog(@"office Hour %@",selectedOfficehours);
		officeHrController.selectedValues = selectedOfficehours;
		[self presentModalViewController:officeHrController animated:YES];
		[officeHrController release];
	}else if ([button tag] == practicebtn) {
		pracListViewController *pracController = [[pracListViewController alloc] initWithNibName:@"SelectListViewController" bundle:nil];
		pracController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		pracController.isSearchFromOnline = searchOnline;
		pracController.filterView = self;
		pracController.maxSelectionLimit = 1;
		pracController.selectedDataSource = self.selectedPractices;
		[self presentModalViewController:pracController animated:YES];
		[pracController release];
	}
	
}

- (IBAction) uiSegmentControllerClicked: (id)sender{
	UISegmentedControl *control = (UISegmentedControl *)sender;
	int index = 0;
	if (control.selectedSegmentIndex == 0) {
		index = 1;
	}
	
	[self setSegmentTextColor:control index:index];
	
	[self hideZipCodeKeyboard:nil];
}

- (void) setSegmentTextColor:(UISegmentedControl *)control index:(int)index{
	
	NSArray *segments = [control subviews];
	UIColor * color = [UIColor colorWithRed:255/255.0f green:252/255.0f blue:199/255.0f alpha:1.0f];
	for(int i=0; i < [segments count]; i++){
		UIView *segment = (UIView *)[segments objectAtIndex:i];
		
		NSArray *rows = [segment subviews];
		for( id row in rows ){
			if ([row isKindOfClass:[UILabel class]]) {
				//NSLog(@"true");
				if (i == index) {
					[row performSelector:@selector(setTextColor:) withObject:color];	
				}else {
					[row performSelector:@selector(setTextColor:) withObject:[UIColor grayColor]];	
				}
			}
		}
	}
}

- (IBAction) hideZipCodeKeyboard: (id)sender{
	
	self.zipToolBar.hidden = YES;
	self.zipToolText.hidden = YES;
	[self.zipCodeText resignFirstResponder];
}

- (IBAction) zipCodeChanged:(id)sender{
	self.zipCodeValue.text = self.zipCodeText.text;
}

- (IBAction) advancedToggleBtnClicked:(id)sender{
	
	NSArray *elements = [self.scrollView subviews];
	
	NSLog(@"elem count %d",[elements count]);
	
	UIView *advView = (UIView *)[elements objectAtIndex:22];
	UIButton *advButton = (UIButton *)[elements objectAtIndex:24];
	UILabel *advLabel = (UILabel *)[elements objectAtIndex:23];
	UIButton *advClickBtn = (UIButton *)[elements objectAtIndex:25]; 
	
	if([[[advButton titleLabel] text] isEqual:@"v"]){
		[advButton titleLabel].text = @"^";
		advLabel.text = @"Hide Advanced Options";
		
		UIView *viewBlock = (UIView *)[elements objectAtIndex:26];
		UILabel *labelBlock = (UILabel *)[elements objectAtIndex:27];
		UILabel *valueBlock = (UILabel *)[elements objectAtIndex:28];
		UIButton *btnBlock = (UIButton *)[elements objectAtIndex:29];
		
		viewBlock.frame = CGRectMake(advView.frame.origin.x, advView.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
		btnBlock.frame = CGRectMake(advView.frame.origin.x, advView.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
		labelBlock.frame = CGRectMake(14, viewBlock.frame.origin.y+6, labelBlock.frame.size.width, labelBlock.frame.size.height);
		valueBlock.frame = CGRectMake(116, viewBlock.frame.origin.y+10, valueBlock.frame.size.width, valueBlock.frame.size.height);
		CGFloat newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 8;
		
		viewBlock.hidden = NO;
		labelBlock.hidden = NO;
		valueBlock.hidden = NO;
		btnBlock.hidden = NO;
		
		viewBlock = (UIView *)[elements objectAtIndex:30];
		labelBlock = (UILabel *)[elements objectAtIndex:31];
		valueBlock = (UILabel *)[elements objectAtIndex:32];
		btnBlock = (UIButton *)[elements objectAtIndex:33];
		
		viewBlock.frame = CGRectMake(advView.frame.origin.x, newY, viewBlock.frame.size.width, viewBlock.frame.size.height);
		btnBlock.frame = CGRectMake(viewBlock.frame.origin.x, viewBlock.frame.origin.y, viewBlock.frame.size.width, viewBlock.frame.size.height);
		labelBlock.frame = CGRectMake(14, viewBlock.frame.origin.y+6, labelBlock.frame.size.width, labelBlock.frame.size.height);
		valueBlock.frame = CGRectMake(116, viewBlock.frame.origin.y+10, valueBlock.frame.size.width, valueBlock.frame.size.height);
		newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 8;
		
		viewBlock.hidden = NO;
		labelBlock.hidden = NO;
		valueBlock.hidden = NO;
		btnBlock.hidden = NO;
		
		advView.frame = CGRectMake(advView.frame.origin.x, newY, advView.frame.size.width, advView.frame.size.height);
		advClickBtn.frame = CGRectMake(advView.frame.origin.x, advView.frame.origin.y, advView.frame.size.width, advView.frame.size.height);
		advButton.frame = CGRectMake(advButton.frame.origin.x, advView.frame.origin.y+5, advButton.frame.size.width, advButton.frame.size.height);
		advLabel.frame = CGRectMake(advLabel.frame.origin.x, advView.frame.origin.y+6, advLabel.frame.size.width, advLabel.frame.size.height);
		
		
		CGFloat scrollHeight = advView.frame.origin.y+advView.frame.size.height+10.0f;
		[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, scrollHeight)];
		
	}else {
		[advButton titleLabel].text = @"v";
		advLabel.text = @"Show Advanced Options";
		
		((UIView *)[elements objectAtIndex:26]).hidden = YES;
		((UILabel *)[elements objectAtIndex:27]).hidden = YES;
		((UILabel *)[elements objectAtIndex:28]).hidden = YES;
		((UIButton *)[elements objectAtIndex:29]).hidden = YES;
		((UIView *)[elements objectAtIndex:30]).hidden = YES;
		((UILabel *)[elements objectAtIndex:31]).hidden = YES;
		((UILabel *)[elements objectAtIndex:32]).hidden = YES;
		((UIButton *)[elements objectAtIndex:33]).hidden = YES;
		
		int i = 14;
		if (!((UIButton *)[elements objectAtIndex:34]).hidden) {
			i = 34;
		}
		
		UIView *viewBlock = (UIView *)[elements objectAtIndex:i];
		CGFloat newY = viewBlock.frame.origin.y + viewBlock.frame.size.height + 8;
		
		advView.frame = CGRectMake(advView.frame.origin.x, newY, advView.frame.size.width, advView.frame.size.height);
		advClickBtn.frame = CGRectMake(advView.frame.origin.x, advView.frame.origin.y, advView.frame.size.width, advView.frame.size.height);
		advButton.frame = CGRectMake(advButton.frame.origin.x, advView.frame.origin.y+3, advButton.frame.size.width, advButton.frame.size.height);
		advLabel.frame = CGRectMake(advLabel.frame.origin.x, advView.frame.origin.y+4, advLabel.frame.size.width, advLabel.frame.size.height);
		
		CGFloat scrollHeight = advView.frame.origin.y+advView.frame.size.height+15.0f;
		[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, scrollHeight)];
	}

}

- (IBAction) zipCntyToggleBtnClicked: (id)sender{
	
	if( !self.countyLabel.hidden ){
		
		self.countyLabel.hidden = TRUE;
		self.counties.hidden = TRUE;
		self.countyButton.hidden = TRUE;
		
		self.zipCodeLabel.hidden = FALSE;
		self.zipCodeValue.hidden = FALSE;
		self.zipButton.hidden = FALSE;
		[self zipButtonClicked:nil];
		[self.zipCntyToggleBtn setTitle:@"County" forState:UIControlStateNormal];
		
	}else {
		self.countyLabel.hidden = FALSE;
		self.counties.hidden = FALSE;
		self.countyButton.hidden = FALSE;
		
		self.zipCodeLabel.hidden = TRUE;
		self.zipCodeValue.hidden = TRUE;
		[self.zipCodeText resignFirstResponder];
		self.zipToolBar.hidden = TRUE;
		self.zipToolText.hidden = TRUE;
		self.zipButton.hidden = TRUE;
		
		[self.zipCntyToggleBtn setTitle:@"Zip" forState:UIControlStateNormal];
				
	}

}

- (IBAction) zipButtonClicked:(id)sender{

	[self.zipCodeText becomeFirstResponder];
	//[NSThread sleepForTimeInterval:.5];
	self.zipToolBar.hidden = FALSE;
	self.zipToolText.hidden = FALSE;
	
}

- (IBAction) getDoctorList: (id)sender{

	if( self.zipCodeLabel.hidden && [self.counties.text isEqual:@"None"]){
		[utils showAlert:@"Warning !!" message:@"Please select at least one county." delegate:self];
		return;	
	}
	if( !self.zipCodeLabel.hidden && [self.zipCodeText.text length] == 0){
		[utils showAlert:@"Warning !!" message:@"Please provide zip code." delegate:self];
		return;	
	}
	UIButton *advButton = (UIButton *)[[self.scrollView subviews] objectAtIndex:24];
	UILabel *label = (UILabel *)[[self.scrollView subviews] objectAtIndex:28];
	if( [[[advButton titleLabel] text] isEqual:@"^"] && [[label text] isEqual:@"None"]){
		[utils showAlert:@"Warning !!" message:@"Please select at least one language." delegate:self];
		return;	
	}
	
	BOOL searchOnline = NO;
	
	if ([self.searchFrom selectedSegmentIndex] == 1) {
		searchOnline = YES;
	}
	BOOL searchType = NO;
    if ([self.searchType selectedSegmentIndex] == 1) {
		searchType = YES;
	}
	doctorListViewController *docController = [[doctorListViewController alloc] initWithNibName:@"doctorListViewController" bundle:nil];
    docController.isResourceSearch = searchType;
	docController.isSearchFromOnline = searchOnline;
    docController.acoIds = [utils getIdsFromList:self.selectedACO];
	docController.insIds = [utils getIdsFromList:self.selectedInsurances];
	docController.spIds = [utils getIdsFromList:self.selectedSpecialities];
	docController.hosIds =  [utils getIdsFromList:self.selectedHospitals];
	docController.countyIds = [utils getIdsFromList:self.selectedCounties];
	docController.pracIds = [utils getIdsFromList:self.selectedPractices];
	
	if([[[advButton titleLabel] text] isEqual:@"^"]){
		docController.languages = ((UILabel *)[[self.scrollView subviews] objectAtIndex:28]).text;
		if (self.selectedOfficehours != NULL && ![self.selectedOfficehours isEqual:@""]) {
			docController.officeHours = self.selectedOfficehours;
		}else {
			docController.officeHours = @"";
		}

	}else {
		docController.languages = @"";
		docController.officeHours = @"";
	}
		
	if(self.zipCodeValue.hidden){
		docController.zipCode = @"";
	}else{
		docController.zipCode = self.zipCodeText.text;
	}
	if(self.includePatient){
		docController.inPatient = @"1";
	}else{
		docController.inPatient = @"";
	}
	docController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:docController animated:YES];
	[docController release];
}


- (IBAction) setupBtnClicked: (id)sender{
	setupViewController *setupController = [[setupViewController alloc] initWithNibName:@"setupViewController" bundle:nil];
	[self presentModalViewController:setupController animated:YES];
	[setupController release];
}

- (IBAction) aboutBtnClicked:(id)sender{
	aboutViewController *abtController = [[aboutViewController alloc] initWithNibName:@"aboutViewController" bundle:nil];
	abtController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:abtController animated:YES];
	[abtController release];
}

- (IBAction) advancedSearchBtnClicked:(id)sender{
	advancedDocListViewController *advancedDocList = [[advancedDocListViewController alloc] initWithNibName:@"doctorListViewController" bundle:nil];
	advancedDocList.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:advancedDocList animated:YES];
	[advancedDocList release];
}

- (void) setOfficeText:(NSString *)text{
	self.officeHourText.text = text;
	NSLog(@"office hour text %@",self.officeHourText.text);
}

- (void)dealloc {
	[officeHourText release];
	[selectedPractices release];
	[scrollView release];
	[zipButton release];
	[zipCodeValue release];
	[zipToolBar release];
	[zipToolText release];
	[dao release];
	[pname release];
	[address release];
	[zipCntyToggleBtn release];
	[countyLabel release];
	[countyButton release];
	[zipCodeLabel release];
	[zipCodeText release];
    [selectedACO release];
	[selectedInsurances release];
	[selectedHospitals release];
	[selectedSpecialities release];
	[selectedCounties release];
	[insurances release];
	[specialities release];
	[hospitals release];
	[counties release];
	[checkBox release];
	[searchFrom release];
	[searchType release];
    [super dealloc];
}


@end
