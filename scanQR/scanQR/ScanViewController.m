//
//  ScanViewController.m
//  fanxiaoqi
//
//  Created by ZCS on 15/11/9.
//  Copyright © 2015年 sinoglobal. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CZWebViewController.h"

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}
@property (nonatomic, retain) UIView * line;
//session
@property (nonatomic, strong) AVCaptureSession *session;
//input
@property (nonatomic, strong) AVCaptureDeviceInput *input;
//output
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
//viewLayer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preLayer;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, assign) BOOL isLightOn;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.isLightOn = NO;
    UIImage *customImage = [UIImage imageNamed:@"public_btn_back"];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[customImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(backSettingVC)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 86, 17)];
    
    titleLabel.font = [UIFont systemFontOfSize:17];
    
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.text = @"二维码扫描与识别";
    
    self.navigationItem.titleView = titleLabel;
    
    [self setImageAndLableAndLine];
    [self scanQR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
    
    
    if (!self.session) {
        self.session = [[AVCaptureSession alloc]init];
        
    }else{
        [self.session startRunning];
    }
}
-(void)setImageAndLableAndLine{

    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-210)*0.5, 95*viewHeight, 210, 210)];
    imageView.image = [UIImage imageNamed:@"image_sweep"];
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    
    _line = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-210)*0.5, 110, 210, 2)];
    _line.backgroundColor = FXQColor(202, 48, 130);
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    UILabel *titleLable = [[UILabel alloc]init];
    self.titleLable = titleLable;
    titleLable.text = @"将二维码放入框内，即可自动扫描";
    titleLable.textColor = [UIColor whiteColor];
    [titleLable setFont:[UIFont systemFontOfSize:14]];
    titleLable.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame)+13, screenWidth, 14);
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.center = CGPointMake(imageView.center.x, titleLable.center.y);
    [self.view addSubview:titleLable];
    
    NSArray *backLocations = @[@[@0, @0, @(screenWidth), @(95*viewHeight)], @[@(screenWidth/2+105), @(95*viewHeight), @(screenWidth/2-105), @(screenHeight-95*viewHeight)], @[@0, @(95*viewHeight), @(screenWidth/2-105), @(screenHeight-95*viewHeight)], @[@(screenWidth/2-105), @(95*viewHeight+210), @(210), @(screenHeight-210-95*viewHeight)]];
    for (int i=0; i<backLocations.count; i++) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake([backLocations[i][0] doubleValue], [backLocations[i][1] doubleValue], [backLocations[i][2] doubleValue], [backLocations[i][3] doubleValue])];
        backView.backgroundColor = FXQColorRGBA(1, 1, 1, 0.5);
        [self.view addSubview:backView];
        
    }
    [self addBtnWithTitle:@"打开相册" :CGPointMake(titleLable.center.x-100, CGRectGetMaxY(self.titleLable.frame)+10):1];
    [self addBtnWithTitle:@"打开手电" :CGPointMake(titleLable.center.x+10, CGRectGetMaxY(self.titleLable.frame)+10):2];
    
    
}
-(void)addBtnWithTitle:(NSString *)title :(CGPoint)btnCenterPoint :(CGFloat)tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(btnCenterPoint.x, CGRectGetMaxY(self.titleLable.frame)+10, 100, 10);
    btn.backgroundColor = FXQColorRGBA(202, 48, 130, 0.8);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.tag = tag;
    if (tag == 1) {
        [btn addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btn addTarget:self action:@selector(openLight) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:btn];

}
-(void)openPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = true;
    [self presentViewController:picker animated:true completion:nil];

}
-(void)openLight{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]){
            
            [device lockForConfiguration:nil];
            if (self.isLightOn == NO) {
                [device setTorchMode:AVCaptureTorchModeOn];
                self.isLightOn = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                self.isLightOn = NO;
            }
            [device unlockForConfiguration];
        }else{
            
            NSLog(@"你的设备不支持");
        }
    }else{
        
        NSLog(@"没有foundation框架");
    }

}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:true completion:^{
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (!image) {
            image = info[UIImagePickerControllerOriginalImage];
        }
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        // kCIContextUseSoftwareRenderer : 软件渲染 -- 可以消除 "BSXPCMessage received error for message: Connection interrupted" 警告
        // kCIContextPriorityRequestLow : 低优先级在 GPU 渲染-- 设置为false可以加快图片处理速度
        CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(true), kCIContextPriorityRequestLow : @(false)}];
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:nil];
        CIImage *ciImage = [CIImage imageWithData:imageData];
        
        NSArray *ar = [detector featuresInImage:ciImage];
        CIQRCodeFeature *feature = [ar firstObject];
        NSLog(@"detector: %@", detector);
        NSLog(@"context: %@", feature.messageString);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"扫描结果：%@", feature.messageString ?: @"空"] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
        
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}


-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake((screenWidth-210)*0.5, 95*viewHeight+2*num, 210, 2);
        if (2*num == 210) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake((screenWidth-210)*0.5, 95*viewHeight+2*num, 210, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}
-(void)scanQR
{
    //1.creat device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //2.creat input device
    NSError *error;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

    //3.creat output device
    self.output = [[AVCaptureMetadataOutput alloc]init];
    //4.creat session
    self.session = [[AVCaptureSession alloc]init];
    //5.creat layer
    self.preLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    self.preLayer.frame = CGRectMake((screenWidth-280)*0.5,110,280,280);
    self.preLayer.frame = CGRectMake(0, 0, screenWidth, screenHeight-64);
    
    //    [self.scanView.layer addSublayer:self.preLayer];
    [self.view.layer insertSublayer:self.preLayer atIndex:0];
    //6.connection device
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }else{
        
        return;
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }else{
        
        return;
    }
    //设置源数据  AVMetadataObjectTypeQRCode 二维码
    
    //    self.output.metadataObjectTypes = [NSArray arrayWithObject:AVMetadataObjectTypeQRCode];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // get result
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    self.output.rectOfInterest = CGRectMake(95*viewHeight/screenHeight, (screenWidth-210)*0.5/screenWidth, 210/screenHeight + 20 , 210/screenWidth + 20);
    
    // start
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session startRunning];
    
    
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    [self.session stopRunning];
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects firstObject];  

        CZWebViewController *czWebView = [[CZWebViewController alloc]init];
        NSMutableString *urlStr = [NSMutableString string];
        urlStr = [NSMutableString stringWithFormat:@"%@",object.stringValue];
        if ([object.stringValue hasPrefix:@"http"]) {
            
            czWebView.webViewURL = urlStr;
            [self.navigationController pushViewController:czWebView animated:YES];

        }else{
        
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"扫描到的信息" message:urlStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        NSLog(@"%@",object.stringValue);
        
    }else{
        NSLog(@"没有数据");
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.session startRunning];
}

-(void)backSettingVC
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
