//
//  SettingViewController.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-10.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

{
    IBOutlet UIView *colorView;
    IBOutlet UISlider *redSlider;
    IBOutlet UISlider *greenSlider;
    IBOutlet UISlider *blueSlider;
    
    
    IBOutlet UILabel *rLabel;
    IBOutlet UILabel *gLabel;
    IBOutlet UILabel *bLabel;
}

- (IBAction)redSlider:(UISlider *)sender;
- (IBAction)green:(UISlider *)sender;
- (IBAction)blueSlider:(UISlider *)sender;

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
}


- (IBAction)redSlider:(UISlider *)sender
{
    CGFloat r = redSlider.value;
    CGFloat g = greenSlider.value;
    CGFloat b = blueSlider.value;
    
    colorView.backgroundColor = RGBColor(r, g, b, 1.0);
    rLabel.text = [NSString stringWithFormat:@"%d",(int)redSlider.value];
    gLabel.text = [NSString stringWithFormat:@"%d",(int)greenSlider.value];
    bLabel.text = [NSString stringWithFormat:@"%d",(int)blueSlider.value];

}

- (IBAction)green:(UISlider *)sender
{
    CGFloat r = redSlider.value;
    CGFloat g = greenSlider.value;
    CGFloat b = blueSlider.value;
    
    colorView.backgroundColor = RGBColor(r, g, b, 1.0);
    
    rLabel.text = [NSString stringWithFormat:@"%d",(int)redSlider.value];
    gLabel.text = [NSString stringWithFormat:@"%d",(int)greenSlider.value];
    bLabel.text = [NSString stringWithFormat:@"%d",(int)blueSlider.value];
}

- (IBAction)blueSlider:(UISlider *)sender
{
    CGFloat r = redSlider.value;
    CGFloat g = greenSlider.value;
    CGFloat b = blueSlider.value;
    colorView.backgroundColor = RGBColor(r, g, b, 1.0);
    rLabel.text = [NSString stringWithFormat:@"%d",(int)redSlider.value];
    gLabel.text = [NSString stringWithFormat:@"%d",(int)greenSlider.value];
    bLabel.text = [NSString stringWithFormat:@"%d",(int)blueSlider.value];


}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
