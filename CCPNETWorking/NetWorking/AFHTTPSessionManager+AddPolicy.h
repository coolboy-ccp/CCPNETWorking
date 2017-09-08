//
//  AFHTTPSessionManager+AddPolicy.h
//  CCPNETWorking
//
//  Created by Ceair on 17/9/8.
//  Copyright © 2017年 Ceair. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface AFHTTPSessionManager (AddPolicy)


/**
 设置自建证书

 @param fileName 自建证书名称
 */
- (void)addPolicy:(NSString *)fileName;

@end
