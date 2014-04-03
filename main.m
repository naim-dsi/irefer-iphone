//
//  main.m
//  irefer2
//
//  Created by Mushraful Hoque on 12/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    @autoreleasepool {
        
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UIUseLegacyUI"];
		[[NSUserDefaults standardUserDefaults] synchronize];
        
		return UIApplicationMain(argc, argv, nil, nil);
	}
    //NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
    //[pool release];
    //return retVal;
}
