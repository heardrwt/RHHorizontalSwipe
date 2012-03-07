//
//  RHLayoutScrollViewSliderBar.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 21/02/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

//overlay view used to give the user context as to where they are in their horizontal swipes.

#import <UIKit/UIKit.h>

#import "RHLayoutScrollViewControllerOverlayViewProtocol.h"
@class RHLayoutScrollViewController;

@interface RHLayoutScrollViewSliderBar : UIView <RHLayoutScrollViewControllerOverlayViewProtocol> {
    NSArray *_buttons;

    UIImageView *_sliderBar;
    
    RHLayoutScrollViewController *_currentController; //weak
    
}

@end
