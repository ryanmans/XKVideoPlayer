//
//  PSVideo.h
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/8/26.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSVideo : NSObject
@property (nonatomic,copy)NSString * playUrl;
@property (nonatomic,copy)NSString * title;

+ (PSVideo*)modelWithDictionary:(NSDictionary*)dictionary;
@end
