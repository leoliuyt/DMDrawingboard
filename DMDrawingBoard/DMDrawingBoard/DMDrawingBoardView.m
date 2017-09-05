//
//  DMDrawingBoardView.m
//  DMDrawingBoard
//
//  Created by lbq on 2017/9/4.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "DMDrawingBoardView.h"
#import "DMStroke.h"

@interface DMDrawingBoardView()

@property (nonatomic, strong) NSMutableArray<DMStroke *> *strokes;
@property (nonatomic, strong) NSMutableArray <NSValue *>*points;

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) BOOL isChanging;

@end
@implementation DMDrawingBoardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    [self configureLayer];
    self.path = [UIBezierPath bezierPath];
    self.strokes = [NSMutableArray arrayWithCapacity:100];
    self.points = [NSMutableArray arrayWithCapacity:100];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
    self.displayLink.frameInterval  = 2;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    return self;
}

- (void)configureLayer
{
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    shapeLayer.fillColor = nil;
}

+(Class)layerClass{
    return [CAShapeLayer class];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)displayLinkAction:(CADisplayLink *)link
{
    if(self.isChanging){
        [self setNeedsDisplay];
    }
}

- (void)draw{
    [self.strokes enumerateObjectsUsingBlock:^(DMStroke * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [obj.points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint point = [obj CGPointValue];
            if (idx == 0) {
                [path moveToPoint:point];
            } else {
                [path addLineToPoint:point];
            }
        }];
        [self.path appendPath:path];
    }];
    
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    shapeLayer.path = self.path.CGPath;
    shapeLayer.lineWidth = 4;
    shapeLayer.lineCap = @"round";
    shapeLayer.lineJoin = @"round";
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = touches.allObjects[0];
    CGPoint point = [touch locationInView:self];
    NSValue *value = [NSValue valueWithCGPoint:point];
    
    self.isChanging = YES;
    [self.points removeAllObjects];
    [self.points addObject:value];
    DMStroke *stroke = [[DMStroke alloc] init];
    [self.strokes addObject:stroke];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = touches.allObjects[0];
    CGPoint point = [touch locationInView:self];
    NSValue *value = [NSValue valueWithCGPoint:point];
    
    [self.points addObject:value];
    DMStroke *stroke = self.strokes.lastObject;
    stroke.points = [self.points copy];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    self.isChanging = NO;
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"%s",__func__);
    [self.strokes enumerateObjectsUsingBlock:^(DMStroke * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 4;
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        [[UIColor redColor] setStroke];
        [path strokeWithBlendMode:kCGBlendModeCopy alpha:1.0];
        [obj.points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint point = [obj CGPointValue];
            if (idx == 0) {
                [path moveToPoint:point];
            } else {
                [path addLineToPoint:point];
            }
        }];
        [path stroke];
    }];
}


@end
