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

@property (nonatomic,strong)UIButton *button;
@property (nonatomic,strong)UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图文并排";
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 250, self.view.frame.size.width - 40, 50)];
    _button.backgroundColor = [UIColor systemGreenColor];
    _button.layer.cornerRadius = 10;
    _button.clipsToBounds = true;
    [_button setTitle:@"将XML转换成NSAttributedString" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(onButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 170, 300, 20)];
    messageLabel.text = @"需要转化的内容，如下";
    messageLabel.textColor = [UIColor systemGreenColor];
    [self.view addSubview:messageLabel];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width - 40, 300)];
    _label.backgroundColor = [UIColor whiteColor];
    _label.text = @"<div>If this demo helps you, please give me a buling buling star at github,thanks!😄😄😊😊\n </div><img src=\"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png\" style=\"width:99%\"/><div>如果帮到你，给一个🌟🌟🌟🌟🌟哦~</div>";
    _label.numberOfLines = 0;
    _label.layer.cornerRadius = 10;
//    _label.clipsToBounds = true;
    _label.layer.borderColor = [UIColor greenColor].CGColor;
    _label.layer.borderWidth = 2;
    [self.view addSubview:_label];
}

- (void)onButtonTouched {
    NSLog(@"button点击了");
    JYImageTextCombineViewController *serviceDetailViewController = [[JYImageTextCombineViewController alloc] init];
    /*
     * oldHtmlString:包含两种标签<div>和<img>两种标签，文本用<div>，图片用<img src="http://...." style=width:99%/>表示
     * 每个标签中间没有空格
     * returnBlock:是返回的字符串格式同上
     */
    serviceDetailViewController.oldHtmlString = _label.text;
    serviceDetailViewController.returnBlock = ^(NSString *resultString) {
        NSLog(@"resultString______%@",resultString);
        _label.text = [NSString stringWithFormat:@"%@",resultString];
    };
    [self.navigationController pushViewController:serviceDetailViewController animated:true];
}

@end
