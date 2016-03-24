//
//  ViewController.m
//  ASPayDemo
//
//  Created by ashen on 16/3/24.
//  Copyright © 2016年 Ashen<http://www.devashen.com>. All rights reserved.
//

#import "ViewController.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)alipay:(id)sender {

    //这里先去请求服务端，拿到订单字符串
    //当然服务端可能需要你传一些参数进入，比如：订单号，商品价格，名字，以及加密token等
    NSString * orderString = @"";
    /*
     code
     
     在这里拿到orderString
     
     */
    
    //这里的orderString，要确保已经取到, 一般这里要和请求服务端拿orderString做同步请求
    [[AlipaySDK defaultService] payOrder:orderString fromScheme: @"alisdkdemo" callback:^(NSDictionary *resultDic) {
        if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
            //9000为支付成功
        }
    }];
    
}



- (IBAction)alipaySelf:(id)sender {
    
    NSString *partner = @""; //PID
    
    NSString *seller = @""; //收款账户，手机号或者邮箱
    
    NSString*privateKey= @"";// 私钥
    
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = @"20160324012412412"; //订单ID（由商家自行制定）
    order.productName = @"iOS 高级教程"; //商品标题
    order.productDescription = @"这是一本关于iOS的一本高级教程书"; //商品描述
    order.amount = @"0.1"; //商品价格
    order.notifyURL = @"http://www.devashen.com/Notify/Alipay/"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    NSString *appScheme = @"alisdkdemo";
    
    //将商品信息拼接成字符串   该方法支付宝已经封好
    NSString *orderSpec = [order description];
    
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    //调用签名
    NSString *signedString = [signer signString:orderSpec];
    
    
    
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        //上面提到好的后台，会把订单字符串直接传给我们，而我们要做的其实也就只剩下这一步了
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                //9000为支付成功
                
            }
        }];
    }
}

@end
