//
//  RHAppDelegate.m
//  LeftMiddleRight
//
//  Created by Richard Heard on 23/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "RHAppDelegate.h"

#import "RHViewController.h"
#import "RHHorizontalSwipeViewController.h"

#import "RHTableView.h"

#import <RHHorizontalSwipe/RHHorizontalSwipe.h>

#import <QuartzCore/QuartzCore.h>

@implementation RHAppDelegate

@synthesize window = _window;
@synthesize layoutScrollViewController= _layoutScrollViewController;

- (void)dealloc
{
    [_window release];
    [_layoutScrollViewController release];    
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //create our window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    
    //create out layout scrollview. it loads its own view on demand using [[UIScreen mainScreen] bounds]
    self.layoutScrollViewController = [[[RHHorizontalSwipeViewController alloc] init] autorelease];
    [self.window setRootViewController:self.layoutScrollViewController];
    
    
    //create 3 example display views
    UIViewController *vc = nil;
    
    // 1
    vc = [[[RHTableView alloc] init] autorelease];
    [vc.view setBackgroundColor:[UIColor greenColor]];
    vc.title = @"Left";
    UIViewController *leftViewController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    leftViewController.title = @"Left";

    // 2
    vc = [[[RHViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [vc.view setBackgroundColor:[UIColor blueColor]];
    vc.title = @"Middle";
    UIViewController *middleViewController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    [[(UINavigationController*)middleViewController navigationBar] setBarStyle:UIBarStyleBlack];

    // 3 (without nav stack)
    vc = [[[RHViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [vc.view setBackgroundColor:[UIColor redColor]];
    vc.title = @"Right";
    UIViewController *rightViewController = vc;

    NSArray *controllers = [NSArray arrayWithObjects:leftViewController, 
                            middleViewController,
                            rightViewController, nil];
    
    //add them as the ordered views in the layoutScrollViewController
    [self.layoutScrollViewController setOrderedViewControllers:controllers];
    
    CGFloat width = self.layoutScrollViewController.view.bounds.size.width;
    CGFloat height = self.layoutScrollViewController.view.bounds.size.height;
    
    //install the slider bar
    RHHorizontalSwipeViewSliderBar *sliderBar = [[[RHHorizontalSwipeViewSliderBar alloc] initWithFrame:CGRectMake(0.0f, height - 22.0f, width, 22.0f)] autorelease];
    [self.layoutScrollViewController addOverlayView:sliderBar];

    //install the expanding Button view
    RHHorizontalSwipeViewExpandingButtonView *sliderButton = [[[RHHorizontalSwipeViewExpandingButtonView alloc] initWithFrame:CGRectMake(0.0f, height - 40.0f - 22.0f, width, 40.0f)] autorelease];
    [self.layoutScrollViewController addOverlayView:sliderButton];
    sliderButton.startPercentage = 0.50f;
    sliderButton.endPercentage = 1.00f;
    

    //set some expanding button demo properties
    [sliderButton.leftButton setTitle:@"L" forState:UIControlStateNormal];
    [sliderButton.rightButton setTitle:@"R" forState:UIControlStateNormal];
    
    sliderButton.leftButton.clipsToBounds = YES;
    sliderButton.rightButton.clipsToBounds = YES;

    sliderButton.leftButton.layer.cornerRadius = 10.0f;
    sliderButton.rightButton.layer.cornerRadius = 10.0f;

    sliderButton.leftButton.backgroundColor = [UIColor lightGrayColor];
    sliderButton.rightButton.backgroundColor = [UIColor lightGrayColor];
    
    
    //set our current controller to 1
    [self.layoutScrollViewController setCurrentIndex:1];
    self.layoutScrollViewController.autoLockingEnabled = YES;
    self.layoutScrollViewController.autoHidingEnabled = YES;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
