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

#import "AES.h"
#import "NSDictionary+json.h"
#import "GZIMPaySocketTool.h"

@interface GZIMPayMainViewController ()


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
    
//    NSString * text = @"6666666666";
//    NSString * encryText = [AES encrypt:text password:@"1234567812345678"];
//    NSLog(@"--->>>加密数据%@",encryText);
//    NSString * decryText = [AES decrypt:encryText password:@"1234567812345678"];
//    NSLog(@"--->>>>解密数据%@",decryText);
    
    
    
    
}
- (void)DeviceAlive {
    NSDictionary * deviceAlive = @{@"directive":@"IpAlive",@"call":@"ping"};
    NSString * encryText = [AES encrypt:[deviceAlive gzim_toJsonString]];
    [[GZIMPaySocketTool instance] sendData:encryText];
}

/* 设备激活 */
- (void)createLongLink {
     [[GZIMPaySocketTool instance] WebSocketOpenWithURLString:@"ws://172.20.10.7:9100"];
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
