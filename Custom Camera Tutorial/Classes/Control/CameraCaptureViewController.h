//
//  CameraCaptureViewController.h
//  Custom Camera Tutorial
//
//  Created by Bruno Tortato Furtado on 29/09/13.
//  Copyright (c) 2013 Bruno Tortato Furtado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
//#import "DIYCam.h"
//#import "DIYAV.h"

@interface CameraCaptureViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

{
    
    UIButton *flashButton;
    UIButton *snapButton;
    int flip;
     UIButton *albumButton;
     UIButton *switchButton;
    UIButton *switchButton2;
    UIImageView *indicator;
    int unit;
    int toggleValue;
    int i;
    int var;
    UIViewController * temp;
    UIImage *iconImage;
    //DIYCam *cam;
    UIView *bg3;
    UIView *bg;
    UIView *bg2;
    UIView *photobg;
    UIImageView *right;
    UILabel *label;
    UILabel *label2;
    UIButton *backButton;
    UIButton *button;
    AVCaptureVideoPreviewLayer *imagePreview;
    AVCaptureSession *session;
   AVCaptureDeviceInput *input;


}
//@property IBOutlet DIYCam *cam;
@property UIImageView *focusImageView;

- (IBAction)snapImage;
- (IBAction)switchCamera;
- (IBAction)switchFlash;
- (IBAction)showPhotoAlbum;

@end