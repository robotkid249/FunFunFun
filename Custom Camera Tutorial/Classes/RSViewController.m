//
//  RSViewController.m
//  Circa
//
//  Created by R0CKSTAR on 7/31/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import "RSViewController.h"
#import <Parse/Parse.h>
#import "RSCircaPageControl.h"
#import "SBlur.h"
#import <QuartzCore/QuartzCore.h>
#import <LiveFrost/LiveFrost.h>
#import "MBProgressHUD.h"
#import "CameraCaptureViewController.h"

@interface RSView : UIView

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readonly, strong) LFGlassView *glassView;


@end

@implementation RSView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *child = nil;
    if ((child = [super hitTest:point withEvent:event]) == self) {
    	return self.scrollView;
    }
    return child;
}

@end

@interface RSViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) RSView *clipView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) RSCircaPageControl *pageControl;

@end

@implementation RSViewController

static const int kScrollViewHeight        = 420;
static const int kScrollViewContentHeight = 600;
static const int kScrollViewTagBase       = 500;


- (void)viewDidAppear:(BOOL)animated {
    
    
    
    
    [super viewDidAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *myString = [prefs stringForKey:@"integerKey"];
    int value = [myString intValue];
    NSLog(@"WHOAO%d", value);
    
    
    if (value == 1) {
        NSLog(@"push");
        UIViewController *vc = [[ShowImageViewController alloc] init];
        [self.navigationController presentViewController:vc animated:NO completion:nil];
        
    }
    
    if (value == 2) {
        NSLog(@"push");
        UIViewController *vc = [[CameraCaptureViewController alloc] init];
        [self.navigationController presentViewController:vc animated:NO completion:nil];
        
    }
    
    
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
        
        
    }
    
    [self createScroll];
    
    
}



#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect labelFrame = CGRectMake( 0, self.view.bounds.size.height/4, 320, 30 );
    label = [[UILabel alloc] initWithFrame: labelFrame];
    [label setText: @""];
    label.font = [UIFont fontWithName:@"Helvetica" size:30];
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor: [UIColor whiteColor]];
    
    touchHappened = 0;
    
    
    glassViewR = nil;
    glassView = nil;
    [glassView removeFromSuperview];
    [glassViewR removeFromSuperview];
    
    snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *sButton = [UIImage imageNamed:@"takePhoto.png"];
    snapButton.frame = CGRectMake(273, 25, 35, 35);
    [snapButton setImage:sButton forState:UIControlStateNormal];
    snapButton.contentMode = UIViewContentModeScaleAspectFit;
    [snapButton addTarget:self
                   action:@selector(snapImage:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:snapButton];
    
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *sButton2 = [UIImage imageNamed:@"men.png"];
    menuButton.frame = CGRectMake(15, 25, 40, 35);
    [menuButton setImage:sButton2 forState:UIControlStateNormal];
    menuButton.contentMode = UIViewContentModeScaleAspectFit;
    [menuButton addTarget:self
                   action:@selector(menu:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuButton];
    
    
    
    
    
    
    letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, -5, 200, 100)];
    [letterLabel setText:@"Heartwood"];
    letterLabel.shadowColor = [UIColor blackColor];
    letterLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    letterLabel.backgroundColor = [UIColor clearColor];
    letterLabel.textAlignment = NSTextAlignmentCenter;
    UIColor *color = [UIColor whiteColor];
    [letterLabel setTextColor:color];
    letterLabel.font = [UIFont fontWithName:@"Remachine Script Personal Use" size:50];
    
    self.view.backgroundColor = [UIColor blackColor];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    
    
    
    [self createScroll];
    
    
    
    
    
    
    NSLog(@"%lu",(unsigned long) imageDataArray);
    
}

- (void)createScroll {
    
    
    //[self.clipView removeFromSuperview];
    // [self.scrollView removeFromSuperview];
    // [self.pageControl removeFromSuperview];
    imageDataArray = nil;
    imageDataArraySecond = nil;
    imageDataArrayBlurred = nil;
    userArray = nil;
    timestampArray = nil;
    
    
    verbArray = nil;
    userArray = nil;
    [sv removeFromSuperview];
    [glassView removeFromSuperview];
    [glassViewR removeFromSuperview];
    [left removeFromSuperview];
    [right removeFromSuperview];
    [snapButton removeFromSuperview];
    [menuButton removeFromSuperview];
    [Label removeFromSuperview];
    
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(-100, -100, 640, 1136)];
    bg.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bg];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    // From http://stackoverflow.com/questions/1220354/uiscrollview-horizontal-paging-like-mobile-safari-tabs/1220605#1220605
    self.clipView = [[RSView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.clipView.clipsToBounds = YES;
    [self.view addSubview:self.clipView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.clipView.bounds.size.width, self.view.bounds.size.height)];
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.scrollView];
    self.clipView.scrollView = self.scrollView;
    
    self.pageControl = [[RSCircaPageControl alloc] initWithNumberOfPages:10];
    CGRect frame = self.pageControl.frame;
    frame.origin.x = self.view.bounds.size.width - frame.size.width - 10;
    frame.origin.y = roundf((self.view.bounds.size.height - frame.size.height) / 2.);
    self.pageControl.frame = frame;
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.pageControl setCurrentPage:0 usingScroller:NO];
    [self.view addSubview:self.pageControl];
    
    CGFloat currentY = 0;
    
    imageDataArray = [NSMutableArray array];
    imageDataArraySecond = [NSMutableArray array];
    imageDataArrayBlurred = [NSMutableArray array];
    verbArray = [NSMutableArray array];
    userArray = [NSMutableArray array];
    captionArray = [NSMutableArray array];
    timestampArray = [NSMutableArray array];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Loading...";
    [hud show:YES];
    
    /*   if (glassView == NULL || glassViewR == NULL) {
     glassView = [[LFGlassView alloc] initWithFrame:(CGRect){ -130, 20, 200, 47 }];
     glassView.backgroundColor = [UIColor whiteColor];
     glassView.layer.cornerRadius = 23.f;
     glassView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
     [self.view addSubview:glassView];
     
     left = [[UIView alloc] initWithFrame:CGRectMake(-130, 20, 200, 47)];
     left.backgroundColor = [UIColor whiteColor];
     left.layer.cornerRadius = 23.f;
     left.alpha = 0.05;
     [self.view addSubview:left];
     
     
     glassViewR = [[LFGlassView alloc] initWithFrame:(CGRect){ 250, 20, 200, 47 }];
     glassViewR.backgroundColor = [UIColor whiteColor];
     glassViewR.layer.cornerRadius = 23.f;
     glassViewR.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
     [self.view addSubview:glassViewR];
     
     right = [[UIView alloc] initWithFrame:CGRectMake(250, 20, 200, 47)];
     right.backgroundColor = [UIColor whiteColor];
     right.layer.cornerRadius = 23.f;
     right.alpha = 0.05;
     [self.view addSubview:right];
     }
     */
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhotos"];
    query.limit = 10;
    //[query whereKey:@"Hidden" equalTo:@];
    [query orderByDescending:@"updatedAt"];
    
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object);
                
                
                
                if (object[@"verb"] == NULL) {
                    verb = @"";
                } else {
                    verb = object[@"verb"];
                }
                [verbArray addObject:verb];
                
                
                
                if (object[@"Caption"] == NULL) {
                    caption  = @"";
                } else {
                    caption = object[@"Caption"];
                }
                
                [captionArray addObject:caption];
                
                NSString *user = object[@"user"];
                [userArray addObject:user];
                
                
                
                
                
                
                PFFile *theImage = [object objectForKey:@"firstImage"];
                NSData *imageData = [theImage getData];
                image = [UIImage imageWithData:imageData];
                [imageDataArray addObject:image];
                
                PFFile *theImage2 = [object objectForKey:@"secondImage"];
                NSData *imageData2 = [theImage2 getData];
                image2 = [UIImage imageWithData:imageData2];
                [imageDataArraySecond addObject:image2];
                
                PFFile *blurredImageFile = [object objectForKey:@"firstImage"];
                NSData *blurredImageData = [blurredImageFile getData];
                blurredImage = [SBlur blur:[UIImage imageWithData:blurredImageData] blurRadius:20.f];
                [imageDataArrayBlurred addObject:blurredImage];
                
                NSLog(@"Photos %@", userArray);
                
                
                [self succeeded];
                [hud hide:YES];
                
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    
    
    for (i = 0; i < 10; i++) {
        
        
        
        
        sv = [[UIView alloc] initWithFrame:CGRectMake(0, currentY, self.scrollView.bounds.size.width, self.view.bounds.size.height)];
        sv.tag = i;
        //sv.delegate = self;
        sv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        sv.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:sv];
        currentY += self.view.bounds.size.height;
        
        
        
        
    }
    
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, currentY);
    
    [self.view addSubview:letterLabel];
    
    
    
    [self.view addSubview:snapButton];
    [self.view addSubview:menuButton];
    [self.view addSubview: label];
    
    
    
    
    
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}


- (void)succeeded {
    
    
    
    
    for (sv in self.scrollView.subviews) {
        
        NSLog(@"Wow %lu", (unsigned long)imageDataArray.count);
        
        if (imageDataArray.count == 10) {
            NSLog(@"good");
            
            for (int val = 0; val < 10; val++) {
                
                if (sv.tag == val) {
                    
                    
                    
                    blurredImage = [imageDataArrayBlurred objectAtIndex:val];
                    UIImage *imageToDisplay =
                    [UIImage imageWithCGImage:[blurredImage CGImage]
                                        scale:1.0
                                  orientation: UIImageOrientationUp];
                    
                    thing = [imageDataArray objectAtIndex:val];
                    thing2 = [imageDataArraySecond objectAtIndex:val];
                    blurredImage = [imageDataArrayBlurred objectAtIndex:val];
                    
                    
                    button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchDown];
                    [button addTarget:self action:@selector(buttonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
                    [button addTarget:self action:@selector(buttonTouchedUp:) forControlEvents:UIControlEventTouchCancel];
                    
                    button.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
                    //thing = [imageDataArray objectAtIndex:val];
                    // thing2 = [imageDataArraySecond objectAtIndex:val];
                    // blurredImage = [imageDataArrayBlurred objectAtIndex:val];
                    button.tag = val;
                    //   [button setImage:imageToDisplay forState:UIControlStateNormal];
                    // [button setImage:thing2 forState:UIControlStateHighlighted];
                    
                    first = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                    first.image = imageToDisplay;
                    first.tag = val;
                    first.alpha = 1.0;
                    [sv addSubview:first];
                    
                    
                    [sv addSubview:button];
                    
                    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, (self.view.bounds.size.height-100), 260, 100)];
                    captionLabel.numberOfLines = 4;
                    NSString *captionText = [captionArray objectAtIndex:val];
                    [captionLabel setText:captionText];
                    captionLabel.shadowColor = [UIColor blackColor];
                    captionLabel.shadowOffset = CGSizeMake(1.0, 1.0);
                    captionLabel.backgroundColor = [UIColor clearColor];
                    captionLabel.textAlignment = NSTextAlignmentLeft;
                    UIColor *color = [UIColor whiteColor];
                    [captionLabel setTextColor:color];
                    captionLabel.font = [UIFont fontWithName:@"Proxima Nova" size:15];
                    [sv addSubview:captionLabel];
                    [sv bringSubviewToFront:captionLabel];
                    
                    
                    
                    /*
                     UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, (self.view.bounds.size.height-120), 270, 100)];
                     userLabel.numberOfLines = 1;
                     NSString *userText = [userArray objectAtIndex:val];
                     [userLabel setText:userText];
                     userLabel.shadowColor = [UIColor blackColor];
                     userLabel.shadowOffset = CGSizeMake(1.0, 1.0);
                     userLabel.backgroundColor = [UIColor clearColor];
                     userLabel.textAlignment = NSTextAlignmentLeft;
                     [userLabel setTextColor:color];
                     userLabel.font = [UIFont fontWithName:@"Proxima Nova" size:15];
                     [sv addSubview:userLabel];
                     [sv bringSubviewToFront:userLabel];*/
                    
                    
                    greenText = [verbArray objectAtIndex:val];
                    NSLog(@"%@", greenText);
                    
                    
                    Label = [[UILabel alloc] initWithFrame:CGRectMake(10, -35, 300, (self.view.bounds.size.height))];
                    Label.backgroundColor = [UIColor clearColor];
                    Label.textAlignment = NSTextAlignmentCenter;
                    NSString *redText = @"I am ";
                    Label.textColor = [UIColor whiteColor];
                    Label.text = redText;
                    Label.shadowColor = [UIColor blackColor];
                    Label.shadowOffset = CGSizeMake(1.0, 1.0);
                    Label.font = [UIFont fontWithName:@"Proxima Nova" size:55];
                    [sv addSubview:Label];
                    
                    Label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 300, (self.view.bounds.size.height))];
                    Label2.backgroundColor = [UIColor clearColor];
                    Label2.textAlignment = NSTextAlignmentCenter;
                    greenText = [verbArray objectAtIndex:val];
                    
                    if ([greenText isEqual: @"at +"]) {
                        greenColor = [UIColor colorWithRed:0 green:1 blue:0.498 alpha:1];
                    }
                    if ([greenText isEqual: @"with +"]) {
                        greenColor = [UIColor colorWithRed:0.043 green:0.71 blue:1 alpha:1];
                    }
                    if ([greenText isEqual: @"feeling +"]) {
                        greenColor = [UIColor colorWithRed:0.898 green:0.247 blue:0.325 alpha:1];
                        
                    }
                    if ([greenText isEqual: @"watching +"]) {
                        greenColor = [UIColor colorWithRed:1 green:0.49 blue:0.251 alpha:1];
                        
                    }
                    if ([greenText isEqual: @"eating +"]) {
                        greenColor = [UIColor colorWithRed:0.729 green:0.333 blue:0.827 alpha:1];
                        
                    }
                    if ([secondText isEqual: @"reading +"]) {
                        greenColor = [UIColor colorWithRed:0.318 green:0.498 blue:0.643 alpha:1];
                        
                    }
                    
                    Label2.text = greenText;
                    Label2.textColor = greenColor;
                    Label2.shadowColor = [UIColor blackColor];
                    Label2.shadowOffset = CGSizeMake(1.0, 1.0);
                    Label2.font = [UIFont fontWithName:@"Proxima Nova" size:55];
                    [sv addSubview:Label2];
                    
                    
                    
                    /*     heartButton = [UIButton buttonWithType:UIButtonTypeCustom];
                     [heartButton setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
                     heartButton.frame = CGRectMake(250, (self.view.bounds.size.height)-55, 65, 35);
                     heartButton.contentMode = UIViewContentModeScaleAspectFit;
                     [heartButton addTarget:self
                     action:@selector(heart:)
                     forControlEvents:UIControlEventTouchUpInside];
                     heartButton.tag = val;
                     [sv addSubview:heartButton];
                     [sv bringSubviewToFront:heartButton];
                     
                     
                     
                     
                     
                     menButton = [UIButton buttonWithType:UIButtonTypeCustom];
                     menButton.frame = CGRectMake(5, (self.view.bounds.size.height)-55, 65, 35);
                     [menButton setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
                     menButton.contentMode = UIViewContentModeScaleAspectFit;
                     [menButton addTarget:self
                     action:@selector(men:)
                     forControlEvents:UIControlEventTouchUpInside];
                     menButton.tag = val;
                     [sv addSubview:menButton];
                     
                     [sv bringSubviewToFront:heartButton];
                     [sv bringSubviewToFront:menButton];*/
                    
                    [self.view addSubview:letterLabel];
                    
                    
                    
                }
                
            }
            
            
        }
        
    }
    
    
    
    
    
    /*  [self.view bringSubviewToFront:glassView];
     [self.view bringSubviewToFront:left];
     [self.view bringSubviewToFront:glassViewR];
     [self.view bringSubviewToFront:right];*/
    
    
    
    
}

- (void)_timerFired {
    
    NSLog(@"fired");
    
    
    switch (valueSwitch) {
        case 0:
            first.alpha = 0.0;
            second.alpha = 1.0;
            valueSwitch = 1;
            break;
        case 1:
            first.alpha = 1.0;
            second.alpha = 0.0;
            valueSwitch = 0;
            
            break;
            
            
    }
    
}


- (void)buttonTouched:(id)sender {
    
    
    
    
    NSLog(@"touched");
    
    touchHappened = 1;
    
    
    NSInteger value = [sender tag];
    
    //  if (btn.tag == 0) {
    NSLog(@"%ld", (long)value);
    
    
    
    if (_timer == nil) {
        
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.7f
                                                  target:self
                                                selector:@selector(_timerFired)
                                                userInfo:nil
                                                 repeats:YES];
        
        valueSwitch = 0;
    }
    
    if (first == nil || second == nil || indicator == nil) {
        
        
        
        first = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        first.image = [imageDataArray objectAtIndex:value];
        //first.tag = val;
        first.alpha = 1.0;
        [self.view addSubview:first];
        
        second = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        second.image = [imageDataArraySecond objectAtIndex:value];
        //first.tag = val;
        second.alpha = 0.0;
        [self.view addSubview:second];
        
        /*  indicator = [[UIView alloc] initWithFrame:CGRectMake(300, 0, 20, self.view.bounds.size.height)];
         indicator.backgroundColor = [UIColor blackColor];
         indicator.alpha = 0.5;
         [self.view addSubview:indicator];*/
        
        
        [self.view bringSubviewToFront:letterLabel];
        [self.view bringSubviewToFront:glassViewR];
        [self.view bringSubviewToFront:glassView];
        [self.view bringSubviewToFront:menuButton];
        [self.view bringSubviewToFront:snapButton];
        
        
    }
    
    
    
}








- (void)buttonTouchedUp:(id)sender {
    
    NSLog(@"touched");
    
    touchHappened = 0;
    
    [_timer invalidate];
    _timer = nil;
    
    [first removeFromSuperview];
    [second removeFromSuperview];
    first = nil;
    second = nil;
    
    [indicator removeFromSuperview];
    indicator = nil;
    
}

- (void)snapImage:(id)sender {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:0 forKey:@"integerKey"];
    
    UIViewController *vc = [[CameraCaptureViewController alloc] init];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)menu:(id)sender {
    
    
}

- (void)heart:(id)sender {
    
    
}

- (void)men:(id)sender {
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.scrollView) {
        float percentage = scrollView.contentOffset.y / (scrollView.contentSize.height - scrollView.bounds.size.height);
        [self.pageControl updateScrollerAtPercentage:percentage animated:YES];
        
        
    }
    
    
    
    
    CGPoint	p =self.scrollView.contentOffset;
    NSLog(@"x = %f, y = %f", p.x, p.y);
    
    if (p.y > -70.f) {
        NSLog(@"hit");
        letterLabel.font = [UIFont fontWithName:@"Remachine Script Personal Use" size:50];
        [letterLabel setText: @"Heartwood"];
        
    }
    if (p.y < -70.f) {
        NSLog(@"hit");
        letterLabel.font = [UIFont fontWithName:@"Proxima Nova" size:30];
        [letterLabel setText: @"Pull to refresh!"];
        
        
    }
    if (p.y < -90.f) {
        NSLog(@"hit me");
        letterLabel.font = [UIFont fontWithName:@"Proxima Nova" size:30];
        [letterLabel setText: @"A little more!"];
        
    }
    if (p.y < -120.f) {
        [self createScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        int index = (int)(scrollView.contentOffset.y / kScrollViewHeight);
        UIScrollView *sv = (UIScrollView *)[self.scrollView viewWithTag:kScrollViewTagBase + index];
        BOOL usingScroller = sv.contentSize.height > sv.bounds.size.height;
        [self.pageControl setCurrentPage:index
                           usingScroller:usingScroller];
        if (usingScroller) {
            float percentage = sv.contentOffset.y / (sv.contentSize.height - sv.bounds.size.height);
            [self.pageControl updateScrollerAtPercentage:percentage animated:NO];
        }
    }
}

@end
