//
//  MoreDetailWebViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/29.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class MoreDetailWebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingBackgound: UIView!
    
    var url: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        if !self.url.isEmpty,
            let url = URL(string: url) {
            webView.loadRequest(URLRequest(url: url))
        } else {
            webView.loadHTMLString("", baseURL: nil)
        }
        
        loadingStackView.setView(hidden: true)
        loadingBackgound.isHidden = true
        loadingBackgound.layer.cornerRadius = 10
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        loadingBackgound.setView(hidden: false)
        loadingStackView.setView(hidden: false)
        loadingIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingBackgound.setView(hidden: true)
        loadingStackView.setView(hidden: true)
        loadingIndicator.stopAnimating()
    }
    
}
