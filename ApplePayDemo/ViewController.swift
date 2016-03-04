//
//  ViewController.swift
//  ApplePayDemo
//
//  Created by Leo on 16/3/4.
//  Copyright © 2016年 Leo. All rights reserved.
//

import UIKit
import PassKit

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iconImage = UIImage.init(named: "Apple_Pay_Payment_Mark")
        
        let payBtn = UIButton.init(frame: CGRectMake((UIScreen.mainScreen().bounds.size.width - 100.0) * 0.5, 200, 100.0, 64.0))
        payBtn.setBackgroundImage(iconImage, forState: UIControlState.Normal)
        payBtn.addTarget(self, action: "payBtnClicked", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(payBtn)
    }
    
    /**
     点击了支付按钮
     */
    func payBtnClicked() {
        
        // 检查用户是否支持 Apple Pay
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            print("设备不支持 Apple Pay")
            let alertView = UIAlertView.init(
                title: "设备不支持 Apple Pay",
                message: nil,
                delegate: nil,
                cancelButtonTitle: "确定")
            alertView.show()
            return
        }
        
        // 检查是否支持用户卡片
        var paymentNetworks: [String]!
        if #available(iOS 9.2, *) {
            paymentNetworks = [
                PKPaymentNetworkVisa,
                PKPaymentNetworkMasterCard,
                PKPaymentNetworkChinaUnionPay]  // 银联卡要求 iOS 9.2 +
        } else {
            paymentNetworks = [
                PKPaymentNetworkVisa,
                PKPaymentNetworkMasterCard]
        }
        if !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(paymentNetworks) {
            print("不支持的卡片类型。目前仅支持 Visa、MasterCard、中国银联卡。")
            let alertView = UIAlertView.init(
                title: "不支持的卡片类型",
                message: "目前仅支持 Visa、MasterCard、中国银联卡。",
                delegate: nil,
                cancelButtonTitle: "确定")
            alertView.show()
            return
        }
        
        // 创建付款请求
        let request                  = PKPaymentRequest()
        request.countryCode          = "CN"
        request.currencyCode         = "CNY"
        request.supportedNetworks    = paymentNetworks
        request.merchantIdentifier   = "merchant.me.leodev.ApplePayDemo"
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        
        // 添加付款项目
        let item1 = PKPaymentSummaryItem.init(label: "美酒", amount: NSDecimalNumber.init(double: 99.99))
        let item2 = PKPaymentSummaryItem.init(label: "咖啡", amount: NSDecimalNumber.init(double: 29.99))
        let item3 = PKPaymentSummaryItem.init(label: "小费", amount: NSDecimalNumber.init(double: 19.99))
        let item4 = PKPaymentSummaryItem.init(label: "超哥", amount: NSDecimalNumber.init(double: 149.97))
        request.paymentSummaryItems = [item1, item2, item3, item4]
        
        // 初始化 PKPaymentAuthorizationViewController 并显示
        let authViewController = PKPaymentAuthorizationViewController.init(paymentRequest: request)
        authViewController.delegate = self
        presentViewController(authViewController, animated: true, completion: nil)
    }
    
    // MARK: - PKPaymentAuthorizationViewControllerDelegate
    
    /**
    处理交易数据，并把状态返回给应用
    
    - parameter controller: 当前的 PKPaymentAuthorizationViewController
    - parameter payment:    payment
    - parameter completion: 返回
    */
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        
        let paymentToken = payment.token
        print("\(paymentToken)")
        
        // 超哥交易成功了
        completion(.Success)
        
        // 交易成功应该 push 个交易成功的界面什么的
        // ...
    }
    
    /**
     支付完成，隐藏 PKPaymentAuthorizationViewController
     
     - parameter controller: 当前的 PKPaymentAuthorizationViewController
     */
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

