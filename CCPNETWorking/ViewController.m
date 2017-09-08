//
//  ViewController.m
//  CCPNETWorking
//
//  Created by Ceair on 17/9/6.
//  Copyright © 2017年 Ceair. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NetWorkingManager.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgv;
@property (nonatomic, strong) NSData *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NetWorkingManager *manager = [[NetWorkingManager alloc] initRqWith:@"https://efbplus.ceair.com:600/muws/adinfo" pragma:nil style:@"get"];
    manager.responseIsJson = NO;
    manager.successBlock = ^(id rsp) {
        NSLog(@"rsp--%@",rsp);
    };
    manager.failureBlock = ^(NSError *error) {
        NSLog(@"error--%@",[error localizedDescription]);
    };
    [manager startTask];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
