//
//  HAlertAction.m
//  HAlertController
//
//  Created by dj-xxzx-10065 on 16/3/8.
//  Copyright © 2016年 Dong jing Ltd. All rights reserved.
//

#import "HAlertAction.h"

@implementation HAlertAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(HHander)handler
{
    return [[self alloc] initWithTitle:title handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title handler:(HHander)handler
{
    self = [super init];
    if (self) {
        _title = title;
        _handler = [handler copy];
    }
    return self;
}

@end
