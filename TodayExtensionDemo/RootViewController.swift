//
//  ViewController.swift
//  TodayExtensionDemo
//
//  Created by Kamal Ahuja on 7/25/16.
//  Copyright © 2016 KamalAhuja. All rights reserved.
//

import UIKit


class RootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URLSessionDelegate {
    var meetingDetailsArray : [(location: String, dateTime : String, subject : String)] = [] ;
    let addMeetingViewController : MeetingInviteViewController = MeetingInviteViewController();
    let todayKeychainWrapper : TodayExtensionKeyChainWrapper = TodayExtensionKeyChainWrapper()
    var meetingIdCounter : Int = 0;
    @IBOutlet weak var addMeeting: UIButton!
    @IBOutlet weak var rootviewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootviewTableView.register(UINib(nibName: "MeetingDetailsViewCellTableViewCell", bundle:nil), forCellReuseIdentifier: "test")
        if let myMeetingData = todayKeychainWrapper.getKeyChainItem("MyService", accountName: "Some account") {
        
            if let todayExtensionMeetingObject : TodayExtensionMeetingObject = NSKeyedUnarchiver.unarchiveObject(with: myMeetingData) as?
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
        let meetingSubmitURL : URL = URL(string: "http://192.168.1.143:3000/db")!
        let sessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        
        let defaultSession : Foundation.URLSession = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        let dataTask : URLSessionDataTask = defaultSession.dataTask(with: meetingSubmitURL, completionHandler: {
            (data, response, error) in
            if let errorLocal = error {
                print(errorLocal.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(httpResponse)
                    do {
                        try  (JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary)
                        
                    } catch {
                        
                    }
                    let testString : NSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                    print(testString)
                } else {
                    print("status code is : \(httpResponse.statusCode)")
                }
            }
        })
        dataTask.resume()
    }

    func submitPostRequest(_ meetingTupleParam : (location: String, dateTime : String, subject : String)) {
        print("checking!!")
      
        let meetingObject : TodayExtensionMeetingObject = TodayExtensionMeetingObject()
        meetingObject.meetingTuple = (meetingTupleParam.location, meetingTupleParam.dateTime, meetingTupleParam.subject)
        
        //Updating meeting object data in keychain to be used with Todays extension
        let meetingObjectData = NSKeyedArchiver.archivedData(withRootObject: meetingObject)
        todayKeychainWrapper.updateKeyChainItem("MyService", accountName: "Some account", updatedData: meetingObjectData)
        
        //Submiting POST request to save meeting data
        meetingIdCounter+=1
        let sessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        let param : [String : AnyObject] = ["id":meetingIdCounter as AnyObject, "location" : meetingTupleParam.location as AnyObject, "Subject" : meetingTupleParam.subject as AnyObject, "dateTime" : meetingTupleParam.dateTime as AnyObject]
        
        let defaultSession : Foundation.URLSession = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let meetingSubmitURL : URL = URL(string: "http://192.168.1.143:3000/meetings/")!
        let meetingRequest : NSMutableURLRequest = NSMutableURLRequest(url: meetingSubmitURL)
        meetingRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        meetingRequest.httpMethod = "POST"
        do {
              try  meetingRequest.httpBody = JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            print(error)
        }
        
        
        let dataTask = defaultSession.dataTask(with: meetingRequest as URLRequest){ data,response, error in
            if let httpResponse = response as? HTTPURLResponse {
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
                let result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                print(result)
            } catch {
                print(error)
            }
            
        }
        dataTask.resume()
        
    }
    func closeMeetingSave() {
        let meetingDate : Date = addMeetingViewController.meetingDateTime.date
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "cccc, MMM d, hh:mm aa"
        let meetingSummaryTuple : (location: String, dateTime : String, subject : String) = (addMeetingViewController.meetingLocation.text!, dateFormatter.string(from: meetingDate), addMeetingViewController.meetingSubject.text!);
        meetingDetailsArray += [meetingSummaryTuple]
        rootviewTableView.reloadData()
        self.submitGetRequest()
        self.submitPostRequest(meetingSummaryTuple)
        self.dismiss(animated: true, completion: nil);
        
    }
    @IBAction func submitNewMeetin(_ sender: AnyObject) {
        
        let addMeetingViewControllerNav : UINavigationController = UINavigationController(rootViewController: addMeetingViewController)
        let closeButton = UIBarButtonItem(title: "Save Meeting", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.closeMeetingSave))
        addMeetingViewController.navigationItem.rightBarButtonItem = closeButton
//        
        addMeetingViewController.meetingSubject?.text = ""
        addMeetingViewController.meetingLocation?.text = ""
        addMeetingViewController.meetingDateTime?.date = Date()
        self.present(addMeetingViewControllerNav, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingDetailsArray.count;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0))
        let descriptionLabel  = UILabel()
        descriptionLabel.frame = CGRect(x: 10.0, y: 5.0, width: 200.0, height: 20.0)
        descriptionLabel.text = "Meeting Details"
        customView.addSubview(descriptionLabel)
        return customView;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let meetingSummaryCell = tableView.dequeueReusableCell(withIdentifier: "test") as? MeetingDetailsViewCellTableViewCell else {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meetingDetails : (location: String, dateTime : String, subject : String)  = meetingDetailsArray[indexPath.row]
        print("At indexpath \(indexPath.row) meeting locatiin \(meetingDetails.location) meeting Date TIme : \(meetingDetails.dateTime)")
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

