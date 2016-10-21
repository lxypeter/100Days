//
//  TimerProgressView.m
//  100Days
//
//  Created by Peter Lee on 2016/10/21.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TimerProgressView.h"
#import "UIColor+HexString.h"

@implementation TimerProgressView

- (void)drawRect:(CGRect)rect {
    
    if (self.progress == 0) return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    UIColor *lineColor = UICOLOR(@"#ffae3b");
    [lineColor set];
    
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.radius, -M_PI_2, M_PI * 2 * self.progress-M_PI_2, 0);
    
    CGContextStrokePath(context);

    
    CGContextSetLineWidth(context, 8);
    
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.radius, M_PI * 2 * self.progress-M_PI_2, M_PI * 2 * self.progress-M_PI_2 +0.0000001, 0);
    
    CGContextStrokePath(context);
    
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self setNeedsDisplay];
}

@end
