//
//  ViewController.m
//  scanQR
//
//  Created by 朱长昇 on 16/5/9.
//  Copyright © 2016年 sinoglobal. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRViewController.h"
@interface ViewController (){

    UIButton* rightBtnItem;
    UIButton* leftBtnItem;
}
@property (weak, nonatomic) IBOutlet UITextField *qrText;

@end

@implementation ViewController
+(void)initialize{
    
    //设置NavigationBar背景颜色
    [[UINavigationBar appearance] setBarTintColor:FXQColor(202, 48, 130)];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self baseSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 基本配置
- (void)baseSetting
{
    
    //3.导航项扫一扫
    rightBtnItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    rightBtnItem.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtnItem.titleLabel setTextAlignment:NSTextAlignmentRight];
    [rightBtnItem addTarget:self action:@selector(saosaoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtnItem setImage:[UIImage imageNamed:@"public_btn_sweep"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtnItem];
    
    //5.添加导航项
    self.navigationController.navigationBar.translucent = NO;
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];

    self.navigationItem.title = @"首页";
    //    取消导航半透明Translucent 
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    else {
        [[UINavigationBar appearance] setBackgroundImage:[self imageWithColor:FXQColor(202, 48, 130)] forBarMetrics:UIBarMetricsDefault];
    }
//    [self.qrText canPerformAction:@selector(textselector:) withSender:self];
}

//-(void)textselector{
//
//    if (action == @selector(paste:))//禁止粘贴
//        return NO;
//    if (action == @selector(select:))// 禁止选择
//        return NO;
//    if (action == @selector(selectAll:))// 禁止全选
//        return NO;
//    return [super canPerformAction:action withSender:sender];
//}
- (UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
#pragma mark - 点击事件
- (void)saosaoBtnClick
{
    //判断拍照权限是否开启
    NSString* mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"摄像头访问受限，请在设备的“设置-隐私-相机”中允许访问相机。" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        
        alert.delegate = self;
        
        [alert show];
    }
    else {
        ScanViewController* scanVC = [[ScanViewController alloc] init];
        [self.navigationController pushViewController:scanVC animated:YES];
    }
}
//生成二维码
- (IBAction)creatMyQR:(UIButton *)sender {
    NSLog(@"QR");
    QRViewController* qrVC = [[QRViewController alloc] init];
//    !simplyIntro || [simplyIntro isEqualToString:@""] || [simplyIntro isKindOfClass:[NSNull class]] || simplyIntro == nil
    NSLog(@"ssss%@",self.qrText.text);
    if ([self.qrText.text isEqualToString:@""]) {
        self.qrText.text = @"https://m.baidu.com";
    }
    qrVC.qrString = self.qrText.text;
    
    [self.navigationController showViewController:qrVC sender:self];
}

#pragma mark - delegate
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        NSString* version = [UIDevice currentDevice].systemVersion;
        float ver = version.floatValue;
        
        if (ver > 8.0) {
            // iOS8 之前不可用
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        else {
            //8.0之前
            NSURL* url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}
@end
