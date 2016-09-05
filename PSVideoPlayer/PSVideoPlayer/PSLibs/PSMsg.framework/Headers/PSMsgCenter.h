//
//  PSMsgCenter.h
//  PSMsg
//
//  Created by Ryan_Man on 16/8/7.
//  Copyright © 2016年 Ryan_Man. All rights reserved.
//

#import <Foundation/Foundation.h>


#define _API_UNAVAILABLE(INFO)    __attribute__((unavailable(INFO)))

NS_ASSUME_NONNULL_BEGIN

@class PSMsgCenter;

@protocol PSMsgDispatcherDelegate <NSObject>
@required;

/**
 *  接收消息，并响应事件
 *
 *  @param type   消息类型
 *  @param sender 消息发送者
 *  @param param  传递的参数
 */
- (void)ps_DidReceivedMessage: (NSString *)type msgDispatcher: (PSMsgCenter *)sender userParam:(__nullable id)param;
@end


#define PSMsgCenterInstance   [PSMsgCenter shareInstance]

// 广播中心 ：实现消息传递，消息接收，消息事件响应
@interface PSMsgCenter : NSObject

+ (instancetype)new _API_UNAVAILABLE("使用shareInstance来获取实例");
/**
 *  单列
 *
 *  @return
 */
+ (instancetype)shareInstance;

/**
 *  发送消息(支持多个或单个)
 *
 *  @param msg     消息类型
 *  @param param   传递的参数
 */
- (void)ps_SendMessage: (NSString *)msg userParam: (nullable id)param;

/**
 *  发送消息 (仅仅支持单个)
 *
 *  @param msg     消息类型
 *  @param param    传递的参数
 */
- (void)ps_DispatchMessageAsync: (NSString *)msg userParam: (nullable id)param;

/**
 *  添加消息监听(是异步发送消息，如有ui操作，请再重回主线程)
 *
 *  @param obj    消息监听者
 *  @param type   消息类型
 *
 *  @return
 */
- (BOOL)ps_AddReceiver:(id<PSMsgDispatcherDelegate>)obj type:(NSString * __nonnull)type;


#pragma mark - NSNotificationCenter  -

/**
 *  添加一个消息监听到通知中心
 *
 *  @param observer
 *  @param selector
 *  @param name     监听的名字
 */
void ps_AddPost(id observer, SEL selector,NSString * name);

/**
 *  通过名字删除消息监听
 *
 *  @param observer
 *  @param name     监听的名字
 */
void ps_RemovePost(id observer,NSString * name);

/**
 *  发送一个消息监听
 *
 *  @param name   监听的名字
 *  @param object 发送的数据，没有就填nil
 */
void ps_Post(NSString *name, id  _Nullable object);


#pragma mark - GCD Thread-

/**
 *  主线程
 *
 *  @param block
 */
void runBlockWithMain(dispatch_block_t block);

/**
 *  异步线程
 *
 *  @param block
 */
void runBlockWithAsync(dispatch_block_t block);

/**
 *  先异步 后同步
 *
 *  @param asyncBlock
 *  @param syncBlock
 */
void runBlock(dispatch_block_t asyncBlock, dispatch_block_t syncBlock);
@end
NS_ASSUME_NONNULL_END
