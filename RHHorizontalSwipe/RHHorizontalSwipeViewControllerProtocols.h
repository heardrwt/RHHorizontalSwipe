//
//  RHHorizontalSwipeViewControllerProtocols.h
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

#import <Foundation/Foundation.h>

@class RHHorizontalSwipeViewController;

@protocol RHHorizontalSwipeViewControllerStatusUpdateProtocol <NSObject>

@optional

//subscription
-(void)subscribedToStatusUpdatesForViewController:(RHHorizontalSwipeViewController*)controller;
-(void)unsubscribedFromStatusUpdatesForViewController:(RHHorizontalSwipeViewController*)controller; //good place to nil out any weak refs to the current controller


//view controllers changed
-(void)scrollViewController:(RHHorizontalSwipeViewController*)controller orderedViewControllersChangedFrom:(NSArray*)oldViewControllers to:(NSArray*)newViewControllers;

//positional updating
-(void)scrollViewController:(RHHorizontalSwipeViewController*)controller updatedNumberOfPages:(NSInteger)numberOfPages;
-(void)scrollViewController:(RHHorizontalSwipeViewController*)controller updatedCurrentPage:(NSInteger)page;
-(void)scrollViewController:(RHHorizontalSwipeViewController*)controller updatedPercentagePosition:(CGFloat)position;

@end


//layout scroll view controller overlay view protocol
@protocol RHHorizontalSwipeViewControllerOverlayViewProtocol <RHHorizontalSwipeViewControllerStatusUpdateProtocol>

@optional

//visibility
-(BOOL)alwaysVisible; //defaults to no


//added/removed to/from scrollviewcontroller
-(void)addedToScrollViewController:(RHHorizontalSwipeViewController*)controller;
-(void)removedFromScrollViewController:(RHHorizontalSwipeViewController*)controller; //good place to nil out any weak refs to the current controller

@end
