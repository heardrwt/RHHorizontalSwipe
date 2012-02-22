//
//  RHLayoutScrollViewSliderBar.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 21/02/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RHLayoutScrollViewControllerOverlayViewProtocol.h"
@class RHLayoutScrollViewController;

@interface RHLayoutScrollViewSliderBar : UIView <RHLayoutScrollViewControllerOverlayViewProtocol> {
    NSArray *_buttons;

    UIImageView *_sliderBar;
    
    RHLayoutScrollViewController *_currentController; //weak
    
}

@end
