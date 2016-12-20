//
//  SVIndefiniteAnimatedView.m
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2014-2016 Guillaume Campagna. All rights reserved.
//

#import "SVIndefiniteAnimatedView.h"
#import "SVProgressHUD.h"

#define CustomImageMargin  7

@interface SVIndefiniteAnimatedView ()

@property (nonatomic, strong) CAShapeLayer *indefiniteAnimatedLayer;
@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, strong) UIImageView  *imageViewDark;
@property (nonatomic, strong) UIImage *imageDark;
@property (nonatomic, strong) UIImage *image;

@end

@implementation SVIndefiniteAnimatedView

- (void)willMoveToSuperview:(UIView*)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    } else {
        [_indefiniteAnimatedLayer removeFromSuperlayer];
        _indefiniteAnimatedLayer = nil;
    }
}

- (void)layoutAnimatedLayer {
    CALayer *layer = self.indefiniteAnimatedLayer;
    [self.layer addSublayer:layer];
    
    CGFloat widthDiff = CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds);
    CGFloat heightDiff = CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds);
    layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2 - widthDiff / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2 - heightDiff / 2);
}

- (CAShapeLayer*)indefiniteAnimatedLayer {
    if(_custom) {
        CABasicAnimation *fullRotation;
        fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        fullRotation.toValue = [NSNumber numberWithFloat:0];
        fullRotation.fromValue = [NSNumber numberWithFloat:((360 * M_PI) / 180)];
        fullRotation.duration = 3;
        fullRotation.repeatCount = 100;
        
        CABasicAnimation *reverseRotation;
        reverseRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        reverseRotation.fromValue = [NSNumber numberWithFloat:0];
        reverseRotation.toValue = [NSNumber numberWithFloat:((360 * M_PI) / 180)];
        reverseRotation.duration = 3;
        reverseRotation.repeatCount = 100;
        
        
        if(!_imageView && !_imageViewDark) {
            NSBundle *bundle = [NSBundle bundleForClass:[SVProgressHUD class]];
            NSURL *url = [bundle URLForResource:@"SVProgressHUD" withExtension:@"bundle"];
            NSBundle *imageBundle = [NSBundle bundleWithURL:url];
            
            
            NSString *pathDark = [imageBundle pathForResource:@"gear_dark" ofType:@"png"];
            NSString *path = [imageBundle pathForResource:@"gear" ofType:@"png"];
            
            
            _imageDark = [UIImage imageWithContentsOfFile:pathDark];
            _image = [UIImage imageWithContentsOfFile:path];
            
            _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-_image.size.width+CustomImageMargin, self.frame.size.width/2-_image.size.width+CustomImageMargin, _image.size.width, _image.size.width)];
            [_imageView setImage:_image];
            
            _imageViewDark = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-CustomImageMargin, self.frame.size.width/2-CustomImageMargin, _imageDark.size.width, _imageDark.size.width)];
            [_imageViewDark setImage:[UIImage imageWithContentsOfFile:pathDark]];
            
            [self addSubview:_imageView];
            [self addSubview:_imageViewDark];
        }
        
        [_imageView setFrame:CGRectMake(self.frame.size.width/2-_image.size.width+CustomImageMargin, self.frame.size.width/2-_image.size.width+CustomImageMargin, _image.size.width, _image.size.width)];
        [_imageViewDark setFrame:CGRectMake(self.frame.size.width/2-CustomImageMargin, self.frame.size.width/2-CustomImageMargin, _imageDark.size.width, _imageDark.size.width)];
        [_imageView.layer addAnimation:fullRotation forKey:@"100"];
        [_imageViewDark.layer addAnimation:reverseRotation forKey:@"100"];
    } else {
        if(!_indefiniteAnimatedLayer) {
            CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
            UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:self.radius startAngle:(CGFloat) (M_PI*3/2) endAngle:(CGFloat) (M_PI/2+M_PI*5) clockwise:YES];
            
            _indefiniteAnimatedLayer = [CAShapeLayer layer];
            _indefiniteAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];
            _indefiniteAnimatedLayer.frame = CGRectMake(0.0f, 0.0f, arcCenter.x*2, arcCenter.y*2);
            _indefiniteAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
            _indefiniteAnimatedLayer.strokeColor = self.strokeColor.CGColor;
            _indefiniteAnimatedLayer.lineWidth = self.strokeThickness;
            _indefiniteAnimatedLayer.lineCap = kCALineCapRound;
            _indefiniteAnimatedLayer.lineJoin = kCALineJoinBevel;
            _indefiniteAnimatedLayer.path = smoothedPath.CGPath;
            
            CALayer *maskLayer = [CALayer layer];
            
            NSBundle *bundle = [NSBundle bundleForClass:[SVProgressHUD class]];
            NSURL *url = [bundle URLForResource:@"SVProgressHUD" withExtension:@"bundle"];
            NSBundle *imageBundle = [NSBundle bundleWithURL:url];
            
            NSString *path = [imageBundle pathForResource:@"angle-mask" ofType:@"png"];
            
            maskLayer.contents = (__bridge id)[[UIImage imageWithContentsOfFile:path] CGImage];
            maskLayer.frame = _indefiniteAnimatedLayer.bounds;
            _indefiniteAnimatedLayer.mask = maskLayer;
            
            NSTimeInterval animationDuration = 1;
            CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            animation.fromValue = (id) 0;
            animation.toValue = @(M_PI*2);
            animation.duration = animationDuration;
            animation.timingFunction = linearCurve;
            animation.removedOnCompletion = NO;
            animation.repeatCount = INFINITY;
            animation.fillMode = kCAFillModeForwards;
            animation.autoreverses = NO;
            [_indefiniteAnimatedLayer.mask addAnimation:animation forKey:@"rotate"];
            
            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            animationGroup.duration = animationDuration;
            animationGroup.repeatCount = INFINITY;
            animationGroup.removedOnCompletion = NO;
            animationGroup.timingFunction = linearCurve;
            
            CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            strokeStartAnimation.fromValue = @0.015;
            strokeStartAnimation.toValue = @0.515;
            
            CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            strokeEndAnimation.fromValue = @0.485;
            strokeEndAnimation.toValue = @0.985;
            
            animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
            [_indefiniteAnimatedLayer addAnimation:animationGroup forKey:@"progress"];
            
        }
    }
    return _indefiniteAnimatedLayer;
}

- (void)setFrame:(CGRect)frame {
    if(!CGRectEqualToRect(frame, super.frame)) {
        [super setFrame:frame];
        
        if(self.superview) {
            [self layoutAnimatedLayer];
        }
    }
    
}

- (void)setRadius:(CGFloat)radius {
    if(radius != _radius) {
        _radius = radius;
        
        [_indefiniteAnimatedLayer removeFromSuperlayer];
        _indefiniteAnimatedLayer = nil;
        
        if(self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (void)setStrokeColor:(UIColor*)strokeColor {
    _strokeColor = strokeColor;
    _indefiniteAnimatedLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _indefiniteAnimatedLayer.lineWidth = _strokeThickness;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

@end
