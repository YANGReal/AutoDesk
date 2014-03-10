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
@interface DetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,SignViewControllerDelegate,UIAlertViewDelegate>
@property (weak , nonatomic) IBOutlet UILabel *label;
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
    NSString *name = [_data stringAttribute:@"name"];
    NSString *deskNO = [_data stringAttribute:@"desk"];
    self.label.text = [NSString stringWithFormat:@"姓名:%@     桌号:%@",name,deskNO];
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)takePhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = YES;
    picker.delegate = self;
    //picker.allowsEditing = YES;
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
    NSData *data = UIImagePNGRepresentation(self.imgView.image);
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
    SignViewController *signVC = [[SignViewController alloc] initWithNibName:@"SignViewController" bundle:nil];
    signVC.delegate = self;
    signVC.image = img;
    [self.navigationController pushViewController:signVC animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -SignViewController delegate methood

- (void)passSignImage:(UIImage *)image
{
    self.imgView.image = image;
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
