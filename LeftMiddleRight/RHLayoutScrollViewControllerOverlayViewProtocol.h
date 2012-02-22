//
//  RHLayoutScrollViewControllerOverlayViewProtocol.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 21/02/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RHLayoutScrollViewController;

//layout scroll view controller overlay view protocol
@protocol RHLayoutScrollViewControllerOverlayViewProtocol <NSObject>

@optional
//visibility
-(BOOL)alwaysVisible; //defaults to no


//added/removed to/from scrollviewcontroller
-(void)addedToScrollViewController:(RHLayoutScrollViewController*)controller;
-(void)removedFromScrollViewController:(RHLayoutScrollViewController*)controller; //good place to nil out any weak refs to the current controller


//view controllers changed
-(void)scrollViewController:(RHLayoutScrollViewController*)controller orderedViewControllersChanged:(NSArray*)viewControllers;

//positional updating
-(void)scrollViewController:(RHLayoutScrollViewController*)controller updateNumberOfPages:(NSInteger)numberOfPages;
-(void)scrollViewController:(RHLayoutScrollViewController*)controller updateCurrentPage:(NSInteger)page;
-(void)scrollViewController:(RHLayoutScrollViewController*)controller updateForPercentagePosition:(CGFloat)position;

@end
