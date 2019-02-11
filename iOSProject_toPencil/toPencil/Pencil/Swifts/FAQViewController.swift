//
//  FAQViewController.swift
//  Pencil
//
//  Created by Lakr Sakura on 2018/8/4.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

import Foundation
import UIKit
import WebKit

let help_url_string = "https://www.bing.com"

class FAQViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var WebView: WKWebView!
    @IBOutlet weak var LoadingLabel: UILabel!
    
    @IBAction func CreditShow(_ sender: Any) {
        let CAlert_text = """
            ---------------------------
            To Pencil by Lakr
            SwiftSocket by aixinyunchou
            Socket by skysent
            BlueSocket by IBM-Swift
            icon illustrator by Achelry
        """
        let CAlert = UIAlertController(title: "Credit", message: CAlert_text, preferredStyle: .alert)
        let CAlert_OK = UIAlertAction(title: "OK", style: .default, handler: nil)
        CAlert.addAction(CAlert_OK)
        self.present(CAlert, animated: true, completion: nil)
    }
    
    @IBAction func OpenInSafari(_ sender: Any) {
        let url_to_help = URL(string: help_url_string)!
        UIApplication.shared.open(url_to_help)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url_to_help = URL(string: help_url_string)!
        WebView.load(URLRequest(url: url_to_help))
        WebView.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.LoadingLabel.fadeTransition(0.6)
            self.LoadingLabel.text = ""
            self.LoadingLabel.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            UIView.animate(withDuration: 0.3, animations: {
                self.WebView.alpha = 1
            })
        }
    }
    
}
