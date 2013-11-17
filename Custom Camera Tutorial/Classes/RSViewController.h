//
//  RSViewController.h
//  Circa
//
//  Created by R0CKSTAR on 7/31/13.
//  Copyright (c) 2013 P.D.Q. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

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
    UIImageView *first;
    UIImageView *second;
    UIImage *imgThing2;
    NSTimer *_timer;
    int i;
    UIImage *thing;
    UIImage *thing2;
    UIImage *blurredImage;
    int tag;
    int valueSwitch;
    UILabel *letterLabel;
    NSString *verb;
    UIColor *greenColor;
    UILabel *Label;
    UIView *indicator;
    int touchHappened;
}



@end
