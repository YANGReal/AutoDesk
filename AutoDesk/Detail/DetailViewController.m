//
//  DetailViewController.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "DetailViewController.h"
#import "SignViewController.h"
#import "SettingViewController.h"
#import "YRDragLabel.h"
@interface DetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,SignViewControllerDelegate,UIAlertViewDelegate,GRRequestsManagerDelegate>
{
    
    NSString *photoPath;
    NSString *signPath;
    NSString *picturePath;
  
    NSInteger time;
    NSTimer *timer;
    int timeOut;

}
@property (weak , nonatomic) IBOutlet YRDragLabel *label;
@property (weak , nonatomic) IBOutlet UIImageView *imgView;
@property (strong , nonatomic) GRRequestsManager *requestsManager;

- (IBAction)save:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)setting:(id)sender;
@end

@implementation DetailViewController

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
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imgView.contentMode = UIViewContentModeScaleToFill;
    [self.view insertSubview:imgView atIndex:0];
    imgView.image = [UIImage imageWithContentsOfFile:DOCUMENTS_PATH(@"bg.png")];
    
    NSString *name = [_data stringAttribute:@"name"];
    NSString *deskNO = [_data stringAttribute:@"desk"];
    self.label.text = [NSString stringWithFormat:@"姓名:%@     桌号:%@",name,deskNO];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"签名" style:UIBarButtonItemStylePlain target:self action:@selector(sign)];
    
    NSString *str = [AppUtility getObjectForKey:@"timeOut"];
    if (str.length == 0)
    {
        timeOut = 15;
    }
    else
    {
        timeOut = str.intValue;
    }
    
}

- (void)sign
{
    BOOL sign = [[NSUserDefaults standardUserDefaults] boolForKey:@"sign"];
    if (sign)
    {
        SignViewController *signVC = [[SignViewController alloc] initWithNibName:@"SignViewController" bundle:nil];
        signVC.delegate = self;
        signVC.name = [_data stringAttribute:@"name"];
        signVC.desk = [_data stringAttribute:@"desk"];
        
        [self.navigationController pushViewController:signVC animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设置中将允许签名开关打开" delegate:Nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (void)back
{
    [self.delegate backFromDetailViewController:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)takePhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = YES;
    picker.delegate = self;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    [self presentViewController:picker animated:YES completion:nil];
}


- (IBAction)save:(id)sender
{
    [self uploadToFTP];
    return;
    if (self.imgView.image == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还未拍照" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您要参加抽奖吗" delegate:self cancelButtonTitle:@"不参加" otherButtonTitles:@"参加", nil];
    [alert show];
    
}

- (IBAction)setting:(id)sender
{
    SettingViewController *settingVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:settingVC animated:YES];
}


#pragma mark -UIAlertView delegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *fileName = nil;
    
    
    UIImage *img1 = [UIImage imageFromView:_label];
    UIImage *img2 = self.imgView.image;
    
    UIImage *img  = [self addImageview:img1 toImage:img2];
    //self.imgView.image = img;
    
    NSData *data = UIImagePNGRepresentation(img);
    [data writeToFile:DOCUMENTS_PATH(@"123.png") atomically:YES];
    return;
    if (buttonIndex == 0)
    {
       fileName = [NSString stringWithFormat:@"N_%@.png",[_data stringAttribute:@"name"]];
    }
    else
    {
        fileName = [NSString stringWithFormat:@"%@.png",[_data stringAttribute:@"name"]];
    }
    [data writeToFile:DOCUMENTS_PATH(fileName) atomically:YES];
}


#pragma mark - UIImagePickerControllerDelegate method


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    //self.imgView.image = img;
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imgView.image = img;
    NSString *photo = [AppUtility getObjectForKey:@"photo"];
    int i ;
    if (photo.length == 0)
    {
        i = 0;
    }
    else
    {
        i = photo.intValue;
    }
    i++;
    NSString *count = [NSString stringWithFormat:@"%d",i];
    [AppUtility storeObject:count forKey:@"photo"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -SignViewController delegate methood

- (void)passSignImage:(UIImage *)image
{
    DLog(@"已经签名");
}

-  (UIImage *)addImageview:(UIImage *)image1 toImage:(UIImage *)image2
{
    CGSize size= CGSizeMake( image2.size.width,image1.size.height+image2.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    // Draw image1
    
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    // Draw image2
    
    [image1 drawInRect:CGRectMake(0, image2.size.height, image2.size.width, image1.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
    
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
    NSString *choujiang = [_data stringAttribute:@"choujiang"];
    if ([choujiang isEqualToString:@"N"])
    {
        photoPath = [NSString stringWithFormat:@"N_%@_%@.jpg",[_data stringAttribute:@"name"],[_data stringAttribute:@"desk"]];
    }
    else
    {
        photoPath = [NSString stringWithFormat:@"%@_%@.jpg",[_data stringAttribute:@"name"],[_data stringAttribute:@"desk"]];

    }
    [self _setupManager];
    
    NSString *server = [AppUtility getObjectForKey:@"server"];
    DLog(@"server = %@",server);
    if(server.length == 0)
    {
        return;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeOut:) userInfo:nil repeats:YES];
    
    [self showMBLoadingWithMessage:@"上传中..."];
    UIImage *img1 = [UIImage imageFromView:_label];
    UIImage *img2 = self.imgView.image;
    UIImage *img  = [self addImageview:img1 toImage:img2];
    NSData *data = UIImageJPEGRepresentation(img, 0.75);
    [data writeToFile:CACH_DOCUMENTS_PATH(photoPath) atomically:YES];
    NSString *remotepath = [NSString stringWithFormat:@"photo/%@",[photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    DLog(@"remotePath = %@",remotepath);
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
    UIImage *img1 = [UIImage imageFromView:_label];
    UIImage *img2 = self.imgView.image;
    UIImage *img  = [self addImageview:img1 toImage:img2];
    NSData *data = UIImagePNGRepresentation(img);
    NSString *choujiang = [_data stringAttribute:@"choujiang"];
    if ([choujiang isEqualToString:@"N"])
    {
        NSString *path = [NSString stringWithFormat:@"Photo/N_%@_%@.png",[_data stringAttribute:@"name"],[_data stringAttribute:@"desk"]];
        [data writeToFile:DOCUMENTS_PATH(path) atomically:YES];
        return;
    }
    NSString *path = [NSString stringWithFormat:@"Photo/%@_%@.png",[_data stringAttribute:@"name"],[_data stringAttribute:@"desk"]];
    [data writeToFile:DOCUMENTS_PATH(path) atomically:YES];

}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    [self savePhoto];
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





#pragma mark - Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
