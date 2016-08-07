//
//  ViewController.swift
//  TodayExtensionDemo
//
//  Created by Kamal Ahuja on 7/25/16.
//  Copyright © 2016 KamalAhuja. All rights reserved.
//

import UIKit


class RootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSURLSessionDelegate {
    var meetingDetailsArray : [(location: String, dateTime : String, subject : String)] = [] ;
    let addMeetingViewController : MeetingInviteViewController = MeetingInviteViewController();
    let todayKeychainWrapper : TodayExtensionKeyChainWrapper = TodayExtensionKeyChainWrapper()
    var meetingIdCounter : Int = 0;
    @IBOutlet weak var addMeeting: UIButton!
    @IBOutlet weak var rootviewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootviewTableView.registerNib(UINib(nibName: "MeetingDetailsViewCellTableViewCell", bundle:nil), forCellReuseIdentifier: "test")
        if let myMeetingData = todayKeychainWrapper.getKeyChainItem("MyService", accountName: "Some account") {
        
            if let todayExtensionMeetingObject : TodayExtensionMeetingObject = NSKeyedUnarchiver.unarchiveObjectWithData(myMeetingData) as?
                TodayExtensionMeetingObject {
                let meetingSummaryTuple : (location: String, dateTime : String, subject : String) = (todayExtensionMeetingObject.meetingTuple!.location!, todayExtensionMeetingObject.meetingTuple!.dateTime!, todayExtensionMeetingObject.meetingTuple!.subject!)
                print(todayExtensionMeetingObject)
                meetingDetailsArray += [meetingSummaryTuple]
                self.rootviewTableView.reloadData()
            }
        }
        
    }
    //Just for testing
    func submitGetRequest() {
        let meetingSubmitURL : NSURL = NSURL(string: "http://192.168.1.143:3000/db")!
        let sessionConfiguration : NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let defaultSession : NSURLSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        let dataTask : NSURLSessionDataTask = defaultSession.dataTaskWithURL(meetingSubmitURL, completionHandler: {
            (data, response, error) in
            if let errorLocal = error {
                print(errorLocal.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(httpResponse)
                    do {
                        try  (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary)
                        
                    } catch {
                        
                    }
                    let testString : NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                    print(testString)
                } else {
                    print("status code is : \(httpResponse.statusCode)")
                }
            }
        })
        dataTask.resume()
    }

    func submitPostRequest(meetingTupleParam : (location: String, dateTime : String, subject : String)) {
        print("checking!!")
      
        let meetingObject : TodayExtensionMeetingObject = TodayExtensionMeetingObject()
        meetingObject.meetingTuple = (meetingTupleParam.location, meetingTupleParam.dateTime, meetingTupleParam.subject)
        
        //Updating meeting object data in keychain to be used with Todays extension
        let meetingObjectData = NSKeyedArchiver.archivedDataWithRootObject(meetingObject)
        todayKeychainWrapper.updateKeyChainItem("MyService", accountName: "Some account", updatedData: meetingObjectData)
        
        //Submiting POST request to save meeting data
        meetingIdCounter+=1
        let sessionConfiguration : NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let param : [String : AnyObject] = ["id":meetingIdCounter, "location" : meetingTupleParam.location, "Subject" : meetingTupleParam.subject, "dateTime" : meetingTupleParam.dateTime]
        
        let defaultSession : NSURLSession = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let meetingSubmitURL : NSURL = NSURL(string: "http://192.168.1.143:3000/meetings/")!
        let meetingRequest : NSMutableURLRequest = NSMutableURLRequest(URL: meetingSubmitURL)
        meetingRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        meetingRequest.HTTPMethod = "POST"
        do {
              try  meetingRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(param, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print(error)
        }
        
        let dataTask = defaultSession.dataTaskWithRequest(meetingRequest) { data,response, error in
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("response was not 200 \(httpResponse)")
                    return
                }
            }
            if (error != nil) {
                print("error submitting request: \(error)")
                return
            }
            
            // handle the data of the successful response here
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                print(result)
            } catch {
                print(error)
            }
            
        }
        dataTask.resume()
        
    }
    func closeMeetingSave() {
        let meetingDate : NSDate = addMeetingViewController.meetingDateTime.date
        let dateFormatter : NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "cccc, MMM d, hh:mm aa"
        let meetingSummaryTuple : (location: String, dateTime : String, subject : String) = (addMeetingViewController.meetingLocation.text!, dateFormatter.stringFromDate(meetingDate), addMeetingViewController.meetingSubject.text!);
        meetingDetailsArray += [meetingSummaryTuple]
        rootviewTableView.reloadData()
        self.submitGetRequest()
        self.submitPostRequest(meetingSummaryTuple)
        self.dismissViewControllerAnimated(true, completion: nil);
        
    }
    @IBAction func submitNewMeetin(sender: AnyObject) {
        
        let addMeetingViewControllerNav : UINavigationController = UINavigationController(rootViewController: addMeetingViewController)
        let closeButton = UIBarButtonItem(title: "Save Meeting", style: UIBarButtonItemStyle.Done, target: self, action: #selector(self.closeMeetingSave))
        addMeetingViewController.navigationItem.rightBarButtonItem = closeButton
//        
        addMeetingViewController.meetingSubject?.text = ""
        addMeetingViewController.meetingLocation?.text = ""
        addMeetingViewController.meetingDateTime?.date = NSDate()
        self.presentViewController(addMeetingViewControllerNav, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingDetailsArray.count;
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
        let descriptionLabel  = UILabel()
        descriptionLabel.frame = CGRect(x: 10.0, y: 5.0, width: 200.0, height: 20.0)
        descriptionLabel.text = "Meeting Details"
        customView.addSubview(descriptionLabel)
        return customView;
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        guard let meetingSummaryCell = tableView.dequeueReusableCellWithIdentifier("test") as? MeetingDetailsViewCellTableViewCell else {
           let meetingSummaryCellNew = MeetingDetailsViewCellTableViewCell()
            let meetingDetails : (location: String, dateTime : String, subject : String)  = meetingDetailsArray[indexPath.row]
            meetingSummaryCellNew.location.text = meetingDetails.location
            meetingSummaryCellNew.subject.text = meetingDetails.subject
            meetingSummaryCellNew.dateAndTime.text = meetingDetails.dateTime
            return meetingSummaryCellNew;
        }
        
        let meetingDetails : (location: String, dateTime : String, subject : String)  = meetingDetailsArray[indexPath.row]
        meetingSummaryCell.location.text = meetingDetails.location
        meetingSummaryCell.subject.text = meetingDetails.subject
        meetingSummaryCell.dateAndTime.text = meetingDetails.dateTime
        return meetingSummaryCell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let meetingDetails : (location: String, dateTime : String, subject : String)  = meetingDetailsArray[indexPath.row]
        print("At indexpath \(indexPath.row) meeting locatiin \(meetingDetails.location) meeting Date TIme : \(meetingDetails.dateTime)")
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

