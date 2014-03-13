//
//  TempSignViewController.h
//  AutoDesk
//
//  Created by YANGReal on 14-3-12.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "YRBaseViewController.h"



@protocol TempSignViewController <NSObject>

@optional


- (void)goBackFromTempSignViewController;
@end


@interface TempSignViewController : YRBaseViewController
@property (assign ,nonatomic) id<TempSignViewController>delegate;
@end
