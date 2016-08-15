//
//  UINavigationItem+_Swizzle.m
//  TCTravel_IPhone
//
//
//


#define RGBA(r,g,b,a)   [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]
#define color_Green                     RGBA(46,189,89,1)//RGBA(80,180,0,1)
//#define KNavItemButtonColor color_Green
#define KNavItemButtonColor [UIColor whiteColor]
#import "UINavigationItem+_Swizzle.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzle)

+ (void)swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    BOOL methodAdded = class_addMethod([self class],
                                       originalSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded)
    {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, newMethod);
    }
    
}

@end


@implementation UINavigationItem (Swizzle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      SEL leftBarButtonItem = @selector(setLeftBarButtonItem:);
                      SEL tcLeftBarButtonItem = @selector(setTCLeftBarButtonItem:);
                      SEL rightBarButtonItem = @selector(setRightBarButtonItem:);
                      SEL tcRightBarButtonItem = @selector(setTCRightBarButtonItem:);
                      
                      [self swizzleInstanceSelector:leftBarButtonItem withNewSelector:tcLeftBarButtonItem];
                      [self swizzleInstanceSelector:rightBarButtonItem withNewSelector:tcRightBarButtonItem];
                  });
}

- (void)setTCRightBarButtonItem:(UIBarButtonItem *)_rightBarButtonItem
{
    [self setBarButtonItemColor:_rightBarButtonItem];
    [self setTCRightBarButtonItem:_rightBarButtonItem];
}

- (void)setTCLeftBarButtonItem:(UIBarButtonItem *)_leftBarButtonItem
{
    [self setBarButtonItemColor:_leftBarButtonItem];
    [self setTCLeftBarButtonItem:_leftBarButtonItem];
}

- (void)setBarButtonItemColor:(UIBarButtonItem *)_barButtonItem
{
    id customView = [_barButtonItem customView];
    if ([customView isKindOfClass:[UIButton class]])
    {
        UIButton *button = (UIButton *)customView;
        [button setExclusiveTouch:YES];
        
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [button setTitleColor:KNavItemButtonColor forState:UIControlStateNormal];
        [button setTitleColor:KNavItemButtonColor forState:UIControlStateHighlighted];
    }
    else if ([customView isKindOfClass:[UIView class]])
    {
        UIView *v = (UIView *)customView;
        [v.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[UIButton class]])
             {
                 UIButton *button = (UIButton *)obj;
                 [button setExclusiveTouch:YES];
                 
                 [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
                 [button setTitleColor:KNavItemButtonColor forState:UIControlStateNormal];
                 [button setTitleColor:KNavItemButtonColor forState:UIControlStateHighlighted];
             }
         }];
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
- (void)setLeftBarButtonItem:(UIBarButtonItem *)_leftBarButtonItem
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -12;
        
        if (_leftBarButtonItem)
        {
            [self setLeftBarButtonItems:@[negativeSeperator, _leftBarButtonItem]];
        }
        else
        {
            [self setLeftBarButtonItems:@[negativeSeperator]];
        }
    }
    else
    {
        [self setLeftBarButtonItem:_leftBarButtonItem animated:NO];
    }
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)_rightBarButtonItem
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -12;
        
        if (_rightBarButtonItem)
        {
            [self setRightBarButtonItems:@[negativeSeperator, _rightBarButtonItem]];
        }
        else
        {
            [self setRightBarButtonItems:@[negativeSeperator]];
        }
    }
    else
    {
        [self setRightBarButtonItem:_rightBarButtonItem animated:NO];
    }
}

#endif

@end

@implementation FKData


-(NSUInteger)length
{
    return 100;
}

-(NSUInteger)fkLength
{
    return 100;
}
@end