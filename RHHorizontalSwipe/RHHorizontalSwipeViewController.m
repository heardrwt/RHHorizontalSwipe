//
//  RHHorizontalSwipeViewController.m
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

#import "RHHorizontalSwipeViewController.h"

#import "RHHorizontalSwipeView.h"

#define kRHHorizontalSwipeViewControllerShowHideOverlayAnimationDuration 0.3f

//private
@interface RHHorizontalSwipeViewController ()

-(void)registerNavigationControllerDelegates;
-(void)deregisterNavigationControllerDelegates;

@end

@implementation RHHorizontalSwipeViewController {
    NSUInteger _unloadedCurrentIndex;
    
    NSArray *_orderedViewControllers;
    
    RHHorizontalSwipeView *_layoutScrollView;
    
    NSMutableSet *_overlayViews;
    BOOL _overlayViewsHidden;
    
    NSMutableSet *_statusSubscribers;
    
    BOOL _willFlag; //used to decide if we need to send viewWillAppear/viewWillDisapear to controllers when setting orderedViewControllers 
    BOOL _didFlag; //used to decide if we need to send viewDidAppear/viewDidDisapear to controllers when setting orderedViewControllers 
}


- (id)init {
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
        _overlayViews = [[NSMutableSet alloc] init];
        _statusSubscribers = [[NSMutableSet alloc] init];
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
    
    //notify overlay views of our destruction, iterate over a copy of the array, because we will be mutating the original
    for (UIView<RHHorizontalSwipeViewControllerOverlayViewProtocol> *overlayView in [[_overlayViews copy] autorelease]) {
        [self removeOverlayView:overlayView];
    }
    
    //notify info subscribers about their unsubscription, iterate over a copy of the array, because we will be mutating the original
    for (id<RHHorizontalSwipeViewControllerStatusUpdateProtocol> subscriber in [[_statusSubscribers copy] autorelease]) {
        [self unsubscribeFromStatusUpdates:subscriber];
    }

    
    //remove any delegates that point to us
    [self deregisterNavigationControllerDelegates];

    
    //regular cleanup
    RN(_orderedViewControllers);
    _layoutScrollView.delegate = nil;
    RN(_layoutScrollView);
    RN(_overlayViews);
    RN(_statusSubscribers);
    
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

-(void)swipeLeftAnimated:(BOOL)animated{
    [self setCurrentIndex:self.currentIndex + 1 animated:animated];
}

-(void)swipeRightAnimated:(BOOL)animated{
    [self setCurrentIndex:self.currentIndex - 1 animated:animated];
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
            [UIViewController instancesRespondToSelector:@selector(removeFromParentViewController)]){
            for (UIViewController *vc in _orderedViewControllers) {
                [vc willMoveToParentViewController:nil];
                [vc removeFromParentViewController];                
            }
        }
        
        //call the will / did disappear methods (only if we are currently loaded)
        for (UIViewController *vc in _orderedViewControllers) {
            if(_willFlag)[vc viewWillDisappear:NO];
            if(_didFlag)[vc viewDidDisappear:NO];
        }
        
        //stash
        NSArray *oldOrderedViewControllers = [_orderedViewControllers retain];
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
        
        //call the will / did appear methods (only if we are currently loaded)
        for (UIViewController *vc in _orderedViewControllers) {
            if (_willFlag)[vc viewWillAppear:NO];
            if (_didFlag)[vc viewDidAppear:NO];
        }
        
        //redisplay
        [_layoutScrollView setOrderedViews:[_orderedViewControllers valueForKey:@"view"]];
        
        //notify status subscribers
        for (id<RHHorizontalSwipeViewControllerStatusUpdateProtocol> subscriber in _statusSubscribers) {
            if ([subscriber respondsToSelector:@selector(scrollViewController:updatedNumberOfPages:)]){
                [subscriber scrollViewController:self updatedNumberOfPages:[_orderedViewControllers count]];
            }
            
            if ([subscriber respondsToSelector:@selector(scrollViewController:orderedViewControllersChangedFrom:to:)]){
                [subscriber scrollViewController:self orderedViewControllersChangedFrom:oldOrderedViewControllers to:_orderedViewControllers];
            }
            
        }
        
        [self registerNavigationControllerDelegates]; //re-set delegates
        
        [oldOrderedViewControllers release];
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
    _layoutScrollView = [[RHHorizontalSwipeView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _layoutScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_layoutScrollView setBackgroundColor:[UIColor lightGrayColor]];
    _layoutScrollView.delegate = self;
    
    [_layoutScrollView setOrderedViews:[_orderedViewControllers valueForKey:@"view"]];
    [_layoutScrollView setCurrentIndex:_unloadedCurrentIndex animated:NO];
    
    [self.view addSubview:_layoutScrollView];
    
    //add our overlay views, respecting the hidden flag
    for (UIView<RHHorizontalSwipeViewControllerOverlayViewProtocol> *overlayView in _overlayViews) {
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
    
    //save flag
    _willFlag = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //fwd
    for (UIViewController *vc in _orderedViewControllers) {
        [vc viewDidAppear:animated];
    }
    
    //save flag
    _didFlag = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //fwd
    for (UIViewController *vc in _orderedViewControllers) {
        [vc viewWillDisappear:animated];
    }
    
    //store the current index so we can make sure we are still alligned after showing and hiding a modal sheet
    _unloadedCurrentIndex = _layoutScrollView.currentIndex;
    
    //reset flag
    _willFlag = NO;
} 

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //fwd
    for (UIViewController *vc in _orderedViewControllers) {
        [vc viewDidDisappear:animated];
    }
    
    //reset flag
    _didFlag = NO;
}

#pragma mark - overlay view logic
-(void)addOverlayView:(UIView <RHHorizontalSwipeViewControllerOverlayViewProtocol> *)view{
    [_overlayViews addObject:view];
    //add if view is loaded
    if (self.isViewLoaded) [self.view addSubview:view];
    
    
    //notify the new view of its environment
    if ([view respondsToSelector:@selector(addedToScrollViewController:)]){
        [view addedToScrollViewController:self];
    }
    
    //add to status subscribers so it gets the standard status info also.
    [self subscribeToStatusUpdates:view];
    
    //set hidden value
    view.alpha = _overlayViewsHidden ? 0.0f : 1.0f;
    
}

-(void)removeOverlayView:(UIView <RHHorizontalSwipeViewControllerOverlayViewProtocol> *)view{
    [_overlayViews removeObject:view];
    //remove from superview if its currently in our container view
    if ([[view superview] isEqual:self.view]) [view removeFromSuperview];
    
    if ([view respondsToSelector:@selector(removedFromScrollViewController:)]){
        [view removedFromScrollViewController:self];
    }

    //remove from status subscribers
    [self unsubscribeFromStatusUpdates:view];

}

-(void)setOverlayViewsHidden:(BOOL)hidden animated:(BOOL)animated{
    NSTimeInterval duration = animated ? kRHHorizontalSwipeViewControllerShowHideOverlayAnimationDuration : 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        for (UIView<RHHorizontalSwipeViewControllerOverlayViewProtocol> *overlayView in _overlayViews) {
            if (!( [overlayView respondsToSelector:@selector(alwaysVisible)] && [overlayView alwaysVisible])){
                overlayView.alpha = hidden ? 0.0f : 1.0f;
            }
        }
        
    } completion:^(BOOL finished) {
        _overlayViewsHidden = hidden;
    }];
    
}


#pragma mark - subscription logic
-(void)subscribeToStatusUpdates:(id <RHHorizontalSwipeViewControllerStatusUpdateProtocol>)subscriber{
    [_statusSubscribers addObject:subscriber];

    //notify the new subscriber of its subscription
    if ([subscriber respondsToSelector:@selector(subscribedToStatusUpdatesForViewController:)]){
        [subscriber subscribedToStatusUpdatesForViewController:self];
    }
    
    if ([subscriber respondsToSelector:@selector(scrollViewController:orderedViewControllersChangedFrom:to:)]){
        [subscriber scrollViewController:self orderedViewControllersChangedFrom:nil to:_orderedViewControllers];
    }
    
    if ([subscriber respondsToSelector:@selector(scrollViewController:updatedNumberOfPages:)]){
        [subscriber scrollViewController:self updatedNumberOfPages:[_orderedViewControllers count]];
    }
    
    
    if ([subscriber respondsToSelector:@selector(scrollViewController:updatedCurrentPage:)]){
        [subscriber scrollViewController:self updatedCurrentPage:[self currentIndex]];
    }

}

-(void)unsubscribeFromStatusUpdates:(id <RHHorizontalSwipeViewControllerStatusUpdateProtocol>)subscriber{
    
    //notify the subscriber of its unsubscription
    if ([subscriber respondsToSelector:@selector(unsubscribedFromStatusUpdatesForViewController:)]){
        [subscriber unsubscribedFromStatusUpdatesForViewController:self];
    }

    [_statusSubscribers removeObject:subscriber];

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
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    for (UIViewController *vc in _orderedViewControllers) {
        if ([vc respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)]){
            [(id)vc willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
        } 
    }    
    
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

#pragma mark - RHHorizontalSwipeViewDelegate

-(void)scrollView:(RHHorizontalSwipeView*)scrollView updateForPercentagePosition:(CGFloat)position{
    for (id<RHHorizontalSwipeViewControllerStatusUpdateProtocol> subscriber in _statusSubscribers) {
        if ([subscriber respondsToSelector:@selector(scrollViewController:updatedPercentagePosition:)]){
            [subscriber scrollViewController:self updatedPercentagePosition:position];
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
