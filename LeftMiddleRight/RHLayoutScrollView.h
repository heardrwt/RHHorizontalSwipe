//
//  RHLayoutScrollView.h
//  LeftMiddleRight
//
//  Created by Richard Heard on 24/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHLayoutScrollView : UIScrollView{
    NSArray *_orderedViews;
}

@property (retain, nonatomic) NSArray *orderedViews;

@property (assign, nonatomic) NSUInteger currentIndex;
-(void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@end
