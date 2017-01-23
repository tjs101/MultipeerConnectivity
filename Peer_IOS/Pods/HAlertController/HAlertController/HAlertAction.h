//
//  HAlertAction.h
//  HAlertController
//
//  Created by dj-xxzx-10065 on 16/3/8.
//  Copyright © 2016年 Dong jing Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HAlertAction;

typedef void(^HHander)(NSString * _Nonnull title);

@interface HAlertAction : NSObject

@property (nonnull, nonatomic, readonly) NSString *title;
@property (nullable, nonatomic, readonly) HHander handler;

+ (nonnull instancetype)actionWithTitle:(nonnull NSString *)title handler:(nullable HHander)handler;

@end
