//
//  YRDragLabel.m
//  AutoDesk
//
//  Created by YANGReal on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "YRDragLabel.h"

@interface YRDragLabel ()
{
      CGPoint beginPoint;
}
@end

@implementation YRDragLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    beginPoint = [touch locationInView:self];
    
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowRadius = 5.0;
//    self.layer.shadowOffset = CGSizeMake(1, 1);
//    self.layer.shadowOpacity = 1.0;
    
//    self.layer.shadowOffset = CGSizeMake(5, 3);
//    self.layer.shadowOpacity = 0.6;
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.masksToBounds = YES;
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint nowPoint = [touch locationInView:self];
    
    float offsetX = nowPoint.x - beginPoint.x;
    float offsetY = nowPoint.y - beginPoint.y;
    
    self.center = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
