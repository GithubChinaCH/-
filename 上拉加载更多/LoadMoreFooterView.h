//
//  LoadMoreFooterView.h
//  上拉加载更多
//
//  Created by jhtxch on 15/11/11.
//  Copyright © 2015年 jhtxch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadMoreFooterView : UIView

- (instancetype)initWithObject:(id)obj AndSEL:(SEL)sel scrollV:(UIScrollView *)scrollView;

- (void)endRefresh:(void(^)(void))finishBlock;
@end
