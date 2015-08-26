//
//  MLInfiniteScrollViewCell.h
//  TestScroll
//
//  Created by 李梦龙 on 15/8/25.
//  Copyright (c) 2015年 LoveBeijingChirapsia. All rights reserved.
//

/**
 *  MLInfiniteScrollViewCell:
 *      请使用 
                - (instancetype) initWithStyle:(MLInfiniteScrollViewStyle)style reusableIdentifier:(NSString *)identifier; 
                        或
                + (instancetype) infiniteScrollViewCellWithStyle:(NSInteger)style reusableIdentifier:(NSString *)identifier;
 
 *  自定义 Cell 的时候, 请在 -(void)setFrame:(CGRect)frame; 方法中重新布局您
 *  的自定义控件的位置
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MLInfiniteScrollViewStyle) {
    MLInfiniteScrollViewStyleDefault,
    /** 带一张图片 */
    MLInfiniteScrollViewStyleSingleImage,
    /** 带图片和下方的文字 */
    MLInfiniteScrollViewStyleSubTitle,
};

typedef void(^InfiniteCellDidClick)(NSInteger index);

@interface MLInfiniteScrollViewCell : UIView

/**
 *  用于复用的标示符
 */
@property (nonatomic, copy, readonly) NSString *reusableIdentifier;

/**
 *  类型
 */
@property (nonatomic, assign, readonly) MLInfiniteScrollViewStyle style;

/**
 *  Init 方法
 *
 *  @param style      MLInfiniteScrollViewCell类型
 *  @param identifier MLInfiniteScrollViewCell标示符
 *
 *  @return MLInfiniteScrollViewCell实例
 */
- (instancetype) initWithStyle:(MLInfiniteScrollViewStyle)style reusableIdentifier:(NSString *)identifier;

/**
 *  工厂方法
 *
 *  @param type       MLInfiniteScrollViewCell类型
 *  @param identifier MLInfiniteScrollViewCell标示符
 *
 *  @return MLInfiniteScrollViewCell实例
 */
+ (instancetype) infiniteScrollViewCellWithStyle:(NSInteger)style reusableIdentifier:(NSString *)identifier;

/**
 *  图片
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 *  内容视图
 */
@property (nonatomic, strong) UIView *contentView;

/**
 *  下方文字 Label
 */
@property (nonatomic, strong) UILabel *textLabel;

/**
 *  自定义 TextLabel 的位置, 默认为: No
 *   该属性允许您自定义 textLabel 的位置和大小
 */
@property (nonatomic, assign) BOOL *customTextLabelFrame;

/**
 *  当前 Cell 的位置
 */
@property (nonatomic, assign) NSInteger index;

/**
 *  Cell 点击后的 Block 回调
 */
@property (nonatomic, copy) InfiniteCellDidClick clickAction;

/**
 *  ContentView 的 Inset
 */
@property (nonatomic, assign) UIEdgeInsets contentViewInset;

@end
