//
//  NetWorkingManager.m
//  CCPNETWorking
//
//  Created by Ceair on 17/9/6.
//  Copyright © 2017年 Ceair. All rights reserved.
//



#import "NetWorkingManager.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface NetWorkingManager()
@property (nonatomic, copy) request_success rq_success;
@property (nonatomic, copy) request_failure rq_failure;
@property (nonatomic, copy) request_progress rq_progress;
@property (nonatomic) NSString *rq_url;
@property (nonatomic) NSDictionary *rq_dic;
@property (nonatomic) NSString *rq_style;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@end

@implementation NetWorkingManager

- (instancetype)initRqWith:(NSString *)url pragma:(NSDictionary *)dic style:(NSString *)style {
    if (self = [super init]) {
        self.rq_url = url;
        self.rq_dic = dic;
        self.rq_style = style?:@"get";
        self.timeout = 60;
        self.accTypes = @[@"text/plain"];
        self.requestIsJson = YES;
        self.responseIsJson = YES;
        _manager = [AFHTTPSessionManager manager];
    }
    return self;
}

- (request_success)rq_success {
    if (!_rq_success) {
        __weak typeof(self)wk = self;
        _rq_success = ^(id rsp) {
            if (wk.successBlock) {
                wk.successBlock(rsp);
            }
        };
    }
    return _rq_success;
}

- (request_failure)rq_failure {
    if (!_rq_failure) {
        __weak typeof(self)wk = self;
        _rq_failure = ^(NSError *error) {
            if (wk.failureBlock) {
                wk.failureBlock(error);
            }
        };
    }
    return _rq_failure;
}

- (request_progress)rq_progress {
    if (!_rq_progress) {
        __weak typeof (self)wk = self;
        _rq_progress = ^(NSProgress *progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (wk.progressBlock) {
                    wk.progressBlock(progress);
                }
            });
        };
    }
    return _rq_progress;
}

- (void)setRequestIsJson:(BOOL)requestIsJson {
    _manager.requestSerializer = requestIsJson?[AFJSONRequestSerializer serializer]:[AFHTTPRequestSerializer serializer];
}

- (void)setResponseIsJson:(BOOL)responseIsJson {
    _manager.responseSerializer = responseIsJson?[AFJSONResponseSerializer serializer]:[AFHTTPResponseSerializer serializer];
}

- (void)setRq_url:(NSString *)rq_url {
    _rq_url = [rq_url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (void)setTimeout:(NSTimeInterval)timeout {
    _manager.requestSerializer.timeoutInterval = timeout;
}

- (void)setAccTypes:(NSMutableArray *)accTypes {
    NSMutableSet *aTps = [NSMutableSet setWithSet:_manager.responseSerializer.acceptableContentTypes];
    [aTps addObjectsFromArray:accTypes];
    _manager.responseSerializer.acceptableContentTypes = aTps.copy;
}

- (void)startTask {
    if ([_rq_style isEqualToString:@"get"]) {
        [self get];
    }
    else if ([_rq_style isEqualToString:@"post"]) {
        [self post];
    }
    else if ([_rq_style isEqualToString:@"upload"]) {
        [self upload];
    }
    else if ([_rq_style isEqualToString:@"download"]) {
        [self download];
    }
}

- (void)startTask:(void(^)(id rsp))sc {
    [self startTask];
    _successBlock = sc;
}

- (void)startTask:(void(^)(id rsp))sc failed:(void(^)(NSError *error))fail {
    [self startTask];
    _successBlock = sc;
    _failureBlock = fail;
}

- (void)startTask:(void(^)(id rsp))sc failed:(void(^)(NSError *error))fail progress:(void(^)(NSProgress *progress))progress {
    [self startTask];
    _successBlock = sc;
    _failureBlock = fail;
    _progressBlock = progress;
}

- (void)post {
    [_manager POST:_rq_url parameters:_rq_dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        rq_log(@"request:%@\nresponse:%@",task.currentRequest,resonseObject);
        self.rq_success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        rq_log(@"%@",[error localizedDescription]);
        self.rq_failure(error);
    }];
}

- (void)get {
    [_manager GET:_rq_url parameters:_rq_dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        rq_log(@"request:%@\nresponse:%@",task.currentRequest,resonseObject);
        self.rq_success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        rq_log(@"%@",[error localizedDescription]);
        self.rq_failure(error);
    }];
}

- (void)upload {
    [_manager POST:_rq_url parameters:_rq_dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [_files enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [formData appendPartWithFileData:obj name:_names[idx] fileName:_fileNames[idx] mimeType:_fileTypes[idx]];
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        self.rq_progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        rq_log(@"request:%@\nresponse:%@",task.currentRequest,resonseObject);
        self.rq_success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        rq_log(@"%@",[error localizedDescription]);
        self.rq_failure(error);
    }];
}

- (void)download {
    NSURLRequest *rq = [NSURLRequest requestWithURL:[NSURL URLWithString:_rq_url]];
    [_manager downloadTaskWithRequest:rq progress:^(NSProgress * _Nonnull downloadProgress) {
        self.rq_progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:_saveFilePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            rq_log(@"%@",[error localizedDescription]);
            self.rq_failure(error);
        }
        else {
            rq_log(@"request:%@\nresponse:%@",task.currentRequest,resonseObject);
            self.rq_success(response);
        }
    }];
}


@end
