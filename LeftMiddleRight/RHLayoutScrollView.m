//
//  RHLayoutScrollView.m
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

#import "RHLayoutScrollView.h"

@implementation RHLayoutScrollView

@synthesize orderedViews=_orderedViews;
@synthesize scrollView=_scrollView;
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        _scrollView.scrollsToTop = NO; //we dont want to steal this from our friends
    }
    return self;
}

#define RN(x) [x release]; x = nil;

- (void)dealloc{
    RN(_scrollView);
    RN(_orderedViews);
    
    [super dealloc];
}

-(void)setOrderedViews:(NSArray *)orderedViews{
    if (_orderedViews != orderedViews){
        [_orderedViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_orderedViews release];
        _orderedViews = [orderedViews retain];
        
        for (UIView *view in _orderedViews) {
            [_scrollView addSubview:view];
        }
        
        [self layoutIfNeeded];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    //keep them the same, always
    if (!CGRectEqualToRect(self.bounds, _scrollView.frame)){
        _scrollView.frame = self.bounds;
    }
    
    //layout our ordered views based on their current dimensions paged horizontally
    CGFloat xOffset = 0.0f;
    for (UIView *view in _orderedViews) {
        CGRect frame = view.frame;
        frame.origin.x = xOffset;
        frame.origin.y = 0.0f;
        view.frame = frame;
        xOffset += frame.size.width;
    }
    
    _scrollView.contentSize = CGSizeMake(xOffset, self.bounds.size.height);    
}


-(NSUInteger)currentIndex{
    return MIN(roundf(_scrollView.contentOffset.x / _scrollView.bounds.size.width), [_orderedViews count]);
}

-(void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated{
    if (currentIndex >= [_orderedViews count]) currentIndex = [_orderedViews count];
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width * currentIndex, 0.0f) animated:animated]; 
    
    //force a delegate call if not animated
    [self scrollViewDidScroll:_scrollView];
}

-(void)setCurrentIndex:(NSUInteger)currentIndex{
    [self setCurrentIndex:currentIndex animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //notify based on scroll update
    if ([_delegate respondsToSelector:@selector(scrollView:updateForPercentagePosition:)]){
        CGFloat position = scrollView.contentOffset.x;
        CGFloat total = scrollView.contentSize.width - scrollView.bounds.size.width;
        CGFloat percentage = total ? position/total : 0.0f;
        [_delegate scrollView:self updateForPercentagePosition:percentage];
    }
    
    //TODO: update based on page index change
    
}

#pragma mark - scroll to top 
//scroll the currently active views first scrollview with scrollToTop=YES to the top. 
//we have to use this instead of the default system provided status bar behaviour if we have more than one view hosting a scrollToTop=YES scroll view.
-(void)scrollCurrentViewToTop{
    //forward down to first scrollview we find under the current view
    UIView *currentView = [_orderedViews objectAtIndex:[self currentIndex]];
    UIScrollView *fwdScrollView = [RHLayoutScrollView firstScrollsToTopViewForView:currentView];
    //scroll to top
    [fwdScrollView setContentOffset:CGPointMake(fwdScrollView.contentOffset.x, 0.0f) animated:YES];
}

#pragma mark - scroll to top helper methods

+(NSArray*)scrollViewsForView:(UIView*)view{
    NSMutableArray *scrollViews = [NSMutableArray array];
    
    //first check self
    if ([view isKindOfClass:[UIScrollView class]]) [scrollViews addObject:view];
    
    //now recurse for subviews
    for (UIView *subView in view.subviews) {
        [scrollViews addObjectsFromArray:[RHLayoutScrollView scrollViewsForView:subView]];
    }
    
    return scrollViews;
}

+(NSArray*)scrollsToTopViewsForView:(UIView*)view{
    NSArray *views = [RHLayoutScrollView scrollViewsForView:view];
    NSIndexSet *set = [views indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj scrollsToTop];
    }];
    
    return [views objectsAtIndexes:set];
}

+(UIScrollView*)firstScrollsToTopViewForView:(UIView*)view{
    NSArray *topViews = [RHLayoutScrollView scrollsToTopViewsForView:view];
    if (topViews.count > 0){
        return [topViews objectAtIndex:0];
    }
    return nil;
}

@end
