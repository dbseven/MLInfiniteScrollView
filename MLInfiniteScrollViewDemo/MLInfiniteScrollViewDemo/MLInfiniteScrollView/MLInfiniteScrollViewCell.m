//
//  MLInfiniteScrollViewCell.m
//  TestScroll
//
//  Created by 李梦龙 on 15/8/25.
//  Copyright (c) 2015年 LoveBeijingChirapsia. All rights reserved.
//

#import "MLInfiniteScrollViewCell.h"

@interface MLInfiniteScrollViewCell ()

/** 用于复用的标示符 */
@property (nonatomic, copy) NSString *identifier;

/** Cell 类型 */
@property (nonatomic, assign) MLInfiniteScrollViewStyle cellStyle;

/** Tap 手势 */
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation MLInfiniteScrollViewCell
#pragma mark - 构造方法
#pragma mark -
#pragma mark Init 方法
- (instancetype) initWithStyle:(MLInfiniteScrollViewStyle)style reusableIdentifier:(NSString *)identifier  {
    if (self = [super init]) {
        
        // 1. 设置私有变量
        self.identifier = identifier;
        self.cellStyle = style;
        self.contentViewInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        // 2. 配置 UI
        [self configureUI];
        
        // 3. 添加手势
        [self addGestureRecognizer];
        
        // 4. 注册观察者
        [self registerObserver];
    }
    return self;
}
#pragma mark 工厂方法
+ (instancetype) infiniteScrollViewCellWithStyle:(NSInteger)style reusableIdentifier:(NSString *)identifier {
    MLInfiniteScrollViewCell *cell = [[MLInfiniteScrollViewCell alloc] initWithStyle: style reusableIdentifier: identifier];
    return cell;
}
#pragma mark - 析构方法
#pragma mark - 
- (void) dealloc {
    [self.textLabel removeObserver: self forKeyPath: @"text"];
    [self.imageView removeObserver: self forKeyPath: @"image"];
    NSLog(@"%@ Dealloc", [self class]);
}

#pragma mark - 初始化方法
#pragma mark -
#pragma mark 配置 UI
- (void) configureUI {
    
    // 1. 添加内容视图
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview: self.contentView];
    
    switch (self.style) {
        case MLInfiniteScrollViewStyleDefault:
        {
            
        }
            break;
            
        case MLInfiniteScrollViewStyleSingleImage:
        {
            [self createImageView];
        }
            break;
            
        case MLInfiniteScrollViewStyleSubTitle:
        {
            [self createImageView];
            [self createLabel];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 创建 ImageView
- (void) createImageView {
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.userInteractionEnabled = NO;
    self.imageView.hidden = YES;
    [self.contentView addSubview: self.imageView];
}
#pragma mark 创建 Label
- (void) createLabel {
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.userInteractionEnabled = NO;
    self.textLabel.hidden = YES;
    self.textLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.textLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview: self.textLabel];
}

#pragma mark 添加手势
- (void) addGestureRecognizer {
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapAction:)];
    [self.contentView addGestureRecognizer: self.tap];
}

#pragma mark 注册观察者
- (void) registerObserver {
    
    [self.textLabel addObserver: self forKeyPath: @"text" options:NSKeyValueObservingOptionNew context: nil];
    [self.imageView addObserver: self forKeyPath: @"image" options:NSKeyValueObservingOptionNew context: nil];
}

#pragma mark - Set 方法重写
#pragma mark -
#pragma mark Set Frame
- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // 0. 设置 ContentView 的 Frame
    self.contentView.frame = CGRectMake(
                                        self.contentViewInset.left,
                                        self.contentViewInset.top,
                                        frame.size.width - self.contentViewInset.left - self.contentViewInset.right,
                                        frame.size.height - self.contentViewInset.top - self.contentViewInset.bottom);
    
    // 1. 设置 图片 的 Frame
    self.imageView.frame = (CGRect) {CGPointZero, self.contentView.frame.size};
    
    // 2. 设置 下方文字 的 Frame
    if (!self.customTextLabelFrame) {
        CGFloat height = self.contentView.frame.size.height/5.0;
        self.textLabel.frame = (CGRect) {{0, self.contentView.frame.size.height-height}, {self.contentView.frame.size.width, height}};
    }
}

#pragma mark - Get 方法重写
#pragma mark -
#pragma mark Get reusableIdentifier
- (NSString *) reusableIdentifier {
    return self.identifier;
}
#pragma mark Get Style
- (MLInfiniteScrollViewStyle) style {
    return self.cellStyle;
}

#pragma mark - 事件
#pragma mark -
#pragma mark Tap Action
- (void) tapAction:(UITapGestureRecognizer *)tap {
    if (self.clickAction) {
        self.clickAction(self.index);
    }
}

#pragma mark - KVO
#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSObject *newValue = change[@"new"];
    
    if (object == self.textLabel) {
        if (newValue != nil  && newValue) {
            self.textLabel.hidden = NO;
        } else {
            self.textLabel.hidden = YES;
        }
    } else if (object == self.imageView) {
        if (newValue != nil  && newValue) {
            self.imageView.hidden = NO;
        } else {
            self.imageView.hidden = YES;
        }
    }
}

@end
