//
//  CustomDoctorCell.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utils.h"

@interface CustomDoctorCell : UITableViewCell {

	IBOutlet UILabel *name;
	IBOutlet UILabel *phone;
	IBOutlet UILabel *pracName;
	IBOutlet UILabel *rankLabel;
	IBOutlet UIView *ratingView;
	IBOutlet UIButton *rankBtn;
	IBOutlet UIButton *callBtn;
}

@property(nonatomic, retain) UILabel *name;
@property(nonatomic, retain) UILabel *phone;
@property(nonatomic, retain) UILabel *pracName;
@property(nonatomic, retain) UILabel *rankLabel;
@property(nonatomic, retain) UIView *ratingView;
@property(nonatomic, retain) NSString *tel;
@property(nonatomic, retain) UIButton *rankBtn;
@property(nonatomic, retain) UIButton *callBtn;

@end
