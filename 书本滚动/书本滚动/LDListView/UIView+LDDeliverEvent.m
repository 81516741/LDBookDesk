//
//  UIView+LDDeliverEvent.m
//  书本滚动
//
//  Created by mac on 16/1/17.
//  Copyright © 2016年 LD. All rights reserved.
//

#import "UIView+LDDeliverEvent.h"
#import <objc/message.h>
#import <objc/runtime.h>

#define LDViewTouchDeliver(target,sel) ((void (*)(id,SEL,UIView *))objc_msgSend)((id)target,sel,self)

static const char targetKey = 'z';
static const char selKey = 'l';
static const char tipIconKey = 'd';

@implementation UIView (LDDeliverEvent)

-(void)addTarget:(id)target sel:(SEL)sel
{
    self.target = target;
    self.sel = sel;
}

#pragma view被点击后将事件传出去
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([self.target respondsToSelector:self.sel]) {
        LDViewTouchDeliver(self.target, self.sel);
    }
}

#pragma 动态绑定一个target 和一个sel（有点类似添加两个变量）
-(id)target
{
    return objc_getAssociatedObject(self, &targetKey);
}

-(void)setTarget:(id)target
{
    objc_setAssociatedObject(self, &targetKey, target, OBJC_ASSOCIATION_RETAIN);
}

-(SEL)sel
{
    return NSSelectorFromString(objc_getAssociatedObject(self, &selKey));
}

-(void)setSel:(SEL)sel
{
    objc_setAssociatedObject(self, &selKey,NSStringFromSelector(sel), OBJC_ASSOCIATION_RETAIN);
}

-(UIImageView *)tipIcon
{
    return objc_getAssociatedObject(self, &tipIconKey);
}

-(void)setTipIcon:(UIImageView *)tipIcon
{
    tipIcon.frame = CGRectMake(0, 0, 15, 15);
    [self addSubview:tipIcon];
    objc_setAssociatedObject(self, &tipIconKey, tipIcon, OBJC_ASSOCIATION_RETAIN);
}
@end
