//
//  UIAlertController+HWW.m
//  HAlertController
//
//  Created by dj-xxzx-10065 on 16/3/7.
//  Copyright © 2016年 Dong jing Ltd. All rights reserved.
//

#import "UIAlertController+HWW.h"
#import "HAlertAction.h"

@implementation UIAlertController (HWW)

+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
                    cancelItem:(HAlertAction *)cancel
               destructiveItem:(HAlertAction *)destructive
{
    return [[self alloc] initWithStyle:UIAlertControllerStyleAlert
                                 title:title
                               message:message
                            cancelItem:cancel
                       destructiveItem:destructive];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                             message:(NSString *)message
                          cancelItem:(HAlertAction *)cancel
                     destructiveItem:(HAlertAction *)destructive
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return [[self alloc] initWithStyle:UIAlertControllerStyleAlert
                                     title:title
                                   message:message
                                cancelItem:cancel
                           destructiveItem:destructive];
    else
        return [[self alloc] initWithStyle:UIAlertControllerStyleActionSheet
                                     title:title
                                   message:message
                                cancelItem:cancel
                           destructiveItem:destructive];
}

- (instancetype)initWithStyle:(UIAlertControllerStyle)style
                        title:(NSString *)title
                      message:(NSString *)message
                   cancelItem:(HAlertAction *)cancel
              destructiveItem:(HAlertAction *)destructive
{
    self = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    //取消项
    if (cancel)
        [self addAction:[UIAlertAction actionWithTitle:cancel.title
                                                 style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction * _Nonnull action)
        {
            !cancel.handler? :cancel.handler(cancel.title);
        }]];
    
    //删除项
    if (destructive)
        [self addAction:[UIAlertAction actionWithTitle:destructive.title
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction * _Nonnull action)
        {
            !destructive.handler? :destructive.handler(destructive.title);
        }]];
    
    
    return self;
}

- (void)addButtonItem:(HAlertAction *)item
{
    [self addAction:[UIAlertAction actionWithTitle:item.title
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action)
                     {
                         !item.handler? :item.handler(item.title);
                     }]];
}

- (void)showIn:(UIViewController *)viewController
{
//    UIPopoverPresentationController *ppc = self.popoverPresentationController;
//    ppc.delegate = self;
//    ppc.sourceView = viewController.view;
//    ppc.sourceRect = CGRectMake((CGRectGetWidth(ppc.sourceView.bounds)-2)*0.5f, (CGRectGetHeight(ppc.sourceView.bounds)-2)*0.5f, 2, 2);// 显示在中心位置
    
    [viewController presentViewController:self animated:YES completion:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view
{
    *rect = CGRectMake((CGRectGetWidth((*view).bounds)-2)*0.5f,
                       (CGRectGetHeight((*view).bounds)-2)*0.5f,
                       2, 2);// 显示在中心位置
}

@end
