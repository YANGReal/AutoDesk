//
//  DetailViewController.h
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@protocol DetailViewControllerDelegate <NSObject>

@optional

- (void)backFromDetailViewController:(DetailViewController *)vc;

@end

@interface DetailViewController : YRBaseViewController
@property (strong , nonatomic) NSDictionary *data;
@property (assign , nonatomic) id<DetailViewControllerDelegate>delegate;
    
@property (assign , nonatomic) BOOL isSign;
@property (assign , nonatomic) BOOL isPhoto;
@end
