//
//  AdpScrollView.m
//  YGCAdvertisement
//
//  Created by apple on 16/5/19.
//  Copyright © 2016年 apple. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "AdpScrollView.h"
@interface AdpScrollView ()<UIScrollViewDelegate>
@property (retain,nonatomic) UIScrollView * imageScrollView;//图片的轮播
@property (strong,nonatomic) UIPageControl * pageControl;//图片的页码
@property (retain,nonatomic) NSTimer * time;//定时滚动图片
@property (assign,nonatomic) NSInteger curIndex;//当前位置
@end

@implementation AdpScrollView
//初始化
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        line.backgroundColor = [UIColor clearColor];
        [self addSubview:line];
        _imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageScrollView.delegate = self;
        _imageScrollView.pagingEnabled = YES;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 25, frame.size.width, 25)];
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        [self addSubview:_imageScrollView];
        [self addSubview:_pageControl];
        _curIndex = 0;
    }
    return self;
}
#pragma mark 重载方法
-(void)reloadView{
    if (self.pics.count == 0) {
        return;
    }
    CGFloat imgWidth = _imageScrollView.frame.size.width * (self.pics.count + (self.pics.count == 1 ? 0 : 1));
    _imageScrollView.contentSize = CGSizeMake(imgWidth, 0);
    //添加图片
    for (int i = 0;i <= (self.pics.count == 1 ? self.pics.count - 1 : self.pics.count); i++) {
        UIImageView *imageView = [UIImageView new];
        imageView.clipsToBounds = YES;
        NSString * urlStr = @"";
        if (i == 0) {
            urlStr = self.pics[self.pics.count - 1];
        }else {
            urlStr = self.pics[i - 1];
        }
        [self loadImage:urlStr imageView:imageView];
        [self setVFrame:i imageView:imageView];
        [_imageScrollView addSubview:imageView];
    }
     //初始化scrollView的滚动位置
    _imageScrollView.contentOffset = CGPointMake((self.pics.count == 1 ? 0 : self.imageScrollView.frame.size.width), 0);
    //pageController的个数
    _pageControl.numberOfPages = self.pics.count;
    //添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImgView:)];
    [_imageScrollView addGestureRecognizer:tap];
    //添加计时器
    [self addTimer];
}
#pragma mark 点击事件
- (void)clickImgView:(UIGestureRecognizer *)sender {
    self.imgeViewSelectBlock(_curIndex);
}
- (void)returnIndex:(scrollViewSelectBlock)block{
    self.imgeViewSelectBlock = block;
}
#pragma mark 图片位置的方法
- (void)setVFrame:(int)index imageView:(UIImageView *)image{
    image.frame = CGRectMake(self.frame.size.width * index, 0, self.frame.size.width, self.frame.size.height);
}
#pragma mark 下一张图片的方法
- (void)nextImage{
    if (_curIndex == self.pics.count - 1) {
        self.pageControl.currentPage = 0;
        _curIndex = 0;
    }else {
        self.pageControl.currentPage++;
        _curIndex++;
    }
    CGFloat x = (_curIndex + 1) * self.imageScrollView.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        _imageScrollView.contentOffset = CGPointMake(x, 0);
    } completion:^(BOOL finished) {
        if (finished && _curIndex == self.pics.count - 1) {
            _imageScrollView.contentOffset = CGPointMake(0, 0);
        }
    }];
}
#pragma mark 拖拉图片的时候关闭计时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.time invalidate]; //停止计时器
    self.time = nil;
}
#pragma mark 结束拖拉的时候开启计时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];
}
#pragma mark 结束拖拉,视图位置确定以后
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.pics.count == 1) {
        return;
    }
    if (scrollView.contentOffset.x == self.pics.count * scrollView.frame.size.width) {
        _imageScrollView.contentOffset = CGPointMake(0, 0);
    }else if (scrollView.contentOffset.x == 0) {
        _imageScrollView.contentOffset = CGPointMake(self.pics.count * scrollView.frame.size.width, 0);
    }
    for (int i = 0; i <= self.pics.count; i++) {
        if (scrollView.contentOffset.x == i * self.frame.size.width) {
            if (i == 0) {
                self.pageControl.currentPage = self.pics.count - 1;
                _curIndex = self.pics.count - 1;
            }else {
                self.pageControl.currentPage = i - 1;
                _curIndex = i - 1;
            }
        }
    }
}
#pragma mark 添加计时器
- (void)addTimer{
    if (self.pics.count != 1) {
        self.time = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    }
}
#pragma mark 下载图片
- (void) loadImage:(NSString *)urlStr imageView:(UIImageView *)imgView {
    imgView.layer.borderWidth = 0.3;
    imgView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url == nil) {
        return;
    }
    dispatch_queue_t queue =dispatch_queue_create("loadImage",NULL);
    dispatch_async(queue, ^{
        if ([self getImageWithName:[self md5:urlStr]] != nil) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                imgView.image = [self getImageWithName:[self md5:urlStr]];
            });
        }else {
            NSData *resultData = [NSData dataWithContentsOfURL:url];
            UIImage *img = [UIImage imageWithData:resultData];
            if (img != nil) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    imgView.image = img;
                    [self saveImage:img withName:[self md5:urlStr]];
                });
            }
        }
    });
}
#pragma mark 保存图片
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData * UIImageJPEGRepresentation (UIImage *image, CGFloat compressionQuality);
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}
#pragma mark 获取图片
- (UIImage *) getImageWithName:(NSString *)imageName{
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    return savedImage;
}
#pragma mark 转换路径为有限的文件名，用于使用路径保存文件
- (NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end
