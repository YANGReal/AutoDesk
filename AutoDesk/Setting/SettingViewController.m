//
//  SettingViewController.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "SettingViewController.h"
#import "GRListingRequest.h"
@interface SettingViewController ()<UIAlertViewDelegate,GRRequestsManagerDelegate>

{
    IBOutlet UIView *colorView;
    IBOutlet UISlider *redSlider;
    IBOutlet UISlider *greenSlider;
    IBOutlet UISlider *blueSlider;
    
    IBOutlet UISlider *fontSlider;
    
    IBOutlet UILabel *rLabel;
    IBOutlet UILabel *gLabel;
    IBOutlet UILabel *bLabel;
    
    IBOutlet UILabel *fontLabel;
    
    IBOutlet UISwitch *switcher;
    
    
    IBOutlet UITextField *serverField;
    IBOutlet UITextField *portField;
    IBOutlet UITextField *userNameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *titleField;
    
    IBOutlet UISlider *timeOut;
    IBOutlet UILabel *timeLabel;
    

}

@property (strong , nonatomic) GRRequestsManager *requestsManager;

- (IBAction)save:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)colorSlider:(UISlider *)sender;

- (IBAction)fontSlider:(UISlider *)sender;


- (IBAction)switcher:(UISwitch *)sender;

- (IBAction)saveUpload:(id)sender;

- (IBAction)restoreTongjiData:(id)sender;


- (IBAction)timeOutSlider:(UISlider *)sender;

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"设置";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *colorDict = [AppUtility getObjectForKey:@"color"];
    if (colorDict == nil)
    {
        colorView.backgroundColor = [UIColor blackColor];
        redSlider.value = 0;
        greenSlider.value = 0;
        blueSlider.value = 0;
        rLabel.text = @"0";
        gLabel.text = @"0";
        bLabel.text = @"0";
    }
    else
    {
       int red = [colorDict stringAttribute:@"red"].intValue;
       int green = [colorDict stringAttribute:@"green"].intValue;
       int blue = [colorDict stringAttribute:@"blue"].intValue;
        redSlider.value = red;
        greenSlider.value = green;
        blueSlider.value = blue;
        rLabel.text = [colorDict stringAttribute:@"red"];
        gLabel.text = [colorDict stringAttribute:@"green"];
        bLabel.text = [colorDict stringAttribute:@"blue"];
        colorView.backgroundColor = RGBColor(red, green, blue, 1);
    }
    
    NSString *font = [AppUtility getObjectForKey:@"font"];
    if (font.length == 0)
    {
        fontSlider.value = 1;
        fontLabel.text = @"1";
        
    }
    else
    {
        fontSlider.value = font.floatValue;
        fontLabel.text = [NSString stringWithFormat:@"%d",font.intValue];
    }
    
    BOOL sign = [[NSUserDefaults standardUserDefaults] boolForKey:@"sign"];
    if (sign == YES)
    {
        switcher.on = YES;
    }
    else
    {
        switcher.on = NO;
    }
    
    NSString *title = [AppUtility getObjectForKey:@"title"];
    if (title.length == 0)
    {
        titleField.text = @"E歌智能找位系统";
    }
    else
    {
        titleField.text = title;
    }
    
    NSString *server = [AppUtility getObjectForKey:@"server"];
   
    if (server.length == 0)
    {
        serverField.text = @"";
    }
    else
    {
        serverField.text = server;
    }
    
    NSString *port = [AppUtility getObjectForKey:@"port"];
    if (port.length == 0)
    {
        portField.text = @"";
    }
    else
    {
        portField.text = port;
    }

    NSString *user = [AppUtility getObjectForKey:@"user"];
    if (user.length != 0)
    {
        
        userNameField.text = user;
    }
    else
    {
        userNameField.text = @"";
    }

    NSString *pw = [AppUtility getObjectForKey:@"pw"];
    if (pw.length == 0)
    {
        passwordField.text = @"";
    }
    else
    {
        passwordField.text = pw;
    }
    
    NSString *time = [AppUtility getObjectForKey:@"timeOut"];
    if (time.length == 0)
    {
        timeLabel.text = @"15秒";
        timeOut.value = 15;
    }
    else
    {
        timeLabel.text = [NSString stringWithFormat:@"%@秒",time];
        timeOut.value = time.floatValue;
    }
    
    
}


- (IBAction)colorSlider:(UISlider *)sender
{
    CGFloat r = redSlider.value;
    CGFloat g = greenSlider.value;
    CGFloat b = blueSlider.value;
    
    colorView.backgroundColor = RGBColor(r, g, b, 1.0);
    rLabel.text = [NSString stringWithFormat:@"%d",(int)redSlider.value];
    gLabel.text = [NSString stringWithFormat:@"%d",(int)greenSlider.value];
    bLabel.text = [NSString stringWithFormat:@"%d",(int)blueSlider.value];

}


- (IBAction)save:(id)sender
{
    NSString *red = [NSString stringWithFormat:@"%d",(int)redSlider.value];
    NSString *green = [NSString stringWithFormat:@"%d",(int)greenSlider.value];
    NSString *blue = [NSString stringWithFormat:@"%d",(int)blueSlider.value];
    NSMutableDictionary *colorDict = [NSMutableDictionary dictionary];
    [colorDict setObject:red forKey:@"red"];
    [colorDict setObject:green forKey:@"green"];
    [colorDict setObject:blue forKey:@"blue"];
    [AppUtility storeObject:colorDict forKey:@"color"];
    
    NSString *fontSize = [NSString stringWithFormat:@"%d",(int)fontSlider.value];
    [AppUtility storeObject:fontSize forKey:@"font"];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}



- (IBAction)switcher:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"sign"];
}

- (IBAction)fontSlider:(UISlider *)sender
{
    fontLabel.text = [NSString stringWithFormat:@"%d",(int)sender.value];
}

-(IBAction)reset:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定恢复默认设置" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (IBAction)restoreTongjiData:(id)sender
{
    [AppUtility removeObjectForkey:@"photo"];
    [AppUtility removeObjectForkey:@"temp_sign"];
    [AppUtility removeObjectForkey:@"sign_count"];
    [[NSFileManager defaultManager] removeItemAtPath:CACH_DOCUMENTS_PATH(@"data.plist") error:nil];
    [self showMBCompletedWithMessage:@"清除成功"];
}


- (IBAction)timeOutSlider:(UISlider *)sender
{
    NSString *str = [NSString stringWithFormat:@"%d",(int)sender.value];
    timeLabel.text = [NSString stringWithFormat:@"%@秒",str];
    [AppUtility storeObject:str forKey:@"timeOut"];
    
}


#pragma mark - UIAlertView method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [AppUtility storeObject:@"5" forKey:@"font"];
        [AppUtility removeObjectForkey:@"color"];
        fontLabel.text = @"1";
        fontSlider.value = 1;
        colorView.backgroundColor = [UIColor blackColor];
        redSlider.value = 0;
        greenSlider.value = 0;
        blueSlider.value = 0;
        rLabel.text = @"0";
        gLabel.text = @"0";
        bLabel.text = @"0";
    }
}


- (IBAction)saveUpload:(id)sender
{
    
    [AppUtility storeObject:titleField.text forKey:@"title"];
    if ([self checkInput])
    {
        [AppUtility storeObject:serverField.text forKey:@"server"];
        [AppUtility storeObject:portField.text forKey:@"port"];
        [AppUtility storeObject:userNameField.text forKey:@"user"];
        [AppUtility storeObject:passwordField.text forKey:@"pw"];
        [self setupFTPServer];
        
        for (UIView *view in self.view.subviews)
        {
            if ([view isKindOfClass:[UITextField class]])
            {
                [view resignFirstResponder];
            }
        }
        
    }
    
}

- (void)setupFTPServer
{
    [self showMBLoadingWithMessage:@"设置中..."];
    NSString *server = serverField.text;
    NSString *port = portField.text;
    NSString *pw = passwordField.text;
    NSString *uid = userNameField.text;
    NSString *url = nil;
    
    if(![server hasPrefix:@"ftp://"])
    {
        url = [NSString stringWithFormat:@"ftp://%@:%@",server,port];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@:%@",server,port];
    }
    
    
    self.requestsManager = [[GRRequestsManager alloc] initWithHostname:url
                                                                  user:uid
                                                              password:pw];
    self.requestsManager.delegate = self;
    
    [self.requestsManager addRequestForCreateDirectoryAtPath:@"photo/"];
    [self.requestsManager addRequestForCreateDirectoryAtPath:@"temp/"];
    [self.requestsManager startProcessingRequests];
   // [self performSelector:@selector(hideLoding) withObject:nil afterDelay:6.0];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteCreateDirectoryRequest:(id<GRRequestProtocol>)request
{
    [self hideMBLoading];
    [self showMBCompletedWithMessage:@"FTP设置成功"];
}


- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    DLog(@"error = %@",error.userInfo);
    NSDictionary *dict = error.userInfo;
    if ([[dict stringAttribute:@"message"] isEqualToString:@"Can't overwrite directory!"])
    {
        [self showMBFailedWithMessage:@"FTP设置成功"];
    }
    else
    {
       
        [self showMBFailedWithMessage:@"FTP设置失败"];

    }
     [self hideMBLoading];
}

- (void)hideLoding
{
  
    
    [self hideMBLoading];
    [self showMBFailedWithMessage:@"连接超时"];
    
}


- (BOOL)checkInput
{
    if (serverField.text.length == 0)
    {
        [serverField becomeFirstResponder];
        [AppUtility showAlert:@"提示" message:@"请输入FTP服务器地址"];
        return NO;
    }
    if (portField.text.length == 0)
    {
        [portField becomeFirstResponder];
        [AppUtility showAlert:@"提示" message:@"请输入FTP端口号"];
        return NO;
    }
    if (userNameField.text.length == 0)
    {
        [userNameField becomeFirstResponder];
        [AppUtility showAlert:@"提示" message:@"请输入FTP用户名"];
        return NO;
    }
    if (passwordField.text.length == 0)
    {
        [passwordField becomeFirstResponder];
        [AppUtility showAlert:@"提示" message:@"请输入FTP密码"];
        return NO;
    }
    return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
