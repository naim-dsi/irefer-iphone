//
//  CustomDoctorCell.m
//  irefer2
//
//  Created by Mushraful Hoque on 1/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomDoctorCell.h"


@implementation CustomDoctorCell

@synthesize name, phone, ratingView, rankBtn, callBtn, pracName, rankLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    //[super setSelected:selected animated:animated];
	// Configure the view for the selected state
}

- (void)dealloc {
	[rankLabel release];
	[pracName release];
	[callBtn release];
	[rankBtn release];
	[ratingView release];
	[name release];
	[phone release];
	[super dealloc];
}


@end
