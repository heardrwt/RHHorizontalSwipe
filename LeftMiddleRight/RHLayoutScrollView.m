//
//  RHLayoutScrollView.m
//  LeftMiddleRight
//
//  Created by Richard Heard on 24/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "RHLayoutScrollView.h"

@implementation RHLayoutScrollView

@synthesize orderedViews=_orderedViews;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

-(void)setOrderedViews:(NSArray *)orderedViews{
    if (_orderedViews != orderedViews){
        [_orderedViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_orderedViews release];
        _orderedViews = [orderedViews retain];
        
        for (UIView*view in _orderedViews) {
            [self addSubview:view];
        }
        
        [self setNeedsLayout];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    //layout our ordered views based on their current dimensions paged horizontally
    CGFloat xOffset = 0.0f;
    for (UIView *view in _orderedViews) {
        CGRect frame = view.frame;
        frame.origin.x = xOffset;
        frame.origin.y = 0.0f;
        view.frame = frame;
        xOffset += frame.size.width;
    }
    
    self.contentSize = CGSizeMake(xOffset, self.bounds.size.height);    
}


-(NSUInteger)currentIndex{
    return MIN(roundf(self.contentOffset.x / self.bounds.size.width), [_orderedViews count]);
}

-(void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated{
    if (currentIndex >= [_orderedViews count]) currentIndex = [_orderedViews count];
    
    [self setContentOffset:CGPointMake(self.bounds.size.width * currentIndex, 0.0f) animated:animated];    
}

-(void)setCurrentIndex:(NSUInteger)currentIndex{
    [self setCurrentIndex:currentIndex animated:YES];
}


@end
