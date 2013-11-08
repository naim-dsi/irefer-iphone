//
//  customDeleteCell.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface customDeleteCell : UITableViewCell {
	
	IBOutlet UILabel *name;
	IBOutlet UIButton *delBtn;
	
}

@property(nonatomic, retain) UILabel *name;
@property(nonatomic, retain) UIButton *delBtn;


@end
