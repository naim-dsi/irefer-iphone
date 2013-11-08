//
//  DeleteListViewController.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DeleteListViewController.h"


@implementation DeleteListViewController

@synthesize dataSource, searchBar, listTableView, spinner, countText, delegate, showDeleteBtn, showActivationModal, spinnerBg, defaultElemId;

int delId = 0;
int actionType = 0;

- (void)loadView{
	[super loadView];
	self.searchBar.placeholder = [self getSearchBarTitle];
	dao = [[setupDao alloc] init];
	[utils roundUpView:[[self.spinnerBg subviews] objectAtIndex:0]];

}

- (void)viewDidLoad {
	
	[self.listTableView setHidden:YES];
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;

	if([self respondsToSelector:@selector(loadDataSource:)]){
		[self loadDataSource:self.searchBar.text];
	}
	NSLog(@"data count %d", [self.dataSource count]);
	[self.listTableView reloadData];
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	[self.listTableView setHidden:NO];
	
}

- (IBAction) searchContentChanged: (id) sender{
	
	NSLog(@"inside searchContentChanged......");
	[self.listTableView setHidden:YES];
	[self.spinner startAnimating];
	self.spinner.hidden = NO;
	self.spinnerBg.hidden = NO;
	
	if([self respondsToSelector:@selector(loadDataSource:)]){
		[self loadDataSource:self.searchBar.text];
	}
	
	[self.listTableView reloadData];
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;
	[self.listTableView setHidden:NO];
	
	
}

// methods for tableview protocols

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	static NSString *cellTableIdentifier = @"CustomDeleteCellIdentifier";
	NSUInteger row = [indexPath row];	
	NSDictionary *rowData = [self.dataSource objectAtIndex:row];
	
	customDeleteCell *cell = (customDeleteCell *)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"customDeleteCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
		cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
		[cell.selectedBackgroundView setBackgroundColor:[UIColor orangeColor]];
	}
	cell.name.text = [rowData objectForKey:@"name"];
	if (!self.showDeleteBtn) {
		cell.delBtn.hidden = YES;
	}else {
		cell.delBtn.tag = [[rowData objectForKey:@"id"] intValue];		
	}

	
	return cell;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 50.0f;
}

// event handler after selecting a table row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self hideKeyboard:nil];
	if( self.showActivationModal ){
		actionType = 2;
		NSUInteger row = [indexPath row];	
		delId = row;
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Request for Activation",@"Activate",@"Cancel",nil];
		[actionSheet showInView:self.listTableView];
		[actionSheet release];
	}
	
}

- (IBAction) hideKeyboard: (id) sender{
	[searchBar resignFirstResponder];
}


-(IBAction) disMissDeleteListView:(id)sender{
	[delegate doneWithDeletion:[self.dataSource count] delegate:self];
}

- (NSString *) getSearchBarTitle{
	return @"Search";
}

-(IBAction) delBtnClicked:(id)sender{
	UIButton *button = (UIButton *)sender;
	delId = [button tag];
	if( self.defaultElemId != nil && [self.defaultElemId isEqual:[NSString stringWithFormat:@"%d", delId]]){
		[utils showAlert:@"Warning !!" message:@"Default option can't be deleted." delegate:nil];
		return;
	}
	actionType = 1;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you really want to delete it?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
	[actionSheet showInView:self.listTableView];
	[actionSheet release];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	if( actionType == 1 ){
		if( !buttonIndex == [actionSheet cancelButtonIndex]){
		
			NSLog(@"delete id.....%d",delId);
			
			if( delId > 0  && [self respondsToSelector:@selector(deleteListRow:)] ){
				NSLog(@"inside");
				if( [self deleteListRow:delId] )
					[self.listTableView reloadData];
			}
			delId = 0;
		}
	}else if (actionType == 2) {
		if( [[actionSheet buttonTitleAtIndex:buttonIndex] isEqual:@"Request for Activation"] ){
		
			[self.spinner startAnimating];
			self.spinner.hidden = NO;
			self.spinnerBg.hidden = NO;
			
			[NSThread detachNewThreadSelector:@selector(practiceActivationThread) toTarget:self withObject:nil];
			
			
		}else if( [[actionSheet buttonTitleAtIndex:buttonIndex] isEqual:@"Activate"] ){
			
			NSDictionary *rowData = [self.dataSource objectAtIndex:delId];

			pracActivationViewController *pracActController = [[pracActivationViewController alloc] initWithNibName:@"pracActivationViewController" bundle:nil];
			pracActController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			pracActController.practice = rowData;
			[self presentModalViewController:pracActController animated:YES];
			[pracActController release];
			
		}
	}
}

- (void) practiceActivationThread{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
	
	NSDictionary *rowData = [self.dataSource objectAtIndex:delId];
	NSDictionary *user = [dao getCurrentUser];
	NSString *serverUrl = [[NSString stringWithString: [utils performSelector:@selector(getServerURL)]] stringByAppendingFormat:@"paUser/req?prac_id=%@&user_id=%@",[rowData objectForKey:@"id"],[user objectForKey:@"id"]];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:serverUrl]];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *newData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *responseString = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
	NSLog(@"response for practice request %@",responseString);
	
	if([responseString isEqual:@"saved"]){				   
		[utils showAlert:@"Confirmation !!" message:@"Your activation request has been sent successfully." delegate:self.listTableView];
	}else if([responseString isEqual:@"already exists"]){				   
		[utils showAlert:@"Confirmation !!" message:@"You have already requested for this practice activation." delegate:self.listTableView];
	}else {
		[utils showAlert:@"Warning !!" message:@"Sorry!! couldn't connect to server for your request." delegate:self.listTableView];	
	}
					   
	[self.spinner stopAnimating];
	self.spinner.hidden = YES;
	self.spinnerBg.hidden = YES;

	[pool release];
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
	[spinnerBg release];
	[delegate release];
	[dao release];
	[countText release];
	[spinner release];
	[listTableView release];
	[dataSource release];
	[searchBar release];
    [super dealloc];
}
@end
