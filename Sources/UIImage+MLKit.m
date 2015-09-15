//
//  UIImage.m
//  MediaLibraryKit
//
//  Created by Felix Paul Kühne on 29/05/15.
//  Copyright (c) 2015 VideoLAN. All rights reserved.
//

#import "UIImage+MLKit.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (MLKit)

+ (CGSize)preferredThumbnailSizeForDevice
{
    CGFloat thumbnailWidth, thumbnailHeight;
    /* optimize thumbnails for the device */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        thumbnailWidth = 272.;
        thumbnailHeight = 204.;
    } else {
        thumbnailWidth = 240.;
        thumbnailHeight = 135.;
    }
    return CGSizeMake(thumbnailWidth, thumbnailHeight);
}

+ (UIImage *)scaleImage:(UIImage *)image toFitRect:(CGRect)rect {
    return [self scaleImage:image toFitRect:rect scale:[UIScreen mainScreen].scale];
}

+ (UIImage *)scaleImage:(UIImage *)image toFitRect:(CGRect)rect scale:(CGFloat)scale
{
    CGRect destinationRect = AVMakeRectWithAspectRatioInsideRect(image.size, rect);

    CGImageRef cgImage = image.CGImage;
    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(cgImage);
    CGBitmapInfo bitmapInfoRef = CGImageGetBitmapInfo(cgImage);

    CGContextRef contextRef = CGBitmapContextCreate(NULL,
                                                    destinationRect.size.width*scale,
                                                    destinationRect.size.height*scale,
                                                    bitsPerComponent,
                                                    bytesPerRow,
                                                    colorSpaceRef,
                                                    bitmapInfoRef);

    CGContextSetInterpolationQuality(contextRef, kCGInterpolationLow);

    CGContextDrawImage(contextRef, (CGRect){CGPointZero, destinationRect.size}, cgImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    UIImage *scaledImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    return scaledImage;
}

@end
