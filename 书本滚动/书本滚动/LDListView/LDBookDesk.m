//
//  LDScrollerView.m
//  书本滚动
//
//  Created by Kingpoint on 16/1/15.
//  Copyright © 2016年 kingpoint. All rights reserved.
//

#import "LDBookDesk.h"
#import "UIView+LDDeliverEvent.h"
#define ViewW ([UIScreen mainScreen].bounds.size.width -(self.marginX * (self.maxCol + 1)))  / self.maxCol
#define ViewH ViewW*self.HWScal
#define screenSize [UIScreen mainScreen].bounds.size
#define BundleImageWithName(name) [UIImage imageNamed:name inBundle:[NSBundle bundleWithPath:[[NSBundle mainBundle]pathForResource:@"source" ofType:@"bundle"]] compatibleWithTraitCollection:nil]
@interface LDBookDesk()
{
    NSInteger _deleteIndex;
    Block _deliverBlcok;
}
/**
 *  临时存储需要删除的元素
 */
@property(nonatomic, strong) NSMutableArray  * deletedViews;

@end

@implementation LDBookDesk

#pragma mark - 懒加载
//用来临时保存需要删除的view的数组
-(NSMutableArray *)deletedViews{
    if (_deletedViews == nil) {
        _deletedViews = [[NSMutableArray alloc]init];
    }
    return _deletedViews;
}

#pragma mark - 重写set方法，初始化view的大小和初始位置
-(void)setBookList:(NSMutableArray *)bookList
{
    _bookList = bookList;
    //知道数组的长度就可以知道contentsize
    [self calculateContentSize];
    //如果不设置延时0.25，那么自定义maxCol,margin等值时,就需要在set方法之前设置
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (int i = 0; i < bookList.count; i ++) {
            UIImageView * imageView = _bookList[i];
            imageView.userInteractionEnabled = YES;
            imageView.frame = CGRectMake(-500, -500, ViewW, ViewH);
            [imageView addTarget:self sel:@selector(click:)];
            [self addSubview:imageView];
            
            UIImageView * tipIcon = [UIImageView new];
            imageView.tipIcon = tipIcon;
        }
        [self flyPaper];
        //放书架背景图
        NSInteger maxRow = bookList.count/self.maxCol;
        for (int i = 0; i < maxRow + 1; i++) {
            UIImageView * imageView = [[UIImageView alloc]initWithImage:BundleImageWithName(@"bookDesk")];
            ;
            
            imageView.frame = CGRectMake(0, (self.marginY  + ViewH)*i, screenSize.width, self.marginY * 2 + ViewH);
            [self insertSubview:imageView atIndex:0];
        }
    });
    
}

#pragma mark - 重写set状态的方法来进行相应的逻辑操作
-(void)setOperationType:(LDBookDeskClickOperationType)operationType
{
    _operationType = operationType;
    _deletedViews = nil;
    for (UIView * view in _bookList) {
        view.tipIcon.image = nil;
        switch (operationType) {
            case LDBookDeskClickOperationTypeDeleteSelectedViewList:
                view.tipIcon.image = BundleImageWithName(@"unSelected");
                break;
            case LDBookDeskClickOperationTypeDeleteSelectedView:
                view.tipIcon.image = BundleImageWithName(@"delete");
                break;
                
            default:
                break;
        }
    }
}
#pragma mark - view被点击
-(void)click:(UIImageView *)imageView
{
    //保存点击的view在数组中的位置
    _deleteIndex= [_bookList indexOfObject:imageView];
    //如果是多选删除则将需要删除的view保存在数组中
    if (self.operationType == LDBookDeskClickOperationTypeDeleteSelectedViewList)
    {
        if ([self.deletedViews containsObject:imageView]) {
            [self.deletedViews removeObject:imageView];
            imageView.tipIcon.image = BundleImageWithName(@"unSelected");
        }else{
            [self.deletedViews addObject:imageView];
            imageView.tipIcon.image = BundleImageWithName(@"selected");
        }
    }
    //如果是点谁删谁则执行下面代码
    if (self.operationType == LDBookDeskClickOperationTypeDeleteSelectedView) {
        [imageView removeFromSuperview];
        [_bookList removeObject:imageView];
        [self flyPaper];
        //每次删除元素后计算一次contentsize
        [self calculateContentSize];
    }
    //将单个点击的view 和 view 在数组中的位置传递出去
    if (_deliverBlcok) {
        _deliverBlcok(imageView,_deleteIndex);
    }
    
}

//设置contentsize
-(void)calculateContentSize{
    //因为这里是用_bookList.count计算的row 和for循环里面用i计算有点区别
    NSInteger row = _bookList.count / self.maxCol;
    CGFloat maxY = (row + 1) * (ViewH + self.marginY) + self.marginY;
    [UIView animateWithDuration:0.5 animations:^{
        //当数组的元素个数刚好整出self.maxCol就少一个高度
        if (0 == (_bookList.count % self.maxCol)) {
            self.contentSize = CGSizeMake(0, maxY - (ViewH + self.marginY));
        }else{
            self.contentSize = CGSizeMake(0, maxY);
        }
    }];
}

#pragma mark - 删除所有的view
-(void)deleteAllView
{
    if (self.userInteractionEnabled) {
        for (UIView * view in _bookList) {
            [view removeFromSuperview];
        }
        _bookList = nil;
        _deleteIndex = 0;
        _deletedViews = nil;
        self.contentSize = CGSizeZero;
    }
    
}

#pragma mark - 删除选中的view集合
-(void)deleteSelectedView
{
    for (UIImageView * view in _deletedViews) {
        [view removeFromSuperview];
    }
    //这里不设置成0会导致一些被删除的图片位置空着
    _deleteIndex = 0;
    [_bookList removeObjectsInArray:_deletedViews];
    [self flyPaper];
    //每次删除元素后计算一次contentsize
    [self calculateContentSize];
    //重置状态
    self.operationType = LDBookDeskClickOperationTypeOnlyDeliver;

}

#pragma mark - 一张一张的动画展示
-(void)flyPaper
{
    //满足这2个条件表示不用再调整位置了
    if (_bookList.count == 0||_bookList.count - 1 < _deleteIndex){
        self.userInteractionEnabled = YES;
        self.deletedViews = nil;
        //当删除最后一个元素，计算一下contentsize，防止最后面空一行
        [self calculateContentSize];
        return;
    }
    NSInteger col = _deleteIndex % self.maxCol;
    NSInteger row = _deleteIndex / self.maxCol;
    CGFloat maxY = (row + 1) * (ViewH + self.marginY) + self.marginY;
    UIView * view = _bookList[_deleteIndex];
    //是否需要动画调整位置
    if (self.isAnimation) {
        if ((maxY + self.contentInset.top) > self.contentOffset.y + self.contentInset.top + screenSize.height) {
            [UIView animateWithDuration:0.5 animations:^{
                self.contentOffset = CGPointMake(0, maxY - screenSize.height);
            }];
        }
        [UIView animateWithDuration:0.25 animations:^{
            view.frame = CGRectMake(self.marginX + (self.marginX + ViewW)*col , self.marginY + (self.marginY + ViewH) * row, ViewW, ViewH);
        }completion:^(BOOL finished) {
            //调整完当前view的位置，继续调整下一个view的位置
            _deleteIndex++;
            [self flyPaper];
        }];
    }else{
        view.frame = CGRectMake(self.marginX + (self.marginX + ViewW)*col , self.marginY + (self.marginY + ViewH) * row, ViewW, ViewH);
        _deleteIndex++;
        [self flyPaper];
    }
}

#pragma mark - block的方法
//这里用个方法主要是希望在调用是可以直接回车敲出来
-(void)viewClick:(Block)deliverBlock{
    _deliverBlcok = deliverBlock;
}

#pragma mark - scrollView的初始化设置
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceVertical = YES;
        self.showsVerticalScrollIndicator = NO;
        self.userInteractionEnabled = NO;
        self.animation = YES;
        self.marginX = 15;
        self.marginY = 25;
        self.maxCol = 3;
        self.HWScal = 1.2;
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.alwaysBounceVertical = YES;
    self.showsVerticalScrollIndicator = NO;
    self.userInteractionEnabled = NO;
    self.animation = YES;
    self.marginX = 15;
    self.marginY = 25;
    self.maxCol = 3;
    self.HWScal = 1.2;
}
@end
