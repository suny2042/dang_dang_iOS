//
//  ViewController.swift
//  dang_dang
//
//  Created by user on 2024/05/20.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WKWebView 설정
        webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        
        // 로드할 URL 설정
        if let url = URL(string: "https://www.google.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
