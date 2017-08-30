//
//  MoreDetailWebViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/29.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class MoreDetailWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingBackgound: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    var webView:WKWebView!
    
    var url: String = ""
    var htmlFileName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        webView = WKWebView(frame: contentView.frame)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        contentView.addSubview(webView)
        constrainView(view: webView, toView: contentView)
        
        if !self.url.isEmpty,
            let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        } else {
            let htmlPath = Bundle.main.path(forResource: htmlFileName, ofType: "html")
            let htmlUrl = URL(fileURLWithPath: htmlPath!, isDirectory: false)
            webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
        }
        
        loadingStackView.setView(hidden: true)
        loadingBackgound.isHidden = true
        loadingBackgound.layer.cornerRadius = 10
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loadingBackgound.setView(hidden: false)
        loadingStackView.setView(hidden: false)
        loadingIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingBackgound.setView(hidden: true)
        loadingStackView.setView(hidden: true)
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            
            let url = navigationAction.request.url
            let shared = UIApplication.shared
            
            if shared.canOpenURL(url!) {
                if let isHttp = url?.absoluteString.contains("http"), isHttp {
                    let sfSafariViewController = SFSafariViewController(url: url!)
                    self.present(sfSafariViewController, animated: true, completion: nil)
                } else {
                    shared.openURL(url!)
                }
            }
            
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func constrainView(view:UIView, toView contentView:UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
}
