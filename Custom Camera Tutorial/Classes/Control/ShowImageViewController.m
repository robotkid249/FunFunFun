//
//  ShowImageViewController.m
//  Custom Camera Tutorial
//
//  Created by Bruno Tortato Furtado on 30/09/13.
//  Copyright (c) 2013 Bruno Tortato Furtado. All rights reserved.
//

#import "ShowImageViewController.h"
#import <Parse/Parse.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "DRNRealTimeBlurView.h"
#import "CRTableViewCell.h"
#import "CameraCaptureViewController.h"
#import "TWBSocialHelper.h"

@interface ShowImageViewController ()

@property (nonatomic) TWBSocialHelper *localInstance;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong)ACAccountStore *accountStore;
@property (weak, nonatomic) IBOutlet UILabel *accountName;

- (void)back;

@end



@implementation ShowImageViewController

#pragma mark - UIViewController

- (void)timerFired:(id)sender {
    
    switch (Number) {
        case 0:
            
            img.alpha = 1.0;
            img2.alpha = 0.0;
            Number = 1;
            
            break;
            
        case 1:
            
            img.alpha = 0.0;
            img2.alpha = 1.0;
            Number = 0;
            
            break;
            
        default:
            break;
    }
}

-(UIImage*) rotate:(UIImage*) src andOrientation:(UIImageOrientation)orientation
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context=(UIGraphicsGetCurrentContext());
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, 90/180*M_PI) ;
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, -90/180*M_PI);
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, 90/180*M_PI);
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    UIImage *img29 =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img29;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    verb= [defaults objectForKey:@"verb"];
    NSLog(@"%@", verb);
    
    
    limit = 0;
    //img.image = self.picture;
    // img2.image = self.picture2;
    
    nextView=[[CameraCaptureViewController alloc] init];
    
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [backButton removeFromSuperview];
    
    dataSource = [[NSArray alloc] initWithObjects:
                  @"Heartwood",
                  @"Save to Camera Roll",
                  @"Twitter",
                  @"Facebook",
                  nil];
    
    selectedMarks = [NSMutableArray new];
    
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-logo"]]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setBounds:CGRectMake(0, 0, 48, 24)];
    [button setImage:[UIImage imageNamed:@"navbar-btn-back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    
    img = [[UIImageView alloc] initWithFrame:CGRectMake(20, 22, 280, 480)];
    img.alpha = 0.0;
    img.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:img];
    
    img2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 22, 280, 480)];
    img2.alpha = 0.0;
    img.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:img2];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.8
                                             target:self
                                           selector:@selector(timerFired:)
                                           userInfo:nil
                                            repeats:YES];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(12, 30, 40, 40);
    backButton.tag = i;
    UIImage *image = [UIImage imageNamed:@"back.png"];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(back:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    
    
    checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkButton.frame = CGRectMake(120, self.view.bounds.size.height-120, 80, 80);
    checkButton.tag = i;
    UIImage *immg = [UIImage imageNamed:@"check.png"];
    checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [checkButton setImage:immg forState:UIControlStateNormal];
    [checkButton addTarget:self
                    action:@selector(check:)
          forControlEvents:UIControlEventTouchUpInside];
    checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [checkButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:24.0]];
    [self.view addSubview:checkButton];
    
    
    
    
    
    
}

- (void)back:(id)sender {
    
    
    UIViewController *viewc = [[CameraCaptureViewController alloc] init];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

- (void)check:(id)sender {
    
    [timer invalidate];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    img.alpha = 1.0;
    img2.alpha = 0.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAccountName)
                                                 name:@"ReadAccessGranted"
                                               object:nil];
    
    _localInstance = [TWBSocialHelper sharedHelper];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_localInstance requestReadAccessToFacebook];
    });
    
    
    
    img.contentMode = UIViewContentModeScaleAspectFill;
    
    [checkButton removeFromSuperview];
    
    [backButton removeFromSuperview];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(12, 30, 40, 40);
    backButton.tag = i;
    UIImage *image = [UIImage imageNamed:@"back.png"];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(back:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    //   [newPost setObject:[textView text] forKey:@"textContent"];
    
    
    
    blurView = [[DRNRealTimeBlurView alloc] initWithFrame:CGRectMake(-320, -self.view.bounds.size.height, 640, 1136*2)];
    blurView.renderStatic = NO;
    [self.view addSubview:blurView];
    
    sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    sv.scrollEnabled = YES;
    sv.clipsToBounds = YES;
    sv.backgroundColor = [UIColor clearColor];
    sv.contentSize = CGSizeMake(self.view.bounds.size.width, ((dataSource.count*100)+400));
    [self.view addSubview:sv];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(12, 30, 40, 40);
    backButton.tag = i;
    UIImage *image2 = [UIImage imageNamed:@"back.png"];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [backButton setImage:image2 forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(back:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, self.view.bounds.size.width, 40)];
    label.text = @"Share it...";
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor: [UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:23.0]];
    [self.view addSubview:label];
    
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 80, 280, 100)];
    [textView setFont:[UIFont systemFontOfSize:16]];
    textView.layer.cornerRadius = 5;
    textView.alpha = 0.7;
    textView.delegate = self;
    //   [textView becomeFirstResponder];
    [sv addSubview:textView];
    
    charCount = [[UILabel alloc] initWithFrame:CGRectMake(260, 110, 100, 100)];
    charCount.text = @"120";
    charCount.font = [UIFont fontWithName:@"Helvetica" size:12];
    [sv addSubview:charCount];
    
    
    
    
    label5 = [[UILabel alloc] initWithFrame:CGRectMake(28, 80, 275, 45)];
    label5.text = @"Write a caption (optional)";
    [label5 setFont:[UIFont systemFontOfSize:16]];
    label5.alpha = 0.7;
    [sv addSubview:label5];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 190, self.view.bounds.size.width, 40)];
    label.text = @"Send to places";
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor: [UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"Helvetica" size:23.0]];
    [sv addSubview:label];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(270, 30, 40, 40);
    backButton.tag = i;
    UIImage *image9 = [UIImage imageNamed:@"done.png"];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [backButton setImage:image9 forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(done:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 240, 280, (dataSource.count)*50) style:UITableViewStylePlain];
    [tableView setAutoresizesSubviews:YES];
    [tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    tableView.scrollEnabled = NO;
    tableView.layer.cornerRadius = 5;
    tableView.alpha = 0.7;
    tableView.backgroundColor=[UIColor clearColor];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [sv addSubview:tableView];
    //  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView selectRowAtIndexPath:0 animated:YES scrollPosition:UITableViewScrollPositionNone];
    [tableView reloadData];
    
    
    [self performSelector:@selector(animationDone) withObject:nil afterDelay:0.1];
    
}

- (void)animationDone {
    
    blurView.renderStatic = YES;
    [sv addSubview:img];
    [img addSubview:blurView];
    [sv sendSubviewToBack:blurView];
    [sv sendSubviewToBack:img];
    
}

-(void)updateAccountName
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _accountName.text = _localInstance.facebookAccount.userFullName;
    });
}

- (void)done:(id)sender {
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhotos"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *value, NSError *error) {
        
        // Now let's update it with some new data. In this case, only cheatMode and score
        // will get sent to the cloud. playerName hasn't changed.
        value[@"Caption"] = textView.text;
        value[@"verb"] = verb;
        
        
        if ([selectedMarks containsObject:@"Heartwood"]) {
            
            value[@"Hidden"]= @NO;
            
        }
        else {
            
            value[@"Hidden"] = @YES;
        }
        
        [value saveInBackground];
        
    }];
    
    
    
    if ([selectedMarks containsObject:@"Facebook"]) {
        
        
        // Check that various permissions have been granted
        if (!_localInstance.readAccessGranted) {
            [_localInstance requestReadAccessToFacebook];
        }
        
        if (!_localInstance.writeAccessGranted) {
            [_localInstance requestWriteAccessToFacebook];
        }
        
        // Only if read and write permissions are granted is the post request performed
        if (_localInstance.readAccessGranted && _localInstance.writeAccessGranted)
        {
            // Create an NSURL pointing the correct open graph end point
            NSURL *postURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
            
            // Create the post details
            NSString *message = @"Just posted a new Heartwood";
            NSString *picture = @"http://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/150px-Apple_logo_black.svg.png";
            NSString *name = @"Social Framework";
            NSString *caption = @"Reference Documentation";
            NSString *description = @"The Social framework lets you integrate your app with supported social networking services. On iOS and OS X, this framework provides a template for creating HTTP requests. On iOS only, the Social framework provides a generalized interface for posting requests on behalf of the user.";
            
            if ([textView.text length] > 0) {
                
                NSLog(@"swag");
                
                bodyMessage = [NSString stringWithFormat:@"%@ %@", textView.text, @"via Heartwood"];
            }
            
            if ([textView.text length] == 0) {
                NSString *string = @"Check out what I'm doing via Heartwood";
                bodyMessage = [NSString stringWithFormat:@"%@", string];
            }
            
            NSLog(@"%d",[textView.text length]);
            
            // Create a dictionary of post elements
            NSDictionary *postDict = @{
                                       
                                       @"message" : bodyMessage,
                                       @"link" : link,
                                       
                                       };
            
            // Create the SLRequest
            SLRequest *postToMyWall = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                         requestMethod:SLRequestMethodPOST
                                                                   URL:postURL
                                                            parameters:postDict];
            
            // Set the account
            [postToMyWall setAccount:_localInstance.facebookAccount];
            
            [postToMyWall performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                // Check for errors, output in alertview
                NSLog(@"Status Code: %li", (long)[urlResponse statusCode]);
                NSLog(@"Response Data: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                
                if (error)
                {
                    NSLog(@"Error message: %@", [error localizedDescription]);
                }
                
                if ([urlResponse statusCode] == 200) {
                    NSString *successMessage = @"The post has been made successfully.";
                }
                
                if ([urlResponse statusCode] == 400) {
                    NSLog(@"The OAuth token has expired. Renewing Access Token.");
                    [_localInstance renewFacebookCredentials];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            }];
            
            // Memory Management
            postToMyWall = nil;
            postDict = nil;
            postURL = nil;
            link = nil;
            message = nil;
            picture = nil;
            name = nil;
            caption = nil;
            description = nil;
        }
        
        
    }
    
    
    
    if ([selectedMarks containsObject:@"Twitter"]) {
        
        
        if ([textView.text length] == 0) {
            NSString *string = @"Check out what I'm doing.";
            bodyMessage = [NSString stringWithFormat:@"%@ %@ %@", string, link, @"via @GetHeartwood #heartwood"];
        }
        if ([textView.text length] > 0) {
            
            bodyMessage = [NSString stringWithFormat:@"%@ %@ %@", textView.text, link, @"via @GetHeartwood #heartwood"];
        }
        
        
        if (bodyMessage.length >= 141) {
            NSLog(@"Tweet won't be sent.");
        } else {
            ACAccountStore *accountStoreTw = [[ACAccountStore alloc] init];
            
            ACAccountType *accountTypeTw = [accountStoreTw accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            [accountStoreTw requestAccessToAccountsWithType:accountTypeTw options:NULL completion:^(BOOL granted, NSError *error) {
                if(granted) {
                    
                    NSArray *accountsArray = [accountStoreTw accountsWithAccountType:accountTypeTw];
                    
                    if ([accountsArray count] > 0) {
                        ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                        
                        SLRequest* twitterRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                       requestMethod:SLRequestMethodPOST
                                                                                 URL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
                                                                          parameters:[NSDictionary dictionaryWithObject:bodyMessage forKey:@"status"]];
                        
                        [twitterRequest setAccount:twitterAccount];
                        
                        [twitterRequest performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error) {
                            NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                            
                        }];
                        
                    }
                    
                }
                
            }];
            textView.text = [NSString stringWithFormat:@""];
            
        }
        charCount.text = [NSString stringWithFormat:@"120"];
        
    }
    
    if ([selectedMarks containsObject:@"Save to Camera Roll"]) {
        
        NSParameterAssert(img.image);
        UIImageWriteToSavedPhotosAlbum(img.image, nil, nil, nil);
        NSParameterAssert(img2.image);
        UIImageWriteToSavedPhotosAlbum(img2.image, nil, nil, nil);
    }
    
    
    
    
}
-(void)textViewDidBeginEditing:(UITextView *)textView { //Keyboard becomes visible
    
    //perform actions.
    
    [label5 removeFromSuperview];
    NSLog(@"hello");
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger length;
    length = [textView.text length];
    NSInteger number;
    number = 120-length;
    charCount.text = [NSString stringWithFormat:@"%u", number];
    
    if (length >= 121) {
        charCount.text = [NSString stringWithFormat:@"nope"];
        
    }
}



- (void)upload {
    NSLog(@"fired");
    
    
    
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    img.image = self.picture;
    img2.image = self.picture2;
    
    NSLog(@"i tried");
    
    NSData *imageData = UIImagePNGRepresentation(self.picture);
    UIImage *img10 = [UIImage imageWithData:imageData];
    
    
    
    NSData *imageData2 = UIImagePNGRepresentation(self.picture2);
    UIImage *img102 = [UIImage imageWithData:imageData2];
    // UIImage *imgThing2 = [UIImage imageWithCGImage:img102.CGImage scale:0.5 orientation:UIImageOrientationRight];
    
    
   UIImage *fun = [self rotate:img10 andOrientation:UIImageOrientationUp];
    UIImage *fun2 = [self rotate:img102 andOrientation:UIImageOrientationUp];

    
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.5f;
    int maxFileSize = 320*480;
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        newImageData = UIImageJPEGRepresentation(fun, compression);
        newImageData2 = UIImageJPEGRepresentation(fun2, compression);
    }
    
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:newImageData];
    
    PFFile *imageFile2 = [PFFile fileWithName:@"image.png" data:newImageData2];
    
    
    
    
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // Hide old HUD, show completed HUD (see example for code)
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *userPhotos = [PFObject objectWithClassName:@"UserPhotos"];
            // Set the access control list to current user for security purposes
            
            PFUser *user = [PFUser currentUser];
            // [userPhotos setObject:user forKey:@"user"];
            [userPhotos setObject:imageFile forKey:@"firstImage"];
            [userPhotos setObject:imageFile2 forKey:@"secondImage"];
            
            // Set the access control list to current user for security purposes
            
            
            [userPhotos saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    NSLog(@"yea bro");
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"UserPhotos"];
                    [query orderByDescending:@"createdAt"];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (!object) {
                            NSLog(@"The getFirstObject request failed.");
                        } else {
                            // The find succeeded.
                            objectId = [object objectId];
                            
                            
                            
                            link = [NSString stringWithFormat:@"%@%@",@"http://getheartwood.co.nf/Viewer.php?pic=",objectId];
                            
                            
                            NSLog(@"Successfully retrieved the object. %@", objectId);
                            
                            
                        }
                    }];
                    
                    
                    
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
    }];
    
    
    
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CRTableViewCellIdentifier = @"cellIdentifier";
    
    // init the CRTableViewCell
    CRTableViewCell *cell = (CRTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CRTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[CRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CRTableViewCellIdentifier];
    }
    
    // Check if the cell is currently selected (marked)
    NSString *text = [dataSource objectAtIndex:[indexPath row]];
    cell.isSelected = [selectedMarks containsObject:text] ? YES : NO;
    cell.textLabel.text = text;
    
    
    
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [dataSource objectAtIndex:[indexPath row]];
    
    
    if ([selectedMarks containsObject:text])// Is selected?
        [selectedMarks removeObject:text];
    else
        [selectedMarks addObject:text];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Private methods

- (void)back
{
}

@end