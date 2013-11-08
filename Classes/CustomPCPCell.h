//
//  CustomPCPCell.h
//  irefer2
//
//  Created by Mushraful Hoque on 12/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomPCPCell : UITableViewCell {
	
	IBOutlet UILabel *dname;
	IBOutlet UILabel *pname;

}

@property(nonatomic, retain) UILabel *dname;
@property(nonatomic, retain) UILabel *pname;

@end
