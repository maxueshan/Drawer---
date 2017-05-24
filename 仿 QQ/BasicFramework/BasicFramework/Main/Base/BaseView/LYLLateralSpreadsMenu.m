//
//  LYLLateralSpreadsMenu.m
//  BasicFramework
//
//  Created by Rainy on 16/10/10.
//  Copyright © 2016年 Rainy. All rights reserved.
//
#define SLIP_WIDTH 200


#import "LYLLateralSpreadsMenu.h"
#import <Accelerate/Accelerate.h>

@interface LYLLateralSpreadsMenu ()<UIGestureRecognizerDelegate>
{
    BOOL isOpen;
    UITapGestureRecognizer *_tap;
    UISwipeGestureRecognizer *_leftSwipe, *_rightSwipe;
    UIImageView *_blurImageView;
    UIViewController *_sender;
    UIView *_contentView;
}
@end
@implementation LYLLateralSpreadsMenu

- (instancetype)initWithController:(UIViewController *)Controller{
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(-SLIP_WIDTH, 0, SLIP_WIDTH, bounds.size.height);//x: -200 w: 200
    self = [super initWithFrame:frame];
    if (self) {
        [self buildViews:Controller];
        self.backgroundColor = kRGB(242, 242, 242);
    }
    return self;
}
-(void)buildViews:(UIViewController*)sender{//传进来的控制器 VC
    _sender = sender;
    //点击手势,先不添加
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchMenu)];
    _tap.numberOfTapsRequired = 1;
    _tap.delegate = self;
    //左扫
    _leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    _leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    //右扫
    _rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(show)];
    _rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    
    [_sender.view addGestureRecognizer:_leftSwipe];
    [_sender.view addGestureRecognizer:_rightSwipe];//轻扫手势添加在VC的view 上面
    
    //模糊视图(放在右边遮挡)
    _blurImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SLIP_WIDTH, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _blurImageView.userInteractionEnabled = NO;
    _blurImageView.alpha = 0;
    _blurImageView.backgroundColor = [UIColor grayColor];
    //_blurImageView.layer.borderWidth = 5;
    //_blurImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self addSubview:_blurImageView];//此时已经覆盖在了 VC 的上面,但是父视图是当前 self
    
}

-(void)setContentView:(UIView*)contentView{
    if (contentView) {
        _contentView = contentView;
    }
    _contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:_contentView];
    
}
//打开
-(void)show:(BOOL)show{
    UIImage *image =  [self imageFromView:_sender.view];//将 VC 的 view 转换成图片
    
    if (!isOpen) {
        _blurImageView.alpha = 1;//展示
    }
    CGFloat x = show?0:-SLIP_WIDTH;//show = YES,x=0则右移,
    [UIView animateWithDuration:0.3 animations:^{
        
        [_sender.view addGestureRecognizer:_tap];//此时添加点击手势-->在 VC 的 view 上面
        //右移
        self.frame = CGRectMake(x, 0, self.frame.size.width, self.frame.size.height);
        if(!isOpen){
            _blurImageView.image = image;
            _blurImageView.image= [self blurryImage:_blurImageView.image withBlurLevel:0.2];
        }
    } completion:^(BOOL finished) {
        isOpen = show;//记录状态
        if(!isOpen){
            [_sender.view removeGestureRecognizer:_tap];
            _blurImageView.alpha = 0;
            _blurImageView.image = nil;
        }
        
    }];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([NSStringFromClass([touch.view class])isEqualToString:@"UITableViewCellContentView"]
        || [NSStringFromClass([touch.view class])isEqualToString:@"MenuView"]
        || [NSStringFromClass([touch.view class])isEqualToString:@"UITableView"]) {
        
        return NO;
    }
    return YES;
}

-(void)switchMenu{
    NSLog(@"开关");
    [self show:!isOpen];
}
//右扫
-(void)show{
    NSLog(@"右扫");
    [self show:YES];
    
}

-(void)hide {
    [self show:NO];
}


#pragma mark - shot
- (UIImage *)imageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
#pragma mark - Blur

- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
