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
    self.title = @"JackYoung's";
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 100)];
    _button.backgroundColor = [UIColor blueColor];
    [_button setTitle:@"将下列报文转换成NSAttributedString" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(onButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(40, _button.frame.origin.y + _button.frame.size.height + 50, self.view.frame.size.width - 80, 200)];
    _label.backgroundColor = [UIColor redColor];
    _label.text = @"<div>JackYoung's</div><img src=\"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png\" style=\"width:99%\"/><div>如果帮到你，给一个🌟🌟🌟🌟🌟哦</div><img src=\"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png\" style=\"width:99%\"/>";
    _label.adjustsFontSizeToFitWidth = true;
    _label.numberOfLines = 0;
    [self.view addSubview:_label];
}

- (void)onButtonTouched {
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
