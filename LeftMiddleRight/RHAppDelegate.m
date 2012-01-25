//
//  RHAppDelegate.m
//  LeftMiddleRight
//
//  Created by Richard Heard on 23/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "RHAppDelegate.h"

#import "RHViewController.h"
#import "RHLayoutScrollViewController.h"

#import "RHTableView.h"
#import "RHLayoutScrollView.h"

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
    self.layoutScrollViewController = [[[RHLayoutScrollViewController alloc] init] autorelease];
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

    // 3
    vc = [[[RHViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [vc.view setBackgroundColor:[UIColor redColor]];
    vc.title = @"Right";
    UIViewController *rightViewController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];

    //add them as the ordered views in the layoutScrollViewController
    [self.layoutScrollViewController setOrderedViewControllers:[NSArray arrayWithObjects:leftViewController, 
                                               middleViewController,
                                               rightViewController,
                                               nil]];
    [self.layoutScrollViewController setCurrentIndex:1];

    
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
