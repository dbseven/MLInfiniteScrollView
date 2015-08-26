//
//  MLInfiniteScrollView.m
//  TestScroll
//
//  Created by 李梦龙 on 15/8/24.
//  Copyright (c) 2015年 LoveBeijingChirapsia. All rights reserved.
//

#import "MLInfiniteScrollView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

NSString * const kStartTimerNotification = @"StartTimerNotification";
NSString * const kStopTimerNotification = @"StopTimerNotification";
CGFloat const kDefaultTimeInterval = 5.0f;

@interface MLInfiniteScrollView () <UIScrollViewDelegate>

/** 主 ScrollView */
@property (nonatomic, strong) UIScrollView *scrollView;

/** 数据源数量 */
@property (nonatomic, assign) NSInteger dataCount;

/** 防止滚动过快的 View */
@property (strong, nonatomic) UIView *maskView;

/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;

/** 存放可以复用的 Cell 的字典 */
@property (nonatomic, strong) NSMutableDictionary *reusableCellDictionary;

/** 用来判断是否正在动画过程中 */
@property (nonatomic, assign) BOOL animating;

/** self.size */
@property (nonatomic, assign) CGSize size;

/** self.frame.size.height */
@property (nonatomic, assign) CGFloat height;

/** self.frame.size.width */
@property (nonatomic, assign) CGFloat width;

@end

@implementation MLInfiniteScrollView
#pragma mark - 构造方法
#pragma mark -
#pragma mark Init方法
- (instancetype) initWithFrame:(CGRect)frame delegate:(id<MLInfiniteScrollViewDelegate>)delegate dataSource:(id<MLInfiniteScrollViewDataSource>)dataSource timerInterval:(NSTimeInterval)timeInterval{
    
    if (self = [super initWithFrame: frame]) {
        
        // 1. 配置 成员变量
        self.delegate = delegate;
        self.dataSource = dataSource;
        self.timeInterval = timeInterval;
        [self configureVariables];
        
        // 1. 配置 UI
        [self configureUI];
    }
    return self;
}
#pragma mark 工厂方法
+ (instancetype) infiniteScrollViewWithFrame:(CGRect)frame delegate:(id<MLInfiniteScrollViewDelegate>)delegate dataSource:(id<MLInfiniteScrollViewDataSource>)dataSource timeInterval:(NSTimeInterval)timeInterval {
    
    MLInfiniteScrollView *scrollView = [[MLInfiniteScrollView alloc] initWithFrame: frame delegate:delegate dataSource:dataSource timerInterval:timeInterval];
    return scrollView;
}

+ (instancetype) infiniteScrollViewWithFrame:(CGRect)frame delegate:(id<MLInfiniteScrollViewDelegate>)delegate dataSource:(id<MLInfiniteScrollViewDataSource>)dataSource {
    
    MLInfiniteScrollView *scrollView = [MLInfiniteScrollView infiniteScrollViewWithFrame: frame delegate:delegate dataSource:dataSource timeInterval: kDefaultTimeInterval];
    return scrollView;
}

+ (instancetype) infiniteScrollViewWithFrame:(CGRect)frame delegate:(id<MLInfiniteScrollViewDelegate>)delegate dataSource:(id<MLInfiniteScrollViewDataSource>)dataSource timeInterval:(NSTimeInterval)timeInterval inView:(UIView *)destinationView {
    
    MLInfiniteScrollView *scrollView = [MLInfiniteScrollView infiniteScrollViewWithFrame:frame delegate:delegate dataSource:dataSource timeInterval:timeInterval];
    [destinationView addSubview: scrollView];
    return scrollView;
}

#pragma mark - 析构方法
#pragma mark -
#pragma mark 释放
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self name: kStartTimerNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: kStartTimerNotification object: nil];
    [self stopAutoScroll];
    self.scrollView.delegate = nil;
    self.scrollView = nil;
    NSLog(@"%@ Dealloc", [self class]);
}

#pragma mark - 初始化方法
#pragma mark -
#pragma mark 配置成员变量
- (void) configureVariables {
    
    // 1. 初始化
    self.reusableCellDictionary = [[NSMutableDictionary alloc] init];
    
    // 2. 设置变量
    self.size = self.frame.size;
    self.height = self.frame.size.height;
    self.width = self.frame.size.width;
}
#pragma mark 配置 UI
- (void) configureUI {
    
    // 0. 注册通知
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(startAutoScroll) name:kStartTimerNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(stopAutoScroll) name:kStopTimerNotification object: nil];
    
    // 1. 创建 ScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame: self.bounds];
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview: self.scrollView];
    
    // 2. 创建 MaskView
    self.maskView = [[UIView alloc] initWithFrame: self.bounds];
    self.maskView.backgroundColor = [UIColor clearColor];
    self.maskView.userInteractionEnabled = NO;
    [self addSubview: self.maskView];
    
    // 3. 刷新数据
    [self reloadData];
}

#pragma mark - 公开方法
#pragma mark -
#pragma mark 获取可复用 Cell 的实例
- (MLInfiniteScrollViewCell *) dequeueReusableCellWithIdentifier:(NSString *)cellIdentifier {
    
    // 1. 如果 可复用 Cell 的字典为空, 则返回空
    if (self.reusableCellDictionary.allKeys.count == 0) return nil;
    
    // 2. 如果 可复用 Cell 的字典中, 没有 cellIdentifier 这个 key, 则返回空
    if (![self.reusableCellDictionary.allKeys containsObject: cellIdentifier]) return nil;
    
    // 3. 如果 没有可复用的 Cell 了, 则返回空
    if ([self.reusableCellDictionary[cellIdentifier] count] == 0) return nil;
    
    // 4. 取出所有 可复用的 Cell 的集合
    NSMutableSet *reusableCellSet = self.reusableCellDictionary[cellIdentifier];
    
    // 5. 任意取出一个 可复用的 Cell
    MLInfiniteScrollViewCell *cell = [reusableCellSet anyObject];
    
    // 6. 将取出的 Cell 从集合中删除
    [reusableCellSet removeObject: cell];
    
    // 7. 用修改后的集合 替换 源集合
    self.reusableCellDictionary[cellIdentifier] = reusableCellSet;

    return cell;
}
#pragma mark 开始自动滚动
- (void) startAutoScroll {
    // 1. 如果子视图数量大于1, 开始自动滚动
    if (self.dataCount > 1) {
        [self startTimer];
    }
}
#pragma mark 停止自动滚动
- (void) stopAutoScroll {
    [self endTimer];
}
#pragma mark 刷新数据
- (void) reloadData {
    
    // 判断是否正在滚动, 这样做可以避免滚动到一半就卡主的情况
    if (self.isScrolling) {
        [self performSelector: @selector(reloadData) withObject: nil afterDelay:0.2];
        return;
    }
    
    // 0. 停止定时器
    [self stopAutoScroll];
    
    // 1. 获取数据源个数
    self.dataCount = [self.dataSource numberOfItemsInInfiniteScrollView: self];
    
    if (self.dataCount == 0) return; // 如果数据源为空, 则直接返回
    
    // 2. 加载显示数据
    //  2.1 创建临时保存 可复用 Cell 的字典
    NSMutableDictionary *tempReusableCellDictionary = [[NSMutableDictionary alloc] init];
    for (NSInteger index=0; index<self.dataCount + 2; index++) {
        
        // 2.2 计算从数据源中取值时的正确索引
        NSInteger exactIndex = 0;
        if (index == 0) {
            exactIndex = self.dataCount-1;
        } else if (index == self.dataCount + 1) {
            exactIndex = 0;
        } else {
            exactIndex = index-1;
        }
        
        // 2.3 回调数据源方法, 询问需要展示的 Cell
        MLInfiniteScrollViewCell *cell = [self.dataSource infiniteScrollView: self viewAtIndex: exactIndex];
        cell.index = exactIndex;
        cell.frame = CGRectMake(index*self.width, 0, self.width, self.height);
        [self.scrollView addSubview: cell];
        
        // 2.4 监听 Cell 的点击事件, 然后回调代理
        MLInfiniteScrollView *__weak weakSelf = self;
        cell.clickAction = ^(NSInteger index) {
            if ([weakSelf.delegate respondsToSelector: @selector(infiniteScrollView:didSelectedItemAtIndex:)]) {
                [weakSelf.delegate infiniteScrollView: weakSelf didSelectedItemAtIndex:index];
            }
        };
        
        // 2.5 将可复用的 Cell 添加到 临时字典中
        [self addReusableCell: cell inReusableDictionay: tempReusableCellDictionary];
    }
    
    // 3. 删除原 可复用 Cell 字典中的 Cell
    [self.reusableCellDictionary enumerateKeysAndObjectsUsingBlock:^(id key, NSSet *obj, BOOL *stop) {
        for (MLInfiniteScrollViewCell *cell in obj) {
            [cell removeFromSuperview];
        }
    }];
    [self.reusableCellDictionary removeAllObjects];
    self.reusableCellDictionary = [[NSMutableDictionary alloc] initWithDictionary: tempReusableCellDictionary];
    
    // 4. 设置大 ScrollView 的 ContentSize
    self.scrollView.contentSize = CGSizeMake((self.dataCount+2) * self.width, 0);
    
    // 5. 设置大 ScrollView 的 ContentOffset
    self.scrollView.contentOffset = CGPointMake(self.width, 0);
    
    // 6. 开启定时器
    [self startAutoScroll];
}

#pragma mark - UIScrollView Delegate
#pragma mark -
#pragma mark 滚动动画结束
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 1. 滚动结束
    [self didStopScrollAnimation];
}
#pragma mark 停止减速
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 1. 滚动结束
    [self didStopScrollAnimation];
    
    // 2. 重新开启定时器
    [self startAutoScroll];
    
    // 3. 关闭遮罩视图的用户交互
    self.maskView.userInteractionEnabled = NO;
}

#pragma mark 开始拖拽
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    // 1. 通知代理, 将要开始滚动
    if ([self.delegate respondsToSelector: @selector(infiniteScrollView:willBeginScroll:)]) {
        self.animating = YES;
        [self.delegate infiniteScrollView: self willBeginScroll: (scrollView.contentOffset.x / self.width)-1];
    }
    
    // 2. 停止定时器
    [self stopAutoScroll];
    
    // 3. 开始遮罩视图的用户交互
    self.maskView.userInteractionEnabled = YES;
}

#pragma mark 开始滚动
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y != 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

#pragma mark - 私有方法
#pragma mark -
#pragma mark 将可复用的 Cell 放入字典中
- (void) addReusableCell:(MLInfiniteScrollViewCell *)cell inReusableDictionay:(NSMutableDictionary *)reusableDictionary {
    
    // 1. 取出 Cell 的 Identifier
    NSString *cellIdentifier = cell.reusableIdentifier;
    
    // 2. 判断字典中是否有这个 Key
    NSMutableSet *reusableCellSet = [[NSMutableSet alloc] init];
    
    if ([reusableDictionary.allKeys containsObject: cellIdentifier]) { // 存在这个 Key
        
        // 2.1 取出 Key 所对应的集合
        reusableCellSet = reusableDictionary[cellIdentifier];
        
    } else { // 这个 Key 不存在
        
        // 2.1 创建 可复用 Cell 的集合
        reusableCellSet = [[NSMutableSet alloc] init];
    }
    
    // 3. 将可复用的 Cell 添加到集合中
    [reusableCellSet addObject: cell];
    
    // 4. 替换原来在字典中的集合
    reusableDictionary[cellIdentifier] = reusableCellSet;
}
#pragma mark 开启定时器
- (void) startTimer {
    
    if (self.timer.isValid) {
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target: self selector: @selector(autoScroll) userInfo: nil repeats: YES];
}

#pragma mark 关闭定时器
- (void) endTimer {
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark 自动滚动
- (void) autoScroll {
    
    if (self.dataCount == 1) {
        return;
    }
    
    // 1. 通知代理, 将要开始滚动
    if ([self.delegate respondsToSelector: @selector(infiniteScrollView:willBeginScroll:)]) {
        self.animating = YES;
        [self.delegate infiniteScrollView: self willBeginScroll: (self.scrollView.contentOffset.x / self.width)-1];
    }
    
    // 2. 获取当前页数
    NSInteger currentPage = self.scrollView.contentOffset.x / self.width;
    
    // 3. 设置 ContentOffset
    [self.scrollView setContentOffset:CGPointMake(self.width * (currentPage+1), 0) animated: YES];
}

#pragma mark 滚动结束
- (void) didStopScrollAnimation {
    
    // 1. 获取当前页数
    NSInteger currentPage = self.scrollView.contentOffset.x / self.width;
    
    // 2. 设置 ContentOffset
    if (currentPage == 0) { // 移动到了第一张, 那么就应该变到倒数第二张
        self.scrollView.contentOffset = CGPointMake(self.dataCount*self.width, 0);
        currentPage = self.dataCount-1;
    } else if (currentPage ==  (self.dataCount+1)) {
        self.scrollView.contentOffset = CGPointMake(self.width, 0);
        currentPage = 0;
    } else {
        currentPage -= 1;
    }
    
    // 3. 通知代理 滚动到了哪一页
    if ([self.delegate respondsToSelector: @selector(infiniteScrollView:stopScrollAnimationAtIndex:)]) {
        self.animating = NO;
        [self.delegate infiniteScrollView: self stopScrollAnimationAtIndex: currentPage];
    }
}

#pragma mark - Get 方法重写
#pragma mark -
#pragma mark Get isScrolling
- (BOOL) isScrolling {
    return self.animating;
}

@end
