//
//  GZIMPaySocketTool.h
//  GZIMPaySmartPOS_Example
//
//  Created by zzg on 2018/9/27.
//  Copyright © 2018年 wanghuizhou21@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>



@protocol webSocketContectDidDelegate <NSObject>

/**
 长连接连接状态

 @param status 连接状态
 */
- (void)webSocketContentStatusDidChanged:(SRReadyState)status;

/**
 接受数据

 @param message 接受的数据
 */
- (void)websocketDidReceiveMessage:(id)message;

@end

@interface GZIMPaySocketTool : NSObject


@property (nonatomic, weak) id<webSocketContectDidDelegate>  contentDelegate;
// 获取连接状态
@property (nonatomic,assign,readonly) SRReadyState socketReadyState;

+ (GZIMPaySocketTool *)instance;

/**
 开启长连接

 @param IPString ip地址
 */
-(void)WebSocketOpenWithIP:(NSString *)IPString withSocketDelegate:(id<webSocketContectDidDelegate>)delegate;

/* 关闭连接 */
- (void)WebSocketClose;

/**
 发送数据

 @param data 数据
 */
- (void)sendData:(id)data;


@end
