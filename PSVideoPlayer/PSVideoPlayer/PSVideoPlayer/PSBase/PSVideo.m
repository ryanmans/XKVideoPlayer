//
//  PSVideo.m
//  PSVideoPlayer
//
//  Created by Ryan_Man on 16/8/26.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import "PSVideo.h"

@implementation PSVideo

+ (PSVideo*)modelWithDictionary:(NSDictionary *)dictionary
{
    PSVideo * video = NewClass(PSVideo);
    [video setValuesForKeysWithDictionary:dictionary];
    return video;
}

@end
