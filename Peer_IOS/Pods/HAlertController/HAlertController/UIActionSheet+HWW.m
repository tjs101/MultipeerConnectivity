//
//  UIActionSheet+HWW.m
//  HAlertController
//
//  Created by dj-xxzx-10065 on 16/3/9.
//  Copyright © 2016年 Dong jing Ltd. All rights reserved.
//

#import "UIActionSheet+HWW.h"
#import "HAlertAction.h"
#import <objc/runtime.h>

static NSString *BUTTON_ASS_KEY = @"com.huweiwei.actionSheet";

@implementation UIActionSheet (HWW)

+ (instancetype)actionSheetWithTitle:(NSString *)title
                             message:(NSString *)message
                          cancelItem:(HAlertAction *)cancel
                     destructiveItem:(HAlertAction *)destructive
{
    
    return [[self alloc] initWithTitle:title
                               message:message
                     cancelButtonTitle:cancel
                destructiveButtonTitle:destructive];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(HAlertAction *)cancel
       destructiveButtonTitle:(HAlertAction *)destructive
{
    title = [NSString stringWithFormat:@"%@\n%@", title, message];
    self = [self initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    if (self) {
        NSMutableArray *items = [self buttonItems];
        //取消项
        if (cancel) {
            [items addObject:cancel];
            NSInteger cancelIndex = [self addButtonWithTitle:cancel.title];
            [self setCancelButtonIndex:cancelIndex];
        }
        //删除项
        if (destructive) {
            [items addObject:destructive];
            NSInteger destIndex = [self addButtonWithTitle:destructive.title];
            [self setDestructiveButtonIndex:destIndex];
        }
    }

    return self;
}

- (void)addButtonItem:(HAlertAction *)item
{
    [self addButtonWithTitle:item.title];
    [[self buttonItems] addObject:item];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    HAlertAction *item = [self buttonItems][buttonIndex];
    !item.handler? :item.handler(item.title);
    
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
