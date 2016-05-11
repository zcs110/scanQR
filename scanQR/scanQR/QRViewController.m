//
//  QRViewController.m
//  scanQR
//
//  Created by 朱长昇 on 16/5/10.
//  Copyright © 2016年 sinoglobal. All rights reserved.
//

#import "QRViewController.h"

@interface QRViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

@end

@implementation QRViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.qrImageView.image = [UIImage imageNamed:@"image_sweep"];
    //1.生成coreImage框架中的滤镜来生产二维码
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    //Value必须传入数据流
    [filter setValue:[@"https://m.baidu.com" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    //4.获取生成的图片
    CIImage *ciImg=filter.outputImage;
    //放大ciImg,默认生产的图片很小
    
    //5.设置二维码的前景色和背景颜色
    CIFilter *colorFilter=[CIFilter filterWithName:@"CIFalseColor"];
    //5.1设置默认值
    [colorFilter setDefaults];
    [colorFilter setValue:ciImg forKey:@"inputImage"];
    [colorFilter setValue:[CIColor colorWithRed:1 green:0 blue:0] forKey:@"inputColor0"];
    [colorFilter setValue:[CIColor colorWithRed:0 green:0 blue:1] forKey:@"inputColor1"];
    //5.3获取生存的图片
    ciImg=colorFilter.outputImage;
    
    CGAffineTransform scale=CGAffineTransformMakeScale(8, 8);
    ciImg=[ciImg imageByApplyingTransform:scale];
    
    //    self.imgView.image=[UIImage imageWithCIImage:ciImg];
    
    //6.在中心增加一张图片
    UIImage *img=[UIImage imageWithCIImage:ciImg];
    //7.生存图片
    //7.1开启图形上下文
    UIGraphicsBeginImageContext(img.size);
    //7.2将二维码的图片画入
    [img drawInRect:CGRectMake(10, 10, img.size.width-20, img.size.height-20)];
    //7.3在中心划入其他图片
    
        UIImage *centerImg=[UIImage imageNamed:@"Center"];
    
        CGFloat centerW=40;
        CGFloat centerH=40;
        CGFloat centerX=(img.size.width-centerImg.size.width)*0.5;
        CGFloat centerY=(img.size.height -centerImg.size.height)*0.5;
    
        [centerImg drawInRect:CGRectMake(centerX, centerY, centerW, centerH)];
    
    //7.4获取绘制好的图片
    UIImage *finalImg=UIGraphicsGetImageFromCurrentImageContext();
    
    //7.5关闭图像上下文
    UIGraphicsEndImageContext();
    //设置图片
    self.qrImageView.image = finalImg;
}

- (IBAction)writeToPhoto:(UIButton *)sender {
   
    UIImageWriteToSavedPhotosAlbum(self.qrImageView.image, self,
                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo {
    NSString *str = @"";
    if (error) {
        str = @"保存失败";
//        NSLog(@"保存失败");
    }else{
        str = @"保存成功";
//        NSLog(@"保存成功");
    }
    UIAlertView *aleart = [[UIAlertView alloc]initWithTitle:@"保存结果" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [aleart show];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
