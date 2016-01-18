//
//  LDScrollerView.h
//  书架滚动
//
//  Created by Kingpoint on 16/1/15.
//  Copyright © 2016年 kingpoint. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Block)(UIView * view,NSInteger index);
typedef enum{
    LDBookDeskClickOperationTypeOnlyDeliver,//只是传递
    LDBookDeskClickOperationTypeDeleteSelectedViewList,//删除多选的view
    LDBookDeskClickOperationTypeDeleteSelectedView//即传递也删除
}LDBookDeskClickOperationType;

@interface LDBookDesk : UIScrollView

/**imageView的数组集合*/
@property(nonatomic, strong) NSMutableArray  * bookList;
/**是否需要动画展示*/
@property(nonatomic, assign, getter=isAnimation) BOOL animation;
/**点击图片是否删除*/
@property(nonatomic, assign) LDBookDeskClickOperationType operationType;
/**最大列数（排几列）*/
@property(nonatomic, assign) NSInteger maxCol;
/**x方向间隙*/
@property(nonatomic, assign) CGFloat marginX;
/**y方向间隙*/
@property(nonatomic, assign) CGFloat marginY;
/**高宽比(高/宽)*/
@property (nonatomic, assign) CGFloat HWScal;
/**回传被点击的view和view在数组中的角标*/
-(void)viewClick:(Block)deliverBlock;
/**删除选中的*/
-(void)deleteSelectedView;
/**全部删除*/
-(void)deleteAllView;
@end
