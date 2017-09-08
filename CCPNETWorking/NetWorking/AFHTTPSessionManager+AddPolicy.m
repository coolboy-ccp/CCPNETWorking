//
//  AFHTTPSessionManager+AddPolicy.m
//  CCPNETWorking
//
//  Created by Ceair on 17/9/8.
//  Copyright © 2017年 Ceair. All rights reserved.
//

#import "AFHTTPSessionManager+AddPolicy.h"

@implementation AFHTTPSessionManager (AddPolicy)

- (void)addPolicy:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@".cer"];
    NSError *error = nil;
    NSData *cerData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
    NSAssert(error==nil, error.localizedDescription);
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey withPinnedCertificates:[NSSet setWithObject:cerData]];
    self.securityPolicy = policy;
}

@end
