//
//  RHLayoutScrollView.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 24/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RHLayoutScrollView;
@protocol RHLayoutScrollViewDelegate <NSObject>

-(void)scrollView:(RHLayoutScrollView*)scrollView updateForPercentagePosition:(CGFloat)position;

@end

@interface RHLayoutScrollView : UIView <UIScrollViewDelegate>{
    id <RHLayoutScrollViewDelegate> _delegate; //weak
    
    UIScrollView *_scrollView;
    NSArray *_orderedViews;
}
//delegate
@property (assign, nonatomic) id <RHLayoutScrollViewDelegate> delegate;

//views
@property (readonly, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) NSArray *orderedViews;

//index
@property (assign, nonatomic) NSUInteger currentIndex;
-(void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@end
