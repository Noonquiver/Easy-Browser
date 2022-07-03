//
//  ViewController.swift
//  Easy Browser
//
//  Created by Camilo Hernández Guerrero on 22/06/22.
//

import UIKit
import WebKit

class ViewController: UITableViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com", "hackingwithswift.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Website", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let URL = URL(string: "https://" + websites[indexPath.row])!
        loadWebView()
        webView.load(URLRequest(url: URL))
    }
    
    func loadWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let back = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(webView.goBack))
        let forward = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(webView.goForward))
        
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.sizeToFit()
        //fdgdfgda
        
        let progress = UIBarButtonItem(customView: progressView)
        
        toolbarItems = [back, spacer, progress, spacer, refresh, spacer, forward]
        navigationController?.isToolbarHidden = false
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        webView.allowsBackForwardNavigationGestures = true
    }
    
    @objc func openTapped() {
        let alertController = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        
        for website in websites {
            alertController.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(alertController, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else {return} //Force unwrap was totally fine here.
        guard let URL = URL(string: "https://" + actionTitle) else {return} //Force unwrap was totally fine here.
        
        webView.load(URLRequest(url: URL))
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let URL = navigationAction.request.url
        var invalidURL = false
        
        if let host = URL?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    
                    return
                }
                else {
                    invalidURL = true
                }
            }
        }
        
        decisionHandler(.cancel)
        
        if invalidURL {
            let alertController = UIAlertController(title: "It's blocked", message: "You are not allowed to access pages not saved in our database.", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Understood", style: .default))
            present(alertController, animated: true)
        }
    }
}
