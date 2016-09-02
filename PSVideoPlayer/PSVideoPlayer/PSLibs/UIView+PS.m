//
//  UIView+PS.m
//  PSScanViewController
//
//  Created by Ryan_Man on 16/8/23.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "UIView+PS.h"

@implementation UIView (PS)
- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x
{
    CGRect r = self.frame;
    r.origin.x = x;
    self.frame = r;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y
{
    CGRect rect = self.frame;
    rect.origin.y = y ;
    self.frame = rect;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width;
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect  rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGPoint)origin
{
    return self.frame.origin;
}
- (void)setOrigin:(CGPoint)origin;
{
    CGRect rect = self.frame;
    rect.origin = origin;
    self.frame = rect;
}

- (CGSize)size
{
    return self.frame.size;
}
- (void)setSize:(CGSize)size
{
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}

#pragma mark - layer -

- (void)setLayerWithCr:(CGFloat)cornerRadius
{
    self.layer.masksToBounds = YES; //没这句话它圆不起来
    self.layer.cornerRadius = cornerRadius; //设置图片圆角的尺度。
}

- (void)setBorderWithColor: (UIColor *)color width: (CGFloat)width
{
    self.layer.borderColor	= [color CGColor];
    self.layer.borderWidth	= width;
}

@end
