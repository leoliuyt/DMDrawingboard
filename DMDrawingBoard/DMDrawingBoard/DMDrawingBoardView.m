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

@end
@implementation DMDrawingBoardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    [self configureLayer];
    self.path = [UIBezierPath bezierPath];
    self.path.lineWidth = 2;
    self.path.lineCapStyle = kCGLineCapRound;
    self.path.lineJoinStyle = kCGLineJoinRound;
    [[UIColor redColor] setStroke];
    [self.path strokeWithBlendMode:kCGBlendModeCopy alpha:1.0];
    self.strokes = [NSMutableArray arrayWithCapacity:100];
    self.points = [NSMutableArray arrayWithCapacity:100];
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


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    DMStroke *stroke = [[DMStroke alloc] init];
    [self.strokes addObject:stroke];
    [self.points removeAllObjects];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = touches.allObjects[0];

    CGPoint point = [touch locationInView:self];
    NSValue *value = [NSValue valueWithCGPoint:point];
    [self.points addObject:value];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    DMStroke *stroke = self.strokes.lastObject;
    stroke.points = [self.points copy];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"%s",__func__);
    
    [self.strokes enumerateObjectsUsingBlock:^(DMStroke * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint point = [obj CGPointValue];
            if (idx == 0) {
                [self.path moveToPoint:point];
            } else {
                [self.path addLineToPoint:point];
            }
        }];
    }];
    
    [self.path stroke];
}


@end
