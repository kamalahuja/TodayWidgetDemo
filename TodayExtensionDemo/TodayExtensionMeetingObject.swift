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
        let meetingLocation = decoder.decodeObjectForKey("meetingLocation") as! String?
        let meetingDateAndTime = decoder.decodeObjectForKey("meetingDateAndTime") as! String?
        let meetingSubject = decoder.decodeObjectForKey("meetingSubject") as! String?
        meetingTuple = (meetingLocation, meetingDateAndTime, meetingSubject);
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(meetingTuple?.location, forKey: "meetingLocation")
        coder.encodeObject(meetingTuple?.dateTime, forKey: "meetingDateAndTime")
        coder.encodeObject(meetingTuple?.subject, forKey: "meetingSubject")
    }
}