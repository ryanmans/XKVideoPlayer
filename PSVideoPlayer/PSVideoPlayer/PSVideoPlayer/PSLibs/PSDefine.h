//
//  PSDefine.h
//  PSScanViewController
//
//  Created by Ryan_Man on 16/8/23.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#ifndef PSDefine_h
#define PSDefine_h

//重写NSLog,Debug模式下打印日志和当前行数
#if DEBUG
#define PSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define PSLog(FORMAT, ...) nil
#endif


//  打印方法名
#define LogFunctionName()  PSLog(@"%s",__func__);


// weak and strong 定义
#define CopyAsWeak(x, y)    __weak typeof(x) y = x
#define WeakSelf(x)         __weak typeof (self) x = self
#define StrongSelf(x)       __strong __typeof(self) x  = self

#define MinMutableCount 4UL
//初始化宏
#define NewRectButton()           [UIButton buttonWithType:UIButtonTypeRoundedRect]
#define NewButton()               [UIButton buttonWithType:UIButtonTypeCustom]
#define NewClass(x)               [[x alloc] init]
#define NewMutableArray()         [NSMutableArray arrayWithCapacity:MinMutableCount]
#define NewMutableDictionary()    [NSMutableDictionary dictionaryWithCapacity:MinMutableCount]

#define ClassName(x)               NSStringFromClass([x class])

// 方法宏
#define IsHasSelector(x,selector) [x respondsToSelector:selector]
#define IsSubclassOfClass(x, y)   [x isSubclassOfClass: [y class]]
#define IsKindOfClass(x, y)       [x isKindOfClass:[y class]]
#define IsMemberOfClass(x, y)     [x isMemberOfClass:[y class]]
#define IsRangeOfString(x, y)     ([x rangeOfString:y].length)
#define IsSafeString(x)           ((x != nil && x.length != 0)? x : @"")
#define IsSameString(x, y)        ([x isEqualToString:y])


// 计算文本 size
#define HalfF(x) ((x)/2.0f)
#define SizeWithAttributes(t,f)      [t sizeWithAttributes:@{NSFontAttributeName:f}]

#define BoundingRectWithSize(t,s,f)  [t boundingRectWithSize:s options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:f} context:nil]


// 字体宏
#define FontOfSize(x)        [UIFont systemFontOfSize:x]
#define BoldFontOfSize(x)    [UIFont boldSystemFontOfSize:x]


//颜色宏
#define RGBA(r,g,b,a)        [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b)           RGBA(r,g,b,1.0f)

#define Arc4randomColor      RGBA(arc4random() % 256,arc4random() % 256,arc4random() % 256,1.0f)  //获取随机色

//16进制获取颜色
#define Hex_Color_Alpha(x,a)  [UIColor colorWithRed:((float)((x & 0xFF0000) >> 16))/255.0 green:((float)((x & 0xFF00) >> 8))/255.0 blue:((float)(x & 0xFF))/255.0 alpha:(a)]

#define Hex_Color(x)  Hex_Color_Alpha(x,1.0)


//系统尺寸宏
#define KScreen_Width         ([UIScreen mainScreen].bounds.size.width)

#define KScreen_Height        ([UIScreen mainScreen].bounds.size.height)

#define KStatus_Height        [[UIApplication sharedApplication] statusBarFrame].size.height

#define KNavigation_Height    (self.navigationController.navigationBar.frame.size.height)

#define KTabBar_Height        (self.tabBarController.tabBar.frame.size.height)

#define Invalid_View_Height   (KStatus_Height + KNavigation_Height) //无效高度

#define Valid_View_Height     (KScreen_Height - Invalid_View_Height) //有效高度


//系统单列
#define ApplicationKeyWindow  [[UIApplication sharedApplication] keyWindow]




#endif /* PSDefine_h */
