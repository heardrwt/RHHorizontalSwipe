//
//  RHHorizontalSwipeViewSliderBar.m
//  RHHorizontalSwipe
//
//  Created by Richard Heard on 21/02/12.
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

#import "RHHorizontalSwipeViewSliderBar.h"
#import "RHHorizontalSwipeViewController.h"

@implementation RHHorizontalSwipeViewSliderBar

static void * RHHorizontalSwipeViewSliderBarKVOContext = &RHHorizontalSwipeViewSliderBarKVOContext;

@synthesize buttons=_buttons;
@synthesize sliderBar=_sliderBar;

#pragma mark - view lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //slider width depends on number of titles
        _sliderBar = [[UIImageView alloc] init];
        [_sliderBar setBackgroundColor:[UIColor darkGrayColor]];
        [self addSubview:_sliderBar];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return self;
}

#define RN(x) [x release]; x = nil;

- (void)dealloc {
    
    //remove kvo observers
    for (UIViewController *vc in _currentController.orderedViewControllers) {
        if ([NSObject instancesRespondToSelector:@selector(removeObserver:forKeyPath:context:)]){
            [vc removeObserver:self forKeyPath:@"title" context:RHHorizontalSwipeViewSliderBarKVOContext];
        } else {
            [vc removeObserver:self forKeyPath:@"title"];
        }
    }
    
    _currentController = nil;
    
    RN(_sliderBar);
    RN(_buttons)
    
    [super dealloc];
}

#pragma mark - properties

//update the center of the slider to the specified percentage
-(void)updateSliderToPosition:(CGFloat)position{
    [self layoutIfNeeded]; //force a layout so we know current width
    
    CGRect frame = _sliderBar.frame;
    frame.origin.x = ((self.bounds.size.width - frame.size.width) * position);
    _sliderBar.frame = frame;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    //set the size for the slider bar
    CGFloat sliderW = [_buttons count] ? floor(self.bounds.size.width / [_buttons count]) : 0.0f;
    CGFloat sliderH = [self sliderHeight];
    CGFloat sliderX = _sliderBar.frame.origin.x;//current
    CGFloat sliderY = self.bounds.size.height - sliderH;
    _sliderBar.frame =  CGRectMake(sliderX, sliderY, sliderW, sliderH);
    
    //layout buttons
    CGFloat buttonW = sliderW;
    CGFloat buttonH = [self buttonHeight];
    CGFloat buttonX = 0.0f;
    CGFloat buttonY = self.bounds.size.height - buttonH;
    
    for (UIButton *button in _buttons) {
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        buttonX += buttonW;
    }
    
    
}

-(IBAction)barButtonPressed:(id)sender{
    NSInteger index = [_buttons indexOfObject:sender];
    if (!_currentController.isLocked){
        [_currentController setCurrentIndex:index animated:YES];
    }
}

#pragma mark - RHHorizontalSwipeViewControllerStatusUpdateProtocol
-(void)subscribedToStatusUpdatesForViewController:(RHHorizontalSwipeViewController*)controller{
    _currentController = controller;
}

-(void)unsubscribedFromStatusUpdatesForViewController:(RHHorizontalSwipeViewController*)controller{

    //remove kvo observers
    for (UIViewController *vc in _currentController.orderedViewControllers) {
        if ([NSObject instancesRespondToSelector:@selector(removeObserver:forKeyPath:context:)]){
            [vc removeObserver:self forKeyPath:@"title" context:RHHorizontalSwipeViewSliderBarKVOContext];
        } else {
            [vc removeObserver:self forKeyPath:@"title"];
        }
    }
    
    _currentController = nil;
    
}

//layout overrides
-(CGFloat)sliderHeight{
    return self.bounds.size.height;
}
-(CGFloat)buttonHeight{
    return self.bounds.size.height;
}
-(UIButton*)configuredButton{
    UIButton *button = [[[UIButton alloc] init] autorelease];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(barButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


//controller updating 
-(void)scrollViewController:(RHHorizontalSwipeViewController *)controller orderedViewControllersChangedFrom:(NSArray *)oldViewControllers to:(NSArray *)newViewControllers{
    //just grab their titles and use them as our button titles
    [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttons release];
    _buttons = [[NSMutableArray array] retain];
    
    //remove old observers
    for (UIViewController *vc in oldViewControllers) {
        if ([NSObject instancesRespondToSelector:@selector(removeObserver:forKeyPath:context:)]){
            [vc removeObserver:self forKeyPath:@"title" context:RHHorizontalSwipeViewSliderBarKVOContext];
        } else {
            [vc removeObserver:self forKeyPath:@"title"];
        }
    }
    
    for (UIViewController *vc in newViewControllers) {
        [vc addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:RHHorizontalSwipeViewSliderBarKVOContext];
        
        UIButton *button = [self configuredButton];
        [button setTitle:[vc title] forState:UIControlStateNormal];
        [(NSMutableArray*)_buttons addObject:button];
        [self addSubview:button];
    }
    
    [self setNeedsLayout];
}


//positional updating
-(void)scrollViewController:(RHHorizontalSwipeViewController*)controller updatedPercentagePosition:(CGFloat)position{
    [self updateSliderToPosition:position];
}

//kvo observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //controller titles
    if ([keyPath isEqualToString:@"title"] && context == RHHorizontalSwipeViewSliderBarKVOContext){
        
        //find index of button to update
        NSUInteger index = [_currentController.orderedViewControllers indexOfObject:object];
        
        if (index != NSNotFound && [_buttons count] > index){
            //update the buttons title
            NSString *title = [object title];            
            [[_buttons objectAtIndex:index] setTitle:title forState:UIControlStateNormal];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
