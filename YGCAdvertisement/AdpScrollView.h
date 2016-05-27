//
//  AdpScrollView.h
//  YGCAdvertisement
//
//  Created by apple on 16/5/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>  
/**
 *Block的定义格式
 返回值类型(^block变量名)(形参列表) = ^(形参列表) {
 };
 调用Block保存的代码
 block变量名(实参);
 ARC情况下
 1.如果用copy修饰Block，该Block就会存储在堆空间。则会对Block的内部对象进行强引用，导致循环引用。内存无法释放。
 解决方法：
 新建一个指针(__weak typeof(Target) weakTarget = Target )指向Block代码块里的对象，然后用weakTarget进行操作。就可以解决循环引用问题。
 2.如果用weak修饰Block，该Block就会存放在栈空间。不会出现循环引用问题。
 */
/**
 *  Block结合typedef使用
 */
typedef void (^scrollViewSelectBlock)(NSInteger index);
@interface AdpScrollView : UIView
/**
 *  图片路径数组
 */
@property (nonatomic,strong) NSMutableArray *pics;
//pageControl 颜色
@property (nonatomic,strong) UIColor *pageColor;
@property (nonatomic,strong) UIColor *pageSelectColor;
//声明Block 图片的点击事件
@property (nonatomic,copy) scrollViewSelectBlock imgeViewSelectBlock;
//块回调方法
-(void)returnIndex:(scrollViewSelectBlock) block;
//赋值以后，调用此方法刷洗视图
-(void)reloadView;
@end
