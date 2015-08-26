//
//  ViewController.m
//  MLInfiniteScrollViewDemo
//
//  Created by CristianoRLong on 15/8/25.
//  Copyright (c) 2015年 CristianoRLong. All rights reserved.
//

#import "ViewController.h"
#import "MLInfiniteScrollView.h"
#import "MLInfiniteScrollViewCell.h"

@interface ViewController () <MLInfiniteScrollViewDataSource, MLInfiniteScrollViewDelegate>

@property (nonatomic, strong) MLInfiniteScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property(nonatomic, strong) UILabel *messageLabel;

@end

@implementation ViewController
#pragma mark - UIViewController 生命周期
#pragma mark -
#pragma mark 析构方法
- (void) dealloc {
    NSLog(@"%@ Dealloc", [self class]);
}
#pragma mark View 加载
- (void) loadView {
    [super loadView];
}

#pragma mark View 加载完成
- (void) viewDidLoad {
    [super viewDidLoad];
    
    // 1. 初始化成员变量
    [self configureVariables];
    
    // 2. 初始化 UI
    [self configureUI];
    
    // 3. 初始化导航栏
    [self configureNavigationBar];
}

#pragma mark - 视图将要出现
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self.scrollView startAutoScroll];
}

#pragma mark - 视图将要消失
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    [self.scrollView stopAutoScroll];
}

#pragma mark - 初始化方法
#pragma mark -
#pragma mark 初始化导航栏
- (void) configureNavigationBar {
    
    self.title = @"ViewController";
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
                       @{@"color":[UIColor brownColor],         @"title":@"棕色"},
                       nil];
}
#pragma mark 初始化 UI
- (void) configureUI {
    
    self.scrollView = [MLInfiniteScrollView infiniteScrollViewWithFrame: CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 200) delegate:self dataSource:self timeInterval:4.0];
    [self.view addSubview: self.scrollView];
    
    self.messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, [UIScreen mainScreen].bounds.size.height-30, [UIScreen mainScreen].bounds.size.width, 40)];
    self.messageLabel.textColor = [UIColor blackColor];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: self.messageLabel];
}

#pragma mark - MLInfiniteScrollView Delegate
#pragma mark -
#pragma mark 停止滚动
- (void) infiniteScrollView:(MLInfiniteScrollView *)scrollView stopScrollAnimationAtIndex:(NSInteger)index {
    
    /**
     * 由于 MLInfiniteScrollView 中并没有 PageControl, 您可以在这个方法中控制
     *  PageControl 的 currentPage 属性.
     */
}
#pragma mark 将要滚动
- (void) infiniteScrollView:(MLInfiniteScrollView *)scrollView willBeginScroll:(NSInteger)index {
}
#pragma mark 点击
- (void) infiniteScrollView:(MLInfiniteScrollView *)scrollView didSelectedItemAtIndex:(NSInteger)index {
    /**
     *  监听该方法, 可以捕获到用户点击 ScrollView 的情况.
     *  除了监听该方法, 您也可以直接监听 MLInfiniteScrollViewCell 的 clickAction Block 回调.
     */
    
    self.messageLabel.text = [NSString stringWithFormat: @"点击了%@", [self.dataSource[index] objectForKey:@"title"]];
    self.messageLabel.backgroundColor = [[self.dataSource[index] objectForKey:@"color"] colorWithAlphaComponent:0.7];
}

#pragma mark - MLInfiniteScrollView DataSource
#pragma mark -
#pragma mark 视图个数
- (NSInteger) numberOfItemsInInfiniteScrollView:(MLInfiniteScrollView *)scrollView {
    return self.dataSource.count;
}
#pragma mark 返回需要显示的视图
- (MLInfiniteScrollViewCell *) infiniteScrollView:(MLInfiniteScrollView *)scrollView viewAtIndex:(NSInteger)index {
    
    MLInfiniteScrollViewCell *cell = [scrollView dequeueReusableCellWithIdentifier: @"CellIdentifier"];
    
    if (!cell) {
        cell = [MLInfiniteScrollViewCell infiniteScrollViewCellWithStyle: MLInfiniteScrollViewStyleSubTitle reusableIdentifier: @"CellIdentifier"];
    }
    
    cell.contentView.backgroundColor = [self.dataSource[index] objectForKey:@"color"];
    
    if (index%2) {
        cell.textLabel.text = [self.dataSource[index] objectForKey: @"title"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"data18.bin_1"];
    }
    
    return cell;
}


@end
