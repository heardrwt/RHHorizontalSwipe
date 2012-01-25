//
//  RHLayoutScrollViewController.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 24/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

/*
 vc takes an array of view controllers, forwards events to said controllers for rotation and adds them to its views subview scrollview 
 also shows / hides the custom page indicator titles / buttons etc
 
 Uses iOS5 View Controller containment so as to be a good citizen.
 
 */

#import <UIKit/UIKit.h>

@class RHLayoutScrollView;

@interface RHLayoutScrollViewController : UIViewController

@property (readonly, nonatomic) RHLayoutScrollView *layoutScrollView;

@property (retain, nonatomic) NSArray *orderedViewControllers;

@property (readonly, nonatomic) UIViewController *currentViewController;

@property (assign, nonatomic) NSUInteger currentIndex;
-(void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@property (assign, nonatomic, getter=isLocked) BOOL locked; //prevent swiping between view controllers

@end
