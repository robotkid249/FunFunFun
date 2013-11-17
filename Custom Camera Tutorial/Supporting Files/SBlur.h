//
//  SBlur.h
//  
//  Created by Satheeshwaran on 28/09/13.
//  Copyright (c) Satheeshwaran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBlur : NSObject

+ (UIImage*) blur:(UIImage*)theImage blurRadius:(CGFloat)val;
+ (UIImage*) scaleIfNeeded:(CGImageRef)cgimg;

@end
