//
//  ViewController.m
//  上拉加载更多
//
//  Created by jhtxch on 15/11/11.
//  Copyright © 2015年 jhtxch. All rights reserved.
//

#import "ViewController.h"
#import "LoadMoreFooterView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    UIImageView *_leftSharkV;
    UIImageView *_leftFishV;
    UIImageView *_bottomV;
    
    UIImageView *_rightFishV;
    UIImageView *_rightSharkV;
    LoadMoreFooterView *_footView;
    NSInteger _num;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ceatTableView];
    _num = 20;
    NSLog(@"%lf",_tableView.contentSize.height);
    _footView = [[LoadMoreFooterView alloc] initWithObject:self AndSEL:@selector(method) scrollV:_tableView];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    _tableView.tableFooterView.backgroundColor = [UIColor yellowColor];
}
- (void)method
{
    _num ++;
    [_footView endRefresh:^{
        [_tableView reloadData];
    }];
//    [_tableView reloadData];
    
    NSLog(@"正在刷新");
}


- (void)ceatTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
#pragma mark - tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%li",indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // NSLog(@"%lf",scrollView.contentSize.height);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
