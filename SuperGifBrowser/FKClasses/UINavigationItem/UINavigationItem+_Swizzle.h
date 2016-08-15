//
//  UINavigationItem+_Swizzle.h
//  TCTravel_IPhone
//


#import <UIKit/UIKit.h>

@interface NSObject (Swizzle)

+ (void)swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector;

@end

@interface UINavigationItem (Swizzle)

@end

@interface FKData:NSData

@end