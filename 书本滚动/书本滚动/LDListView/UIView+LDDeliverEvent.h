//
//  UIView+LDDeliverEvent.h
//  书本滚动
//
//  Created by mac on 16/1/17.
//  Copyright © 2016年 LD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LDDeliverEvent)

/**
 添加target对像,监听点击事件
 */
-(void)addTarget:(id)target sel:(SEL)sel;
/**
 *  提示图标
 */
@property(nonatomic, strong) UIImageView  * tipIcon;

@end
