//
//  UIAlertController+HWW.h
//  HAlertController
//
//  Created by dj-xxzx-10065 on 16/3/7.
//  Copyright © 2016年 Dong jing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HAlertAction;

NS_ASSUME_NONNULL_BEGIN
@interface UIAlertController (HWW) <UIPopoverPresentationControllerDelegate>

+ (instancetype)alertWithTitle:(nullable NSString *)title
                       message:(nullable NSString *)message
                    cancelItem:(nullable HAlertAction *)cancel
               destructiveItem:(nullable HAlertAction *)destructive;

+ (instancetype)actionSheetWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                          cancelItem:(nullable HAlertAction *)cancel
                     destructiveItem:(nullable HAlertAction *)destructive;

- (void)addButtonItem:(HAlertAction *)item;

- (void)showIn:(UIViewController *)viewController;

@end
NS_ASSUME_NONNULL_END

/*
 待完善:
 actionsheet在iPad上的sourceRect。可以采用类初始化方法添加(void(^)(UIPopoverPresentationController *popover))参数
 */