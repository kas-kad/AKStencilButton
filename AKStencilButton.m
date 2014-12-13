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
    UIView * _maskingView;
    UIView * _bgView;
    UIColor * _buttonColor;
}
@end

@implementation AKStencilButton

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]){
        [self setupDefaults]
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
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGPoint center = CGPointMake(buttonSize.width/2-textSize.width/2, buttonSize.height/2-textSize.height/2);
    [text drawAtPoint:center withAttributes:@{NSFontAttributeName:font}];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef img = [self invertedAlpha:viewImage.CGImage];
    CALayer *maskLayer = [CALayer layer];
    maskLayer.contents = CFBridgingRelease(img);
    maskLayer.frame = self.bounds;
    
    if (!_maskingView){
        _maskingView = [[UIView alloc] initWithFrame:self.bounds];
        _maskingView.userInteractionEnabled = NO;
        _maskingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _maskingView.backgroundColor = [UIColor clearColor];
        
        _bgView = [[UIView alloc] initWithFrame:_maskingView.bounds];
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _bgView.userInteractionEnabled = NO;
        [_maskingView addSubview:_bgView];
        [self addSubview:_maskingView];
    }
    _bgView.backgroundColor = _buttonColor;
    _maskingView.layer.mask = maskLayer;
    [_maskingView setNeedsLayout];
}
-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:[UIColor clearColor]];
    _buttonColor = backgroundColor;
}
-(CGImageRef)invertedAlpha:(CGImageRef)originalMaskImage
{
#define ROUND_UP(N, S) ((((N) + (S) - 1) / (S)) * (S))
    float width = CGImageGetWidth(originalMaskImage);
    float height = CGImageGetHeight(originalMaskImage);
    
    int strideLength = ROUND_UP(width * 1, 4);
    unsigned char * alphaData = calloc(strideLength * height, sizeof(unsigned char));
    CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData,
                                                          width,
                                                          height,
                                                          8,
                                                          strideLength,
                                                          NULL,
                                                          (CGBitmapInfo)kCGImageAlphaOnly);
    CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), originalMaskImage);
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned char val = alphaData[y*strideLength + x];
            val = 255 - val;
            alphaData[y*strideLength + x] = val;
        }
    }
    
    CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
    CGContextRelease(alphaOnlyContext);
    free(alphaData);
    
    return alphaMaskImage;
}
@end
