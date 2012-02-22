//
//  RHLayoutScrollViewController.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 24/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

/*
 vc takes an array of view controllers, forwards events to said controllers for rotation and adds them to its views subview scrollview 
 also shows / hides the custom page indicator titles / buttons etc (collectivly, overlay views)
 
 Uses iOS5 View Controller containment so as to be a good citizen.
 
 */

#import <UIKit/UIKit.h>

#import "RHLayoutScrollView.h"
#import "RHLayoutScrollViewControllerOverlayViewProtocol.h"

@interface RHLayoutScrollViewController : UIViewController <RHLayoutScrollViewDelegate>

@property (readonly, nonatomic) RHLayoutScrollView *layoutScrollView;

@property (retain, nonatomic) NSArray *orderedViewControllers;

@property (readonly, nonatomic) UIViewController *currentViewController;

@property (assign, nonatomic) NSUInteger currentIndex;
-(void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@property (assign, nonatomic, getter=isLocked) BOOL locked; //prevent swiping between view controllers

//overlay views, regular views installed staticly over the scrollview, if they implement the RHLayoutScrollViewControllerOverlayViewProtocol, will be updated with current index position etc
-(void)addOverlayView:(UIView <RHLayoutScrollViewControllerOverlayViewProtocol> *)view;
-(void)removeOverlayView:(UIView <RHLayoutScrollViewControllerOverlayViewProtocol> *)view;

-(void)setOverlayViewsHidden:(BOOL)hidden animated:(BOOL)animated; //hide overlay views, eg for when drilled down etc

@end

