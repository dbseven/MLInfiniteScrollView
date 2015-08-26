//
//  CustomTableViewCell.m
//  MLInfiniteScrollViewDemo
//
//  Created by 李梦龙 on 15/8/25.
//  Copyright (c) 2015年 CristianoRLong. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "MLInfiniteScrollView.h"
#import "MLInfiniteScrollViewCell.h"

@interface CustomTableViewCell () <MLInfiniteScrollViewDelegate, MLInfiniteScrollViewDataSource>

@property (nonatomic, strong) MLInfiniteScrollView *scrollView;

@end

@implementation CustomTableViewCell
-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle: style reuseIdentifier: reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureUI];
    }
    
    return self;
}

- (void) dealloc {
    [self.scrollView stopAutoScroll];
    NSLog(@"%@ Dealloc", [self class]);
}

- (void) configureUI {
    
    self.scrollView = [MLInfiniteScrollView infiniteScrollViewWithFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200) delegate:self dataSource:self timeInterval:4.0];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview: self.scrollView];
}

- (void) setDataSource:(NSMutableArray *)dataSource {
    
    _dataSource = dataSource;
    
    [self.scrollView reloadData];
}

#pragma mark - MLInfiniteScrollView Delegate
#pragma mark -
#pragma mark 点击
- (void) infiniteScrollView:(MLInfiniteScrollView *)scrollView didSelectedItemAtIndex:(NSInteger)index {
    
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
    
        cell.contentViewInset = UIEdgeInsetsMake(10, 10, 0, 10);
    
    return cell;
}
@end
