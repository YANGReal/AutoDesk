//
//  MainViewController.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-7.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"AutoDesk";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initDatabase];
    [self setupViews];
}


- (void)setupViews
{
    PPSSignatureView *signView = [[PPSSignatureView alloc] initWithFrame:self.view.bounds];
    signView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:signView];
}


- (void)initDatabase
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TestDB" ofType:@"sqlite"];
    BOOL exist =[[NSFileManager defaultManager] fileExistsAtPath:DOCUMENTS_PATH(@"TestDB.sqlite")];
    if (!exist)
    {
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:path toPath:DOCUMENTS_PATH(@"TestDB.sqlite") error:nil];
        DLog(@"success = %d",success);
    }
    else
    {
        DLog(@"数据库文件已存在");
    }
    
    NSArray *data = [AppUtility dataFromDB:DOCUMENTS_PATH(@"TestDB.sqlite") withQuery:@"select * from data1"];
    DLog(@"data = %@",data);
    NSDictionary *colum = data[0];
    //DLog(@"person = %@",[colum stringAttribute:@"pinyin"]);
    NSString *pinyin  = [colum stringAttribute:@"pinyin"];
    if (pinyin.length == 0)
    {
        for (NSDictionary *dict in data)
        {
            NSString *name = [dict stringAttribute:@"name"];
            NSString *pinyin = [ChineseToPinyin pinyinFromChiniseString:name].lowercaseString;
            NSString *sql = [NSString stringWithFormat:@"update  data1 set pinyin = '%@' where name = '%@'",pinyin,name];
            [AppUtility updateDB:DOCUMENTS_PATH(@"TestDB.sqlite") WithSQL:sql];
        }
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
