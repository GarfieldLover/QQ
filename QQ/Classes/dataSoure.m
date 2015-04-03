//
//  dataSoure.m
//  iPhoneXMPP
//
//  Created by zhangke on 15/3/10.
//  Copyright (c) 2015年 XMPPFramework. All rights reserved.
//

#import "dataSoure.h"

@implementation dataSoure
+(NSString*)name:(NSString*)jid
{
    if([jid containsString:@"zhangke"]){
        return @"张科";
    }else if([jid containsString:@"heju"]){
        return @"何举";
    }else{
        return @"张丹丹";

    }
}


@end
