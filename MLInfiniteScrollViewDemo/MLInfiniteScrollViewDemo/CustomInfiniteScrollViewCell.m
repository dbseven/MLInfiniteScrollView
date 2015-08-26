//
//  CustomInfiniteScrollViewCell.m
//  MLInfiniteScrollViewDemo
//
//  Created by 李梦龙 on 15/8/26.
//  Copyright (c) 2015年 CristianoRLong. All rights reserved.
//

#import "CustomInfiniteScrollViewCell.h"

@interface CustomInfiniteScrollViewCell ()

@property (nonatomic, strong) UIView *centerView;

@property (nonatomic, strong) UILabel *topLabel;

@end

@implementation CustomInfiniteScrollViewCell
#pragma mark - 构造方法
#pragma mark -
#pragma mark 复写 Init 方法
- (instancetype) initWithStyle:(MLInfiniteScrollViewStyle)style reusableIdentifier:(NSString *)identifier bounds:(CGRect)bounds {
    
    if (self = [super initWithStyle: style reusableIdentifier: identifier bounds: bounds]) {
        
        // 1. 配置 UI
        [self createUI];
    }
    
    return self;
}

#pragma mark - 初始化方法
#pragma mark -
#pragma mark 配置 UI
- (void) createUI {
    
    self.centerView = [[UIView alloc] initWithFrame: CGRectMake(10, 10, self.contentView.frame.size.width-20, self.contentView.frame.size.height-20)];
    self.centerView.layer.cornerRadius = 10;
    self.centerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.centerView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.centerView.layer.shadowOpacity = 1.0;
    self.centerView.clipsToBounds = YES;
    [self.contentView addSubview: self.centerView];
    
    
    self.topLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.centerView.frame.size.width, 30)];
    self.topLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.font = [UIFont boldSystemFontOfSize:14];
    self.topLabel.textColor = [UIColor whiteColor];
    [self.centerView addSubview: self.topLabel];
}

#pragma mark - Set 方法重写
#pragma mark -
#pragma mark Set DataSource
- (void) setDataSource:(NSMutableDictionary *)dataSource {
    
    _dataSource = dataSource;
    
    self.centerView.backgroundColor = dataSource[@"color"];
    self.topLabel.text = dataSource[@"title"];
}

@end
