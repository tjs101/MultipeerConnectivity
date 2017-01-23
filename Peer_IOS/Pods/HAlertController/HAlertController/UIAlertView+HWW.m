//
//  UIAlertView+HWW.m
//  HAlertController
//
//  Created by dj-xxzx-10065 on 16/3/8.
//  Copyright © 2016年 Dong jing Ltd. All rights reserved.
//

#import "UIAlertView+HWW.h"
#import "HAlertAction.h"
#import <objc/runtime.h>

static NSString *BUTTON_ASS_KEY = @"com.huweiwei.alertView";

@implementation UIAlertView (HWW)

+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
                    cancelItem:(HAlertAction *)cancel
               destructiveItem:(HAlertAction *)destructive
{
    return [[self alloc] initWithTitle:title message:message cancelItem:cancel destructiveItem:destructive];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                   cancelItem:(HAlertAction *)cancel
              destructiveItem:(HAlertAction *)destructive
{
    self = [self initWithTitle:title
                       message:message
                      delegate:self
             cancelButtonTitle:cancel.title
             otherButtonTitles:nil, nil];
    if (self) {
        NSMutableArray *items = [self buttonItems];
        //取消项
        if (cancel) [items addObject:cancel];
        //删除项
        if (destructive) {
            [self addButtonWithTitle:destructive.title];
            [items addObject:destructive];
        }
    }
    return self;
}

- (void)addButtonItem:(HAlertAction *)item
{
    [self addButtonWithTitle:item.title];
    [[self buttonItems] addObject:item];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    HAlertAction *action = [self buttonItems][buttonIndex];
    !action.handler? :action.handler(action.title);
    
    objc_setAssociatedObject(self, (__bridge const void *)BUTTON_ASS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - runtime
- (NSMutableArray *)buttonItems
{
    NSMutableArray *items = objc_getAssociatedObject(self, (__bridge const void *)BUTTON_ASS_KEY);
    if (!items)
    {
        items = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void *)BUTTON_ASS_KEY, items, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return items;
}

@end
