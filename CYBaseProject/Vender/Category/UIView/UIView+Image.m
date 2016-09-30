//
//  UIView+Image.m
//  100Days
//
//  Created by Peter Lee on 16/9/30.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "UIView+Image.h"

@implementation UIView(Image)

- (UIImage*)convertToImage{
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
