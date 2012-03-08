//
//  RHLayoutScrollViewController.m
//  LeftMiddleRight
//
//  Created by Richard Heard on 24/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "RHLayoutScrollViewController.h"

#import "RHAppDelegate.h"

#import "RHLayoutScrollView.h"

#define kRHScrollViewControllerShowHideOverlayAnimationDuration 0.3f

//private
@interface RHLayoutScrollViewController ()

-(void)registerNavigationControllerDelegates;
-(void)deregisterNavigationControllerDelegates;

@end

@implementation RHLayoutScrollViewController {
    NSUInteger _unloadedCurrentIndex;
    NSUInteger _preRotationIndex;
    
    NSArray *_orderedViewControllers;
    
    RHLayoutScrollView *_layoutScrollView;

    NSMutableSet *_overlayViews;
    BOOL _overlayViewsHidden;
}

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
        _overlayViews = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#define RN(x) [x release]; x = nil;

- (void)dealloc {
        
    //notify overlay views of our destruction
    for (UIView<RHLayoutScrollViewControllerOverlayViewProtocol> *overlayView in _overlayViews) {
        if ([overlayView respondsToSelector:@selector(removedFromScrollViewController:)]){
            [overlayView removedFromScrollViewController:self];
        }
    }

    //remove any delegates that point to us
    [self deregisterNavigationControllerDelegates];
    
    //regular cleanup
    
    RN(_orderedViewControllers);
    _layoutScrollView.delegate = nil;
    RN(_layoutScrollView);
    RN(_overlayViews);

    [super dealloc];
}


#pragma mark - Properties
@synthesize orderedViewControllers=_orderedViewControllers;
@synthesize layoutScrollView=_layoutScrollView;
@synthesize autoLockingEnabled=_autoLockingEnabled;
@synthesize autoHidingEnabled=_autoHidingEnabled;

-(NSUInteger)currentIndex{
    if ([self isViewLoaded]){
        return _layoutScrollView.currentIndex;
    } else {
       return _unloadedCurrentIndex;
    }    
}

-(void)setCurrentIndex:(NSUInteger)index{
    [self setCurrentIndex:index animated:YES];
}

-(void)setCurrentIndex:(NSUInteger)index animated:(BOOL)animated{
    if ([self isViewLoaded]){
        [_layoutScrollView setCurrentIndex:index animated:animated];
    } else {
        _unloadedCurrentIndex = index;
    }
}

-(UIViewController*)currentViewController{
    NSUInteger index = [self currentIndex];
    if (index >= [_orderedViewControllers count]) return nil;
    
    return [_orderedViewControllers objectAtIndex:index];
}

-(void)setOrderedViewControllers:(NSArray *)orderedViewControllers{
    if (_orderedViewControllers != orderedViewControllers){
        
        [self deregisterNavigationControllerDelegates]; //unset delegates
        
        [_layoutScrollView setOrderedViews:nil];
        
        //iOS5+ remove from containment
        if ([UIViewController instancesRespondToSelector:@selector(willMoveToParentViewController:)] && 
            [UIViewController instancesRespondToSelector:@selector(removeFromParentViewController:)]){
            for (UIViewController *vc in _orderedViewControllers) {
                [vc willMoveToParentViewController:nil];
                [vc removeFromParentViewController];
            }
        }
        
        //stash
        [_orderedViewControllers release];
        _orderedViewControllers = [orderedViewControllers retain];
        
        //iOS5+ add to containment
        if ([UIViewController instancesRespondToSelector:@selector(addChildViewController:)] && 
            [UIViewController instancesRespondToSelector:@selector(didMoveToParentViewController:)]){
            for (UIViewController *vc in _orderedViewControllers) {
                [self addChildViewController:vc];
                [vc didMoveToParentViewController:self];
            }
        }        
        
        //redisplay
        [_layoutScrollView setOrderedViews:[_orderedViewControllers valueForKey:@"view"]];
        
        //notify overlay views
        for (UIView<RHLayoutScrollViewControllerOverlayViewProtocol> *overlayView in _overlayViews) {
            if ([overlayView respondsToSelector:@selector(scrollViewController:updateNumberOfPages:)]){
                [overlayView scrollViewController:self updateNumberOfPages:[_orderedViewControllers count]];
            }
            
            if ([overlayView respondsToSelector:@selector(scrollViewController:orderedViewControllersChanged:)]){
                [overlayView scrollViewController:self orderedViewControllersChanged:_orderedViewControllers];
            }
            
        }
    
    [self registerNavigationControllerDelegates]; //re-set delegates
    
    }
}

-(void)setLocked:(BOOL)locked{
    _layoutScrollView.scrollView.scrollEnabled = !locked;
}

-(BOOL)isLocked{
    return !_layoutScrollView.scrollView.scrollEnabled;
}

-(void)setAutoLockingEnabled:(BOOL)autoLockingEnabled{
    _autoLockingEnabled = autoLockingEnabled;

    //toggle stuff...
    
}

-(void)registerNavigationControllerDelegates{
    for (UINavigationController *controller in _orderedViewControllers) {
        if ([controller isKindOfClass:[UINavigationController class]] && !controller.delegate){
            controller.delegate = self;
        }
    }
}

-(void)deregisterNavigationControllerDelegates{
    for (UINavigationController *controller in _orderedViewControllers) {
        if ([controller isKindOfClass:[UINavigationController class]] && controller.delegate == self){
            controller.delegate = nil;
        }
    }
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    //add our scrollview
    _layoutScrollView = [[RHLayoutScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _layoutScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_layoutScrollView setBackgroundColor:[UIColor orangeColor]];
    _layoutScrollView.delegate = self;

    [_layoutScrollView setOrderedViews:[_orderedViewControllers valueForKey:@"view"]];
    [_layoutScrollView setCurrentIndex:_unloadedCurrentIndex animated:NO];
    
    [self.view addSubview:_layoutScrollView];
        
    //add our overlay views, respecting the hidden flag
    for (UIView<RHLayoutScrollViewControllerOverlayViewProtocol> *overlayView in _overlayViews) {
        if (!( [overlayView respondsToSelector:@selector(alwaysVisible)] && [overlayView alwaysVisible])){
            overlayView.alpha = _overlayViewsHidden ? 0.0f : 1.0f;
        }
        [self.view addSubview:overlayView];
    }

    
}

-(void)viewDidLoad{
    [super viewDidLoad];

}

-(void)viewWillUnload{
    //store off our current index into the unloaded index variable so we can restore to the same state if needed
    _unloadedCurrentIndex = _layoutScrollView.currentIndex;

    [super viewWillUnload];
}
- (void)viewDidUnload{
    [_layoutScrollView release]; _layoutScrollView = nil;
    
    [super viewDidUnload];
}

#pragma mark - view appearance
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //fwd
    for (UIViewController *vc in _orderedViewControllers) {
        [vc viewWillAppear:animated];
    }
    
    //handle view layout rotations 
    [_layoutScrollView setCurrentIndex:_unloadedCurrentIndex animated:NO];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //fwd
    for (UIViewController *vc in _orderedViewControllers) {
        [vc viewDidAppear:animated];
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //fwd
    for (UIViewController *vc in _orderedViewControllers) {
        [vc viewWillDisappear:animated];
    }

    //store the current index so we can make sure we are still alligned after showing and hiding a modal sheet
    _unloadedCurrentIndex = _layoutScrollView.currentIndex;

} 

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //fwd
    for (UIViewController *vc in _orderedViewControllers) {
        [vc viewDidDisappear:animated];
    }

}

#pragma mark - overlay view logic
-(void)addOverlayView:(UIView <RHLayoutScrollViewControllerOverlayViewProtocol> *)view{
    [_overlayViews addObject:view];
    //add if view is loaded
    if (self.isViewLoaded) [self.view addSubview:view];
    
    
    //notify the new view of its environment
    if ([view respondsToSelector:@selector(addedToScrollViewController:)]){
        [view addedToScrollViewController:self];
    }

    if ([view respondsToSelector:@selector(scrollViewController:orderedViewControllersChanged:)]){
        [view scrollViewController:self orderedViewControllersChanged:_orderedViewControllers];
    }    
    
    
    if ([view respondsToSelector:@selector(scrollViewController:updateCurrentPage:)]){
        [view scrollViewController:self updateCurrentPage:[self currentIndex]];
    }
    
    //set hidden value
    view.alpha = _overlayViewsHidden ? 0.0f : 1.0f;

}

-(void)removeOverlayView:(UIView <RHLayoutScrollViewControllerOverlayViewProtocol> *)view{
    [_overlayViews removeObject:view];
    //remove from superview if its currently in our container view
    if ([[view superview] isEqual:self.view]) [view removeFromSuperview];
    
    if ([view respondsToSelector:@selector(removedFromScrollViewController:)]){
        [view removedFromScrollViewController:self];
    }

}

-(void)setOverlayViewsHidden:(BOOL)hidden animated:(BOOL)animated{
    NSTimeInterval duration = animated ? kRHScrollViewControllerShowHideOverlayAnimationDuration : 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        for (UIView<RHLayoutScrollViewControllerOverlayViewProtocol> *overlayView in _overlayViews) {
            if (!( [overlayView respondsToSelector:@selector(alwaysVisible)] && [overlayView alwaysVisible])){
                overlayView.alpha = hidden ? 0.0f : 1.0f;
            }
        }
    
    } completion:^(BOOL finished) {
        _overlayViewsHidden = hidden;
    }];
    
}


#pragma mark - view controller containment logic
- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers{
    return NO;
}


#pragma mark - View Orientation Forwarding Logic.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES if all our current controllers support this orientation
    
    for (UIViewController *vc in _orderedViewControllers) {
        if (![vc shouldAutorotateToInterfaceOrientation:interfaceOrientation]) return NO;
    }
    
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    for (UIViewController *vc in _orderedViewControllers) {
        if ([vc respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]){
            [(id)vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
    }

    //store the current index so we can animate to it during rotation
    _preRotationIndex = _layoutScrollView.currentIndex;

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    for (UIViewController *vc in _orderedViewControllers) {
        if ([vc respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)]){
            [(id)vc willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
        } 
    }    
    
    //handle view layout rotations 
    [_layoutScrollView setCurrentIndex:_preRotationIndex animated:NO];

    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    for (UIViewController *vc in _orderedViewControllers) {
        if ([vc respondsToSelector:@selector(didRotateFromInterfaceOrientation:)]){
            [(id)vc didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        }
    }    
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - RHLayoutScrollViewDelegate

-(void)scrollView:(RHLayoutScrollView*)scrollView updateForPercentagePosition:(CGFloat)position{
    for (UIView<RHLayoutScrollViewControllerOverlayViewProtocol> *overlayView in _overlayViews) {
        if ([overlayView respondsToSelector:@selector(scrollViewController:updateForPercentagePosition:)]){
            [overlayView scrollViewController:self updateForPercentagePosition:position];
        }
    }
}

#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //if auto locking is enabled we need to check to see if any root nav controller is currently not showing its root view controller, if so. lock, otherwise unlock
        BOOL shouldLock = NO;
        BOOL shouldHide = NO;
        
        for (UINavigationController *controller in _orderedViewControllers) {
            if ([controller isKindOfClass:[UINavigationController class]] && controller.delegate == self){
                NSUInteger index = [[controller viewControllers] indexOfObject:controller.topViewController];
                if (index != 0 && index != NSNotFound){
                    shouldLock = YES;
                    shouldHide = YES;
                }
            }
        }
    
    if (_autoLockingEnabled) [self setLocked:shouldLock];
    if (_autoHidingEnabled) [self setOverlayViewsHidden:shouldHide animated:YES];
    
}


@end
