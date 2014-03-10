//
//  SignViewController.h
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignViewControllerDelegate <NSObject>

@optional

- (void)passSignImage:(UIImage *)image;

@end

@interface SignViewController : UIViewController
@property (strong , nonatomic) UIImage *image;
@property (assign , nonatomic) id<SignViewControllerDelegate>delegate;
@property (copy ,nonatomic) NSString *name;
@end
