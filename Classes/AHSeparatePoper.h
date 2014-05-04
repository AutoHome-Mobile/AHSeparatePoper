//
//  AHSeparatePoper.h
//  AHSeparatePoper
//
//  Created by jun on 4/30/14.
//  Copyright (c) 2014 Junkor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AHSeparatePoper : UIView

/**
 *  @method
 *  @abstract  easy way to show a separate Poper
 *  @param view   用于展示的superView
 *  @param sender 用于判断弹出位置的触发者
 */
+ (void) separatePoperTo:(UIView *)view withContent:(UIView *)content by:(UIView *)sender;

/**
 *  @method
 *  @abstract  代码关闭某view的子view中的separatePoper
 *  @param view 展示poper的父view
 */
+ (void) deSeparateForView:(UIView *)view;

/**
 *  @method
 *  @abstract  初始化函数
 *  @param view 根据这个View来初始化遮罩的尺寸和self的尺寸
 *  @return self
 */
- (instancetype) initWithView:(UIView *)view;

/**
 *  @method
 *  @abstract  在指定的View中弹出固定内容的分割弹出框
 *  @param view    用于展示的superView
 *  @param content 用于展示的内容view
 *  @param sender  用于判断弹出位置的触发者
 */
- (void) separateTo:(UIView *)view withContent:(UIView *)content by:(UIView *)sender;

/**
 *  @method
 *  @abstract  隐藏poper
 */
- (void) deSeparate;

@end
