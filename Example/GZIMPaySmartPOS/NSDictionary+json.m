//
//  NSDictionary+json.m
//  GZIMPaySmartPOS_Example
//
//  Created by zzg on 2018/9/27.
//  Copyright © 2018年 wanghuizhou21@163.com. All rights reserved.
//

#import "NSDictionary+json.h"

@implementation NSDictionary (json)


- (NSString *)gzim_toJsonString
{
    if (!self) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) {
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end
