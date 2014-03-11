//
//  YRBaseViewController.m
//  iCanvas
//
//  Created by 杨锐 on 13-8-17.
//  Copyright (c) 2013年 yangrui. All rights reserved.
//

#import "YRBaseViewController.h"

@interface YRBaseViewController ()

{
    MBProgressHUD *_hud;
}

@end

@implementation YRBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


-(void)showMBLoadingWithMessage:(NSString *)message
{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.tag = -10000;
    hud.alpha = 0.75;
    hud.labelText = message;
    hud.animationType = MBProgressHUDAnimationZoomIn;
    [self.view addSubview:hud];
    [hud show:YES];

}
-(void)hideMBLoading
{
    MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:-10000];
    [hud removeFromSuperview];
}
-(void)showMBCompletedWithMessage:(NSString *)message
{
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    _hud.mode = MBProgressHUDModeCustomView;
    _hud.animationType = MBProgressHUDAnimationZoomIn;
    _hud.labelText = message;
    [self.view addSubview:_hud];
    [_hud show:YES];
    [_hud hide:YES afterDelay:2];
}
-(void)showMBFailedWithMessage:(NSString *)message
{
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"failed.png"]];
    _hud.animationType = MBProgressHUDAnimationZoomIn;
    _hud.mode = MBProgressHUDModeCustomView;
    _hud.labelText = message;
    [self.view addSubview:_hud];
    [_hud show:YES];
    [_hud hide:YES afterDelay:2];

}

- (void)showMBLoadingWithProgress:(float)progress
{
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.labelText = @"正在上传中..";
    _hud.animationType = MBProgressHUDAnimationZoomIn;
    _hud.mode = MBProgressHUDModeDeterminate;
    _hud.progress = progress;
    [self.view addSubview:_hud];
    [_hud show:YES];
}

/******************
 合成图像
 ******************/
- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image1.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    CGFloat x1 = image1.size.width;
    CGFloat y1 = image1.size.height;
    CGFloat x2 = image2.size.width;
    CGFloat y2 = image2.size.height;
    // Draw image2
    [image2 drawInRect:CGRectMake(x1-x2, y1-y2, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
