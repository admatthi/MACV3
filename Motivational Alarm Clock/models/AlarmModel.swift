//
//  AlarmModel.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 12/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import Foundation
import MediaPlayer

struct Alarm: PropertyReflectable {
    var date: Date = Date()
    var enabled: Bool = false
    var snoozeEnabled: Bool = false
    var repeatWeekdays: [Int] = []
    var uuid: String = ""
    var mediaID: String = ""
    var mediaLabel: String = "newtrack2"
    var label: String = "Alarm"
    var onSnooze: Bool = false
    var imageName: String = "nowandnever"
    var category:String = "Motivation"
    var repeatEnabled:Bool = false
    var isDailyWake:Bool = false
    init(){}
    
    init(date:Date, enabled:Bool, snoozeEnabled:Bool, repeatWeekdays:[Int], uuid:String, mediaID:String, mediaLabel:String, label:String, onSnooze: Bool,imageName:String,category:String,isRepeat:Bool,isDailyWake:Bool){
        self.date = date
        self.enabled = enabled
        self.snoozeEnabled = snoozeEnabled
        self.repeatWeekdays = repeatWeekdays
        self.uuid = uuid
        self.mediaID = mediaID
        self.mediaLabel = mediaLabel
        self.label = label
        self.onSnooze = onSnooze
        self.imageName = imageName
        self.category = category
        self.repeatEnabled = isRepeat
        self.isDailyWake = isDailyWake
        
    }
    
    init(_ dict: PropertyReflectable.RepresentationType){
        date = dict["date"] as! Date
        enabled = dict["enabled"] as! Bool
        snoozeEnabled = dict["snoozeEnabled"] as! Bool
        repeatWeekdays = dict["repeatWeekdays"] as! [Int]
        uuid = dict["uuid"] as! String
        mediaID = dict["mediaID"] as! String
        mediaLabel = dict["mediaLabel"] as! String
        label = dict["label"] as! String
        onSnooze = dict["onSnooze"] as! Bool
        imageName = dict["imageName"] as? String ?? ""
        category = dict["category"] as? String ?? ""
        repeatEnabled = dict["repeatEnabled"] as? Bool ?? false
        isDailyWake = dict["isDailyWake"] as? Bool ?? false
    }
    
    static var propertyCount: Int = 13
}

extension Alarm {
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self.date)
    }
}

//This can be considered as a viewModel
class Alarms: Persistable {
    let ud: UserDefaults = UserDefaults.standard
    let persistKey: String = "myAlarmKey"
    var alarms: [Alarm] = [] {
        //observer, sync with UserDefaults
        didSet{
            persist()
        }
    }
    
    private func getAlarmsDictRepresentation()->[PropertyReflectable.RepresentationType] {
        return alarms.map {$0.propertyDictRepresentation}
    }
    
    init() {
        alarms = getAlarms()
    }
    
    func persist() {
        ud.set(getAlarmsDictRepresentation(), forKey: persistKey)
        ud.synchronize()
    }
    
    func unpersist() {
        for key in ud.dictionaryRepresentation().keys {
            if key.description.contains("revenuecat") || key.description.contains("isInitialAlrmCreated") || key.description.contains("launchedBefore") || key.description.contains("isInitialAlrmCreatedForDaily") || key.description.contains("newUserWithOutCreatingAlarm") {
                
            }else{
                UserDefaults.standard.removeObject(forKey: key.description)
            }
            
        }
    }
    
    var count: Int {
        return alarms.count
    }
    
    //helper, get all alarms from Userdefaults
    private func getAlarms() -> [Alarm] {
        let array = UserDefaults.standard.array(forKey: persistKey)
        guard let alarmArray = array else{
            return [Alarm]()
        }
        if let dicts = alarmArray as? [PropertyReflectable.RepresentationType]{
            if dicts.first?.count == Alarm.propertyCount {
                return dicts.map{Alarm($0)}
            }
        }
        unpersist()
        return [Alarm]()
    }
}

