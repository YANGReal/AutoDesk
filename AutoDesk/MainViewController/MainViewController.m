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
@interface MainViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSArray *allDataArray;
@property (nonatomic, strong) NSArray *searchDataArray;
@property (nonatomic, assign) NSInteger currentMaxDisplayedCell;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"找座位";
        self.currentMaxDisplayedCell = 0;
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
    //签名UI
//    PPSSignatureView *signView = [[PPSSignatureView alloc] initWithFrame:self.view.bounds];
//    signView.backgroundColor = [UIColor clearColor];
//    signView.color = GLKColor(100, 23, 100);
//    [self.view addSubview:signView];
//    return;
    
    //countLabel.text
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, DEVICE_HEIGHT, 36)];
    self.searchBar.delegate = self;
    [self.searchBar setSearchBarStyle:UISearchBarStyleDefault];
    [self.searchBar setPlaceholder:@"请输入拼音首字母搜索"];
    [self.searchBar setTranslucent:NO];
    [self.searchBar setShowsCancelButton:YES];
    
    [self.view addSubview:_searchBar];
    
    self.countLabel = [[UILabel alloc] initWithFrame:RECT(100, 0, 400, 50)];
    self.countLabel.textColor = [UIColor redColor];
    self.countLabel.font = [UIFont boldSystemFontOfSize:20];

    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, DEVICE_HEIGHT, DEVICE_WIDTH - 100) style:UITableViewStylePlain];
    [self.mainTableView setDelegate:self];
    [self.mainTableView setDataSource:self];
    self.mainTableView.tableHeaderView = self.countLabel;
    [self.view addSubview:_mainTableView];
    
    
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
    
    NSArray *data = [AppUtility dataFromDB:DOCUMENTS_PATH(@"TestDB.sqlite") withQuery:@"select * from data"];
    self.allDataArray = data;
    NSDictionary *colum = data[0];
    //DLog(@"person = %@",[colum stringAttribute:@"pinyin"]);
    NSString *pinyin  = [colum stringAttribute:@"pinyin"];
    if (pinyin.length == 0)
    {
        for (NSDictionary *dict in data)
        {
            NSString *name = [dict stringAttribute:@"name"];
            NSString *pinyin = [ChineseToPinyin pinyinFromChiniseString:name].lowercaseString;
            NSString *sql = [NSString stringWithFormat:@"update  data set pinyin = '%@' where name = '%@'",pinyin,name];
            [AppUtility updateDB:DOCUMENTS_PATH(@"TestDB.sqlite") WithSQL:sql];
        }
    }
}

#pragma mark *****UITableViewDelegate*****

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_searchDataArray.count == 0)
    {
        self.countLabel.text = [NSString stringWithFormat:@"总计:%d人",_allDataArray.count];
        return _allDataArray.count;
    }
    else
    {
        self.countLabel.text = [NSString stringWithFormat:@"找到:%d人",_searchDataArray.count];
        return _searchDataArray.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (MainTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (_searchDataArray.count == 0) {
        [cell initData:_allDataArray[indexPath.row]];
    }
    else
    {
        [cell initData:_searchDataArray[indexPath.row]];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentMaxDisplayedCell == 0) {
        self.currentMaxDisplayedCell = -1;
    }
    
    if (indexPath.row > _currentMaxDisplayedCell) {
        
        [(MainTableViewCell *)cell setupCell];
        self.currentMaxDisplayedCell = indexPath.row;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
    [self.navigationController pushViewController:detailVC animated:YES];
}


#pragma mark *****UISearchBarDelegate*****

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *string = [[NSString alloc] init];
    for (int i = 0; i < (int)searchBar.text.length; i ++) {
        char j = [searchBar.text characterAtIndex:i];
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%%%c", j]];
    }
    
    NSString *wildcard = [NSString stringWithFormat:@"%@%%", string];

    NSString *sql = [NSString stringWithFormat:@"select * from data where pinyin like '%@'", wildcard];
    self.searchDataArray = [AppUtility dataFromDB:DOCUMENTS_PATH(@"TestDB.sqlite") withQuery:sql];

    if (_searchDataArray.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无搜索结果,请重新搜索" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
    }
   else
   {
    [self.mainTableView reloadData];
   }
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //searchBar.showsCancelButton = YES;
    for(UIView *cancelBtn in [searchBar subviews])
    {
        DLog(@"cancelBtn = %@",cancelBtn);
        if([cancelBtn isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cancelBtn;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (_searchDataArray.count != 0)
    {
        self.searchDataArray = nil;
        [self.mainTableView reloadData];
    }
    [searchBar resignFirstResponder];
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
