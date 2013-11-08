//
//  DeleteListProtocol.h
//  irefer2
//
//  Created by Mushraful Hoque on 1/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DeleteListProtocol

- (void) doneWithDeletion:(NSUInteger *)count delegate:(UIViewController *)controller;

@end
