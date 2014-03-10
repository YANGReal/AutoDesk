//
//  DetailViewController.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "DetailViewController.h"
#import "SignViewController.h"
@interface DetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,SignViewControllerDelegate>
@property (weak , nonatomic) IBOutlet UILabel *label;
@property (weak , nonatomic) IBOutlet UIImageView *imgView;

- (IBAction)takePhoto:(id)sender;

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
