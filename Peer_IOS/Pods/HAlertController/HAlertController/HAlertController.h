//
//  HAlertController.h
//  HAlertController
//
//  Created by dj-xxzx-10065 on 16/3/7.
//  Copyright © 2016年 Dong jing Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HAlertAction.h"

NS_ASSUME_NONNULL_BEGIN
@interface HAlertController : NSObject

+ (instancetype)alertWithTitle:(nullable NSString *)title
                       message:(nullable NSString *)message
              cancelButtonItem:(nullable HAlertAction *)cancelItem
         destructiveButtonItem:(nullable HAlertAction *)destructiveItem;

+ (instancetype)actionSheetWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                    cancelButtonItem:(nullable HAlertAction *)cancelItem
               destructiveButtonItem:(nullable HAlertAction *)destructiveItem;

- (void)addButtonItem:(HAlertAction *)item;

- (void)showIn:(UIViewController *)viewController;

@end
NS_ASSUME_NONNULL_END
