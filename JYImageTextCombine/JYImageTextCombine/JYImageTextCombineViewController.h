//
//  TSServiceDetailViewController.h
//  TS_iOS
//
//  Created by Jack Young on 2017/10/17.
//  Copyright © 2017年 ZhouYingbin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^callBackBlock)(NSString *);
@interface JYImageTextCombineViewController : UIViewController
/*
 * oldHtmlString:包含两种标签<div>和<img>两种标签，文本用<div>，图片用<img src="http://...." style=width:99%/>表示
 * 每个标签中间没有空格
 * returnBlock:是返回的字符串格式同上
 */
@property (nonatomic,copy) NSString *oldHtmlString;
@property (nonatomic,copy) callBackBlock returnBlock;

@end
