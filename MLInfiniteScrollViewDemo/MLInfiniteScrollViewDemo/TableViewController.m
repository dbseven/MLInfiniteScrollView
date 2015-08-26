//
//  TableViewController.m
//  MLInfiniteScrollViewDemo
//
//  Created by CristianoRLong on 15/8/25.
//  Copyright (c) 2015年 CristianoRLong. All rights reserved.
//

#import "TableViewController.h"
#import "MLInfiniteScrollView.h"
#import "CustomTableViewCell.h"

@interface TableViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation TableViewController
#pragma mark - UIViewController 生命周期
#pragma mark -
#pragma mark 析构方法
- (void) dealloc {
    NSLog(@"%@ Dealloc", [self class]);
}
#pragma mark View 加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 初始化成员变量
    [self configureVariables];
    
    // 2. 初始化航栏
    [self configureNavigationBar];
    
    // 3. 配置 TableView
    [self configureTableView];
}
#pragma mark - 视图将要消失
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
}

#pragma mark - 初始化方法
#pragma mark -
#pragma mark 初始化导航栏
- (void) configureNavigationBar {
    self.title = @"TableViewController";
}
#pragma mark 初始化成员变量
- (void) configureVariables {
    
    self.dataSource = [[NSMutableArray alloc] initWithObjects:
                       @{@"color":[UIColor redColor],               @"title":@"红色"},
                       @{@"color":[UIColor orangeColor],         @"title":@"橙色"},
                       @{@"color":[UIColor yellowColor],         @"title":@"黄色"},
                       @{@"color":[UIColor greenColor],           @"title":@"绿色"},
                       @{@"color":[UIColor cyanColor],            @"title":@"青色"},
                       @{@"color":[UIColor blueColor],            @"title":@"蓝色"},
                       @{@"color":[UIColor purpleColor],         @"title":@"紫色"},
                       @{@"color":[UIColor blackColor],         @"title":@"黑色"},
                       nil];
}
#pragma mark 初始化 TableView
- (void) configureTableView {
    [self.tableView reloadData];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableView Delegate
#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 200;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CellIdentifier"];
    
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"CellIdentifier"];
    }
    
    cell.dataSource = self.dataSource;
    
    return cell;
}

@end
