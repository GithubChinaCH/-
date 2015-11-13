//
//  LoadMoreFooterView.m
//  上拉加载更多
//
//  Created by jhtxch on 15/11/11.
//  Copyright © 2015年 jhtxch. All rights reserved.
//

#import "LoadMoreFooterView.h"
#import "Masonry.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kSelfHeight self.frame.size.height

typedef void(^finishBlock)(void);

@interface LoadMoreFooterView ()
{
    UIImageView *_leftSharkV;
    UIImageView *_leftFishV;
    UIImageView *_rightSharkV;
    UIImageView *_rightFishV;
    UIImageView *_lineV;
    UIImageView *_bottomV;
    
    SEL _sel;
    id _object;
    UIScrollView *_scrollView;
    
    UILabel *_remindLabel;
    BOOL _isRefresh;
}

@property (nonatomic, copy) finishBlock endRefreshB;
@end
@implementation LoadMoreFooterView

- (instancetype)initWithObject:(id)obj AndSEL:(SEL)sel scrollV:(UIScrollView *)scrollView
{
    self = [super init];
    if (self) {
        _sel = sel;
        _object = obj;
        _isRefresh = NO;
        _scrollView = scrollView;
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        //self.hidden = YES;
        //self.frame
        //self.backgroundColor = [UIColor orangeColor];
        self.frame = CGRectMake(0, 0, kScreenWidth, 40);
        if (_scrollView.contentSize.height != 0) {
            CGRect frame = self.frame;
            frame.origin.y = _scrollView.contentSize.height;
            self.frame = frame;
        }
        [_scrollView addSubview:self];
        NSLog(@"%lf",_scrollView.contentSize.height);
        [self initSubView];
       // [self sharkAnimation];
        //CGRect frame = self.frame;
    }
    return self;
}
- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}
- (void)initSubView
{
    _remindLabel = [UILabel new];
    [self addSubview:_remindLabel];
    _remindLabel.text = @"上拉加载更多";
    _remindLabel.font = [UIFont systemFontOfSize:17];
    typeof(self) __weak weakSelf = self;
    [_remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf);
    }];
    
    _bottomV = [[UIImageView alloc] initWithFrame:CGRectMake(0, kSelfHeight - 3, kScreenWidth, 3)];
    _bottomV.image = [UIImage imageNamed:@"loading_line"];
    [self addSubview:_bottomV];
    
    //左边
    _leftSharkV = [[UIImageView alloc] initWithFrame:CGRectMake(10, kSelfHeight - 20, 30, 20)];
    _leftSharkV.image = [UIImage imageNamed:@"loading_shark"];
    [self addSubview:_leftSharkV];
    
    _leftFishV = [[UIImageView alloc] initWithFrame:CGRectMake(80, 18, 20, 12)];
    _leftFishV.image = [UIImage imageNamed:@"loading_fish"];
    [self addSubview:_leftFishV];
    _leftFishV.hidden = YES;
    
    //右边
    _rightFishV = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 80 - 20, 18, 20, 12)];
    _rightFishV.image = [UIImage imageNamed:@"loading_fish2"];
    [self addSubview:_rightFishV];
    _rightFishV.hidden = YES;
    
    _rightSharkV = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 30, kSelfHeight - 20, 30, 20)];
    _rightSharkV.image = [UIImage imageNamed:@"loading_shark2"];
    [self addSubview:_rightSharkV];
    _rightSharkV.hidden = YES;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (_scrollView.contentSize.height < kScreenHeight) {
        [self removeFromSuperview];
        return;
    }
    //NSLog(@"%lf",_tableV.contentSize.height);
    if (!_isRefresh) {
        self.frame = CGRectMake(0, _scrollView.contentSize.height, kScreenWidth, 40);
    }
    if (![keyPath isEqualToString:@"contentOffset"]) {
        return;
    }
    NSValue *value = change[@"new"];
    CGPoint point = [value CGPointValue];
    //NSLog(@"%lf",point.y);
    if (point.y >= _scrollView.contentSize.height - _scrollView.frame.size.height + 40) {
        _remindLabel.text = @"放开刷新";
        if (!_isRefresh) {
            self.frame = CGRectMake(0, point.y - 40 + _scrollView.frame.size.height, kScreenWidth, 40);
        }
        [_remindLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo([NSNumber numberWithDouble:_scrollView.contentSize.height - _scrollView.frame.size.height + 40 - point.y]);
        }];
        _remindLabel.font = [UIFont systemFontOfSize:(17 + (point.y - _scrollView.contentSize.height + _scrollView.frame.size.height - 40) * .4)];
        //如果向上拉 的尺寸大于40放开则刷新
        if (_scrollView.panGestureRecognizer.numberOfTouches == 0 && !_isRefresh) {
            if ([_object respondsToSelector:_sel]) {
                [_object performSelector:_sel withObject:nil];
            }
            [UIView animateWithDuration:.2 animations:^{
                _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + 40);
            }];
            _isRefresh = YES;
            //开始动画
            [self startAnimation];
        }
        if (_isRefresh) {
            [UIView animateWithDuration:.2 animations:^{
                self.frame = CGRectMake(0, _scrollView.contentSize.height - 40, kScreenWidth, 40);
            }];
            _scrollView.bounces = NO;
            _remindLabel.hidden = YES;
        }
        
    }
    else
    {
        _remindLabel.text = @"上拉加载更多";
        [_remindLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
        }];
    }
    
    
//    NSLog(@"%li",_scrollView.panGestureRecognizer.numberOfTouches);
    
}

#pragma mark - animation

- (void)rSharkAnimation
{
    [self rFishAnimation];
    _rightFishV.hidden = NO;
    _rightSharkV.hidden = NO;
    _leftSharkV.hidden = YES;
    _leftFishV.hidden = YES;
    CABasicAnimation *rightSharkA = [CABasicAnimation animationWithKeyPath:@"position.x"];
    rightSharkA.fromValue = @(kScreenWidth - 10 - 30);
    rightSharkA.toValue = @(30);
    rightSharkA.duration = 0.9f;
    //    leftSharkA.autoreverses = YES;
    [_rightSharkV.layer addAnimation:rightSharkA forKey:nil];
    [self performSelector:@selector(sharkAnimation) withObject:nil afterDelay:.9];
    
}
- (void)rFishAnimation
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, kScreenWidth - 80 - 20, 18);
    CGPathAddQuadCurveToPoint(path, NULL, kScreenWidth - 100, 0, 80 , 50);
    CAKeyframeAnimation *rightFishA = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    rightFishA.path = path;
    rightFishA.duration = .5;
    rightFishA.beginTime = CACurrentMediaTime();
    rightFishA.removedOnCompletion = NO;
    rightFishA.fillMode = kCAFillModeForwards;
    [_rightFishV.layer addAnimation:rightFishA forKey:nil];
    CGPathRelease(path);
}

//鲨鱼动画
- (void)sharkAnimation
{
    [self fishAnimation];
    _leftSharkV.hidden = NO;
    _leftFishV.hidden = NO;
    _rightSharkV.hidden = YES;
    _rightFishV.hidden = YES;
    CABasicAnimation *leftSharkA = [CABasicAnimation animationWithKeyPath:@"position.x"];
    leftSharkA.fromValue = @30;
    leftSharkA.toValue = @(kScreenWidth - 10 - 30);
    leftSharkA.duration = 0.9f;
    //leftSharkA.removedOnCompletion = NO;
    //leftSharkA.fillMode = kCAFillModeBoth;
    //    leftSharkA.autoreverses = YES;
    [_leftSharkV.layer addAnimation:leftSharkA forKey:nil];
    [self performSelector:@selector(rSharkAnimation) withObject:nil afterDelay:.9];
    
    typeof(self) __weak weakSelf = self;
    //刷新结束block
    self.endRefreshB = ^{
        typeof(weakSelf) __strong strongSelf = weakSelf;
        [UIView animateWithDuration:.2 animations:^{
            strongSelf -> _scrollView.contentSize = CGSizeMake(strongSelf -> _scrollView.contentSize.width, _scrollView.contentSize.height - 40);
        } completion:^(BOOL finished) {
            strongSelf -> _scrollView.bounces = YES;
            strongSelf -> _remindLabel.hidden = NO;
            strongSelf -> _remindLabel.font = [UIFont systemFontOfSize:17];
            strongSelf -> _isRefresh = NO;
            
            strongSelf -> _leftFishV.hidden = YES;
            strongSelf -> _leftSharkV.hidden = NO;
            strongSelf -> _rightFishV.hidden = YES;;
            strongSelf -> _rightSharkV.hidden = YES;
            
            strongSelf -> _leftFishV.layer.speed = 0;
            strongSelf -> _leftSharkV.layer.speed = 0;
            strongSelf -> _rightFishV.layer.speed = 0;
            strongSelf -> _rightSharkV.layer.speed = 0;
            
            [LoadMoreFooterView cancelPreviousPerformRequestsWithTarget:strongSelf];
        }];
        
    };
}
//小鱼动画
- (void)fishAnimation
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 80, 18);
    CGPathAddQuadCurveToPoint(path, NULL, 80, 0, kScreenWidth - 100, 50);
    CAKeyframeAnimation *leftFishA = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    leftFishA.path = path;
    leftFishA.removedOnCompletion = NO;
    leftFishA.fillMode = kCAFillModeForwards;
    leftFishA.duration = .5;
    leftFishA.beginTime = CACurrentMediaTime();
    [_leftFishV.layer addAnimation:leftFishA forKey:nil];
    CGPathRelease(path);
}


- (void)endRefresh:(void (^)(void))finishBlock
{
    [self performSelector:@selector(endRefreshAfterDelay:) withObject:finishBlock afterDelay:.9];
}

- (void)endRefreshAfterDelay:(void(^)(void))block
{
    if (self.endRefreshB) {
        self.endRefreshB();
    }
    if (block) {
        block();
        self.frame = CGRectMake(0, _scrollView.contentSize.height, kScreenHeight, 40);
        _scrollView.contentOffset = CGPointMake(0, _scrollView.contentSize.height - kScreenHeight);
    }
    block = nil;
    self.endRefreshB = nil;
}

- (void)startAnimation
{
    _leftFishV.layer.speed = 1;
    _leftSharkV.layer.speed = 1;
    _rightFishV.layer.speed = 1;
    _rightSharkV.layer.speed = 1;
    [self sharkAnimation];
    _scrollView.contentOffset = CGPointMake(0, _scrollView.contentSize.height);

}

@end
