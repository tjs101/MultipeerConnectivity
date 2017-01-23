//
//  HAlertController.m
//  HAlertController
//
//  Created by dj-xxzx-10065 on 16/3/7.
//  Copyright © 2016年 Dong jing Ltd. All rights reserved.
//

#import "HAlertController.h"

#import "UIAlertController+HWW.h"
#import "UIAlertView+HWW.h"
#import "UIActionSheet+HWW.h"

@interface HAlertController ()

@property (nonatomic, assign) BOOL useAlertController;

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UIActionSheet *actionSheet;

@end

@implementation HAlertController

+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
              cancelButtonItem:(HAlertAction *)cancelItem
         destructiveButtonItem:(HAlertAction *)destructiveItem
{
    HAlertController *controller = [HAlertController new];
    
    if (controller.useAlertController) {
        controller.alertController = [UIAlertController alertWithTitle:title
                                                               message:message
                                                            cancelItem:cancelItem
                                                       destructiveItem:destructiveItem];
    }else {
        controller.alertView = [UIAlertView alertWithTitle:title
                                                   message:message
                                                cancelItem:cancelItem
                                           destructiveItem:destructiveItem];
    }
    
    return controller;
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                             message:(NSString *)message
                    cancelButtonItem:(HAlertAction *)cancelItem
               destructiveButtonItem:(HAlertAction *)destructiveItem
{
    HAlertController *controller = [HAlertController new];
    
    if (controller.useAlertController) {
        controller.alertController = [UIAlertController actionSheetWithTitle:title
                                                                     message:message
                                                                  cancelItem:cancelItem
                                                             destructiveItem:destructiveItem];
    }else {
        controller.actionSheet = [UIActionSheet actionSheetWithTitle:title
                                                             message:message
                                                          cancelItem:cancelItem
                                                     destructiveItem:destructiveItem];
    }

    return controller;
}

#pragma mark - 添加
- (void)addButtonItem:(HAlertAction *)item
{
    if (self.useAlertController)
        [self.alertController addButtonItem:item];
    
    else if (self.alertView)
        [self.alertView addButtonItem:item];
    
    else if (self.actionSheet)
        [self.actionSheet addButtonItem:item];
}

#pragma mark - Show
- (void)showIn:(UIViewController *)viewController
{
    if (self.useAlertController) 
        [self.alertController showIn:viewController];
    
    else if (self.alertView)
        [self.alertView show];
    
    else if (self.actionSheet)
        [self.actionSheet showInView:viewController.view];
}

#pragma mark - 其他
- (BOOL)useAlertController
{
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
}

@end
