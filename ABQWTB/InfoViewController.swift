//
//  InfoViewController.swift
//  ABQWTB
//
//  Created by Chris Hughes on 2/10/15.
//  Copyright (c) 2015 Chris Hughes. All rights reserved.
//

import Foundation

class InfoViewController:UIViewController,UIWebViewDelegate {


    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (navigationType == UIWebViewNavigationType.LinkClicked){
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }
        return true
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        
        let windowframe = UIScreen.mainScreen().bounds
        let x = windowframe.width/2 - 150
        let y = windowframe.height/2 - 120
        let infoView = UIWebView(frame:CGRect(x: x, y: y, width: 300, height: 200))
        
        infoView.delegate = self

        self.view.addSubview(infoView)
        
        let button:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRect(x:x,y:y+200,width:300,height:50)
        button.setTitle("Close", forState: UIControlState.Normal)
        button.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
        button.backgroundColor = UIColor.lightGrayColor()
        
        self.view.addSubview(button)
        
        let infoUrlString = "http://chrishughes.me/inapp.html"
        let infoUrl = NSURL(string:infoUrlString)
        let request = NSURLRequest(URL: infoUrl!)
        
        infoView.loadRequest(request)
        
    }
    
    func close(){
        dismissViewControllerAnimated(false, completion: nil)
    }
    
}
