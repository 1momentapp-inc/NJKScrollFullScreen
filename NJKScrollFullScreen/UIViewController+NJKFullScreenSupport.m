//
//  UIViewController+NJKFullScreenSupport.m
//
//  Copyright (c) 2014 Satoshi Asano. All rights reserved.
//

#import "UIViewController+NJKFullScreenSupport.h"

#define kNearZero 0.000001f

@implementation UIViewController (NJKFullScreenSupport)

- (void)showNavigationBar:(NJKScrollFullScreen *)fullScreenProxy animated:(BOOL)animated
{
    CGFloat statusBarHeight = [self statusBarHeight];

    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];

    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;

    [self setNavigationBarOriginY:overwrapStatusBarHeight proxy:fullScreenProxy animated:animated];
}

- (void)hideNavigationBar:(NJKScrollFullScreen *)fullScreenProxy animated:(BOOL)animated
{
    CGFloat statusBarHeight = [self statusBarHeight];

    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];

    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;

    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;

    CGRect accessoryFrame = fullScreenProxy.accessoryView.frame;
    CGFloat accessoryViewHeight = accessoryFrame.size.height;

    CGFloat top = -navigationBarHeight -accessoryViewHeight -overwrapStatusBarHeight;

    [self setNavigationBarOriginY:top proxy:fullScreenProxy animated:animated];
}

- (void)moveNavigationBar:(CGFloat)deltaY proxy:(NJKScrollFullScreen *)fullScreenProxy animated:(BOOL)animated
{
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat nextY = frame.origin.y + deltaY;
    [self setNavigationBarOriginY:nextY proxy:fullScreenProxy animated:animated];
}

- (void)setNavigationBarOriginY:(CGFloat)y proxy:(NJKScrollFullScreen *)fullScreenProxy animated:(BOOL)animated
{
    CGFloat statusBarHeight = [self statusBarHeight];

    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];

    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;
    CGFloat bottomLimit             = overwrapStatusBarHeight;

    CGRect navBarFrame    = self.navigationController.navigationBar.frame;
    CGRect accessoryFrame = fullScreenProxy.accessoryView.frame;

    CGFloat topLimit = -[self navBarAccessoryHeight:fullScreenProxy];

    navBarFrame.origin.y    = fmin (fmax (y, topLimit), bottomLimit);
    accessoryFrame.origin.y = CGRectGetMaxY (navBarFrame);

    CGFloat invisiblePixels = overwrapStatusBarHeight - navBarFrame.origin.y;
    CGFloat totalPixels     = overwrapStatusBarHeight - topLimit;
    CGFloat alpha           = MAX (1 - invisiblePixels / totalPixels, kNearZero);

    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        self.navigationController.navigationBar.frame = navBarFrame;
        fullScreenProxy.accessoryView.frame = accessoryFrame;
        NSUInteger index = 0;
        for (UIView *view in self.navigationController.navigationBar.subviews) {
            index++;
            if (index == 1 || view.hidden || view.alpha <= 0.0f)
                continue;
            view.alpha = alpha;
        }
        self.navigationController.navigationBar.alpha = alpha;
        for (UIView *view in fullScreenProxy.accessoryView.subviews) {
            if (view.hidden || view.alpha <= 0.0f)
                continue;
            view.alpha = alpha;
        }
        fullScreenProxy.accessoryView.alpha = alpha;
        // fade bar buttons
        UIColor *tintColor = self.navigationController.navigationBar.tintColor;
        if (tintColor) {
            self.navigationController.navigationBar.tintColor = [tintColor colorWithAlphaComponent:alpha];
            fullScreenProxy.accessoryView.tintColor           = [tintColor colorWithAlphaComponent:alpha];
        }
    }];
}

- (CGFloat)statusBarHeight
{
    CGSize statuBarFrameSize = [UIApplication sharedApplication].statusBarFrame.size;
    return statuBarFrameSize.height;
}

- (CGFloat)navBarAccessoryHeight:(NJKScrollFullScreen *)fullScreenProxy
{
    CGRect frame                = self.navigationController.navigationBar.frame;
    CGFloat navigationBarHeight = frame.size.height;

    CGRect accessoryFrame       = fullScreenProxy.accessoryView.frame;
    CGFloat accessoryViewHeight = accessoryFrame.size.height;

    return navigationBarHeight + accessoryViewHeight;
}

#pragma mark -
#pragma mark manage ToolBar

- (void)showToolbar:(BOOL)animated
{
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControllerViewHeightFromViewSize:viewSize];
    CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
    [self setToolbarOriginY:viewHeight - toolbarHeight animated:animated];
}

- (void)hideToolbar:(BOOL)animated
{
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControllerViewHeightFromViewSize:viewSize];
    [self setToolbarOriginY:viewHeight animated:animated];
}

- (void)moveToolbar:(CGFloat)deltaY animated:(BOOL)animated
{
    CGRect frame = self.navigationController.toolbar.frame;
    CGFloat nextY = frame.origin.y + deltaY;
    [self setToolbarOriginY:nextY animated:animated];
}

- (void)setToolbarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGRect toolBarFrame   = self.navigationController.toolbar.frame;
    CGFloat toolBarHeight = toolBarFrame.size.height;
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControllerViewHeightFromViewSize:viewSize];

    CGFloat topLimit = viewHeight - toolBarHeight;
    CGFloat bottomLimit = viewHeight;

    toolBarFrame.origin.y = fmin (fmax (y, topLimit), bottomLimit);  // limit over moving

    CGFloat invisiblePixels = toolBarHeight - (viewHeight - toolBarFrame.origin.y);
    CGFloat alpha           = MAX (1 - invisiblePixels / toolBarHeight, kNearZero);

    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.navigationController.toolbar.frame = toolBarFrame;
        for (UIView *view in self.navigationController.toolbar.subviews) {
            if (view.hidden || view.alpha <= 0.0f)
                continue;
            view.alpha = alpha;
        }
        self.navigationController.toolbar.alpha = alpha;
        // fade bar buttons
        UIColor *tintColor = self.navigationController.toolbar.tintColor;
        if (tintColor) {
            self.navigationController.toolbar.tintColor = [tintColor colorWithAlphaComponent:alpha];
        }
    }];
}

#pragma mark -
#pragma mark manage TabBar

- (void)showTabBar:(BOOL)animated
{
    CGSize viewSize = self.tabBarController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControllerViewHeightFromViewSize:viewSize];
    CGFloat toolbarHeight = self.tabBarController.tabBar.frame.size.height;
    [self setTabBarOriginY:viewHeight - toolbarHeight animated:animated];
}

- (void)hideTabBar:(BOOL)animated
{
    CGSize viewSize = self.tabBarController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControllerViewHeightFromViewSize:viewSize];
    [self setTabBarOriginY:viewHeight animated:animated];
}

- (void)moveTabBar:(CGFloat)deltaY animated:(BOOL)animated
{
    CGRect frame =  self.tabBarController.tabBar.frame;
    CGFloat nextY = frame.origin.y + deltaY;
    [self setTabBarOriginY:nextY animated:animated];
}

- (void)setTabBarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGRect tabBarFrame   = self.tabBarController.tabBar.frame;
    CGFloat tabBarHeight = tabBarFrame.size.height;
    CGSize viewSize = self.tabBarController.view.frame.size;

    CGFloat viewHeight = [self bottomBarViewControllerViewHeightFromViewSize:viewSize];

    CGFloat topLimit    = viewHeight - tabBarHeight;
    CGFloat bottomLimit = viewHeight;

    tabBarFrame.origin.y = fmin (fmax (y, topLimit), bottomLimit);  // limit over moving

    CGFloat invisiblePixels = tabBarHeight - (viewHeight - tabBarFrame.origin.y);
    CGFloat alpha           = MAX (1 - invisiblePixels / tabBarHeight, kNearZero);

    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        self.tabBarController.tabBar.frame = tabBarFrame;
        for (UIView *view in self.tabBarController.tabBar.subviews) {
            if (view.hidden || view.alpha <= 0.0f)
                continue;
            view.alpha = alpha;
        }
        self.tabBarController.tabBar.alpha = alpha;
        // fade bar buttons
        UIColor *tintColor = self.tabBarController.tabBar.tintColor;
        if (tintColor) {
            self.tabBarController.tabBar.tintColor = [tintColor colorWithAlphaComponent:alpha];
        }
    }];
}

- (CGFloat)bottomBarViewControllerViewHeightFromViewSize:(CGSize)viewSize
{
    CGFloat viewHeight = 0.f;
    viewHeight = viewSize.height;

    return viewHeight;
}

@end
