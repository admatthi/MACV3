//
//  AddNewAlarmViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 24/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import FBSDKCoreKit
class AddNewAlarmViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    var segueInfo: SegueInfo!
    var snoozeEnabled: Bool = false
    var enabled: Bool!
    var selectedSound:Sounds?

    @IBOutlet weak var tapsave: UIButton!
    @IBOutlet weak var tapback: UIButton!
    @IBOutlet weak var mainview: UIVisualEffectView!
    
    func selecttime(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "selecttime"), parameters: ["referrer" : referrer])
                                 }
    override func viewDidLoad() {
        
        selecttime(referrer: referrer)
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
      
        tapsave.layer.borderWidth = 1.0
        tapsave.layer.borderColor = UIColor.white.cgColor
        tapsave.layer.cornerRadius = 10.0
        tapsave.clipsToBounds = true
        datePicker.becomeFirstResponder()
        datePicker.tintColor = UIColor.white
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            datePicker.preferredDatePickerStyle = .compact // Replace .inline with .compact
        }
        datePicker.overrideUserInterfaceStyle = .dark

    }
    override func viewWillAppear(_ animated: Bool) {
        alarmModel=Alarms()
        self.navigationController?.navigationBar.isHidden = true
        snoozeEnabled = segueInfo.snoozeEnabled
        
        super.viewWillAppear(animated)
    }
    
    
    func tapsave(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "tapsave"), parameters: ["referrer" : referrer])
                                 }
    
    override func viewDidAppear(_ animated: Bool) {
        
        referrer = "SelectTime"

        if firstinstall {
            tapback.alpha = 0
            
        } else {
            
            tapback.alpha = 1
        }
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func saveButtonAction(_ sender: Any) {
        
        firstinstall = false

        tapsave(referrer: referrer)
                if didpurchase {
                    if let sound = selectedSound {
                        
                        segueInfo.mediaLabel = sound.soundName
                        segueInfo.mediaID = sound.soundName
                        segueInfo.category = sound.category
                        segueInfo.imageName = sound.image
                        segueInfo.label = sound.title
                    }

                    
                    let date = Scheduler.correctSecondComponent(date: self.datePicker.date )
                    var tempAlarm = Alarm()
                    tempAlarm.date = date
                    tempAlarm.label = segueInfo.label
                    tempAlarm.enabled = true
                    tempAlarm.mediaLabel = segueInfo.mediaLabel
                    tempAlarm.mediaID = segueInfo.mediaID
                    tempAlarm.snoozeEnabled = false
                    tempAlarm.imageName = segueInfo.imageName
                    tempAlarm.category = segueInfo.category
                    tempAlarm.repeatWeekdays = segueInfo.repeatWeekdays
                    tempAlarm.uuid = UUID().uuidString
                    tempAlarm.onSnooze = false
                    alarmModel.alarms.append(tempAlarm)
                    alarmScheduler.reSchedule()
                    self.navigationController?.popViewController(animated: true)
//                    self.performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
                    NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)
        
        
                } else {
                    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc : PaywallViewViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "PaywallViewViewController") as! PaywallViewViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
        
    }
}
