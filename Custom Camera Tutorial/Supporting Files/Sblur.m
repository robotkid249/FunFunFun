//
//  SBlur.m
//
//  Created by Satheeshwaran on 28/09/13.
//  Copyright (c) 2013 Satheeshwaran. All rights reserved.
//

#import "SBlur.h"

@implementation SBlur

+ (UIImage*) blur:(UIImage*)theImage blurRadius:(CGFloat)val
{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:val] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
    
    // if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}

+(UIImage*) scaleIfNeeded:(CGImageRef)cgimg {
    bool isRetina = [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.5;
    if (isRetina) {
        return [UIImage imageWithCGImage:cgimg scale:2.5 orientation:UIImageOrientationUp];
    } else {
        return [UIImage imageWithCGImage:cgimg];
    }
}

@end
