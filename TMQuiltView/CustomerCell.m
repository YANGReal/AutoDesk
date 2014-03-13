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
