//
//  RHLayoutScrollViewExpandingButton.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 5/03/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

//overlay view that provides a single button that grows and shrinks into 2 separate buttons based on a percentage change in the containing scroll view.

#import <UIKit/UIKit.h>

#import "RHLayoutScrollViewControllerOverlayViewProtocol.h"
@class RHLayoutScrollViewController;

@interface RHLayoutScrollViewExpandingButtonView : UIView <RHLayoutScrollViewControllerOverlayViewProtocol> {
    
    RHLayoutScrollViewController *_currentController; //weak
    NSUInteger _fullWidthIndex;

    NSUInteger _numberOfPages;

    UIButton *_leftButton;
    UIButton *_rightButton;
 
}


//as a user, you need to specify some point where we are full width vs minimum width

@property (nonatomic, assign) CGFloat startPercentage; //eg 0.50f;
@property (nonatomic, assign) CGFloat endPercentage; //eg 1.00f;

@property (nonatomic, assign) NSUInteger fullWidthIndex; // section that has full width buttons . eg 

@property (readonly) UIButton *leftButton; //button frames are ignored.
@property (readonly) UIButton *rightButton;

//small buttons are same width as views height, large buttons are width of view / 2

-(void)updateForPercentagePosition:(CGFloat)position;
-(void)applyAnimation:(CGFloat)prog;

@end
