//
//  GZIMPaySocketTool.h
//  GZIMPaySmartPOS_Example
//
//  Created by zzg on 2018/9/27.
//  Copyright © 2018年 wanghuizhou21@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>

extern NSString * const kNeedPayOrderNote;
extern NSString * const kWebSocketDidOpenNote;
extern NSString * const kWebSocketDidCloseNote;
extern NSString * const kWebSocketdidReceiveMessageNote;


@interface GZIMPaySocketTool : NSObject


// 获取连接状态
@property (nonatomic,assign,readonly) SRReadyState socketReadyState;

+ (GZIMPaySocketTool *)instance;

- (void)WebSocketOpenWithURLString:(NSString *)urlString;//开启连接
- (void)WebSocketClose;//关闭连接
- (void)sendData:(id)data;//发送数据


@end
