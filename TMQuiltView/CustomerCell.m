//
//  CustomerCell.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "CustomerCell.h"

@interface CustomerCell ()

@property (strong , nonatomic) IBOutlet UILabel *nameLabel;
@property (strong , nonatomic) IBOutlet UILabel *deskLabel;
@property (strong , nonatomic) IBOutlet UIImageView *pen;
@property (strong , nonatomic) IBOutlet UIImageView *photoView;
@end

@implementation CustomerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 10.0;
    self.layer.masksToBounds=  YES;
}


- (void)layoutSubviews
{
    self.nameLabel.text = [_data stringAttribute:@"name"];
    self.deskLabel.text = [_data stringAttribute:@"desk"];
    NSString *sign = [_data stringAttribute:@"sign"];
    if ([sign isEqualToString:@"YES"])
    {
        self.pen.hidden = NO;
    }
    else
    {
        self.pen.hidden = YES;
    }
    NSString *photo = [_data stringAttribute:@"photo"];
    if ([photo isEqualToString:@"YES"])
    {
        self.photoView.hidden = NO;
    }
    else
    {
        self.photoView.hidden = YES;
    }

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
