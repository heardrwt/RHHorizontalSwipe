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

@implementation RHLayoutScrollViewController {
    NSUInteger _unloadedCurrentIndex;
    NSUInteger _preRotationIndex;
    
    NSArray *_orderedViewControllers;
    
    RHLayoutScrollView *_layoutScrollView;

}

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [_orderedViewControllers release]; _orderedViewControllers  = nil;    
    [_layoutScrollView release]; _layoutScrollView = nil;

    [super dealloc];
}


#pragma mark - Properties
@synthesize orderedViewControllers=_orderedViewControllers;
@synthesize layoutScrollView=_layoutScrollView;

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
    }
}

-(void)setLocked:(BOOL)locked{
    _layoutScrollView.scrollEnabled = !locked;
}

-(BOOL)isLocked{
    return !_layoutScrollView.scrollEnabled;
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    //add our scrollview
    _layoutScrollView = [[RHLayoutScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _layoutScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _layoutScrollView.pagingEnabled = YES;
    [_layoutScrollView setBackgroundColor:[UIColor orangeColor]];

    [_layoutScrollView setOrderedViews:[_orderedViewControllers valueForKey:@"view"]];
    [_layoutScrollView setCurrentIndex:_unloadedCurrentIndex animated:NO];
    
    [self.view addSubview:_layoutScrollView];
    
    //add a position indicator view
    //TODO:
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


@end
