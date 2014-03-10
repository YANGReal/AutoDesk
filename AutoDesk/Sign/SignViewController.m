//
//  SignViewController.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "SignViewController.h"
#import "PPSSignatureView.h"
@interface SignViewController ()
@property (weak , nonatomic) IBOutlet UIImageView  *imgView;
@property (strong , nonatomic) PPSSignatureView  *signView;
@property (strong , nonatomic) UIImageView *imgView2;
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
    
    //self.imgView.image = self.image;
    //self.imgView2 = [[UIImageView alloc] initWithFrame:self.view.bounds];
   // self.imgView2.contentMode = UIViewContentModeScaleAspectFit;
    //[self.view addSubview:self.imgView2];
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
    //self.signView.color = GLKColor(255 , 255, 255);
    self.signView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.signView];
    //[self.view.layer addSublayer:self.signView.layer];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
}


- (void)clear
{
    [self.signView erase];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.signView hasSignature])
    {
        UIImage *img = [self.signView signatureImage];
        NSData *data = UIImagePNGRepresentation(img);
        NSString *fileName = [NSString stringWithFormat:@"sign_%@_.png",_name];
        [data writeToFile:DOCUMENTS_PATH(fileName) atomically:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
