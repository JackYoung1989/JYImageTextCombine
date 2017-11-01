//
//  ViewController.m
//  JYImageTextCombine
//
//  Created by Jack Young on 2017/11/1.
//  Copyright © 2017年 Jack Young. All rights reserved.
//

#import "ViewController.h"
#import "JYImageTextCombineViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(40, 200, 200, 100)];
    button.center = self.view.center;
    button.backgroundColor = [UIColor greenColor];
    [button addTarget:self action:@selector(onButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)onButtonTouched {
    JYImageTextCombineViewController *serviceDetailViewController = [[JYImageTextCombineViewController alloc] init];
    /*
     * oldHtmlString:包含两种标签<div>和<img>两种标签，文本用<div>，图片用<img src="http://...." style=width:99%/>表示
     * 每个标签中间没有空格
     * returnBlock:是返回的字符串格式同上
     */
    serviceDetailViewController.oldHtmlString = @"<div>helloworld</div><img src=\"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png\" style=\"width:99%\"/><div>你好</div><img src=\"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png\" style=\"width:99%\"/>";
    serviceDetailViewController.returnBlock = ^(NSString *resultString) {
        NSLog(@"resultString______%@",resultString);
    };
    [self.navigationController pushViewController:serviceDetailViewController animated:true];
}

@end
