//
//  GZIMPayMainViewController.m
//  GZIMPaySmartPOS_Example
//
//  Created by zzg on 2018/9/27.
//  Copyright © 2018年 wanghuizhou21@163.com. All rights reserved.
//

#define AP_SUBVIEW_XGAP   (20.0f)
#define AP_SUBVIEW_WIDTH  (([UIScreen mainScreen].bounds.size.width) - 2*(AP_SUBVIEW_XGAP))
#define AP_BUTTON_HEIGHT  (60.0f)

#import "GZIMPayMainViewController.h"
#import <GZIMPaySmartPOS/AES.h>
#import <GZIMPaySmartPOS/GZIMPaySocketTool.h>
#import <GZIMPaySmartPOS/NSDictionary+json.h>



@interface GZIMPayMainViewController ()

@property (nonatomic, strong) UITextView * logInfo;

@end

@implementation GZIMPayMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"招商银行POS";
    
    
    CGFloat originalPosY = [UIApplication sharedApplication].statusBarFrame.size.height + 80.0f;
    [self generateBtnWithTitle:@"长连接连接" selector:@selector(createLongLink) posy:originalPosY];
    
    originalPosY += (AP_BUTTON_HEIGHT + 20);
    [self generateBtnWithTitle:@"设备存活" selector:@selector(DeviceAlive) posy:originalPosY];

    originalPosY += (AP_BUTTON_HEIGHT + 20);
    [self generateBtnWithTitle:@"消费接口" selector:@selector(shopAction) posy:originalPosY];
    
    originalPosY += (AP_BUTTON_HEIGHT + 20);
    [self generateBtnWithTitle:@"撤销接口" selector:@selector(backAction) posy:originalPosY];
    
    originalPosY += (AP_BUTTON_HEIGHT + 20);
    [self generateBtnWithTitle:@"取消交易接口" selector:@selector(cancleAction) posy:originalPosY];
    
    self.logInfo = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150)];
    self.logInfo.textColor = [UIColor grayColor];
    [self.view addSubview:self.logInfo];
    
    NSLog(@"%p",__builtin_return_address(0));
    
}
- (void)cancleAction {
    NSDictionary * cancleInfo =
        @{
        @"directive": @"IpCancelPay",
        @"data":
            @{
            @"mhtOrderNo": @"82ur32jr923jr32rj23r2"
            }
        };
    NSString * encryText = [AES encrypt:[cancleInfo gzim_toJsonString]];
    [[GZIMPaySocketTool instance] sendData:encryText];
}
- (void)backAction {
    NSDictionary * backinfo =
    @{
        @"directive": @"IpPayRollback",
        @"transData":
            @{
            @"ipOrderNo": @"82ur32jr923jr32rj23r2"
            },
        @"mhtCustomData":
            @{
            @"mhtReserved": @"xxxxxxxxxxxxx"
            }
        };
    NSString * encryText = [AES encrypt:[backinfo gzim_toJsonString]];
    [[GZIMPaySocketTool instance] sendData:encryText];
    
}
- (void)shopAction {
    NSDictionary * shopInfo = @{@"directive": @"IpPay",
                                @"transData":
                                    @{
                                        @"mhtOrderNo": @"123129898234509234509324093480983409",
                                        @"payType": @"01",
                                        @"orderPrice": @"1",
                                        @"orderName": @"零售 PC 订单"
                                        },
        @"mhtCustomData":
                                    @{
                                        @"mhtReserved": @"xxxxxxxxxxxxx"
                                    }
                                };
    NSString * encryText = [AES encrypt:[shopInfo gzim_toJsonString]];
    [[GZIMPaySocketTool instance] sendData:encryText];
}

- (void)DeviceAlive {
    NSDictionary * deviceAlive = @{@"directive":@"IpAlive",@"call":@"ping"};
    NSString * encryText = [AES encrypt:[deviceAlive gzim_toJsonString]];
    [[GZIMPaySocketTool instance] sendData:encryText];
}

/* 设备激活 */
- (void)createLongLink {
     [[GZIMPaySocketTool instance] WebSocketOpenWithIP:@"172.20.10.7" withSocketDelegate:(id<webSocketContectDidDelegate>)self];
}


#pragma mark - SocketDelegate
/* 长连接连接状态 */
- (void)webSocketContentStatusDidChanged:(SRReadyState)status {
    NSLog(@"----------------%ld",status);
    if (SR_OPEN == status) {
        NSLog(@"-连接成功");
    } else {
        NSLog(@"-连接非成功");
    }
}
/* 接受数据 */
- (void)websocketDidReceiveMessage:(id)message {
    NSLog(@"--接受数据：%@",message);
    NSLog(@"---->>%@",[AES decrypt:message]);
    self.logInfo.text = [AES decrypt:message];
}





- (void)generateBtnWithTitle:(NSString*)title selector:(SEL)selector posy:(CGFloat)posy {
    UIButton* tmpBtn = [[UIButton alloc]initWithFrame:CGRectMake(AP_SUBVIEW_XGAP, posy, AP_SUBVIEW_WIDTH, AP_BUTTON_HEIGHT)];
    tmpBtn.backgroundColor = [UIColor colorWithRed:81.0f/255.0f green:141.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    tmpBtn.layer.masksToBounds = YES;
    tmpBtn.layer.cornerRadius = 4.0f;
    [tmpBtn setTitle:title forState:UIControlStateNormal];
    [tmpBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tmpBtn];
}


@end
