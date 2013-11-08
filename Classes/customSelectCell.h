//
//  customSelectCell.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface customSelectCell : UITableViewCell {
	
	IBOutlet UILabel *name;
	IBOutlet UIImageView *checked;
	BOOL isSelected;
}

@property(nonatomic, retain) UILabel *name;
@property(nonatomic, retain) UIImageView *checked;
@property(nonatomic, assign) BOOL isSelected;

@end
