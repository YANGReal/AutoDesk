//
//  SignViewController.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "SignViewController.h"
#import "PPSSignatureView.h"
@interface SignViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,GRRequestsManagerDelegate>
{
    BOOL takePhoto;
    NSString *photoPath;
    UIImage *photo;
    NSTimer *timer;
    NSInteger time;
}
@property (weak , nonatomic) IBOutlet UIImageView  *imgView;
@property (strong , nonatomic) PPSSignatureView  *signView;
@property (strong , nonatomic) UIImageView *imgView2;
@property (strong , nonatomic) GRRequestsManager *requestsManager;

@end

@implementation SignViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"请在屏幕空白处签名";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [self setupViews];
  
}

- (void)setupViews
{
    self.signView = [[PPSSignatureView alloc] initWithFrame:self.view.bounds];
    NSDictionary *colorDict = [AppUtility getObjectForKey:@"color"];
    if (colorDict == nil)
    {
         self.signView.color = GLKColor(0, 0, 0);
    }
    else
    {
        int red = [colorDict stringAttribute:@"red"].intValue;
        int green = [colorDict stringAttribute:@"green"].intValue;
        int blue = [colorDict stringAttribute:@"blue"].intValue;
        self.signView.color = GLKColor(red , green, blue);
    }
    NSString *fontWidth = [AppUtility getObjectForKey:@"font"];
    if (fontWidth == nil)
    {
        self.signView.fontWidth = 1;
    }
    else
    {
        self.signView.fontWidth = fontWidth.intValue;
    }
    self.signView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.signView];
    if (self.isTemp)
    {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"拍照" style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto)];
        
        self.navigationItem.rightBarButtonItems = @[item1,item2];

    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
    }
}


- (void)clear
{
    [self.signView erase];
}


- (void)takePhoto
{
    takePhoto = YES;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = YES;
    picker.delegate = self;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    [self presentViewController:picker animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    takePhoto = NO;
    photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        [self uploadToFTP];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    takePhoto = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (takePhoto)
    {
        return;
    }
    if ([self.signView hasSignature])
    {
        UIImage *img = [self.signView signatureImage];
        NSData *data = UIImagePNGRepresentation(img);
        
        NSString *fileName = nil;
        fileName =  [NSString stringWithFormat:@"Sign/sign_%@_%@.png",_name,_desk];
        NSString *temp_sign = [AppUtility getObjectForKey:@"sign_count"];
        int i ;
        if (temp_sign.length == 0)
        {
            i = 0;
        }
        else
        {
            i = temp_sign.intValue;
        }
        i++;
        NSString *count = [NSString stringWithFormat:@"%d",i];
        [AppUtility storeObject:count forKey:@"sign_count"];
        [data writeToFile:DOCUMENTS_PATH(fileName) atomically:YES];
        [self.delegate passSignImage:self.signView.signatureImage];
    }
    
}


- (void)_setupManager
{
    NSString *server = [AppUtility getObjectForKey:@"server"];
    if(server.length == 0)
    {
        [AppUtility showAlert:@"提示" message:@"还未设置FTP服务器"];
        return;
    }
    NSString *port = [AppUtility getObjectForKey:@"port"];
    NSString *uid = [AppUtility getObjectForKey:@"user"];
    NSString *pw = [AppUtility getObjectForKey:@"pw"];
    
    NSString *url = nil;
    if(![server hasPrefix:@"ftp://"])
    {
        url = [NSString stringWithFormat:@"ftp://%@:%@",server,port];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@:%@",server,port];
    }
    
    if (self.requestsManager == nil)
    {
        self.requestsManager = [[GRRequestsManager alloc] initWithHostname:url
                                                                      user:uid
                                                                  password:pw];
        self.requestsManager.delegate = self;
        
    }
}


- (void)uploadToFTP
{
    
    [self _setupManager];
    
    NSString *server = [AppUtility getObjectForKey:@"server"];
   // DLog(@"server = %@",server);
    if(server.length == 0)
    {
        return;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeOut:) userInfo:nil repeats:YES];
    
    [self showMBLoadingWithMessage:@"上传中..."];
    NSData *data = UIImagePNGRepresentation(photo);
    NSString *fileName = [NSString stringWithFormat:@"%@.png",[AppUtility timeStample]];
    [data writeToFile:CACH_DOCUMENTS_PATH(fileName) atomically:YES];
    NSString *remotepath = [NSString stringWithFormat:@"photo/%@",[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   // DLog(@"remotePath = %@",remotepath);
    [self.requestsManager addRequestForUploadFileAtLocalPath:CACH_DOCUMENTS_PATH(photoPath) toRemotePath:remotepath];
    [self.requestsManager startProcessingRequests];
}

#pragma mark - FTP 代理方法

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteUploadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    // static int i = 0;
    //  i++;
    //  if (i%3 == 0)
    // {
    [self hideMBLoading];
    [self showMBCompletedWithMessage:@"上传成功"];
    //[self hideMBLoading];
    //   i = 0;
    [timer invalidate];
    time = 0;
    // }
}

- (void)timeOut:(NSTimer *)t
{
    time ++;
    if (time>15)
    {
        time = 0;
        [timer invalidate];
        [self hideMBLoading];
        [self showMBFailedWithMessage:@"超时,请稍后再试"];
        [self savePhoto];
    }
    DLog(@"time = %ld",(long)time);
}



- (void)savePhoto
{
    NSData *data = UIImagePNGRepresentation(photo);
    NSString *path = [NSString stringWithFormat:@"Temp_Photo/%@.png",[AppUtility timeStample]];
    [data writeToFile:DOCUMENTS_PATH(path) atomically:YES];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    DLog(@"error code = %@",error.userInfo);
    NSString *str = [error.userInfo objectForKey:@"message"];
    if (![str isEqualToString:@"Can't overwrite directory!"])
    {
        
    }
    if ([str isEqualToString:@"Unknown error!"])
    {
        [self hideMBLoading];
        [self showMBFailedWithMessage:@"请检查FTP设置"];
        //[self hideMBLoading];
    }
    
    if ([str isEqualToString:@"Not logged in."])
    {
        [self hideMBLoading];
        [self showMBFailedWithMessage:@"用户名错误或密码错误"];
    }
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
