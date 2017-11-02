//
//  TodayExtensionMeetingObject.swift
//  TodayExtensionDemo
//
//  Created by Kamal Ahuja on 8/4/16.
//  Copyright © 2016 KamalAhuja. All rights reserved.
//

import Foundation

class TodayExtensionMeetingObject : NSObject, NSCoding  {
    var meetingTuple : (location: String?, dateTime : String?, subject : String?)?
    required convenience init(coder decoder: NSCoder) {
        self.init()
        let meetingLocation = decoder.decodeObject(forKey: "meetingLocation") as! String?
        let meetingDateAndTime = decoder.decodeObject(forKey: "meetingDateAndTime") as! String?
        let meetingSubject = decoder.decodeObject(forKey: "meetingSubject") as! String?
        meetingTuple = (meetingLocation, meetingDateAndTime, meetingSubject);
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(meetingTuple?.location, forKey: "meetingLocation")
        coder.encode(meetingTuple?.dateTime, forKey: "meetingDateAndTime")
        coder.encode(meetingTuple?.subject, forKey: "meetingSubject")
    }
}
