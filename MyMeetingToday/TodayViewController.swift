//
//  TodayViewController.swift
//  MyMeetingToday
//
//  Created by Kamal Ahuja on 7/26/16.
//  Copyright © 2016 KamalAhuja. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, URLSessionDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var todaysWidgetTableView: UITableView!
    var todayWidgetDataSource : [(location: String, dateTime : String, subject : String)] = []
    let todayKeychainWrapper : TodayExtensionKeyChainWrapper = TodayExtensionKeyChainWrapper()
    override func viewDidLoad() {
        print("viewdidload")
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        
        
       todaysWidgetTableView.dataSource = self
        todaysWidgetTableView.delegate = self
        todaysWidgetTableView.isScrollEnabled = false
        self.initialDataLoadForWIdget()
        self.todaysWidgetTableView.reloadData()
        self.preferredContentSize = self.todaysWidgetTableView.contentSize
        todaysWidgetTableView.register(UINib(nibName: "TodayMeetingTableViewCell", bundle:nil), forCellReuseIdentifier: "test")
    }
    
    func widgetMarginInsets
        (forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsets.zero
    }
    
    func initialDataLoadForWIdget () {
        if  self.todayWidgetDataSource.count == 0 {
            let myMeetingData : Data? = todayKeychainWrapper.getKeyChainItem("MyService", accountName: "Some account")
            NSKeyedUnarchiver.setClass(TodayExtensionMeetingObject.self, forClassName: "TodayExtensionDemo.TodayExtensionMeetingObject")
            if let todayExtensionMeetingObject : TodayExtensionMeetingObject = NSKeyedUnarchiver.unarchiveObject(with: myMeetingData!) as?
                TodayExtensionMeetingObject {
                let meetingSummaryTuple : (location: String, dateTime : String, subject : String) = (todayExtensionMeetingObject.meetingTuple!.location!, todayExtensionMeetingObject.meetingTuple!.dateTime!, todayExtensionMeetingObject.meetingTuple!.subject!)
                print(todayExtensionMeetingObject)
                todayWidgetDataSource += [meetingSummaryTuple]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        // Perform any setup necessary in order to update the view.
        let meetingSubmitURL : URL = URL(string: "http://192.168.1.143:3000/meetings/")!
        let sessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        let defaultSession : Foundation.URLSession = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        let dataTask : URLSessionDataTask = defaultSession.dataTask(with: meetingSubmitURL, completionHandler: {
            (data, response, error) in
            if let errorLocal = error {
                print(errorLocal.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(httpResponse)
                    var meetingResultDicionaryArray : [NSDictionary]?
                    do {
                        try   meetingResultDicionaryArray  = (JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [NSDictionary])
                        self.todayWidgetDataSource = []
                        for meetingDict in meetingResultDicionaryArray! {
                            let meetigTuple :    (location: String, dateTime : String, subject : String) = (location : meetingDict.object(forKey: "location") as! String, dateTime : meetingDict.object(forKey: "dateTime") as! String, subject  : meetingDict.object(forKey: "Subject") as! String )
                            self.todayWidgetDataSource += [meetigTuple]
                        }
                        
                    } catch {
                        
                    }
                    let testString : NSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                    print(testString)
                    completionHandler(NCUpdateResult.newData)
                } else {
                    print("status code is : \(httpResponse.statusCode)")
                }
            }
        })
        dataTask.resume()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meetingDetails : (location: String, dateTime : String, subject : String)  = todayWidgetDataSource[indexPath.row]
        var todaysWidgetTableViewCell : TodayMeetingTableViewCell
        if todaysWidgetTableView.dequeueReusableCell(withIdentifier: "test") as? TodayMeetingTableViewCell == nil {
            todaysWidgetTableViewCell = TodayMeetingTableViewCell();
        } else {
            todaysWidgetTableViewCell = todaysWidgetTableView.dequeueReusableCell(withIdentifier: "test") as!TodayMeetingTableViewCell
        }
        todaysWidgetTableViewCell.subjectLabel.text = meetingDetails.subject
        todaysWidgetTableViewCell.dateLabel.text = meetingDetails.dateTime
        todaysWidgetTableViewCell.locationLabel.text = meetingDetails.location
        todaysWidgetTableViewCell.selectionStyle = UITableViewCellSelectionStyle.none
        return todaysWidgetTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url : URL = URL(string: "todayextension://com.todayExtension.demo")!
        self.extensionContext?.open(url, completionHandler: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayWidgetDataSource.count;
    }
    
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.host == "192.168.1.143" || challenge.protectionSpace.host == "localhost" {
                let credential : URLCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
            }
        }
    }
    
}
