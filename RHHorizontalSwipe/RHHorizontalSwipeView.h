//
//  RHHorizontalSwipeView.h
//  RHHorizontalSwipe
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

#import <UIKit/UIKit.h>

@class RHHorizontalSwipeView;
@protocol RHHorizontalSwipeViewDelegate <NSObject>

-(void)scrollView:(RHHorizontalSwipeView*)scrollView updateForPercentagePosition:(CGFloat)position;

@end

@interface RHHorizontalSwipeView : UIView <UIScrollViewDelegate>{
    id <RHHorizontalSwipeViewDelegate> _delegate; //weak
    
    UIScrollView *_scrollView;
    NSArray *_orderedViews;
}
//delegate
@property (assign, nonatomic) id <RHHorizontalSwipeViewDelegate> delegate;

//views
@property (readonly, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) NSArray *orderedViews;

//index
@property (assign, nonatomic) NSUInteger currentIndex;
-(void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

//scroll to top
-(void)scrollCurrentViewToTop; //scroll the currently active views first scrollview with scrollToTop=YES to the top.
                               //we have to use this instead of the default system provided status bar behaviour if we have more than one view hosting a scrollToTop=YES scroll view.

//scroll to top helper methods
+(NSArray*)scrollViewsForView:(UIView*)view;
+(NSArray*)scrollsToTopViewsForView:(UIView*)view;
+(UIScrollView*)firstScrollsToTopViewForView:(UIView*)view;

@end
