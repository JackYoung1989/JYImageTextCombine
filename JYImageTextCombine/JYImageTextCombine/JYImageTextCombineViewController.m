//
//  TSServiceDetailViewController.m
//  TS_iOS
//
//  Created by Jack Young on 2017/10/17.
//  Copyright © 2017年 ZhouYingbin. All rights reserved.
//

#import "JYImageTextCombineViewController.h"
#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

#define appDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define kBaseUrl @"http://sj.taoshangapp.com"

@interface JYImageTextCombineViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *serviceContentTextView;
@property (nonatomic,strong)NSMutableArray *imageUploadedArray;//图片数组
@property (nonatomic,strong)NSMutableArray *imageUploadedNameArray;//所有上传图片名字数组（上传图片之后，返回的名字）
@property (nonatomic,strong)NSMutableArray *imageDownloadedNameArray;//之前上传的oldHtmlString解析出来的图片地址

@property (nonatomic,strong)NSMutableArray *imageMarkArray;//图片对应的记号`0`表示第0张图片

@property (nonatomic,assign) BOOL hasEndDiv;
@property (nonatomic,assign) BOOL hasHeadDiv;
@property (nonatomic,assign) NSInteger imageIndex;
@property (nonatomic,strong) NSMutableString *resultString;//拼接之后的字符串

@property (nonatomic,strong)UIImagePickerController *pickerController;
@property (nonatomic,assign)CGFloat imageWidth;
@property (nonatomic,assign)CGFloat wordFont;

//光标位置
@property (nonatomic,assign)NSRange curserRange;

@end

@implementation JYImageTextCombineViewController

- (void)dealloc {
    _imageUploadedArray = nil;
    _imageUploadedNameArray = nil;
    _imageDownloadedNameArray = nil;
    _imageMarkArray = nil;
    _pickerController = nil;
    _returnBlock = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图文并排";
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _wordFont = 30.0;
    _imageWidth = 150;
    
    _resultString = [[NSMutableString alloc] init];
    _imageUploadedArray = [[NSMutableArray alloc] init];
    _imageUploadedNameArray = [[NSMutableArray alloc] init];
    _imageDownloadedNameArray = [[NSMutableArray alloc] init];
    
    _imageMarkArray = [[NSMutableArray alloc] init];
    _serviceContentTextView.font = [UIFont systemFontOfSize:_wordFont];
    _serviceContentTextView.delegate = self;
    _serviceContentTextView.returnKeyType = UIReturnKeyDone;
    [_serviceContentTextView setFont:[UIFont systemFontOfSize:60]];

    if (_oldHtmlString != nil && ![_oldHtmlString isEqualToString:@""]) {
        [self setOldStringToAttributeString:_oldHtmlString];
    }
    
    if (_pickerController == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _pickerController = [[UIImagePickerController alloc] init];
            _pickerController.view.backgroundColor = [UIColor redColor];
            _pickerController.delegate = self;
            _pickerController.allowsEditing = YES;
        });
    }
    NSLog(@"光标位置%ld——%ld",_curserRange.location,_curserRange.length);
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.view endEditing:true];
        return NO;
    }

    return true;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"光标位置%ld——%ld",textView.selectedRange.location,textView.selectedRange.length);
    _curserRange = textView.selectedRange;
}

- (void)setOldStringToAttributeString:(NSString *)oldHtmlString {
    NSString *oldString1 = oldHtmlString;
    oldString1 = [oldString1 stringByReplacingOccurrencesOfString:@"</div>" withString:@"<div>"];
    oldString1 = [oldString1 stringByReplacingOccurrencesOfString:@"<img src=\"" withString:@"<div>"];
    oldString1 = [oldString1 stringByReplacingOccurrencesOfString:@"\" style=\"width:99%\"/>" withString:@"<div>"];
    oldString1 = [oldString1 stringByReplacingOccurrencesOfString:@"<div><div>" withString:@"<div>"];
    NSArray *resultArray = [oldString1 componentsSeparatedByString:@"<div>"];
    NSMutableAttributedString *resultAttributedString = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i < resultArray.count; i ++) {
        NSLog(@"(%@)",resultArray[i]);
        if (![resultArray[i] isEqualToString:@""]) {
            if ([(NSString *)resultArray[i] containsString:@"http"]) {
                NSString *tempString = resultArray[i];
                tempString = [tempString stringByReplacingOccurrencesOfString:appDelegate.webImageDir withString:@""];
                [_imageDownloadedNameArray addObject:tempString];
                
                NSTextAttachment *attch = [[NSTextAttachment alloc] init];
                // 表情图片
                attch.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:resultArray[i]]]];
                // 设置图片大小
                attch.bounds = CGRectMake(0, 0, _imageWidth, _imageWidth);
                
                // 创建带有图片的富文本
                NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
                [resultAttributedString appendAttributedString:string];
            } else {
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:resultArray[i]];
                [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:_wordFont] range:NSMakeRange(0, [string length])];
                [resultAttributedString appendAttributedString:string];
            }
        }
    }
    _serviceContentTextView.attributedText = resultAttributedString;
    [_serviceContentTextView setFont:[UIFont systemFontOfSize:_wordFont]];
}

- (void)setOldHtmlString:(NSString *)oldHtmlString {
    _oldHtmlString = oldHtmlString;
}

//将HTML字符串转化为NSAttributedString富文本字符串
- (NSAttributedString *)attributedStringWithHTMLString:(NSString *)htmlString
{
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                               NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding) };
    
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    return [[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];
}

- (IBAction)okButtonTouched:(id)sender {
    _hasEndDiv = false;
    _hasHeadDiv = false;
    _imageIndex = 0;
    
    NSAttributedString * att = _serviceContentTextView.attributedText;
    NSMutableAttributedString * resultAtt = [[NSMutableAttributedString alloc]initWithAttributedString:att];
//    __weak __block UITextView * copy_self = self; //枚举出所有的附件字符串
    [att enumerateAttributesInRange:NSMakeRange(0, att.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSTextAttachment * textAtt = attrs[@"NSAttachment"];//从字典中取得那一个图片
        if (textAtt) {
            if (self.hasEndDiv == true) {
                [_resultString insertString:@"<div>" atIndex:0];
                self.hasHeadDiv = true;
                self.hasEndDiv = false;
            }
            
            UIImage * image = textAtt.image;
            [_resultString insertString:[NSString stringWithFormat:@"`%ld`",self.imageIndex] atIndex:0];
            [self.imageMarkArray addObject:[NSString stringWithFormat:@"`%ld`",self.imageIndex]];
            [self.imageUploadedArray addObject:image];
            self.imageIndex ++;
        } else {
            if (self.hasEndDiv == false) {
                [_resultString insertString:@"</div>" atIndex:0];
                self.hasEndDiv = true;
            }
            [_resultString insertString:[resultAtt attributedSubstringFromRange:range].string atIndex:0];
        }
    }];
    if (_hasEndDiv == true) {
        [_resultString insertString:@"<div>" atIndex:0];
    }
    NSLog(@"%@",_resultString);
    //上传图片，拼接字符串
    if (self.imageUploadedArray.count > 0) {
        [self uploadImageArray];
    } else {
        [self deleteImageFromArray:_imageDownloadedNameArray];//如果图片都删掉了之后，直接清除掉之前所有的图片
        if (self.returnBlock != nil) {
            self.returnBlock(self.resultString);
            [self.navigationController popViewControllerAnimated:true];
        }
    }
}

- (void)uploadImageArray {//_imageUploadedArray,_imageMarkArray
    _imageIndex = 0;//用来计数
    [SVProgressHUD showInfoWithStatus:@"图片上传中..."];
    for (int i = 0; i < _imageUploadedArray.count; i ++) {
        [self uploadHeadImage:_imageUploadedArray[i] imageIndex:i];
    }
}

- (void)uploadHeadImage:(UIImage *)image imageIndex:(NSInteger)index{
    //上传地址
    NSString *postUrl = [NSString stringWithFormat:@"%@/new/index.php?c=merchant&a=saveImg",kBaseUrl];
    NSData *data = UIImageJPEGRepresentation(image,1.0);
    NSString *pictureDataString=[data base64Encoding];
    NSDictionary *dict = @{@"content":[NSString stringWithFormat:@"data:image/jpg;base64,%@",pictureDataString]};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:postUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject[@"code"] boolValue]) {
            [_imageUploadedNameArray addObject:responseObject[@"fileName"]];//返回的是文件的名字，不是全路径
            
            NSArray *array = [self.resultString componentsSeparatedByString:self.imageMarkArray[index]];
            NSString *imageDir = appDelegate.webImageDir;
            if (array.count == 1) {
                if (index != 0) {//说明是最前面的一个image
                    self.resultString = [NSMutableString stringWithFormat:@"<img src=\"%@%@\" style=\"width:99%%\"/>%@",imageDir,responseObject[@"fileName"],array[0]];
                } else {//说明是最后面的一个image
                    self.resultString = [NSMutableString stringWithFormat:@"%@<img src=\"%@%@\" style=\"width:99%%\"/>",array[0],imageDir,responseObject[@"fileName"]];
                }
            } else {
                self.resultString = [NSMutableString stringWithFormat:@"%@<img src=\"%@%@\" style=\"width:99%%\"/>%@",array[0],imageDir,responseObject[@"fileName"],array[1]];
            }
            _imageIndex ++;
            if (_imageIndex == _imageUploadedArray.count) {//图片都上传完了
                [SVProgressHUD dismiss];
                NSLog(@"result is _____:%@",self.resultString);
                
                //删除在编辑中删掉的图片
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < _imageDownloadedNameArray.count; i ++) {
                    for (int j = 0; j < _imageUploadedNameArray.count; j ++) {
                        if ([_imageDownloadedNameArray[i] isEqualToString:_imageUploadedNameArray[j]]) {
                            continue;
                        }
                    }
                    [tempArray addObject:_imageDownloadedNameArray[i]];
                }
                if (tempArray.count > 0) {//删除剩下的图片
                    [self deleteImageFromArray:tempArray];
                }
                
                //上传内容
                if (self.returnBlock != nil) {
                    self.returnBlock(self.resultString);
                    [self.navigationController popViewControllerAnimated:true];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败");
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
    }];
}

- (void)deleteImageFromArray:(NSArray *)imageArray {
    NSLog(@"删除了%ld张图片",imageArray.count);
    if (imageArray == nil || imageArray.count == 0) {
        return;
    }
    NSMutableString *tempString = [[NSMutableString alloc] init];
    for (int i = 0; i < imageArray.count; i ++) {//删除的照片名称（非全路径），用逗号隔开
        if (i != imageArray.count - 1) {
            [tempString appendString:[NSString stringWithFormat:@"%@,",imageArray[i]]];
        } else {
            [tempString appendString:[NSString stringWithFormat:@"%@",imageArray[i]]];
        }
    }
    
    [SVProgressHUD showInfoWithStatus:@"正在删除..."];
    //上传地址
    NSString *postUrl = [NSString stringWithFormat:@"%@/new/index.php?c=merchant&a=delImg2",kBaseUrl];
    NSDictionary *dict = @{@"imgDate":appDelegate.webImageDir,
                           @"imgName":tempString
                           };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:postUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //记录返回的图片名字
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败");
        [SVProgressHUD dismiss];
    }];
}

#pragma mark ------------图片处理------------------
//缩小图片
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (IBAction)addImgButtonTouched:(id)sender {

    UIAlertController*ZhengC=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction*XiangCe=[UIAlertAction actionWithTitle:@"从手机相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:_pickerController animated:YES completion:nil];
    }];
    UIAlertAction*ZhaoXiang=[UIAlertAction actionWithTitle:@"打开照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:_pickerController animated:YES completion:nil];
        
    }];
    UIAlertAction*  Cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [ZhengC addAction:Cancel];
    [ZhengC addAction:XiangCe];
    [ZhengC addAction:ZhaoXiang];
    [self presentViewController:ZhengC animated:YES completion:nil];
}

#pragma mark ------ UIImagePickerControllerDelegate ----------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"选择了一张图片");
    UIImage *userImage = [self fixOrientation:info[UIImagePickerControllerEditedImage]];
    userImage = [self scaleImage:userImage toScale:1];
    [_pickerController dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithAttributedString:_serviceContentTextView.attributedText];
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    // 表情图片
    attch.image = userImage;
    // 设置图片大小
    attch.bounds = CGRectMake(0, 0, _imageWidth, _imageWidth);
    
    // 创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    [attri replaceCharactersInRange:_curserRange withAttributedString:string];
    
    // 用label的attributedText属性来使用富文本
    _serviceContentTextView.attributedText = attri;
    [_serviceContentTextView setFont:[UIFont systemFontOfSize:_wordFont]];
}

@end
