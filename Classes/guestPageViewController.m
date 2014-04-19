//
//  guestPageViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 12/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "guestPageViewController.h"

#define PCP_BTN 1;
#define HOS_BTN 2;
#define REG_BTN 3;
#define ABT_BTN 4;

@implementation guestPageViewController

@synthesize pcpBtn, hosBtn, regBtn, abtBtn, bgView, pname, addrs, actText, pcpView, hosView, regView, abtView, pcpImg, hosImg, regImg, abtImg, pcpLbl, hosLbl, regLbl, abtLbl;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	dao = [[registrationDao alloc] init];
    
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	NSDictionary *registeredUser = [dao getRegisteredUser];
	if( registeredUser == nil ){
		self.actText.hidden = TRUE;
	}else {
		CGFloat elemYDiff = 10.0f;
		self.pcpBtn.hidden = TRUE;
		self.hosBtn.hidden = TRUE;	
		self.pcpView.hidden = TRUE;
		self.hosView.hidden = TRUE;	
		self.pcpImg.hidden = TRUE;
		self.hosImg.hidden = TRUE;	
		self.pcpLbl.hidden = TRUE;
		self.hosLbl.hidden = TRUE;	
		
		self.pname.font = [UIFont systemFontOfSize:20.0f];
		self.pname.text = [registeredUser objectForKey:@"prac_name"];
		
		//code for dynamically resizable ui elements
		UIFont* font = self.pname.font;			
		CGSize constraintSize = CGSizeMake(self.pname.frame.size.width, MAXFLOAT);
		CGSize labelSize = [self.pname.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		self.pname.frame = CGRectMake(self.pname.frame.origin.x, self.pname.frame.origin.y, self.pname.frame.size.width, labelSize.height);
		CGFloat nextY = (self.pname.frame.origin.y + labelSize.height + elemYDiff);
		
		NSString *address = [registeredUser objectForKey:@"prac_addr"];
		if (address != nil && [address length] > 0) {
			
			self.addrs.text = address;
			self.addrs.frame = CGRectMake(self.addrs.frame.origin.x, nextY, self.addrs.frame.size.width, self.addrs.frame.size.height);
			nextY += (self.addrs.frame.size.height + elemYDiff);			
			
		}else {
			self.addrs.hidden = TRUE;
		}
		
		self.actText.frame = CGRectMake(self.actText.frame.origin.x, nextY, self.actText.frame.size.width, self.actText.frame.size.height);
		nextY += (self.actText.frame.size.height + elemYDiff);
		
		self.bgView.frame = CGRectMake(self.bgView.frame.origin.x, self.bgView.frame.origin.y, self.bgView.frame.size.width, nextY);
		
		CGFloat buttonY = (self.bgView.frame.size.height + 20.0f);
		
		self.regView.frame = CGRectMake(self.regView.frame.origin.x, buttonY, self.regView.frame.size.width, self.regView.frame.size.height);
		self.regBtn.frame = CGRectMake(self.regBtn.frame.origin.x, buttonY, self.regBtn.frame.size.width, self.regBtn.frame.size.height);
		self.regImg.frame = CGRectMake(self.regImg.frame.origin.x, buttonY+5.0f, self.regImg.frame.size.width, self.regImg.frame.size.height);
		self.regLbl.frame = CGRectMake(self.regLbl.frame.origin.x, buttonY+20.0f, self.regLbl.frame.size.width, self.regLbl.frame.size.height);
		
		buttonY += 	(self.regView.frame.size.height + 6.0f);
		self.abtView.frame = CGRectMake(self.abtView.frame.origin.x, buttonY, self.abtView.frame.size.width, self.abtView.frame.size.height);
		self.abtBtn.frame = CGRectMake(self.abtBtn.frame.origin.x, buttonY, self.abtBtn.frame.size.width, self.abtBtn.frame.size.height);
		self.abtImg.frame = CGRectMake(self.abtImg.frame.origin.x, buttonY+5.0f, self.abtImg.frame.size.width, self.abtImg.frame.size.height);
		self.abtLbl.frame = CGRectMake(self.abtLbl.frame.origin.x, buttonY+20.0f, self.abtLbl.frame.size.width, self.abtLbl.frame.size.height);
		
	}

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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction) buttonClicked: (id)sender{
	UIButton *button = (UIButton *)sender;
	int pcp = PCP_BTN;
	int hos = HOS_BTN;
	int reg = REG_BTN;
	int abt = ABT_BTN;
	
	if ([button tag] == pcp){
		
		pcpListViewController *pcpController = [[pcpListViewController alloc] initWithNibName:@"pcpListViewController" bundle:nil];
		pcpController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:pcpController animated:YES];
		[pcpController release];
		
	}else if ([button tag] == hos){
		
		hospitalListViewController *hosController = [[hospitalListViewController alloc] initWithNibName:@"CustomListViewController" bundle:nil];
		hosController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:hosController animated:YES];
		[hosController release];
		
	}else if ([button tag] == reg){
		
		activationViewController *activateController = [[activationViewController alloc] initWithNibName:@"activationViewController" bundle:nil];
		activateController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:activateController animated:YES];
		[activateController release];
		
	}else if ([button tag] == abt ){
		
		aboutViewController *abtController = [[aboutViewController alloc] initWithNibName:@"aboutViewController" bundle:nil];
		abtController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:abtController animated:YES];										
		[abtController release];
		
	}
}


- (void)dealloc {
	[dao release];
	[bgView release];
	[pname release];
	[addrs release];
	[actText release];
	[pcpBtn release];
	[hosBtn release];
	[regBtn release];
	[abtBtn release];
	[pcpView release];
	[hosView release];
	[regView release];
	[abtView release];
	[pcpImg release];
	[hosImg release];
	[regImg release];
	[abtImg release];
	[pcpLbl release];
	[hosLbl release];
	[regLbl release];
	[abtLbl release];
    [super dealloc];
}

@end
