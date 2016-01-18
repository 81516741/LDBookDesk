//
//  ViewController.m
//  书架动画测试
//
//  Created by Kingpoint on 16/1/15.
//  Copyright © 2016年 kingpoint. All rights reserved.
//

#import "ViewController.h"
#import "LDBookDesk.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet LDBookDesk * bookDesk;

@end

@implementation ViewController

//全部删除
- (IBAction)deleteAll:(UIBarButtonItem *)sender {
    [_bookDesk deleteAllView];
}
- (IBAction)dismisi:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//多选删除
- (IBAction)multiSelected:(UIBarButtonItem *)sender {
   _bookDesk.operationType = _bookDesk.operationType != LDBookDeskClickOperationTypeDeleteSelectedViewList ? LDBookDeskClickOperationTypeDeleteSelectedViewList : LDBookDeskClickOperationTypeDeleteSelectedView;
}
- (IBAction)delete:(UIBarButtonItem *)sender {
    [_bookDesk deleteSelectedView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray * arr = [NSMutableArray array];
    for (int i = 0;  i < 30; i ++) {
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i+1]]];
        [arr addObject:imageView];
    }
    //传一个图片数组
    _bookDesk.bookList = arr;
    //动画列书
    _bookDesk.animation = YES;
    //点击后回调block
    [_bookDesk viewClick:^(UIView *view, NSInteger index) {
        NSLog(@"%@---%zd",view,index);
    }];
   
}

@end
