//
//  RSViewController.h
//  Circa
//
//  Created by R0CKSTAR on 7/31/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <LiveFrost/LiveFrost.h>

@interface RSViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate> {
    
    NSMutableArray *allImages;
    UIView *sv;
    UIImage *image;
    UIImage *image2;
    UIButton *button;
    UIImage *imgThing;
    NSMutableArray *imageDataArray;
    NSMutableArray *imageDataArraySecond;
    NSMutableArray *imageDataArrayBlurred;
    NSMutableArray *verbArray;
    NSMutableArray *captionArray;
    NSMutableArray *timestampArray;
    NSString *caption;
    
    
    UIImageView *first;
    UIImageView *second;
    UIImage *imgThing2;
    NSString *greenText;
    NSString *secondText;
    NSTimer *_timer;
    int i;
    UIImage *thing;
    UIImage *thing2;
    UIImage *blurredImage;
    UIButton *snapButton;
    UIButton *menuButton;
    UIButton *menButton;
    UIButton *heartButton;
    int tag;
    UILabel* label;
    UIView *left;
    UIView *right;
    int valueSwitch;
    UILabel *letterLabel;
    NSString *verb;
    NSMutableArray *userArray;
    UIColor *greenColor;
    UILabel *Label;
    UILabel *Label2;
    UIView *indicator;
    int touchHappened;
    LFGlassView *glassView;
    LFGlassView *glassViewR;
    LFGlassView *glassViewLD;
    LFGlassView *glassViewRD;
    LFGlassView *heartGlass;
    LFGlassView *blurView;
    NSString *userId;
    
}



@end
