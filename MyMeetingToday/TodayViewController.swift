//
//  TodayViewController.swift
//  MyMeetingToday
//
//  Created by Kamal Ahuja on 7/26/16.
//  Copyright © 2016 KamalAhuja. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, NSURLSessionDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var todaysWidgetTableView: UITableView!
    var todayWidgetDataSource : [(location: String, dateTime : String, subject : String)] = []
    let todayKeychainWrapper : TodayExtensionKeyChainWrapper = TodayExtensionKeyChainWrapper()
    override func viewDidLoad() {
        print("viewdidload")
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        
        
       todaysWidgetTableView.dataSource = self
        todaysWidgetTableView.delegate = self
        todaysWidgetTableView.scrollEnabled = false
        self.initialDataLoadForWIdget()
        self.todaysWidgetTableView.reloadData()
        self.preferredContentSize = self.todaysWidgetTableView.contentSize
        todaysWidgetTableView.registerNib(UINib(nibName: "TodayMeetingTableViewCell", bundle:nil), forCellReuseIdentifier: "test")
    }
    
    func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsetsZero
    }
    
    func initialDataLoadForWIdget () {
        if  self.todayWidgetDataSource.count == 0 {
            let myMeetingData : NSData? = todayKeychainWrapper.getKeyChainItem("MyService", accountName: "Some account")
            NSKeyedUnarchiver.setClass(TodayExtensionMeetingObject.self, forClassName: "TodayExtensionDemo.TodayExtensionMeetingObject")
            if let todayExtensionMeetingObject : TodayExtensionMeetingObject = NSKeyedUnarchiver.unarchiveObjectWithData(myMeetingData!) as?
                TodayExtensionMeetingObject {
                let meetingSummaryTuple : (location: String, dateTime : String, subject : String) = (todayExtensionMeetingObject.meetingTuple!.location!, todayExtensionMeetingObject.meetingTuple!.dateTime!, todayExtensionMeetingObject.meetingTuple!.subject!)
                print(todayExtensionMeetingObject)
                todayWidgetDataSource += [meetingSummaryTuple]
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        print("viewDidAppear")
       self.initialDataLoadForWIdget()
        self.todaysWidgetTableView.reloadData()
        self.preferredContentSize = self.todaysWidgetTableView.contentSize
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        
        // Perform any setup necessary in order to update the view.
        let meetingSubmitURL : NSURL = NSURL(string: "http://192.168.1.143:3000/meetings/")!
        let sessionConfiguration : NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let defaultSession : NSURLSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        let dataTask : NSURLSessionDataTask = defaultSession.dataTaskWithURL(meetingSubmitURL, completionHandler: {
            (data, response, error) in
            if let errorLocal = error {
                print(errorLocal.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(httpResponse)
                    var meetingResultDicionaryArray : [NSDictionary]?
                    do {
                        try   meetingResultDicionaryArray  = (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary])
                        self.todayWidgetDataSource = []
                        for meetingDict in meetingResultDicionaryArray! {
                            let meetigTuple :    (location: String, dateTime : String, subject : String) = (location : meetingDict.objectForKey("location") as! String, dateTime : meetingDict.objectForKey("dateTime") as! String, subject  : meetingDict.objectForKey("Subject") as! String )
                            self.todayWidgetDataSource += [meetigTuple]
                        }
                        
                    } catch {
                        
                    }
                    let testString : NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                    print(testString)
                    completionHandler(NCUpdateResult.NewData)
                } else {
                    print("status code is : \(httpResponse.statusCode)")
                }
            }
        })
        dataTask.resume()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let meetingDetails : (location: String, dateTime : String, subject : String)  = todayWidgetDataSource[indexPath.row]
        var todaysWidgetTableViewCell : TodayMeetingTableViewCell
        if todaysWidgetTableView.dequeueReusableCellWithIdentifier("test") as? TodayMeetingTableViewCell == nil {
            todaysWidgetTableViewCell = TodayMeetingTableViewCell();
        } else {
            todaysWidgetTableViewCell = todaysWidgetTableView.dequeueReusableCellWithIdentifier("test") as!TodayMeetingTableViewCell
        }
        todaysWidgetTableViewCell.subjectLabel.text = meetingDetails.subject
        todaysWidgetTableViewCell.dateLabel.text = meetingDetails.dateTime
        todaysWidgetTableViewCell.locationLabel.text = meetingDetails.location
        todaysWidgetTableViewCell.selectionStyle = UITableViewCellSelectionStyle.None
        return todaysWidgetTableViewCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url : NSURL = NSURL(string: "todayextension://com.todayExtension.demo")!
        self.extensionContext?.openURL(url, completionHandler: nil)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayWidgetDataSource.count;
    }
    
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.host == "192.168.1.143" || challenge.protectionSpace.host == "localhost" {
                let credential : NSURLCredential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
                completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
            }
        }
    }
    
}
