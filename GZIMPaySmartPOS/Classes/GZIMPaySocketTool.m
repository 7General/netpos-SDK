//
//  GZIMPaySocketTool.m
//  GZIMPaySmartPOS_Example
//
//  Created by zzg on 2018/9/27.
//  Copyright © 2018年 wanghuizhou21@163.com. All rights reserved.
//

#import "GZIMPaySocketTool.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

NSString * const kNeedPayOrderNote               = @"kNeedPayOrderNote";
NSString * const kWebSocketDidOpenNote           = @"kWebSocketdidReceiveMessageNote";
NSString * const kWebSocketDidCloseNote          = @"kWebSocketDidCloseNote";
NSString * const kWebSocketdidReceiveMessageNote = @"kWebSocketdidReceiveMessageNote";

@interface GZIMPaySocketTool()<SRWebSocketDelegate>
{
    int _index;
    NSTimer * heartBeat;
    NSTimeInterval reConnectTime;
}
@property (nonatomic,strong) SRWebSocket *socket;

@property (nonatomic,copy) NSString *socketIPString;
@end

@implementation GZIMPaySocketTool

+ (GZIMPaySocketTool *)instance {
    static GZIMPaySocketTool *Instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        Instance = [[GZIMPaySocketTool alloc] init];
    });
    return Instance;
}

#pragma mark - **************** public methods
-(void)WebSocketOpenWithIP:(NSString *)IPString withSocketDelegate:(id<webSocketContectDidDelegate>)delegate {
    [self WebSocketOpenWithIP:IPString];
    self.contentDelegate = delegate;
}
-(void)WebSocketOpenWithIP:(NSString *)IPString {
    //如果是同一个url return
    if (self.socket) {
        return;
    }
    if (!IPString) {
        return;
    }
    self.socketIPString = IPString;
    self.socket = [[SRWebSocket alloc] initWithURLRequest:
                   [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:9100",IPString]]]];
    NSLog(@"请求的websocket地址：%@",self.socket.url.absoluteString);
    self.socket.delegate = self;
    [self.socket open];
}

-(void)WebSocketClose {
    if (self.socket){
        [self.socket close];
        self.socket = nil;
        //断开连接时销毁心跳
        [self destoryHeartBeat];
    }
}

#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self
- (void)sendData:(id)data {
    WeakSelf(ws);
    dispatch_queue_t queue =  dispatch_queue_create("com.senddata.queue", NULL);
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            if (weakSelf.socket.readyState == SR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
                // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
                // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
                // 代码有点长，我就写个逻辑在这里好了
                [self reConnect];
            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                NSLog(@"重连");
                [self reConnect];
            }
        } else {
            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
            NSLog(@"其实最好是发送前判断一下网络状态比较好，我写的有点晦涩，socket==nil来表示断网");
        }
    });
}

#pragma mark - **************** private mothodes
//重连机制
- (void)reConnect {
    [self WebSocketClose];
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (reConnectTime > 64) {
        // 网络状态不好
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.socket = nil;
        [self WebSocketOpenWithIP:self.socketIPString];
        NSLog(@"重连");
    });
    if (reConnectTime == 0) {
        reConnectTime = 2;
    } else {
        reConnectTime *= 2;
    }
}


//取消心跳
- (void)destoryHeartBeat {
    dispatch_main_async_safe(^{
        if (heartBeat) {
            if ([heartBeat respondsToSelector:@selector(isValid)]){
                if ([heartBeat isValid]){
                    [heartBeat invalidate];
                    heartBeat = nil;
                }
            }
        }
    })
}

//初始化心跳
- (void)initHeartBeat {
    dispatch_main_async_safe(^{
        [self destoryHeartBeat];
        //心跳设置为3分钟，NAT超时一般为5分钟
        heartBeat = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(sentheart) userInfo:nil repeats:YES];
        //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
        [[NSRunLoop currentRunLoop] addTimer:heartBeat forMode:NSRunLoopCommonModes];
    })
}

-(void)sentheart {
    //发送心跳 和后台可以约定发送什么内容  一般可以调用ping  我这里根据后台的要求 发送了data给他
    [self sendData:@"heart"];
    NSLog(@"--发送心跳");
}

//pingPong
- (void)ping{
    if (self.socket.readyState == SR_OPEN) {
        [self.socket sendPing:nil];
    }
}

#pragma mark - socket delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    //开启心跳
    [self initHeartBeat];
    NSLog(@"************************** socket 连接************************** %ld",webSocket.readyState);
    if (self.contentDelegate && [self.contentDelegate respondsToSelector:@selector(webSocketContentStatusDidChanged:)]) {
        [self.contentDelegate webSocketContentStatusDidChanged:webSocket.readyState];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    if (webSocket == self.socket) {
        NSLog(@"************************** socket 连接失败************************** ");
        _socket = nil;
        //连接失败就重连
        [self reConnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    if (webSocket == self.socket) {
        NSLog(@"************************** socket连接断开************************** ");
        NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",(long)code,reason,wasClean);
        [self WebSocketClose];
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidCloseNote object:nil];
    }
}

/*该函数是接收服务器发送的pong消息，其中最后一个是接受pong消息的，
 在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，
 用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，
 我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
 */
-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"reply===%@",reply);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message  {
    if (webSocket == self.socket) {
        NSLog(@"************************** socket收到数据了************************** ");
        NSLog(@"message:%@",message);
        if (self.contentDelegate && [self.contentDelegate respondsToSelector:@selector(websocketDidReceiveMessage:)]) {
            [self.contentDelegate websocketDidReceiveMessage:message];
        }
    } else {
        NSLog(@"************************** socket不是当前socket接受数据************************** ");
    }
}

#pragma mark - **************** setter getter
- (SRReadyState)socketReadyState {
    return self.socket.readyState;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
