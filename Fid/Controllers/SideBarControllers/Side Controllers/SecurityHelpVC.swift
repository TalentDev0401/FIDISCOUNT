//
//  SecurityHelpVC.swift
//  Fid
//
//  Created by CROCODILE on 16.01.2021.
//

import UIKit
import WebKit

class SecurityHelpVC: BaseVC {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        self.progressView.progress = 0
        
        if let url = URL(string: "https://fid.ninja//GP//legal.php") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(Float(webView.estimatedProgress))
            
            self.progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
}
