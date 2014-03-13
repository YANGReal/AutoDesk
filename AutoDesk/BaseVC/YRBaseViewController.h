//
//  YRBaseViewController.h
//  iCanvas
//
//  Created by 杨锐 on 13-8-17.
//  Copyright (c) 2013年 yangrui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YRBaseViewController : UIViewController


/*关于MB开源框架的进度提示符，会阻塞主线程*/
-(void)showMBLoadingWithMessage:(NSString *)message;//显示基本的mb等待
-(void)hideMBLoading;//隐藏mb
-(void)showMBCompletedWithMessage:(NSString *)message;//显示一个对号，表明操作成功
-(void)showMBFailedWithMessage:(NSString *)message;//显示一个叉叉，表明操作失败
/*显示进度*/
- (void)showMBLoadingWithProgress:(float)progress;

/*合成图像*/
- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;
@end
