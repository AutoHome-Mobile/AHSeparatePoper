//
//  AHSeparatePoper.m
//  AHSeparatePoper
//
//  Created by jun on 4/30/14.
//  Copyright (c) 2014 Junkor. All rights reserved.
//

#import "AHSeparatePoper.h"
#import "UIView+ViewFrameGeometry.h"

#define kViewTag (23444)

#define kArrowSize ((CGSize){14,8})
#define kArrowMargin (8.0)
#define kAnimationDuration (0.2)

// 当contentView超过父View高度的时候，保留的不展开区域的高度
#define kDeSeparateHeight (44)

typedef enum {
    eBottomSeparate,    // 下边展开
    eTopSepatate,       // 上边展开
    eCenterSeparate,    // 中间展开
    eLinerSeparate,     // 自上而下展开
}ESeparateType;

@implementation AHSeparatePoper
{
    UIImageView *topPart;
    UIImageView *bottomPart;
    UIView *contentView;
    UIView *arrowView;
    
    CGRect topRect;
    CGRect bottomRect;
    CGRect openBottomRect;
    CGRect openTopRect;
    
    BOOL isShow;
    
    // 实际的content高度 (超出一View的高度时会按照view的最大显示区域来保留显示)
    float contentHeight;
}

+ (void) separatePoperTo:(UIView *)view withContent:(UIView *)content by:(UIView *)sender
{
    AHSeparatePoper *tmpPoper = [[AHSeparatePoper alloc] initWithView:view];
    [tmpPoper separateTo:view withContent:content by:sender];
}

+ (void) deSeparateForView:(UIView *)view
{
    AHSeparatePoper *poper = (AHSeparatePoper *)[view viewWithTag:kViewTag];
    [poper deSeparate];
}

- (instancetype) initWithView:(UIView *)view
{
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.tag = kViewTag;
    }
    return self;
}

/**
 *  
 *   separate to show the content View
 *   展开并show出content
 */
- (void) separateTo:(UIView *)view withContent:(UIView *)content by:(UIView *)sender
{
    /*
     *  calculate the separate Locations
     *  计算展开位置，(向上展开，or 向下展开，or 两边上下展开)
     */
    
    // 转换坐标
    CGRect senderRect = [view convertRect:sender.frame fromView:sender.superview];
    CGPoint senderCenter = CGRectGetCenter(senderRect);
    
    // 判断触发点是在上半屏还是下半屏；如果是上半屏，优先下展开，如果是下半屏，优先上展开；如果too high, 优先自上而下展示
    BOOL isTopSeparate;
    
    // 获取到分割点
    CGPoint topSeparatePoint = (CGPoint){senderCenter.x,senderCenter.y - sender.height*0.5 - kArrowMargin - kArrowSize.height};
    CGPoint bottomSeparatePoint = (CGPoint){senderCenter.x,senderCenter.y + sender.height*0.5+kArrowMargin+kArrowSize.height};
    
    // 根据条件选择上展开点还是下展开点
    CGPoint separatePoint = bottomSeparatePoint;
    contentHeight = content.height;
    
    if (content.height < view.height - kDeSeparateHeight)
    {
        // 显示区域足够时
        if (bottomSeparatePoint.y + content.height < view.height)
        {
            // 从下边展开时足够展示内容，则从下边展开
            separatePoint = bottomSeparatePoint;
            topRect = (CGRect){CGPointZero,view.width,separatePoint.y};
            bottomRect = (CGRect){0,separatePoint.y,view.width,view.height-separatePoint.y};
            openTopRect = topRect;
            openBottomRect = (CGRect){0,bottomRect.origin.y+content.height,bottomRect.size};
            isTopSeparate = NO;
        }
        else if (topSeparatePoint.y - content.height > 0)
        {
            // 下边不够展示了，尝试从上边展示
            separatePoint = topSeparatePoint;
            topRect = (CGRect){CGPointZero,view.width,separatePoint.y};
            bottomRect = (CGRect){0,separatePoint.y,view.width,view.height-separatePoint.y};
            openTopRect = (CGRect){0,topRect.origin.y-contentHeight,topRect.size};
            openBottomRect = bottomRect;
            isTopSeparate = YES;
        }
        else
        {
            // view的高度够显示Content，不过单纯的移动上下区间都不够显示content，这时候就需要上下都要移动了
            separatePoint = bottomSeparatePoint;
            topRect = (CGRect){CGPointZero,view.width,separatePoint.y};
            bottomRect = (CGRect){0,separatePoint.y,view.width,view.height-separatePoint.y};
            
            float spaceHeight = (view.height - contentHeight)*0.5;
            openTopRect = (CGRect){0,spaceHeight-topRect.size.height,topRect.size};
            openBottomRect = (CGRect){0,view.height-spaceHeight,bottomRect.size};
            isTopSeparate = NO;
        }
    }
    else
    {
        // 显示区域不够时
        contentHeight = view.height - kDeSeparateHeight;
        isTopSeparate = senderCenter.y < view.height*0.5 ? NO : YES;
        
        if (isTopSeparate)
        {
            // 向上展开
            separatePoint = topSeparatePoint;
            topRect = (CGRect){CGPointZero,view.width,separatePoint.y};
            bottomRect = (CGRect){0,separatePoint.y,view.width,view.height-separatePoint.y};
            
            if (bottomRect.size.height<kDeSeparateHeight)
            {
                // 触发的区域比留的区域还要小的时候，不需要移动
                openTopRect = (CGRect){0,(kDeSeparateHeight-bottomRect.size.height)-topRect.size.height,topRect.size};
                openBottomRect = (CGRect){0,view.height-bottomRect.size.height,bottomRect.size};
            }
            else
            {
                openTopRect = (CGRect){0,-topRect.size.height,topRect.size};
                openBottomRect = (CGRect){0,view.height-kDeSeparateHeight,bottomRect.size};
            }
        }
        else
        {
            // 向下展开
            separatePoint = bottomSeparatePoint;
            topRect = (CGRect){CGPointZero,view.width,separatePoint.y};
            bottomRect = (CGRect){0,separatePoint.y,view.width,view.height-separatePoint.y};
            if (topRect.size.height<kDeSeparateHeight)
            {
                openTopRect = (CGRect){0,topRect.size.height-topRect.size.height,topRect.size};
                openBottomRect = (CGRect){0,view.height-(kDeSeparateHeight-topRect.size.height),bottomRect.size};
            }
            else
            {
                openTopRect = (CGRect){0,kDeSeparateHeight-topRect.size.height,topRect.size};
                openBottomRect = (CGRect){0,view.height,bottomRect.size};
            }
        }
    }
    
    // 添加要展示的内容
    if (contentView)
    {
        [contentView removeFromSuperview];
        contentView = nil;
    }
    contentView = content;
    [self addSubview:contentView];
    contentView.center = (CGPoint){self.width*0.5,openTopRect.origin.y+openTopRect.size.height+content.height*0.5};
    
    // create the imageView by capture the 'View'
    UIImage *viewImage = [self captureForView:view];
    UIImage *topImage = [self subImage:topRect forImage:viewImage];
    UIImage *bottomImage = [self subImage:bottomRect forImage:viewImage];
    
    if (topPart)
    {
        [topPart removeFromSuperview];
        topPart = nil;
    }
    topPart = [[UIImageView alloc] initWithImage:topImage];
    topPart.frame = topRect;
    [self addSubview:topPart];
    
    if (bottomPart) {
        [bottomPart removeFromSuperview];
        bottomPart = nil;
    }
    bottomPart = [[UIImageView alloc] initWithImage:bottomImage];
    bottomPart.frame = bottomRect;
    [self addSubview:bottomPart];
    
    arrowView = [self createTriangleView:isTopSeparate];
    if (isTopSeparate)
    {
        [bottomPart addSubview:arrowView];
        arrowView.frame = (CGRect){separatePoint.x-kArrowSize.width*0.5,0,kArrowSize};
    }
    else
    {
        [topPart addSubview:arrowView];
        arrowView.frame = (CGRect){separatePoint.x-kArrowSize.width*0.5,separatePoint.y-kArrowSize.height,kArrowSize};
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        topPart.frame = openTopRect;
        bottomPart.frame = openBottomRect;
        arrowView.alpha = 1;
    }];
    
    [view addSubview:self];
    isShow = YES;
}

- (void) deSeparate
{
    //do animation to dissmiss
    isShow = NO;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        topPart.frame = topRect;
        bottomPart.frame = bottomRect;
        arrowView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished)
        {
            [self removeFromSuperview];
        }
    }];
}

/*
 *      de-separate the view when touch out of the content
 *      手势触碰时关闭展开
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    CGPoint location = [anyTouch locationInView:self];
    
    // 实际展示的尺寸可能不是全尺寸(当content的尺寸超出可显示尺寸时)
    CGRect realContentRect = (CGRect){contentView.origin,contentView.width,contentHeight};
    if (!CGRectContainsPoint(realContentRect, location))
    {
        if (isShow)
        {
            [self deSeparate];
        }
    }
}

/*
 *  create a Triangle View
 *  创建一个三角形的view
 */
- (UIView *)createTriangleView:(BOOL)isArrowTop
{
    UIView *tmpArrowView = [[UIView alloc] initWithFrame:(CGRect){0,0,kArrowSize}];
    tmpArrowView.backgroundColor = [UIColor blackColor];
    
    CGPoint point0,point1,point2;
    
    if (isArrowTop)
    {
        point0 = CGPointZero;
        point1 = tmpArrowView.bottomCenter;
        point2 = tmpArrowView.topRight;
    }
    else
    {
        point0 = tmpArrowView.bottomLeft;
        point1 = tmpArrowView.topCenter;
        point2 = tmpArrowView.bottomRight;
    }
    
    // 创建遮罩的path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, point0.x, point0.y);
    CGPathAddLineToPoint(path, NULL, point1.x, point1.y);
    CGPathAddLineToPoint(path, NULL, point2.x, point2.y);
    CGPathCloseSubpath(path);
    
    // 创建遮罩的layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:path];
    CFRelease(path);
    tmpArrowView.layer.mask = shapeLayer;
    
    // alpha为0是为了展开时动画展现淡入淡出
    tmpArrowView.alpha = 0;
    return tmpArrowView;
}

/*
 *  take a screen shoot of a view
 *  获取view的截图
 */
- (UIImage *)captureForView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/*
 *  get a part of an image by rect
 *  获取一个image的一块儿
 */
-(UIImage *)subImage:(CGRect)rect forImage:(UIImage *)orgImage
{
    
    if (CGRectEqualToRect(rect,CGRectZero))
    {
        return nil;
    }
    
    // 截取到的图片的scale是2，retina屏幕下，需要获取到两倍的图片区域
    float scale = orgImage.scale;
    if(scale != 1)
    {
        rect = (CGRect){rect.origin.x*scale,rect.origin.y*scale,rect.size.width*scale,rect.size.height*scale};
    }
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(orgImage.CGImage, rect);
	CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
	
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
	
    return smallImage;
}

@end
