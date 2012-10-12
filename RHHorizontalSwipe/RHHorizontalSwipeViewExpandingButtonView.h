//
//  RHHorizontalSwipeViewExpandingButtonView.h
//  RHHorizontalSwipe
//
//  Created by Richard Heard on 5/03/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

//overlay view that provides a single button that grows and shrinks into 2 separate buttons based on a percentage change in the containing scroll view.

#import <UIKit/UIKit.h>

#import "RHHorizontalSwipeViewControllerProtocols.h"
@class RHHorizontalSwipeViewController;

@interface RHHorizontalSwipeViewExpandingButtonView : UIView <RHHorizontalSwipeViewControllerOverlayViewProtocol> {
    
    RHHorizontalSwipeViewController *_currentController; //weak
    NSUInteger _fullWidthIndex;
    
    NSUInteger _numberOfPages;
    
    UIButton *_leftButton;
    UIButton *_rightButton;
    
}


//as a user, you need to specify some point where we are full width vs minimum width

@property (nonatomic, assign) CGFloat startPercentage; //eg 0.50f;
@property (nonatomic, assign) CGFloat endPercentage; //eg 1.00f;

@property (readonly) UIButton *leftButton; //button frames are ignored.
@property (readonly) UIButton *rightButton;

//small buttons are same width as views height, large buttons are width of view / 2

-(void)updateForPercentagePosition:(CGFloat)position;
-(void)applyAnimation:(CGFloat)prog;

@end
