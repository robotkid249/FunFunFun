//
//  CameraCaptureViewController.m
//  Custom Camera Tutorial
//
//  Created by Bruno Tortato Furtado on 29/09/13.
//  Copyright (c) 2013 Bruno Tortato Furtado. All rights reserved.
//

#import "CameraCaptureViewController.h"
#import "MBProgressHUD.h"
#import "RBVolumeButtons.h"
#import "ShowImageViewController.h"
#import "DRNRealTimeBlurView.h"
#import "SHK.h"
//#import "DIYCam.h"
//#import "DIYAV.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

static int const kFacebookMinSize = 480;
static int const kSwitchButtonOriginY4inch = 4;
static int const kImagePreviewOriginY4inch = 62;


@interface CameraCaptureViewController ()

@property (nonatomic, strong) IBOutlet UIView *imagePreview;

@property (nonatomic) BOOL frontCameraEnabled;
@property (nonatomic, strong) ShowImageViewController *showImageController;
@property (nonatomic, strong) RBVolumeButtons *stealerButton;

@property (nonatomic, strong) AVCaptureDevice *frontCamera;
@property (nonatomic, strong) AVCaptureDevice *backCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIImagePickerController *albumPicker;

- (void)captureImage;
- (void)deviceOrientationDidChangeNotification;
- (void)initializeCamera;
- (void)processImage:(UIImage *)image;
- (void)showCameraPreviewFromDevice:(AVCaptureDevice *)device;

@end



@implementation CameraCaptureViewController

@synthesize stillImageOutput;
//@synthesize cam             = _cam;

#pragma mark - UIViewController


/*-(void)doTheCam {
    [self.view bringSubviewToFront:self.focusImageView];
    
    
    self.cam         = [[DIYCam alloc] initWithFrame:self.view.bounds];
    self.cam.delegate        = self;
    [self.cam setupWithOptions:nil]; // Check DIYAV.h for options
    [self.cam setCamMode:DIYAVModePhoto];
    [self.view addSubview:self.cam];
    [self.view sendSubviewToBack:self.cam];
    
}*/

- (void)viewDidLoad
{
    [self initializeCamera];
    //[self performSelector:@selector(doTheCam) withObject:self afterDelay:0.0000001];
    
 /*   // Setup cam
    self.cam.delegate       = self;
    [self.cam setupWithOptions:@{DIYAVSettingCameraPosition : [NSNumber numberWithInt:AVCaptureDevicePositionBack] }];
    [self.cam setCamMode:DIYAVModePhoto];*/
    
  

    toggleValue = 0;
    [super viewDidLoad];
    unit = 0;
    toggleValue = 0;
    self.view.backgroundColor = [UIColor blackColor];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.3;
    [self.view addSubview:view];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(65, 28, self.view.bounds.size.width, 40)];
    label.text = @"What are you doing?";
    [label setTextColor: [UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:23.0]];
    [self.view addSubview:label];
    
    
    
    bg2 = [[UIView alloc] initWithFrame:CGRectMake(0, (30), self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:bg2];
    
    [self createBackButton:self];
    
    
    for (i = 1; i < 7; i++) {
        
        bg = [[UIView alloc] initWithFrame:CGRectMake(25, (i*self.view.bounds.size.height/7.5), self.view.bounds.size.width-50, self.view.bounds.size.height/9)];
        [bg.layer setCornerRadius:5.0f];
        bg.tag = i+10;
        [bg2 addSubview:bg];
        
        
        if (self.view.bounds.size.height == 568) {
            var = 12;
        }
        if (self.view.bounds.size.height == 480) {
            var = 7;
        }
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(38,(i*self.view.bounds.size.height/7.5)+var, 40, 40)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.tag = i+20;
        [bg2 addSubview:icon];
        
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, (i*self.view.bounds.size.height/7.5)+3, self.view.bounds.size.width-50, self.view.bounds.size.height/10);
        button.tag = i;
        [button addTarget:self
                   action:@selector(pressedButton:)
         forControlEvents:UIControlEventTouchDown];
        [button addTarget:self
                   action:@selector(pressedButtonDown:)
         forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self
                   action:@selector(pressedButtonUp:)
         forControlEvents:UIControlEventTouchUpInside];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:24.0]];
        [bg2 addSubview:button];
        
        
        
        
        if (i == 1) {
            
            [button setTitle:@"            I am at +" forState:UIControlStateNormal];
            bg.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0.498 alpha:1]; /*#00ff7f*/
            icon.image = [UIImage imageNamed:@"at.png"];
            
            right = [[UIImageView alloc] initWithFrame:CGRectMake(75, self.view.bounds.size.height-145, 170, (170))];
            right.contentMode = UIViewContentModeScaleToFill;
            right.image = [UIImage imageNamed:@"1.png"];
            right.tag = i+50;
            right.alpha = 0.0;
            [self.view addSubview:right];
            
            
        }
        if (i == 2) {
            [button setTitle:@"            I am with +" forState:UIControlStateNormal];
            bg.backgroundColor = [UIColor colorWithRed:0.043 green:0.71 blue:1 alpha:1]; /*#0bb5ff*/
            icon.image = [UIImage imageNamed:@"with.png"];
            
            
            right = [[UIImageView alloc] initWithFrame:CGRectMake(75, self.view.bounds.size.height-145, 170, (170))];
            right.contentMode = UIViewContentModeScaleToFill;
            right.image = [UIImage imageNamed:@"2.png"];
            right.tag = i+50;
            right.alpha = 0.0;
            [self.view addSubview:right];
            
        }
        if (i == 3) {
            [button setTitle:@"            I am feeling +" forState:UIControlStateNormal];
            bg.backgroundColor = [UIColor colorWithRed:0.898 green:0.247 blue:0.325 alpha:1]; /*#e53f53*/
            icon.image = [UIImage imageNamed:@"feeling.png"];
            
            right = [[UIImageView alloc] initWithFrame:CGRectMake(75, self.view.bounds.size.height-145, 170, (170))];
            right.contentMode = UIViewContentModeScaleToFill;
            right.image = [UIImage imageNamed:@"3.png"];
            right.tag = i+50;
            right.alpha = 0.0;
            [self.view addSubview:right];
            
        }
        if (i == 4) {
            [button setTitle:@"            I am watching +" forState:UIControlStateNormal];
            bg.backgroundColor = [UIColor colorWithRed:1 green:0.49 blue:0.251 alpha:1]; /*#ff7d40*/
            icon.image = [UIImage imageNamed:@"tv.png"];
            
            right = [[UIImageView alloc] initWithFrame:CGRectMake(75, self.view.bounds.size.height-145, 170, (170))];
            right.contentMode = UIViewContentModeScaleToFill;
            right.image = [UIImage imageNamed:@"4.png"];
            right.tag = i+50;
            right.alpha = 0.0;
            [self.view addSubview:right];
            
            
        }
        
        if (i == 5) {
            [button setTitle:@"            I am eating +" forState:UIControlStateNormal];
            bg.backgroundColor = [UIColor colorWithRed:0.729 green:0.333 blue:0.827 alpha:1]; /*#ba55d3*/
            icon.image = [UIImage imageNamed:@"food.png"];
            
            right = [[UIImageView alloc] initWithFrame:CGRectMake(75, self.view.bounds.size.height-145, 170, (170))];
            right.contentMode = UIViewContentModeScaleToFill;
            right.image = [UIImage imageNamed:@"5.png"];
            right.tag = i+50;
            right.alpha = 0.0;
            [self.view addSubview:right];
            
        }
        if (i == 6) {
            [button setTitle:@"            I am reading +" forState:UIControlStateNormal];
            bg.backgroundColor = [UIColor colorWithRed:0.318 green:0.498 blue:0.643 alpha:1]; /*#517fa4*/
            icon.image = [UIImage imageNamed:@"book.png"];
            
            right = [[UIImageView alloc] initWithFrame:CGRectMake(75, self.view.bounds.size.height-145, 170, (170))];
            right.contentMode = UIViewContentModeScaleToFill;
            right.image = [UIImage imageNamed:@"6.png"];
            right.tag = i+50;
            right.alpha = 0.0;
            [self.view addSubview:right];
            
            
        }
        
        
        
    }

    
   
    snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *sButton = [UIImage imageNamed:@"photoooo.png"];
    snapButton.alpha = 0.0;
    snapButton.frame = CGRectMake(120, self.view.bounds.size.height-100, 80, 80);
    [snapButton setImage:sButton forState:UIControlStateNormal];
    snapButton.contentMode = UIViewContentModeScaleAspectFit;
    [snapButton addTarget:self
                   action:@selector(snapImage:)
         forControlEvents:UIControlEventTouchUpInside];
    snapButton.alpha = 0.0;
    [self.view addSubview:snapButton];
    
    flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flashButton.alpha = 0.0;
    flashButton.frame = CGRectMake(20, 20, 80, 130);
    UIImage *nah = [UIImage imageNamed:@"button-flash-off.png"];
    [flashButton setImage:nah forState:UIControlStateNormal];
    flashButton.contentMode = UIViewContentModeScaleAspectFit;
    [flashButton addTarget:self
                   action:@selector(switchFlash:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashButton];
    
   
    
    switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    switchButton.alpha = 0.0;
    switchButton.frame = CGRectMake(76, self.view.bounds.size.height-78, 40, 40);
    UIImage *switchbutton = [UIImage imageNamed:@"left.png"];
    [switchButton setImage:switchbutton forState:UIControlStateNormal];
    switchButton.contentMode = UIViewContentModeScaleAspectFit;
    [switchButton addTarget:self
                    action:@selector(switchCamera:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchButton];
    
    switchButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    switchButton2.alpha = 0.0;
    switchButton2.userInteractionEnabled = NO;
    switchButton2.frame = CGRectMake(204, self.view.bounds.size.height-80, 40, 40);
    UIImage *switchbutton2 = [UIImage imageNamed:@"right.png"];
    [switchButton2 setImage:switchbutton2 forState:UIControlStateNormal];
    switchButton2.contentMode = UIViewContentModeScaleAspectFit;
    [switchButton2 addTarget:self
                     action:@selector(switchCamera2:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchButton2];
        
    
    
    

    
   
        [switchButton setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
        [switchButton2 setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];


    
   // AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-logo"]]];
    
    self.imagePreview.layer.masksToBounds = NO;
    
    self.showImageController = [self.storyboard instantiateViewControllerWithIdentifier:
                                NSStringFromClass([ShowImageViewController class])];
    
    self.frontCameraEnabled = YES;
    
    self.albumPicker = [[UIImagePickerController alloc] init];
    self.albumPicker.delegate = self;
    self.albumPicker.allowsEditing = YES;
    self.albumPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    self.stealerButton = [[RBVolumeButtons alloc] init];
    
    __weak typeof (self) weakSelf = self;
    
    _stealerButton.upBlock = ^{
        NSLog(@"up");
        [weakSelf snapImage];
    };
    
    _stealerButton.downBlock = ^{
        NSLog(@"down");
        [weakSelf snapImage];
    };
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.stealerButton startStealingVolumeButtonEvents];
    
    [self deviceOrientationDidChangeNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    
    toggleValue = 0;
    
  /*  if (self.frontCameraEnabled) {
        [self showCameraPreviewFromDevice:self.frontCamera];
    } else {
        [self showCameraPreviewFromDevice:self.backCamera];
    }*/
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.stealerButton stopStealingVolumeButtonEvents];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    self.frontCameraEnabled = YES;
    
    self.frontCamera = nil;
    self.backCamera = nil;
    self.stillImageOutput = nil;
    session = nil;
    
    self.showImageController = nil;
    
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self.showImageController setPicture:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.navigationController pushViewController:self.showImageController animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Actions

- (void)snap {
    
    snapButton.userInteractionEnabled = YES;
    
}

- (void)snapImage:(id)sender
{
   
    
    switch(toggleValue)
    {
        case 0: {
           
         //  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            
            [self.showImageController setPicture:nil];
            [self captureImage];
            
            //   [self changeCamera];
            
            if (unit == 0) {
            
           [self switchCamera2:self.backCamera];
            [self switchCamera2:self.backCamera];

            }
            
            if (unit == 1) {
                [self switchCamera2:self.backCamera];

            }
            toggleValue = 1;
            switchButton2.userInteractionEnabled = YES;
            switchButton.userInteractionEnabled = NO;
            //  [self captureImage];
            
            snapButton.userInteractionEnabled = NO;
            [self performSelector:@selector(snap) withObject:nil afterDelay:0.5];
            
            [UIView animateWithDuration:0.5f
                             animations:^
             {
               //  [self switchCamera2:sender];

                 for(right in self.view.subviews) {
                     
                     if (right.tag == 51) {
                         right.transform = CGAffineTransformMakeRotation(3.14159);
                         
                     }
                 }
                 
                 for(right in self.view.subviews) {
                     
                     if (right.tag == 52) {
                         right.transform = CGAffineTransformMakeRotation(3.14159);
                         
                     }
                 }
                 
                 for(right in self.view.subviews) {
                     
                     if (right.tag == 53) {
                         right.transform = CGAffineTransformMakeRotation(3.14159);
                         
                     }
                 }
                 
                 for(right in self.view.subviews) {
                     
                     if (right.tag == 54) {
                         right.transform = CGAffineTransformMakeRotation(3.14159);
                         
                     }
                 }
                 
                 for(right in self.view.subviews) {
                     
                     if (right.tag == 55) {
                         right.transform = CGAffineTransformMakeRotation(3.14159);
                         
                     }
                 }
                 for(right in self.view.subviews) {
                     
                     if (right.tag == 56) {
                         right.transform = CGAffineTransformMakeRotation(3.14159);
                         
                     }
                 }
                 
                 
             }];
            
            

            
       
            
            break; }
        case 1:
            toggleValue = 0;

            
            [self.showImageController setPicture2:nil];
            [self captureImage2];
        
          //  [self performSelector:@selector(push) withObject:nil afterDelay:0.5];
            break;
    }
    

}

- (void)switchCamera:(id)sender
{
    switch(unit)
    {
        case 0: {
           
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                CATransition *transition = [CATransition animation];
                //transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.duration = .6f;
                transition.type =  @"alignedFlip";
                
                [switchButton.layer addAnimation:transition forKey:@"button-rippleEffect"];
                [switchButton setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
                
                
            }) ;
            
            [self showCameraPreviewFromDevice:self.backCamera];

            
            unit = 1;
            

            
            
        
    
            break; }
    
        case 1: {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                CATransition *transition = [CATransition animation];
                //transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.duration = .6f;
                transition.type =  @"alignedFlip";
                
                [switchButton.layer addAnimation:transition forKey:@"button-rippleEffect"];
                [switchButton setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
                
                
            }) ;
            
            [self showCameraPreviewFromDevice:self.frontCamera];

            
            unit = 0;

            break; }
            
        default:
            /* do some default thing for unknown unit */
            break;
    };
    return;
    
}



- (void)switchCamera2:(id)sender
{
    
    switch(unit)
    {
        case 0: {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                CATransition *transition = [CATransition animation];
                //transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.duration = .6f;
                transition.type =  @"alignedFlip";
                
                [switchButton2.layer addAnimation:transition forKey:@"button-rippleEffect"];
                [switchButton2 setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
                
                
            }) ;
            
            
            [self showCameraPreviewFromDevice:self.frontCamera];
            unit = 1;
            
            
            
            
            
            
            break; }
            
        case 1: {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                CATransition *transition = [CATransition animation];
                //transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.duration = .6f;
                transition.type =  @"alignedFlip";
                
                [switchButton2.layer addAnimation:transition forKey:@"button-rippleEffect"];
                [switchButton2 setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
                
                
            }) ;
            
            [self showCameraPreviewFromDevice:self.backCamera];

            
            unit = 0;
            
            break; }
            
        default:
            /* do some default thing for unknown unit */
            break;
    };
    return;
}

- (void)pressedButton:(id)sender {
    
    
    UIButton *aButton = (UIButton *)sender; // we know the sender is a UIButton object, so cast it
    
    if (aButton.tag == 1)
    {
        NSLog(@"we did it #1");
        
        for(bg in bg2.subviews){
            if(bg.tag==11){
                bg.alpha = 0.3;
            }
        }
        
        
    }
    else if (aButton.tag == 2)
    {
        
        NSLog(@"we did it #2");
        for(bg in bg2.subviews){
            if(bg.tag==12){
                bg.alpha = 0.3;
            }
        }}
    else if (aButton.tag == 3)
    {
        for(bg in bg2.subviews){
            if(bg.tag==13){
                bg.alpha = 0.3;
            }
            NSLog(@"we did it #3");
        }}
    else if (aButton.tag == 4)
    {
        for(bg in bg2.subviews){
            if(bg.tag==14){
                bg.alpha = 0.3;
            }}
        NSLog(@"we did it #4");
    }
    else if (aButton.tag == 5)
    {
        for(bg in bg2.subviews){
            if(bg.tag==15){
                bg.alpha = 0.3;
            }}
        NSLog(@"we did it #5");
    }
    else if (aButton.tag == 6)
    {
        for(bg in bg2.subviews){
            if(bg.tag==16){
                bg.alpha = 0.3;
            }}
        NSLog(@"we did it #6");
    }
    
}
- (void)pressedButtonDown:(id)sender {
    
    
    UIButton *aButton = (UIButton *)sender; // we know the sender is a UIButton object, so cast it
    
    if (aButton.tag == 1)
    {
        
        for(bg in bg2.subviews){
            if(bg.tag==11){
                bg.alpha = 1.0;
            }
        }
        
        
    }
    else if (aButton.tag == 2)
        
    {
        for(bg in bg2.subviews){
            if(bg.tag==12){
                bg.alpha = 1.0;
            }
        }
    }
    else if (aButton.tag == 3)
    {
        for(bg in bg2.subviews){
            if(bg.tag==13){
                bg.alpha = 1.0;
            }
        }
    }
    else if (aButton.tag == 4)
    {
        for(bg in bg2.subviews){
            if(bg.tag==14){
                bg.alpha = 1.0;
            }
        }
    }
    else if (aButton.tag == 5)
    {
        for(bg in bg2.subviews){
            if(bg.tag==15){
                bg.alpha = 1.0;
            }
        }
    }
    else if (aButton.tag == 6)
    {
        for(bg in bg2.subviews){
            if(bg.tag==16){
                bg.alpha = 1.0;
            }
        }
    }
    
}
- (void)pressedButtonUp:(id)sender {
    
    // do all the view pushing stuff here!!!
    
    snapButton.alpha = 1.0;
    switchButton.alpha = 1.0;
    switchButton2.alpha = 1.0;

    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    UIButton *aButton = (UIButton *)sender; // we know the sender is a UIButton object, so cast it
    
    
    if (aButton.tag == 1)
    {
        
        for(right in self.view.subviews) {
            
            if (right.tag == 51) {
                right.alpha = 1.0;
                [right setImage:[UIImage imageNamed:@"1.png"]];
                NSLog(@"we rock");
                
            }
        }
        
        
        for(bg in bg2.subviews){
            
            if(bg.tag==2 || bg.tag ==3 || bg.tag == 4 || bg.tag == 5 || bg.tag == 6 || bg.tag==12 || bg.tag ==13 || bg.tag == 14 || bg.tag == 15 || bg.tag == 16 || bg.tag==22 || bg.tag ==23 || bg.tag == 24 || bg.tag == 25 || bg.tag == 26){
                [UIView animateWithDuration:0.6f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(160, 800)];
                     
                 }];
                
            }
            
            if(bg.tag==1){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(145, 20)];
                     label.alpha = 0.0;
                     label2.alpha = 0.0;
                 }];
                
            }
            
            
            if(bg.tag==11){
                bg.alpha = 1.0;
                
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     //[bg setCenter:CGPointMake(160, 20)];
                     bg.frame = CGRectMake(0, -5, self.view.bounds.size.width, self.view.bounds.size.height/9);
                     bg.alpha = 0.8;
                     [bg.layer setCornerRadius:0.0f];
                 }];
            }
            
            
            
            if(bg.tag==21){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     [bg setCenter:CGPointMake(100, 20)];
                     bg.alpha = 0.0;
                     
                     
                 }];
            }
            
        }
        
        
        
        
    }
    else if (aButton.tag == 2)
    {
        
        for(right in self.view.subviews) {
            
            if (right.tag == 52) {
                right.alpha = 1.0;
                [right setImage:[UIImage imageNamed:@"2.png"]];
                NSLog(@"we rock");
                
            }
        }
        
        for(bg in bg2.subviews){
            
            if(bg.tag==1 || bg.tag ==3 || bg.tag == 4 || bg.tag == 5 || bg.tag == 6 || bg.tag==11 || bg.tag ==13 || bg.tag == 14 || bg.tag == 15 || bg.tag == 16 || bg.tag==21 || bg.tag ==23 || bg.tag == 24 || bg.tag == 25 || bg.tag == 26){
                [UIView animateWithDuration:0.6f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(160, 800)];
                     
                 }];
                
            }
            
            if(bg.tag==2){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(145, 20)];
                     label.alpha = 0.0;
                     label2.alpha = 0.0;
                 }];
                
            }
            
            
            if(bg.tag==12){
                bg.alpha = 1.0;
                
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     //[bg setCenter:CGPointMake(160, 20)];
                     bg.frame = CGRectMake(0, -5, self.view.bounds.size.width, self.view.bounds.size.height/9);
                     bg.alpha = 0.8;
                     [bg.layer setCornerRadius:0.0f];
                 }];
            }
            
            
            
            if(bg.tag==22){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     [bg setCenter:CGPointMake(95, 20)];
                     bg.alpha = 0.0;
                     
                     
                 }];
            }}}
    
    
    else if (aButton.tag == 3)
    {
        for(right in self.view.subviews) {
            
            if (right.tag == 53) {
                right.alpha = 1.0;
                [right setImage:[UIImage imageNamed:@"3.png"]];
                NSLog(@"we rock");
                
            }
        }
        
        
        for(bg in bg2.subviews){
            
            if(bg.tag==1 || bg.tag ==2 || bg.tag == 4 || bg.tag == 5 || bg.tag == 6 || bg.tag==11 || bg.tag ==12 || bg.tag == 14 || bg.tag == 15 || bg.tag == 16 || bg.tag==21 || bg.tag ==22 || bg.tag == 24 || bg.tag == 25 || bg.tag == 26){
                [UIView animateWithDuration:0.6f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(160, 800)];
                     
                 }];
                
            }
            
            if(bg.tag==3){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(145, 20)];
                     label.alpha = 0.0;
                     label2.alpha = 0.0;
                 }];
                
            }
            
            
            if(bg.tag==13){
                bg.alpha = 1.0;
                
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     //[bg setCenter:CGPointMake(160, 20)];
                     bg.frame = CGRectMake(0, -5, self.view.bounds.size.width, self.view.bounds.size.height/9);
                     bg.alpha = 0.8;
                     [bg.layer setCornerRadius:0.0f];
                 }];
            }
            
            
            
            if(bg.tag==23){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     [bg setCenter:CGPointMake(95, 20)];
                     bg.alpha = 0.0;
                     
                     
                 }];
            }}}
    
    else if (aButton.tag == 4)
    {
        for(right in self.view.subviews) {
            
            if (right.tag == 54) {
                right.alpha = 1.0;
                [right setImage:[UIImage imageNamed:@"4.png"]];
                NSLog(@"we rock");
                
            }
        }
        
        for(bg in bg2.subviews){
            
            if(bg.tag==1 || bg.tag ==2 || bg.tag == 3 || bg.tag == 5 || bg.tag == 6 || bg.tag==11 || bg.tag ==12 || bg.tag == 13 || bg.tag == 15 || bg.tag == 16 || bg.tag==21 || bg.tag ==22 || bg.tag == 23 || bg.tag == 25 || bg.tag == 26){
                [UIView animateWithDuration:0.6f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(160, 800)];
                     
                 }];
                
            }
            
            if(bg.tag==4){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(145, 20)];
                     label.alpha = 0.0;
                     label2.alpha = 0.0;
                 }];
                
            }
            
            
            if(bg.tag==14){
                bg.alpha = 1.0;
                
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     //[bg setCenter:CGPointMake(160, 20)];
                     bg.frame = CGRectMake(0, -5, self.view.bounds.size.width, self.view.bounds.size.height/9);
                     bg.alpha = 0.8;
                     [bg.layer setCornerRadius:0.0f];
                 }];
            }
            
            
            
            if(bg.tag==24){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     [bg setCenter:CGPointMake(95, 20)];
                     bg.alpha = 0.0;
                     
                     
                 }];
            }}}
    
    else if (aButton.tag == 5)
    {
        
        for(right in self.view.subviews) {
            
            if (right.tag == 55) {
                right.alpha = 1.0;
                [right setImage:[UIImage imageNamed:@"5.png"]];
                NSLog(@"we rock");
                
            }
        }
        
        for(bg in bg2.subviews){
            
            if(bg.tag==1 || bg.tag ==2 || bg.tag == 3 || bg.tag == 4 || bg.tag == 6 || bg.tag==11 || bg.tag ==12 || bg.tag == 13 || bg.tag == 14 || bg.tag == 16 || bg.tag==21 || bg.tag ==22 || bg.tag == 23 || bg.tag == 24 || bg.tag == 26){
                [UIView animateWithDuration:0.6f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(160, 800)];
                     
                 }];
                
            }
            
            if(bg.tag==5){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(145, 20)];
                     label.alpha = 0.0;
                     label2.alpha = 0.0;
                 }];
                
            }
            
            
            if(bg.tag==15){
                bg.alpha = 1.0;
                
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     //[bg setCenter:CGPointMake(160, 20)];
                     bg.frame = CGRectMake(0, -5, self.view.bounds.size.width, self.view.bounds.size.height/9);
                     bg.alpha = 0.8;
                     [bg.layer setCornerRadius:0.0f];
                 }];
            }
            
            
            
            if(bg.tag==25){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     [bg setCenter:CGPointMake(95, 20)];
                     bg.alpha = 0.0;
                     
                     
                 }];
            }}}
    else if (aButton.tag == 6)
    {
        for(right in self.view.subviews) {
            
            if (right.tag == 56) {
                right.alpha = 1.0;
                [right setImage:[UIImage imageNamed:@"6.png"]];
                NSLog(@"we rock");
                
            }
        }
        
        for(bg in bg2.subviews){
            
            if(bg.tag==1 || bg.tag ==2 || bg.tag == 3 || bg.tag == 4 || bg.tag == 5 || bg.tag==11 || bg.tag ==12 || bg.tag == 13 || bg.tag == 14 || bg.tag == 15 || bg.tag==21 || bg.tag ==22 || bg.tag == 23 || bg.tag == 24 || bg.tag == 25){
                [UIView animateWithDuration:0.6f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(160, 800)];
                     
                 }];
                
            }
            
            if(bg.tag==6){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     bg.userInteractionEnabled = NO;
                     [bg setCenter:CGPointMake(145, 20)];
                     label.alpha = 0.0;
                     label2.alpha = 0.0;
                 }];
                
            }
            
            
            if(bg.tag==16){
                bg.alpha = 1.0;
                
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     //[bg setCenter:CGPointMake(160, 20)];
                     bg.frame = CGRectMake(0, -5, self.view.bounds.size.width, self.view.bounds.size.height/9);
                     bg.alpha = 0.8;
                     [bg.layer setCornerRadius:0.0f];
                 }];
            }
            
            
            
            if(bg.tag==26){
                bg.alpha = 1.0;
                [UIView animateWithDuration:0.4f
                                 animations:^
                 {
                     [bg setCenter:CGPointMake(95, 20)];
                     bg.alpha = 0.0;
                     
                 }];
            }}}
    
    
}





#pragma mark - Private methods

- (void)captureImage
{
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in
         stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         
         
         
         [self processImage:[UIImage imageWithData:imageData]];
         
         
         
         NSString *path;
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SomeDirectoryName"];
         path = [path stringByAppendingPathComponent:@"SomeFileName"];
         
         [[NSFileManager defaultManager] createFileAtPath:path
                                                 contents:imageData
                                               attributes:nil];
         
         
     }];
  
}


- (void)captureImage2
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in
         stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         
         NSData *imageData2 = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         
         
        
         [self processImage2:[UIImage imageWithData:imageData2]];
         
         
         
         NSString *path;
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SomeDirectoryName2"];
         path = [path stringByAppendingPathComponent:@"SomeFileName2"];
         
         [[NSFileManager defaultManager] createFileAtPath:path
                                                 contents:imageData2
                                               attributes:nil];
         
         
     }];

}




- (void)initializeCamera
{
    
   
    
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    
   
    self.imagePreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.imagePreview.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imagePreview];

    
    CALayer *viewLayer = self.imagePreview.layer;
    [viewLayer setMasksToBounds:YES];
    NSLog(@"viewLayer = %@", viewLayer);
    
    imagePreview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    
    imagePreview.frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [self.imagePreview.layer addSublayer:imagePreview];
    
   /* self.frontCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];*/

   

    
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    
    
    NSError *error;
        if (([device hasMediaType:AVMediaTypeVideo]) &&
            ([device position] == AVCaptureDevicePositionBack) ) {
            [device lockForConfiguration:&error];
            if ([device isFocusModeSupported:AVCaptureFocusModeLocked]) {
                device.focusMode = AVCaptureFocusModeLocked;
                NSLog(@"Focus locked");
            }
            
            [device unlockForConfiguration];
        
    }

    
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionFront) {
                self.backCamera = device;
            } else {
                self.frontCamera = device;
            }
        }
    }
    
    [self showCameraPreviewFromDevice:device];

    
  /*  NSError *error = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];*/

    
   stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    

    [session startRunning];
}

- (void)processImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect cropRect = CGRectMake(0, 0, 0, 0);
    int sideSize = kFacebookMinSize;
    
    if (imageCopy.size.height > kFacebookMinSize && imageCopy.size.width > kFacebookMinSize) {
        sideSize = imageCopy.size.width;
        
        if (imageCopy.size.height < imageCopy.size.width)
            sideSize = imageCopy.size.height;
    }
    
    cropRect.size.height = cropRect.size.width = sideSize;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageCopy CGImage], cropRect);

    UIImage *cropImage = nil;
    UIImageOrientation imageOrientation;
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationUp;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationUp;
            break;

        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationUp;
            break;
            
        case UIDeviceOrientationPortrait:
        default:
            imageOrientation = UIImageOrientationUp;
            break;
    }
    
    
    
    
    [self.showImageController setPicture:image];
    
    
   
	   
   
}

- (void)processImage2:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect cropRect = CGRectMake(0, 0, 0, 0);
    int sideSize = kFacebookMinSize;
    
    if (imageCopy.size.height > kFacebookMinSize && imageCopy.size.width > kFacebookMinSize) {
        sideSize = imageCopy.size.width;
        
        if (imageCopy.size.height < imageCopy.size.width)
            sideSize = imageCopy.size.height;
    }
    
    cropRect.size.height = cropRect.size.width = sideSize;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageCopy CGImage], cropRect);
    
    UIImage *cropImage = nil;
    UIImageOrientation imageOrientation;
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationUp;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationUp;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationUp;
            break;
            
        case UIDeviceOrientationPortrait:
        default:
            imageOrientation = UIImageOrientationUp;
            break;
    }
    
    
    
    
    [self.showImageController setPicture2:image];
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
   // [self.navigationController pushViewController:self.showImageController animated:YES];
    
    
  
    [self.navigationController pushViewController:self.showImageController animated:YES];

}

- (void)showCameraPreviewFromDevice:(AVCaptureDevice *)device
{
    if (self.input) {
        if ([session isRunning])
            [session stopRunning];
        
        [session removeInput:self.input];
    }
    
    NSError *error = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    
    
    if (self.input) {
        session.sessionPreset = AVCaptureSessionPresetHigh;
        [session addInput:self.input];
        [session startRunning];
    } else {
        NSLog(@"Error: trying to open camera: %@", error);
    }

}

#pragma mark - Notifications

- (void)deviceOrientationDidChangeNotification
{    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
        
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationUnknown:
            transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
            break;

        case UIDeviceOrientationLandscapeLeft:
            transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
            break;
            
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            break;
            
        case UIDeviceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(DegreesToRadians(270));
            break;
    }
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [UIView animateWithDuration:.5f animations:^{        
        
    }];
}

- (void)createBackButton:(id)sender {
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(12, 30, 40, 40);
    backButton.tag = i;
    UIImage *img = [UIImage imageNamed:@"back.png"];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [backButton setImage:img forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(back:)
         forControlEvents:UIControlEventTouchUpInside];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:24.0]];
    [self.view addSubview:backButton];
    
}

@end