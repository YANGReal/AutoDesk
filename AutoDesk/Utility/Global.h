//
//  Global.h
//  AutoDesk
//
//  Created by YANGRui on 14-3-7.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#ifndef AutoDesk_Global_h
#define AutoDesk_Global_h

#import "ChineseToPinyin.h"
#import "AppUtility.h"
#import "UIColor+HexString.h"
#import "UIImage+Loader.h"
#import "UIView+ModifyFrame.h"
#import "NSDictionary+JSON.h"
#import "FMDatabase.h"
#import "PPSSignatureView.h"
#import "MBProgressHUD.h"
#import "GRRequestsManager.h"
#import "YRBaseViewController.h"
#import "PinYin4Objc.h"
#define RECT(x,y,w,h) CGRectMake(x,y,w,h)
#define POINT(x,y) CGPointMake(x,y)

#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height
#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width

#define NAV_HEIGHT 64

#define GLKColor(r,g,b) GLKVector3Make(r/255.0, g/255.0, b/255.0)

#pragma mark -- 定义APP沙盒路径
/******************************
 定义APP沙盒路径
 ******************************/
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define TMPPATH NSTemporaryDirectory()
#define CACHPATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define CACH_DOCUMENTS_PATH(fileName) [CACHPATH stringByAppendingPathComponent:fileName]//缓存文件路径
#define DOCUMENTS_PATH(fileName) [DOCUMENTPATH stringByAppendingPathComponent:fileName]//Documents文件夹路径

#pragma mark --定义颜色
/******************************
 定义RGB颜色
 ******************************/
#define RGBColor(r,g,b,a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a*1.0]


#pragma mark --定义日志输出
/******************************
 定义日志输出模式
 DLog is almost a drop-in replacement for NSLog
 DLog();
 DLog(@"here");
 DLog(@"value: %d", x);
 Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);
 ******************************/
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define ELog(err) {if(err) DLog(@"%@", err)}
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);




#endif
