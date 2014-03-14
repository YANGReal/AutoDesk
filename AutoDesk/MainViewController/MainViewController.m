//
//  MainViewController.m
//  AutoDesk
//
//  Created by YANGRui on 14-3-7.
//  Copyright (c) 2014年 YANGRui. All rights reserved.
//

#import "MainViewController.h"
#import "MainTableViewCell.h"
#import "DetailViewController.h"
#import "TMQuiltView.h"
#import "CustomerCell.h"
#import "SettingViewController.h"
#import "YRDragView.h"
#import "SignViewController.h"
#import "TempSignViewController.h"
@interface MainViewController () <UISearchBarDelegate, UIAlertViewDelegate,TMQuiltViewDataSource,TMQuiltViewDelegate,UITextFieldDelegate,DetailViewControllerDelegate,TempSignViewController>
{
    IBOutlet UILabel *label1;//总计
    IBOutlet UILabel *label2;//已拍照
    IBOutlet UILabel *label3;//未拍照
    IBOutlet UILabel *label4;//临时签到
    IBOutlet UILabel *label5;//未签到
    
}

@property (nonatomic, strong) TMQuiltView *mainTableView;
@property (nonatomic, strong) NSMutableArray *allDataArray;
@property (nonatomic, strong) NSArray *searchDataArray;
@property (nonatomic, assign) NSInteger currentMaxDisplayedCell;
@property (nonatomic, strong) UILabel *countLabel;
@property (weak , nonatomic) IBOutlet UITextField *searchBar;
@property (weak , nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak , nonatomic) IBOutlet YRDragView *dragView;
- (IBAction)cancelBtnClicked:(id)sender;

- (IBAction)hiddenDragView:(id)sender;

- (IBAction)tempSign:(id)sender;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      
        NSString *title = [AppUtility getObjectForKey:@"title"];
        if (title.length == 0)
        {
            self.title = @"E歌智能找位系统";
        }
        else
        {
            self.title = title;
        }
        //DLog(@"title = %@",title);
        self.searchDataArray = [NSArray array];
        self.allDataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initDatabase];
    [self setupViews];
    [self setExpireDate:10];

    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
   [self.searchBar addTarget:self action:@selector(searchWithText:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setExpireDate:(NSInteger)day
{
    
    NSDate *date = [AppUtility dateAfterDay:10];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *future = [df stringFromDate:date];

    NSString *expireDate = [AppUtility getObjectForKey:@"expireDate"];
    if (expireDate.length == 0)
    {
        [AppUtility storeObject:future forKey:@"expireDate"];
    }
    else
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDate = [df stringFromDate:[NSDate date]];
        if ([currentDate isEqualToString:expireDate])
        {
            UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
            maskView.alpha = 0.7;
            maskView.backgroundColor = [UIColor blackColor];
            [self.navigationController.view addSubview:maskView];
            UILabel *label = [[UILabel alloc] initWithFrame:RECT(0, 0, 200, 50)];
            label.text = @"软件已过期";
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:22];
            label.textColor = [UIColor redColor];
            label.center = self.view.center;
            [self.navigationController.view addSubview:label];

        }
    }
}


- (void)setupViews
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imgView.contentMode = UIViewContentModeScaleToFill;
    [self.view insertSubview:imgView atIndex:0];
    imgView.image = [UIImage imageWithContentsOfFile:DOCUMENTS_PATH(@"bg.png")];
    //DLog(@"path = %@",CACH_DOCUMENTS_PATH(@"bg.png"));
    //imgView.backgroundColor = [UIColor redColor];
    self.cancelBtn.enabled = NO;
    self.mainTableView = [[TMQuiltView alloc] initWithFrame:CGRectMake(0, 130, 1024, DEVICE_WIDTH - 130)];
    [self.mainTableView setDelegate:self];
    [self.mainTableView setDataSource:self];
    //self.mainTableView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_mainTableView];
    [self.mainTableView reloadData];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"统计" style:UIBarButtonItemStylePlain target:self action:@selector(statistics)];
    
    self.dragView.alpha = 0.0;
    [self.view bringSubviewToFront:self.dragView];
    
}

- (void)setting
{
    SettingViewController *settingVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:settingVC animated:YES];

}


- (void)statistics
{
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
            
            self.dragView.alpha = 1.0;
        }];
    
}


- (IBAction)hiddenDragView:(id)sender
{
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.dragView.alpha = 0.0;
    }];
}

- (IBAction)cancelBtnClicked:(id)sender
{
    self.searchBar.text = @"";
    self.searchDataArray = nil;
    [self.searchBar resignFirstResponder];
    [self.mainTableView reloadData];
}

- (IBAction)tempSign:(id)sender
{
    [self.searchBar resignFirstResponder];
    TempSignViewController *signVC = [[TempSignViewController alloc] initWithNibName:@"TempSignViewController" bundle:nil];
    
    signVC.delegate = self;
    [self.navigationController pushViewController:signVC animated:YES];
}
- (void)initDatabase
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"sqlite"];
    BOOL exist =[[NSFileManager defaultManager] fileExistsAtPath:DOCUMENTS_PATH(@"data.sqlite")];
    if (!exist)
    {
       [[NSFileManager defaultManager] copyItemAtPath:path toPath:DOCUMENTS_PATH(@"data.sqlite") error:nil];
       
    }
    else
    {
        DLog(@"数据库文件已存在");
    }
    
    NSArray *data = [AppUtility dataFromDB:DOCUMENTS_PATH(@"data.sqlite") withQuery:@"select * from data"];
    
    for(NSDictionary *record in data)
    {
        if ([record stringAttribute:@"name"].length!=0)
        {
            [_allDataArray addObject:record];
        }
    }
    DLog(@"data = %@",_allDataArray);
    NSDictionary *colum = _allDataArray[0];
    NSString *pinyin  = [colum stringAttribute:@"pinyin"];
    DLog(@"pinyin = %@",pinyin);
    if (pinyin.length == 0)
    {
        for (NSDictionary *dict in _allDataArray)
        {
            NSString *name = [dict stringAttribute:@"name"];
            if ([ChineseInclude isIncludeChineseInString:name]) {
            NSString *initial = [PinYinForObjc chineseConvertToPinYinHead:name];

            NSString *sql = [NSString stringWithFormat:@"update  data set pinyin = '%@' where name = '%@'",initial,name];
            [AppUtility updateDB:DOCUMENTS_PATH(@"data.sqlite") WithSQL:sql];
            }
            else
            {
                NSArray *words = [name componentsSeparatedByString:@" "];

                NSString *str = [[NSString alloc]init];
                for (NSString *word in words)
                {
                    if ([word isEqual:@""]) {
                        continue;
                    }
                    char j = [word characterAtIndex:0];
                    str = [str stringByAppendingString:[NSString stringWithFormat:@"%c", j]];
                }
                NSString *sql = [NSString stringWithFormat:@"update  data set pinyin = '%@' where name = '%@'",str,name];
                [AppUtility updateDB:DOCUMENTS_PATH(@"data.sqlite") WithSQL:sql];
            }
        }
        
    }
    [self flushStatisticsData];
//    DLog(@"data = %@", _allDataArray);
}

#pragma mark *****UITableViewDelegate*****


- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView
{
    if (_searchDataArray.count == 0)
    {
        self.cancelBtn.enabled = NO;
        return _allDataArray.count;
    }
    else
    {
        self.cancelBtn.enabled = YES;
        return _searchDataArray.count;
    }

}

- (NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView
{
    return 4;
}


- (CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 111.0;
}

- (CGFloat)quiltViewMargin:(TMQuiltView *)quilView marginType:(TMQuiltViewMarginType)marginType
{
    return 20;
}


- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    CustomerCell *cell = (CustomerCell *)[quiltView dequeueReusableCellWithReuseIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomerCell" owner:self options:nil] lastObject];
    }
    if (_searchDataArray.count == 0) {
        cell.data = _allDataArray[indexPath.row];
    }
    else
    {
        cell.data = _searchDataArray[indexPath.row];
    }

    return cell;
}



- (void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data;
    if (self.searchDataArray.count == 0)
    {
        data = _allDataArray[indexPath.row];
    }
    else
    {
        data = _searchDataArray[indexPath.row];
    }

    DetailViewController *detailVC = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    detailVC.data = data;
    detailVC.delegate = self;
    [self.navigationController pushViewController:detailVC animated:YES];

}

#pragma mark - DetailViewController delegate method

- (void)backFromDetailViewController:(DetailViewController *)vc
{
    [self flushStatisticsData];
}


#pragma mark - TempSignViewController delegate method
- (void)goBackFromTempSignViewController
{
    [self flushStatisticsData];
}

- (void)flushStatisticsData
{
    label1.text = [NSString stringWithFormat:@"%lu人",(unsigned long)_allDataArray.count];
    NSString *photo = [AppUtility getObjectForKey:@"photo"];
    if (photo.length == 0)
    {
        label2.text = @"0人";
        label3.text = label1.text;
    }
    else
    {
        label2.text = [NSString stringWithFormat:@"%@人",photo];
        label3.text = [NSString stringWithFormat:@"%lu人",(long)(_allDataArray.count-photo.intValue)];
    }
    
    NSString *temp_sign = [AppUtility getObjectForKey:@"temp_sign"];
    if (temp_sign.length == 0)
    {
        label4.text = @"0人";
    }
    else
    {
        label4.text = [NSString stringWithFormat:@"%@人",temp_sign];
    }
    
    NSString *sign = [AppUtility getObjectForKey:@"sign_count"];
    if (sign.length == 0)
    {
        label5.text = [NSString stringWithFormat:@"%lu人",(unsigned long)_allDataArray.count];
    }
    else
    {
        NSInteger sign_count = sign.integerValue;
        NSInteger all = _allDataArray.count;
        label5.text = [NSString stringWithFormat:@"%lu人",(long)(all-sign_count)];
        if (sign_count>all)
        {
            label5.text = @"0人";
        }
    }

}


#pragma mark *****UITextFieldDelegate method*****

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchWithText:textField];
    
    if (_searchDataArray.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无搜索结果,请重新搜索" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
    [self.searchBar resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.cancelBtn.enabled = YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.searchBar.text = nil;
}

- (void)searchWithText:(UITextField *) sender
{
    NSString *text = sender.text;
    if (text.length == 0)
    {
        return;
    }
    NSString *wildcard = [[NSString alloc] init];

    for (int i = 0; i < (int)text.length; i ++) {
        char j = [text characterAtIndex:i];
        wildcard = [wildcard stringByAppendingString:[NSString stringWithFormat:@"%c%%",  j]];
    }
    self.cancelBtn.enabled = YES;

    NSString *sql = [NSString stringWithFormat:@"select * from data where pinyin like '%@%%'", text];
    if (_searchDataArray.count != 0) {
        self.searchDataArray = nil;
    }
    self.searchDataArray = [AppUtility dataFromDB:DOCUMENTS_PATH(@"data.sqlite") withQuery:sql];
    
    if (_searchDataArray.count == 0) {
//       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无搜索结果,请重新搜索" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//       [alertView show];
    }
    else
    {
        [self.mainTableView reloadData];
    }
}

#pragma mark -UIAlertViewDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        self.searchDataArray = nil;
        [self.mainTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
