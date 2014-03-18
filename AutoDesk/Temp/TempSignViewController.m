//
//  TempSignViewController.m
//  AutoDesk
//
//  Created by YANGReal on 14-3-12.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "TempSignViewController.h"
#import "PPSSignatureView.h"
#import "YRDragView.h"
@interface TempSignViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,GRRequestsManagerDelegate>
{
    BOOL takePhoto;
    NSString *photoPath;
    UIImage *photo;
    NSTimer *timer;
    NSInteger time;
    int timeOut;
    UIImage *snap;

}
@property (weak , nonatomic) IBOutlet UIImageView  *imgView;
@property (strong , nonatomic) PPSSignatureView  *signView;
@property (strong , nonatomic) UIImageView *imgView2;
@property (strong , nonatomic) GRRequestsManager *requestsManager;
@property (weak , nonatomic) IBOutlet YRDragView *dragView;

- (IBAction)save:(id)sender;

- (IBAction)takePhoto:(id)sender;

@end

@implementation TempSignViewController

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
   // self.view.backgroundColor = [UIColor redColor];
    [self setupViews];
    // Do any additional setup after loading the view from its nib.
}

- (void)setupViews
{
    
    self.imgView2 = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imgView2.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imgView2];
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
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
   // UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"拍照" style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto)];
    
    self.navigationItem.rightBarButtonItems = @[item1];
    [self.view bringSubviewToFront:self.dragView];
    
    
    NSString *str = [AppUtility getObjectForKey:@"timeOut"];
    if (str.length == 0)
    {
        timeOut = 15;
    }
    else
    {
        timeOut = str.intValue;
    }
    
    [self takePhoto];

}


- (void)clear
{
    self.imgView2.image = [UIImage createImageWithColor:[UIColor clearColor]];
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
    [self presentViewController:picker animated:NO completion:nil];
    
}

- (IBAction)takePhoto:(id)sender
{
    [self takePhoto];
}


- (IBAction)save:(id)sender
{
    self.dragView.hidden = YES;
    [self uploadToFTP];
}



- (void)_setupManager
{
    NSString *server = [AppUtility getObjectForKey:@"server"];
    if(server.length == 0)
    {
        [self savePhoto];
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
    
     photoPath = [NSString stringWithFormat:@"%@.jpg",[AppUtility timeStample]];
    
    UIImage *sign = self.signView.signatureImage;
    if (sign == nil)
    {
        sign = [UIImage createImageWithColor:[UIColor clearColor]];
    }
    self.imgView2.image = sign;
    UIImage *pictue = photo;
    if (pictue == nil)
    {
        pictue = [UIImage createImageWithColor:[UIColor clearColor]];
    }
    self.imgView.image = pictue;
    snap = [UIImage imageFromView:self.view];

    NSString *server = [AppUtility getObjectForKey:@"server"];
    // DLog(@"server = %@",server);
    if(server.length == 0)
    {
        return;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeOut:) userInfo:nil repeats:YES];
    
    [self showMBLoadingWithMessage:@"上传中..."];
    NSData *data = UIImageJPEGRepresentation(snap, 0.5);//(snap);
    [data writeToFile:CACH_DOCUMENTS_PATH(photoPath) atomically:YES];
    NSString *remotepath = [NSString stringWithFormat:@"temp/%@",[photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *localPath = [CACH_DOCUMENTS_PATH(photoPath) stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.requestsManager addRequestForUploadFileAtLocalPath:localPath toRemotePath:remotepath];
    [self.requestsManager startProcessingRequests];
    
}

#pragma mark - FTP 代理方法

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteUploadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    [self hideMBLoading];
    [self showMBCompletedWithMessage:@"上传成功"];
    self.dragView.hidden = NO;
    [timer invalidate];
    time = 0;
    [self clearAllImages];
    [self savePhoto];
    
    
}

- (void)timeOut:(NSTimer *)t
{
    time ++;
    if (time>timeOut)
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
    self.dragView.hidden = NO;
    NSData *data = UIImageJPEGRepresentation(snap, 1);
    [data writeToFile:DOCUMENTS_PATH(photoPath) atomically:YES];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    DLog(@"error code = %@",error.userInfo);
    [self hideMBLoading];
    [self showMBFailedWithMessage:@"上传失败"];
    
    [timer invalidate];
    [self savePhoto];
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
    [self clearAllImages];
    
}
    
    
- (void)clearAllImages
{
    [self.signView erase];
    self.imgView2.image = [UIImage createImageWithColor:[UIColor clearColor]];
    self.imgView.image = [UIImage createImageWithColor:[UIColor clearColor]];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    

    if (takePhoto)
    {
        return;
    }
    
    if ([self.signView hasSignature]||photo)
    {
        DLog(@"签到");
        NSString *temp_sign = [AppUtility getObjectForKey:@"temp_sign"];
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
        [AppUtility storeObject:count forKey:@"temp_sign"];

        if([self.delegate respondsToSelector:@selector(goBackFromTempSignViewController)])
        {
            [self.delegate goBackFromTempSignViewController];
        }

        
    }
    else
    {
        DLog(@"未签到");
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    takePhoto = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    takePhoto = NO;
    photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    if ([AppUtility iSRetinaiPad])
    {
        CGSize size = CGSizeMake(photo.size.width/3, photo.size.height/3);
        photo = [photo scaleToSize:size];
    }
    self.imgView.image = photo;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
