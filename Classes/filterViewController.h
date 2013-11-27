//
//  filterViewController.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "insuranceListViewController.h"
#import "acoListViewController.h"
#import "sptListViewController.h"
#import "SelectBoxProtocol.h"
#import "selHosListViewController.h"
#import "countyListViewController.h"
#import "doctorListViewController.h"
#import "setupViewController.h"
#import "searchDao.h"
#import "aboutViewController.h"
#import "advancedDocListViewController.h"
#import "languageListViewController.h"
#import "selOfficeHrViewController.h"
#import "pracListViewController.h"
#import "IreferConstraints.h"


@interface filterViewController : UIViewController<SelectBoxProtocol> {
    IBOutlet UILabel *aco;
	IBOutlet UILabel *insurances;
	IBOutlet UILabel *specialities;
	IBOutlet UILabel *hospitals;
	IBOutlet UILabel *counties;
	IBOutlet UIButton *checkBox;
	IBOutlet UISegmentedControl *searchFrom;
	IBOutlet UISegmentedControl *searchType;
	IBOutlet UILabel *countyLabel;
	IBOutlet UIButton *countyButton;
	IBOutlet UILabel *zipCodeLabel;
	IBOutlet UITextField *zipCodeText;
	IBOutlet UIButton *zipCntyToggleBtn;
	IBOutlet UIToolbar *zipToolBar;
	IBOutlet UILabel *zipToolText;
	IBOutlet UILabel *zipCodeValue;
	IBOutlet UILabel *officeHourText;
	IBOutlet UIButton *zipButton;

	IBOutlet UILabel *pname;
	IBOutlet UILabel *address;
	
	
	IBOutlet UIScrollView *scrollView;
	
	searchDao *dao;
	BOOL includePatient;
    NSMutableArray *selectedACO;
	NSMutableArray *selectedInsurances;
	NSMutableArray *selectedSpecialities;
	NSMutableArray *selectedHospitals;
	NSMutableArray *selectedCounties;
	NSMutableArray *selectedLanguages;
	NSString *selectedOfficehours;
	NSMutableArray *selectedPractices;
}

@property(nonatomic, retain) UILabel *aco;
@property(nonatomic, retain) UILabel *insurances;
@property(nonatomic, retain) UILabel *specialities;
@property(nonatomic, retain) UILabel *hospitals;
@property(nonatomic, retain) UILabel *counties;
@property(nonatomic, retain) UIButton *checkBox;
@property(nonatomic, retain) UISegmentedControl *searchFrom;
@property(nonatomic, retain) UISegmentedControl *searchType;
@property(nonatomic, retain) UILabel *countyLabel;
@property(nonatomic, retain) UIButton *countyButton;
@property(nonatomic, retain) UILabel *zipCodeLabel;
@property(nonatomic, retain) UITextField *zipCodeText;
@property(nonatomic, retain) UIButton *zipCntyToggleBtn;
@property(nonatomic, retain) UIToolbar *zipToolBar;
@property(nonatomic, retain) UILabel *zipToolText;
@property(nonatomic, retain) UILabel *zipCodeValue;
@property(nonatomic, retain) UILabel *officeHourText;
@property(nonatomic, retain) UIButton *zipButton;

@property(nonatomic, retain) UILabel *pname;
@property(nonatomic, retain) UILabel *address;

@property(nonatomic, retain) UIScrollView *scrollView;


@property(nonatomic, assign) BOOL includePatient;
@property(nonatomic, retain) NSMutableArray *selectedInsurances;
@property(nonatomic, retain) NSMutableArray *selectedSpecialities;
@property(nonatomic, retain) NSMutableArray *selectedHospitals;
@property(nonatomic, retain) NSMutableArray *selectedCounties;
@property(nonatomic, retain) NSMutableArray *selectedLanguages;
@property(nonatomic, retain) NSString *selectedOfficehours;
@property(nonatomic, retain) NSMutableArray *selectedPractices;
@property(nonatomic, retain) NSMutableArray *selectedACO;

- (void) setOfficeText:(NSString *)text;
- (IBAction) checkBoxClicked: (id)sender;
- (IBAction) selectionOptionClicked: (id)sender;
- (IBAction) hideZipCodeKeyboard: (id)sender;
- (IBAction) zipCntyToggleBtnClicked: (id)sender;
- (IBAction) getDoctorList: (id)sender;
- (IBAction) setupBtnClicked: (id)sender;
- (IBAction) aboutBtnClicked:(id)sender;
- (IBAction) advancedSearchBtnClicked:(id)sender;
- (IBAction) zipCodeChanged:(id)sender;
- (IBAction) zipButtonClicked:(id)sender;
- (IBAction) advancedToggleBtnClicked:(id)sender;
- (IBAction) uiSegmentControllerClicked: (id)sender;

   
@end