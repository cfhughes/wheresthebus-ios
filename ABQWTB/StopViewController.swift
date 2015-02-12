//
//  DetailViewController.swift
//  ABQWTB
//
//  Created by Chris Hughes on 11/15/14.
//  Copyright (c) 2014 Chris Hughes. All rights reserved.
//

import UIKit
import Foundation

class StopViewController: GAITrackedViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableView:UITableView!
    
    let locale = NSLocale(localeIdentifier: "en_US")
    
    var stopID: Int = 0
    
    var rows:[String] = []
    
    let base_url = "http://abqwtb.com/android.php"
    
    let dateReader = NSDateFormatter()
    let dateWriter = NSDateFormatter()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "StopScheduleiOS"
        
        dateReader.locale = locale
        dateWriter.locale = locale
        dateReader.dateFormat = "HH:mm:ss"
        dateWriter.dateFormat = "h:mm a"
        
        tableView.rowHeight = 32
    }
    
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "schedulecell")
        
        
        let url = NSURL(string: "\(base_url)?stop_id=\(stopID)&version=7")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data,response,error) in
            let raw = NSString(data: data,encoding: NSUTF8StringEncoding) as String
            println(raw)
            if (raw.rangeOfString("No More Stops Today") != nil){
                self.rows = ["No More Stops Today"]
            }else{
                self.rows = split(raw, {$0 == "|"}, maxSplit: Int.max, allowEmptySlices: false)
            }
            dispatch_async(dispatch_get_main_queue(), {self.tableView.reloadData()})
            
        }
        
        task.resume()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView1: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("schedulecell") as UITableViewCell
        if (rows[indexPath.row].rangeOfString("No More Stops Today") != nil){
            cell.textLabel?.text = "No More Stops Today"
        }else{
            let data = split(rows[indexPath.row],{$0 == ";"},maxSplit: Int.max, allowEmptySlices: true)
            let time = dateWriter.stringFromDate(dateReader.dateFromString(data[0].stringByReplacingOccurrencesOfString("24", withString: "00").stringByReplacingOccurrencesOfString("25", withString: "01").stringByReplacingOccurrencesOfString("26", withString: "02"))!)
            var late = ""
            let number = NSNumberFormatter().numberFromString(data[2])
            if (number!.integerValue == 0){
                late += "On Time"
            }else if(number!.integerValue > 0){
                late += NSString(format: "%.1f Minutes Late", number!.floatValue/60)
            }else if(number!.integerValue < -1){
                late += NSString(format: "%.1f Minutes Early", abs(number!.floatValue)/60)
            }
            cell.textLabel?.text = "\(time) \(late)"
            cell.imageView?.image = routeImage(data[1])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func routeImage(route:NSString) -> UIImage{
        let font = UIFont.systemFontOfSize(45.0)
        UIGraphicsBeginImageContext(CGSizeMake(80, 80))
        
        let stmt = db.query("SELECT `route_color`,`route_text_color` FROM routes WHERE route_short_name LIKE \"\(route)%\"")
        
        var color:UIColor
        var text_color:UIColor
        if (sqlite3_step(stmt) == SQLITE_ROW){
            let scannercolor = NSScanner(string: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(stmt, 0)))!)
            let scannertextcolor = NSScanner(string: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(stmt, 1)))!)
            var colorint:UInt32 = 0
            var textcolorint:UInt32 = 0
            scannercolor.scanHexInt(&colorint)
            scannertextcolor.scanHexInt(&textcolorint)
            color = UIColor(red: CGFloat(((colorint >> 16) & 0xFF))/255.0, green: CGFloat(((colorint >> 8) & 0xFF))/255.0, blue: CGFloat((colorint & 0xFF))/255.0, alpha: 1.0)
            text_color = UIColor(red: CGFloat(((textcolorint >> 16) & 0xFF))/255.0, green: CGFloat(((textcolorint >> 8) & 0xFF))/255.0, blue: CGFloat((textcolorint & 0xFF))/255.0, alpha: 1.0)
        }else{
            color = UIColor.blackColor()
            text_color = UIColor.whiteColor()
        }
        route.drawInRect(CGRectMake(0.0, 12.0, 80, 80), withAttributes: [NSFontAttributeName:font, NSForegroundColorAttributeName:text_color, NSBackgroundColorAttributeName:color])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
}

