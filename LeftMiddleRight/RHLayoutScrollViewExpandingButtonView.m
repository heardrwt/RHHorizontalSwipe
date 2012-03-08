//
//  RHLayoutScrollViewExpandingButtonView.m
//  LeftMiddleRight
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

#import "RHLayoutScrollViewExpandingButtonView.h"
#import "RHLayoutScrollViewController.h"


//config
#define buttonHPadding 6.0f
#define buttonVPadding 1.0f

#define buttonHeight (self.bounds.size.height - (2.0f * buttonVPadding))

#define minButtonWidth buttonHeight //square buttons
#define maxButtonWidth ((self.bounds.size.width - (3.0f * buttonHPadding)) / 2.0f) //2 buttons



@implementation RHLayoutScrollViewExpandingButtonView

@synthesize startPercentage=_startPercentage;
@synthesize endPercentage=_endPercentage;

@synthesize fullWidthIndex=_fullWidthIndex;
@synthesize leftButton=_leftButton;
@synthesize rightButton=_rightButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;

        _leftButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:_leftButton];
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:_rightButton];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
    }
    return self;
}

#define RN(x) [x release]; x = nil;
- (void)dealloc
{
    RN(_leftButton);
    RN(_rightButton);

    _currentController = nil; //weak
    
    [super dealloc];
}


#pragma mark - layout
-(void)updateForPercentagePosition:(CGFloat)position{
    
    //work out positioning and pass down to progression source
    
    
    if (_startPercentage <= _endPercentage){
        //normal direction
    
        if (position < _startPercentage){
            //minimum size
            [self applyAnimation:0.0f];
            
        } else if (position > _endPercentage){
            //maximum size
            [self applyAnimation:1.0f];
        } else {
            //somewhere in-between
            
            //ratio
            CGFloat ratio = position - _startPercentage;
            ratio = ratio * (1.0f / (_endPercentage - _startPercentage));
            [self applyAnimation:ratio];
        }
    
    } else {
        //backwards people, backwards
        
        if (position > _startPercentage){
            //maximum size
            [self applyAnimation:0.0f];
            
        } else if (position < _endPercentage){
            //minimum size
            [self applyAnimation:1.0f];
        } else {
            //somewhere in-between
            
            //ratio
            CGFloat ratio = position - _endPercentage;
            ratio = ratio * (1.0f / (_startPercentage - _endPercentage));
            [self applyAnimation:1.0f-ratio];
        }
    }
    

}

//value between 0.0 and 1.0
-(void)applyAnimation:(CGFloat)progression{
    
    //0.0f means small
    //1.0f means large
    
    //left
    CGFloat leftW = MIN(minButtonWidth + ((maxButtonWidth - minButtonWidth) * 2 * progression), maxButtonWidth);
    CGFloat leftH = buttonHeight;
    CGFloat leftX= self.bounds.size.width - leftW - buttonHPadding;
    if (progression >= 0.50f){
        leftX -= ((maxButtonWidth + buttonHPadding )*  (progression-0.5f) * 2.0);
    }
    CGFloat leftY = buttonVPadding;
    
    //right
    CGFloat rightX = leftX + leftW + buttonHPadding;
    CGFloat rightY = buttonVPadding;
    CGFloat rightW = MAX(minButtonWidth, (self.bounds.size.width - rightX - buttonHPadding));
    CGFloat rightH = buttonHeight;

    //apply
    _leftButton.frame = CGRectMake(leftX, leftY, leftW, leftH);
    _rightButton.frame = CGRectMake(rightX, rightY, rightW, rightH);

}



#pragma mark - RHLayoutScrollViewControllerOverlayViewProtocol

//add/remove
-(void)addedToScrollViewController:(RHLayoutScrollViewController*)controller{
    _currentController = controller;
    _numberOfPages = controller.orderedViewControllers.count;

}
-(void)removedFromScrollViewController:(RHLayoutScrollViewController*)controller{
    _currentController = nil;
    _numberOfPages = 0;
}

//controller updating 
-(void)scrollViewController:(RHLayoutScrollViewController*)controller orderedViewControllersChanged:(NSArray*)viewControllers{
    //store the number of pages.
    _numberOfPages = controller.orderedViewControllers.count;

    [self setNeedsLayout];
}


//positional updating
-(void)scrollViewController:(RHLayoutScrollViewController*)controller updateForPercentagePosition:(CGFloat)position{
    [self updateForPercentagePosition:position];
}


@end
