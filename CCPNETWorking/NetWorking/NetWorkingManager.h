//
//  NetWorkingManager.h
//  CCPNETWorking
//
//  Created by Ceair on 17/9/6.
//  Copyright © 2017年 Ceair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#define RQ_TEST
#ifdef RQ_TEST
#define rq_log(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define rq_log(...)
#endif


typedef void(^request_success)(id rsp);
typedef void(^request_failure)(NSError *errorMsg);
typedef void(^request_progress)(NSProgress *progress);

@interface NetWorkingManager : NSObject


//请求成功回调
@property (nonatomic, copy) request_success successBlock;
//失败回调
@property (nonatomic, copy) request_failure failureBlock;
//过程回调
@property (nonatomic, copy) request_progress progressBlock;
//接收数据类型
@property (nonatomic, strong) NSArray *accTypes;
//超时时间设置 默认三十秒
@property (nonatomic,assign) NSTimeInterval timeout;
//请求参数是否为json格式 默认为YES
@property (nonatomic, assign) BOOL requestIsJson;
//返回数据是否为json格式 默认为YES
@property (nonatomic, assign) BOOL responseIsJson;
//文件
@property (nonatomic, strong) NSArray <NSData *> *files;
//文件名
@property (nonatomic, strong) NSArray <NSString *> *fileNames;
//文件类型
@property (nonatomic, strong) NSArray <NSString *> *fileTypes;
//后台对应的表单名
@property (nonatomic, strong) NSArray <NSString *> *names;
//文件下载存储路径
@property (nonatomic, strong) NSString *saveFilePath;


/**
 初始化请求类

 @param url 请求地址
 @param dic 请求参数
 @param style 请求方式 默认为get get,post,upload,download
 @return 返回请求类
 */
- (instancetype)initRqWith:(NSString *)url pragma:(NSDictionary *)dic style:(NSString *)style;

/**
 * 开始请求
 */
- (void)startTask;

/**
 * 开始请求

 @param sc 成功回调
 */
- (void)startTask:(void(^)(id rsp))sc;

/**
 * 开始请求

 @param sc 成功回调
 @param fail 失败回调
 */
- (void)startTask:(void(^)(id rsp))sc failed:(void(^)(NSError *error))fail;

/**
 * 开始请求

 @param sc 成功回调
 @param fail 失败回调
 @param progress 进度回调
 */
- (void)startTask:(void(^)(id rsp))sc failed:(void(^)(NSError *error))fail progress:(void(^)(NSProgress *progress))progress;
@end
