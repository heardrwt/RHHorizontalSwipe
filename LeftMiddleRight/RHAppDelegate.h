//
//  RHAppDelegate.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 23/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RHLayoutScrollViewController;

@interface RHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RHLayoutScrollViewController *layoutScrollViewController; //view controller that forwards all rotations etc. and hosts our controllers views


@end
