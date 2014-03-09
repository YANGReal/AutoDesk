//
//  MainTableViewCell.m
//  AutoDesk
//
//  Created by andy on 14-3-9.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "MainTableViewCell.h"

@interface MainTableViewCell ()

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation MainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.numberLabel= [[UILabel alloc] initWithFrame:CGRectMake(400, 6, 100, 40)];
        [self.numberLabel setBackgroundColor:[UIColor clearColor]];
        [self.numberLabel setFont:[UIFont boldSystemFontOfSize:24]];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(600, 6, 200, 40)];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.nameLabel setFont:[UIFont systemFontOfSize:20]];
    }
    return self;
}

- (void)initData:(NSDictionary *)dic
{
    [self.numberLabel setText:[dic stringAttribute:@"note"]];
    [self.nameLabel setText:[dic stringAttribute:@"name"]];
}

- (void)setupCell
{
    [self.contentView addSubview:_numberLabel];
    [self.contentView addSubview:_nameLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
