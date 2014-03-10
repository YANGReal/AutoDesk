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
@interface DetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,SignViewControllerDelegate,UIAlertViewDelegate>
@property (weak , nonatomic) IBOutlet YRDragLabel *label;
@property (weak , nonatomic) IBOutlet UIImageView *imgView;


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
    
}

- (void)sign
{
    BOOL sign = [[NSUserDefaults standardUserDefaults] boolForKey:@"sign"];
    if (sign)
    {
        SignViewController *signVC = [[SignViewController alloc] initWithNibName:@"SignViewController" bundle:nil];
        signVC.delegate = self;
        signVC.name = [_data stringAttribute:@"name"];
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
    
    [image1 drawInRect:CGRectMake(0, image2.size.height, image1.size.width, image1.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
    
}




#pragma mark - Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
