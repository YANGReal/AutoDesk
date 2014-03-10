//
//  SettingViewController.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()<UIAlertViewDelegate>

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
}

- (IBAction)save:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)colorSlider:(UISlider *)sender;

- (IBAction)fontSlider:(UISlider *)sender;


- (IBAction)switcher:(UISwitch *)sender;

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
        titleField.text = @"找座位";
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
    if (server.length == 0)
    {
        serverField.text = @"";
    }
    else
    {
        serverField.text = port;
    }

    NSString *user = [AppUtility getObjectForKey:@"user"];
    if (server.length == 0)
    {
        serverField.text = @"";
    }
    else
    {
        serverField.text = user;
    }

    NSString *pw = [AppUtility getObjectForKey:@"pw"];
    if (server.length == 0)
    {
        serverField.text = @"";
    }
    else
    {
        serverField.text = pw;
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
    
    
    [AppUtility storeObject:titleField.text forKey:@"title"];
    [AppUtility storeObject:serverField.text forKey:@"server"];
    [AppUtility storeObject:portField.text forKey:@"port"];
    [AppUtility storeObject:userNameField.text forKey:@"user"];
    [AppUtility storeObject:passwordField.text forKey:@"pw"];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
