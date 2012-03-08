//
//  RHLayoutScrollViewController.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 24/01/12.
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

/*
 vc takes an array of view controllers, forwards events to said controllers for rotation and adds them to its views subview scrollview 
 also shows / hides the custom page indicator titles / buttons etc (collectively, overlay views)
 
 Uses iOS5 View Controller containment so as to be a good citizen.
 
 */

#import <UIKit/UIKit.h>

#import "RHLayoutScrollView.h"
#import "RHLayoutScrollViewControllerOverlayViewProtocol.h"

@interface RHLayoutScrollViewController : UIViewController <RHLayoutScrollViewDelegate, UINavigationControllerDelegate>

@property (readonly, nonatomic) RHLayoutScrollView *layoutScrollView;

@property (retain, nonatomic) NSArray *orderedViewControllers;

@property (readonly, nonatomic) UIViewController *currentViewController;

@property (assign, nonatomic) NSUInteger currentIndex;
-(void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@property (assign, nonatomic, getter=isLocked) BOOL locked; //prevent swiping between view controllers
@property (assign, nonatomic, getter=isAutoLockingEnabled) BOOL autoLockingEnabled; // if any top level nav controllers are not displaying their root view, locked, otherwise unlocked. (sets each nav controllers delegate if nil)

//overlay views, regular views installed statically over the scrollview, if they implement the RHLayoutScrollViewControllerOverlayViewProtocol, will be updated with current index position etc
-(void)addOverlayView:(UIView <RHLayoutScrollViewControllerOverlayViewProtocol> *)view;
-(void)removeOverlayView:(UIView <RHLayoutScrollViewControllerOverlayViewProtocol> *)view;

-(void)setOverlayViewsHidden:(BOOL)hidden animated:(BOOL)animated; //hide overlay views, eg for when drilled down etc
@property (assign, nonatomic, getter=isAutoHidingEnabled) BOOL autoHidingEnabled; // if any nav controllers are not showing root view, overlay views are hidden, otherwise not hidden

@end

