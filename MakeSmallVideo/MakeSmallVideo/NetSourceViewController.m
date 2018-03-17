//
//  NetSourceViewController.m
//  MakeSmallVideo
//
//  Created by wutaotao on 2016/12/21.
//  Copyright © 2016年 mac_wsdasd. All rights reserved.
//

#import "NetSourceViewController.h"
#import <WebKit/WebKit.h>

@interface NetSourceViewController ()<WKUIDelegate,WKNavigationDelegate>

@property(nonatomic,strong)WKWebView *webView;
@end

@implementation NetSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    NSURL *url=[NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}



- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.getElementById(\"video\").flashvars;"completionHandler:^(id result,NSError *_Nullable error) {
        //获取页面高度，并重置webview的frame
  
    }];
//   http://p.7791.com.cn/d/i.php?url=XMTc4NDYxNTkxMg==
}

// 类似 UIWebView的 -webView: shouldStartLoadWithRequest: navigationType:
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void(^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *strRequest = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    decisionHandler(WKNavigationActionPolicyAllow);
    if([strRequest isEqualToString:@"about:blank"]) {//主页面加载内容
        decisionHandler(WKNavigationActionPolicyAllow);//允许跳转
    } else {//截获页面里面的链接点击
        //do something you want
        decisionHandler(WKNavigationActionPolicyCancel);//不允许跳转
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(WKWebView *)webView
{
    if (_webView==nil) {
        _webView=[[WKWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH)];
        _webView.UIDelegate=self;
        _webView.navigationDelegate=self;
    }
    return _webView;
}

@end
