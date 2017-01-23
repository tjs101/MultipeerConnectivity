//
//  UIAlertView+HWW.h
//  HAlertController
//
//  Created by dj-xxzx-10065 on 16/3/8.
//  Copyright © 2016年 Dong jing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HAlertAction;

NS_ASSUME_NONNULL_BEGIN
@interface UIAlertView (HWW)

+ (instancetype)alertWithTitle:(nullable NSString *)title
                       message:(nullable NSString *)message
                    cancelItem:(nullable HAlertAction *)cancel
               destructiveItem:(nullable HAlertAction *)destructive;

- (void)addButtonItem:(HAlertAction *)item;

@end
NS_ASSUME_NONNULL_END