//
//  UIViewController+NJKFullScreenSupport.h
//
//  Copyright (c) 2014 Satoshi Asano. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NJKScrollFullScreen.h"

@interface UIViewController (NJKFullScreenSupport)

- (void)showNavigationBar:(NJKScrollFullScreen *)fullScreenProxy animated:(BOOL)animated;
- (void)hideNavigationBar:(NJKScrollFullScreen *)fullScreenProxy animated:(BOOL)animated;
- (void)moveNavigationBar:(CGFloat)deltaY proxy:(NJKScrollFullScreen *)fullScreenProxy animated:(BOOL)animated;
- (void)setNavigationBarOriginY:(CGFloat)y proxy:(NJKScrollFullScreen *)fullScreenProxy animated:(BOOL)animated;

- (void)showToolbar:(BOOL)animated;
- (void)hideToolbar:(BOOL)animated;
- (void)moveToolbar:(CGFloat)deltaY animated:(BOOL)animated;
- (void)setToolbarOriginY:(CGFloat)y animated:(BOOL)animated;

- (void)showTabBar:(BOOL)animated;
- (void)hideTabBar:(BOOL)animated;
- (void)moveTabBar:(CGFloat)deltaY animated:(BOOL)animated;
- (void)setTabBarOriginY:(CGFloat)y animated:(BOOL)animated;

@end
