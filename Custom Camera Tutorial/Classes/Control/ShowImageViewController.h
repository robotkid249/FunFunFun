//
//  ShowImageViewController.h
//  Custom Camera Tutorial
//
//  Created by Bruno Tortato Furtado on 30/09/13.
//  Copyright (c) 2013 Bruno Tortato Furtado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRNRealTimeBlurView.h"
#import <Social/Social.h>
@interface ShowImageViewController : UIViewController {
    
    UIImageView *img;
    UIButton *backButton;
    UIButton *checkButton;
    NSString *link;
    UIImageView *img2;
    int i;
    int Number;
    NSTimer *timer;
    DRNRealTimeBlurView *blurView;
    UILabel *label;
    UIImage *imageFun;
    UITableView  *tableView;
    NSString *bodyMessage;
    UILabel *label5;
    NSData *newImageData;
    NSData *newImageData2;
    UIScrollView *sv;
    NSArray *dataSource;
    UITextView *textView;
    NSMutableArray *selectedMarks;
    UILabel *charCount;
    int limit;
    UIViewController *nextView;
    NSString * objectId;
    NSString *verb;
}
@property (nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UIImage *picture;
@property (strong, nonatomic) UIImage *picture2;

@end