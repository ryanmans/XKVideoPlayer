//
//  PSTypedef.h
//  PSScanViewController
//
//  Created by Ryan_Man on 16/8/23.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#ifndef PSTypedef_h
#define PSTypedef_h
#import <Foundation/Foundation.h>
typedef void (^EmptyBlock)();

typedef void (^NSObjectBlock)(id object);

typedef void (^IntegerBlock) (NSInteger object);

typedef void (^NSNumberBlock)(NSNumber * object);

typedef void (^NSStringBlock)(NSString * object);

typedef void (^DictionaryBlock)(NSDictionary * object);

typedef void (^ArrayBlock)(NSArray * object);

typedef void (^NetResponeBlock)(id object, NSError * error, id userParam);

typedef void (^NetDictionaryResponeBlock)(NSDictionary * object, NSError * error, id userParam);


#endif /* PSTypedef_h */
