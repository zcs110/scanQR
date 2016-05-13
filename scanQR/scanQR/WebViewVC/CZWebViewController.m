//
//  CZWebViewController.m
//  fanxiaoqi
//
//  Created by ZCS on 15/11/9.
//  Copyright © 2015年 sinoglobal. All rights reserved.
//

#import "CZWebViewController.h"
@interface CZWebViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *czWebView;
/** 没有网络 */
//@property (nonatomic, copy) NSString *netWorkName;
//@property (nonatomic, strong) UIView *noNetWorkView;
//@property (nonatomic, assign, getter=isShowNoNetWorkView) BOOL showNetWorkView;
/** 商家名 */
@property (nonatomic, copy) NSString *businessName;
/** 优惠券名 */
@property (nonatomic, copy) NSString *couponName;
/** 优惠券ID */
@property (nonatomic, copy) NSString *coupon_IDStr;
/** 优惠券图片 */
@property (nonatomic, strong) UIImage *couponImage;

@end


@implementation CZWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.czWebView.opaque = NO;
    [self baseSetting];
    [self loadWebRequest];

}
#pragma mark - 没有网络代理方法

-(void)loadWebRequest
{
    //详情页面
    NSURL *url = [NSURL URLWithString:self.webViewURL];

    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];

    self.czWebView.delegate = self;

    [self.czWebView loadRequest:request];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)baseSetting
{
    //导航设置
    self.navigationItem.title = @"网站";
    [self setBackBarButton];

}
-(void)setBackBarButton{
    
    //取消蒙板
    UIImage *customImage = [UIImage imageNamed:@"public_btn_back"];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[customImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(popUnLockedCity)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
}

-(void)popUnLockedCity{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    if (error.code!=-999) {
        
        [self loadBlankPage];
//        NSURL* url = [NSURL URLWithString:@"http://www.fxq.com/html/404.html"];
//        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
//        [self.czWebView loadRequest:request];
    }
    
}
//加载本地的一个空html页面，解决webview没有加载完网页，底部留下tabbar黑色区域的问题
- (void)loadBlankPage {
    
    NSURLRequest *errorRequest;
    
    if (!errorRequest) {
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Legal" ofType:@"html"];
        
        NSURL *errorUrl = [NSURL fileURLWithPath:filePath];
        
        errorRequest = [NSURLRequest requestWithURL:errorUrl];
        
    }
    
    [self.czWebView loadRequest:errorRequest];
    
}

- (void)backDetail {
    [self.czWebView goBack];
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    
    urlString = [urlString stringByRemovingPercentEncoding];
    
    NSArray *urls = [urlString componentsSeparatedByString:@"#"];
    
    NSString *url = urls.lastObject;
    
    NSArray *urlComps = [url componentsSeparatedByString:@"://"];
    
    if ([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"returnDetail"]) {
        
        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps objectAtIndex:1] componentsSeparatedByString:@":/"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        
        if ([arrFucnameAndParameter count] == 2) {
            if ([funcStr isEqualToString:@"re:"]) {
                [webView goBack];
            }
        }
        return NO;
    } else if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"fxq"]) {
        
//        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps objectAtIndex:1] componentsSeparatedByString:@":/"];
//        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
//        
//        if ([arrFucnameAndParameter count] == 2) {
//            BOOL login = [[NSUserDefaults standardUserDefaults] boolForKey:isLogin];
//            if (!login) {
//                LoginViewController *loginVC = [[LoginViewController alloc] init];
//                [self.navigationController pushViewController:loginVC animated:YES];
//            } else {
//                if ([funcStr isEqualToString:@"para:"]) {
//                    SubmitOrderVC *submit = [[SubmitOrderVC alloc] init];
//                    submit.couponID_Str = [NSString stringWithFormat:@"%@", arrFucnameAndParameter[1]];
//                    [self.navigationController pushViewController:submit animated:YES];
//                }
//            }
//        }
        return NO;
    }
    return TRUE;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView.canGoBack) {
        //自定义返回按钮
        UIImage *backButtonImage = [UIImage imageNamed:@"public_btn_back"];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[backButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(backDetail)];
        
        self.navigationItem.leftBarButtonItem = leftItem;
    } else {
        //自定义返回按钮
        UIImage *backButtonImage = [UIImage imageNamed:@"public_btn_back"];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[backButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(backOrderVC)];
        
        self.navigationItem.leftBarButtonItem = leftItem;
    }
}
-(void)backOrderVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
