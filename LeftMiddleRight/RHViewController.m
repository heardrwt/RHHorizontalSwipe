//
//  RHViewController.m
//  LeftMiddleRight
//
//  Created by Richard Heard on 23/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "RHViewController.h"

#import "RHTableView.h"

@implementation RHViewController {
    id _moreController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStylePlain target:self action:@selector(showMore:)] autorelease]; 
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)loadView{
    [super loadView];
    
    UIColor *randomColor = [UIColor colorWithRed:(arc4random() % 256 / 256.0f) 
                                     green:(arc4random() % 256 / 256.0f)  
                                      blue:(arc4random() % 256 / 256.0f)  
                                     alpha:1.0f];
    [self.view setBackgroundColor:randomColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] autorelease];
    gr.numberOfTapsRequired = 1;

    [self.view addGestureRecognizer:gr];
}

-(void)tap:(id)sender{
    RHViewController *vc = [[[RHViewController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - handle more event
-(void)showMore:(id)sender{
    if (_moreController){
        //hide
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            [(UIPopoverController*)_moreController dismissPopoverAnimated:YES];
        } else {
            //see note below on pre iOS 5
            //[[[[UIApplication sharedApplication] delegate] layoutScrollViewController] dismissModalViewControllerAnimated:YES];
            [self dismissModalViewControllerAnimated:YES];
        }
        [_moreController release];
        _moreController = nil;
        
    } else {
        
        //show
        RHTableView *vc = [[[RHTableView alloc] init] autorelease];
        vc.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(showMore:)] autorelease]; 

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            _moreController = [[UIPopoverController alloc] initWithContentViewController:vc];
            
            [_moreController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

        } else {
            _moreController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];

            
            //Before iOS 5, presenting a modal controller from self  allows for swipes from the modal view controller to switch away from the modal view. 
            //If you dont want that, you will have to present from the container view controller. (eg appDelegate.layoutScrollViewController)
            //[[[[UIApplication sharedApplication] delegate] layoutScrollViewController] presentModalViewController:_moreController animated:YES];
            [self presentModalViewController:_moreController animated:YES];
        }

    
    }
}

@end
