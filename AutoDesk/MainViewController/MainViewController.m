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
@interface MainViewController () <UISearchBarDelegate, UIAlertViewDelegate,TMQuiltViewDataSource,TMQuiltViewDelegate,UITextFieldDelegate,DetailViewControllerDelegate>
{
    IBOutlet UILabel *label1;//总计
    IBOutlet UILabel *label2;//已拍照
    IBOutlet UILabel *label3;//未拍照
    IBOutlet UILabel *label4;//临时签到
    IBOutlet UILabel *label5;//未签到
    
}

@property (nonatomic, strong) TMQuiltView *mainTableView;
@property (nonatomic, strong) NSArray *allDataArray;
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
        self.searchDataArray = [[NSArray alloc] init];
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
   
    [UIView animateWithDuration:0.3 animations:^{
            
            self.dragView.alpha = 1.0;
        }];
    
}


- (IBAction)hiddenDragView:(id)sender
{
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
    SignViewController *signVC = [[SignViewController alloc] initWithNibName:@"SignViewController" bundle:nil];
    signVC.isTemp = YES;
    [self.navigationController pushViewController:signVC animated:YES];
}
- (void)initDatabase
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TestDB" ofType:@"sqlite"];
    BOOL exist =[[NSFileManager defaultManager] fileExistsAtPath:DOCUMENTS_PATH(@"data.sqlite")];
    if (!exist)
    {
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:path toPath:DOCUMENTS_PATH(@"data.sqlite") error:nil];
        DLog(@"success = %d",success);
    }
    else
    {
        DLog(@"数据库文件已存在");
    }
    
    NSArray *data = [AppUtility dataFromDB:DOCUMENTS_PATH(@"data.sqlite") withQuery:@"select * from data"];
    self.allDataArray = data;
    NSDictionary *colum = data[0];
    NSString *pinyin  = [colum stringAttribute:@"pinyin"];
    if (pinyin.length == 0)
    {
        for (NSDictionary *dict in data)
        {
            NSString *name = [dict stringAttribute:@"name"];
            NSString *pinyin = [ChineseToPinyin pinyinFromChiniseString:name].lowercaseString;
            NSString *sql = [NSString stringWithFormat:@"update  data set pinyin = '%@' where name = '%@'",pinyin,name];
            [AppUtility updateDB:DOCUMENTS_PATH(@"data.sqlite") WithSQL:sql];
        }
    }
    [self flushStatisticsData];
    
    
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
    [self searchWithText:textField.text];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.cancelBtn.enabled = YES;
}



- (void)searchWithText:(NSString *)text
{
    if (text.length == 0)
    {
        return;
    }
    NSString *string = [[NSString alloc] init];
    for (int i = 0; i < (int)text.length; i ++) {
        char j = [text characterAtIndex:i];
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%%%c", j]];
    }
    self.cancelBtn.enabled = YES;
    NSString *wildcard = [NSString stringWithFormat:@"%@%%", string];
    
    NSString *sql = [NSString stringWithFormat:@"select * from data where pinyin like '%@'", wildcard];
    self.searchDataArray = [AppUtility dataFromDB:DOCUMENTS_PATH(@"data.sqlite") withQuery:sql];
    
    if (_searchDataArray.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无搜索结果,请重新搜索" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self.mainTableView reloadData];
    }
    [self.searchBar resignFirstResponder];

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
