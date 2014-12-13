//
//  AKStencilButton.m
//
//  Created by Andrey Kadochnikov on 13.12.14.
//  Copyright (c) 2014 Andrey Kadochnikov. All rights reserved.
//

#import "AKStencilButton.h"
#import <QuartzCore/QuartzCore.h>

@interface AKStencilButton ()
{
    UIColor * _buttonColor;
}
@end

@implementation AKStencilButton

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]){
        [self setupDefaults];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        [self setupDefaults];
    }
    return self;
}
-(void)setupDefaults
{
    self.backgroundColor = [UIColor redColor];
    self.layer.cornerRadius = 4;
    self.clipsToBounds = YES;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshMask];
}
-(void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleColor:[UIColor clearColor] forState:state];
}
-(void)refreshMask
{
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    NSString * text = self.titleLabel.text;
    CGSize buttonSize = self.bounds.size;
    UIFont * font = self.titleLabel.font;
    
    NSDictionary* attribs = @{NSFontAttributeName: self.titleLabel.font};
    CGSize textSize = [text sizeWithAttributes:attribs];
    
    
    UIGraphicsBeginImageContextWithOptions(buttonSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGPoint center = CGPointMake(buttonSize.width/2-textSize.width/2, buttonSize.height/2-textSize.height/2);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
    CGContextAddPath(ctx, path.CGPath);
    CGContextFillPath(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeDestinationOut);
    
    [text drawAtPoint:center withAttributes:@{NSFontAttributeName:font}];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.contents = (__bridge id)(viewImage.CGImage);
    maskLayer.frame = self.bounds;
    self.layer.mask = maskLayer;
}
@end
