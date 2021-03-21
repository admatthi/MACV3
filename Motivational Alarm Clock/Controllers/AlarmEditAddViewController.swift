//
//  AlarmEditAddViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 12/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import FBSDKCoreKit
import StoreKit

var grayl = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.00)



class AlarmEditAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var isfromOnboarding = false
var isFromSoundVc = false
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    var segueInfo: SegueInfo!
    var snoozeEnabled: Bool = false
    var repeatEnabled: Bool = false
    var enabled: Bool!
    
    
    func selecttime(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "selecttime"), parameters: ["referrer" : referrer])
                                 }
    
    override func viewDidAppear(_ animated: Bool) {
        
        referrer = "EditAlarm"
//        if firstinstall {
//            tapback.alpha = 0
//
//        } else {
//
//            tapback.alpha = 1
//        }
    }
    func notificationpermissionRequest(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let app = UIApplication.shared
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = appDelegate
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound,]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
//
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            app.registerUserNotificationSettings(settings)
        }
        

        app.registerForRemoteNotifications()
    }
    @IBOutlet weak var tapback: UIButton!
    override func viewDidLoad() {
        
        selecttime(referrer: referrer)
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        if isfromOnboarding{
            let refreshAlert = UIAlertController(title: "You'll need to turn on push", message: "In order for us to send you an alarm, you'll need to turn on notifications", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.notificationpermissionRequest()
                  print("Handle Ok logic here")
            }))

            refreshAlert.addAction(UIAlertAction(title: "Not now", style: .cancel, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
                  print("Handle Cancel Logic here")
            }))

            present(refreshAlert, animated: true, completion: nil)
           
        }
        tapsave.layer.borderWidth = 1.0
        tapsave.layer.borderColor = UIColor.white.cgColor
        tapsave.layer.cornerRadius = 10.0
        tapsave.clipsToBounds = true
        tableView.backgroundColor = .clear

        datePicker.becomeFirstResponder()
        datePicker.tintColor = UIColor.white
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            datePicker.preferredDatePickerStyle = .compact // Replace .inline with .compact
        }
        datePicker.overrideUserInterfaceStyle = .dark
        if segueInfo.isEditMode {
            let index = segueInfo.curCellIndex
            datePicker.date = alarmModel.alarms[index].date
        }
        else {
            
            
        }
        if isfromOnboarding{
            datePicker.date = Date().addingTimeInterval(60)
            tapback.isHidden = true
        }else{
            tapback.isHidden = false
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        alarmModel=Alarms()
        self.navigationController?.navigationBar.isHidden = true
        tableView.reloadData()
        repeatEnabled = segueInfo.repeatEnabled
//        let newUserCreatedAlarm = UserDefaults.standard.bool(forKey: "newUserWithOutCreatingAlarm")
//        if newUserCreatedAlarm  {
//            tapback.isHidden = false
//        } else {
//            tapback.isHidden = true
//        }
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            let statusbarView = UIView()
            statusbarView.backgroundColor = self.view.backgroundColor
            
            navigationController?.navigationBar.addSubview(statusbarView)
            
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor.constraint(equalToConstant: UIApplication.shared.statusBarFrame.size.height).isActive = true
            statusbarView.widthAnchor.constraint(equalTo: navigationController!.navigationBar.widthAnchor).isActive = true
            statusbarView.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.topAnchor).isActive = true
            statusbarView.centerXAnchor.constraint(equalTo: navigationController!.navigationBar.centerXAnchor).isActive = true
        }
        else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = self.view.backgroundColor
        }
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController!.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.shadowImage = UIColor.clear.as1ptImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func saveEditAlarm(_ sender: AnyObject) {
        
        firstinstall = false
        tapsave(referrer: referrer)
        

//         didpurchase = true
        let index = segueInfo.curCellIndex
        if segueInfo.isEditMode{
            if alarmModel.alarms[index].isDailyWake {
                createalarm(referrer: referrer)
                


                let interval = Date() - self.datePicker.date
                print(interval.day)
                print(interval.month)
                print(interval.hour)
                let modifiedDate = Calendar.current.date(byAdding: .day, value: interval.day ?? 0, to: self.datePicker.date)!
                print(modifiedDate)
                let date = Scheduler.correctSecondComponent(date: modifiedDate)
                let index = segueInfo.curCellIndex
                var tempAlarm = Alarm()
                tempAlarm.date = date
                tempAlarm.label = segueInfo.label
                tempAlarm.enabled = true
                tempAlarm.mediaLabel = segueInfo.mediaLabel
                tempAlarm.mediaID = segueInfo.mediaID
                tempAlarm.snoozeEnabled = false
                tempAlarm.repeatEnabled = self.repeatEnabled
                tempAlarm.imageName = segueInfo.imageName
                tempAlarm.category = segueInfo.category
                tempAlarm.repeatWeekdays = segueInfo.repeatWeekdays
                tempAlarm.uuid = UUID().uuidString
                tempAlarm.onSnooze = false
                if segueInfo.isEditMode {
                    if alarmModel.alarms[index].isDailyWake{
                        tempAlarm.isDailyWake = true
                    }
                    alarmModel.alarms[index] = tempAlarm

                }
                else {
                    alarmModel.alarms.append(tempAlarm)
                }
                alarmScheduler.reSchedule()
                self.dismiss(animated: true, completion: nil)
                if self.isFromSoundVc{
                    if let viewController = UIApplication.shared.windows.first!.rootViewController as? TabBarViewController {
                        viewController.selectedIndex = 0
                    }
                    
                }
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

                let newUserCreatedAlarm = UserDefaults.standard.bool(forKey: "newUserWithOutCreatingAlarm")
                if newUserCreatedAlarm  {

                } else {
                    UserDefaults.standard.setValue(true,forKey: "newUserWithOutCreatingAlarm")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    print("Not first launch.")
                    let vc : UITabBarController = mainStoryboardIpad.instantiateViewController(withIdentifier: "mainTabbarController") as! UITabBarController
                    appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                    appDelegate.window?.rootViewController = vc
                    appDelegate.window?.makeKeyAndVisible()
                }
    //                    self.performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
                NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)


            }
        }

        if didpurchase || isfromOnboarding {
                    
                    createalarm(referrer: referrer)
                    


                    let interval = Date() - self.datePicker.date
                    print(interval.day)
                    print(interval.month)
                    print(interval.hour)
                    let modifiedDate = Calendar.current.date(byAdding: .day, value: interval.day ?? 0, to: self.datePicker.date)!
                    print(modifiedDate)
                    let date = Scheduler.correctSecondComponent(date: modifiedDate)
                    let index = segueInfo.curCellIndex
                    var tempAlarm = Alarm()
                    tempAlarm.date = date
                    tempAlarm.label = segueInfo.label
                    tempAlarm.enabled = true
                    tempAlarm.mediaLabel = segueInfo.mediaLabel
                    tempAlarm.mediaID = segueInfo.mediaID
                    tempAlarm.snoozeEnabled = false
                    tempAlarm.repeatEnabled = self.repeatEnabled
                    tempAlarm.imageName = segueInfo.imageName
                    tempAlarm.category = segueInfo.category
                    tempAlarm.repeatWeekdays = segueInfo.repeatWeekdays
                    tempAlarm.uuid = UUID().uuidString
                    tempAlarm.onSnooze = false
                    if segueInfo.isEditMode {
                        if alarmModel.alarms[index].isDailyWake{
                            tempAlarm.isDailyWake = true
                        }
                        alarmModel.alarms[index] = tempAlarm
                    }
                    else {
                        let alarmCount =  UserDefaults.standard.integer(forKey: "alarmCount")
                        UserDefaults.standard.setValue(alarmCount+1, forKey: "alarmCount")
                        alarmModel.alarms.append(tempAlarm)
                    }
                    alarmScheduler.reSchedule()
                    self.dismiss(animated: true, completion: nil)
                    if self.isFromSoundVc{
                        if let viewController = UIApplication.shared.windows.first!.rootViewController as? TabBarViewController {
                            viewController.selectedIndex = 0
                        }
                        
                    }
                    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

                    let newUserCreatedAlarm = UserDefaults.standard.bool(forKey: "newUserWithOutCreatingAlarm")
                    if newUserCreatedAlarm  {

                    } else {
                        UserDefaults.standard.setValue(true,forKey: "newUserWithOutCreatingAlarm")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        print("Not first launch.")
                        let vc : UITabBarController = mainStoryboardIpad.instantiateViewController(withIdentifier: "mainTabbarController") as! UITabBarController
                        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                        appDelegate.window?.rootViewController = vc
                        appDelegate.window?.makeKeyAndVisible()
                    }
//                    self.performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
                    NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)
            if isfromOnboarding{
                NotificationCenter.default.post(name: .didFinishOnbaordingScreen, object: self, userInfo: nil)
            }
        
                } else {
                    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc : PaywallViewViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "PaywallViewViewController") as! PaywallViewViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
//                    self.performSegue(withIdentifier: "AlarmToPayWall", sender: self)
                }
        
    }
    
 
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        if segueInfo.isEditMode {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        else {
            return 1
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: Id.settingIdentifier)
       
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: Id.settingIdentifier)
        }
        cell!.backgroundColor = grayl
        cell!.selectedBackgroundView?.backgroundColor = grayl
        
        
        let image = UIImage(systemName: "chevron.right")
        let accessory  = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width)!, height:(image?.size.height)!))
        accessory.image = image

        // set the color here
        accessory.tintColor = UIColor.white
        cell?.selectionStyle = .none
        cell!.accessoryView = accessory
        if indexPath.section == 0 {
            
//            if indexPath.row == 0 {
//                cell?.tintColor = .white
//                cell!.textLabel!.text = "Repeat"
//                cell!.textLabel?.textColor = .white
//                cell!.detailTextLabel?.textColor = .white
//                cell!.textLabel!.font = UIFont(name: "Avenir-Next", size: CGFloat(22))
//
//                cell!.detailTextLabel!.text = SelectWeekdaysViewController.repeatText(weekdays: segueInfo.repeatWeekdays)
//                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
//            }
//            else
            if indexPath.row == 0 {
                cell!.textLabel?.textColor = .white
                cell!.detailTextLabel?.textColor = .gray
                cell!.textLabel!.text = "Label"
                cell!.detailTextLabel!.text = segueInfo.label
                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
            else if indexPath.row == 1 {
                cell!.textLabel?.textColor = .white
                cell!.detailTextLabel?.textColor = .white
                cell!.textLabel!.text = "Sound"
                cell!.detailTextLabel!.text = segueInfo.mediaLabel
                cell!.textLabel!.font = UIFont(name: "Avenir-Next", size: CGFloat(22))

                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
            else if indexPath.row == 2 {
                cell!.textLabel?.textColor = .white
                cell!.detailTextLabel?.textColor = .gray

                cell!.textLabel!.text = "Repeat"
                let sw = UISwitch(frame: CGRect())
                sw.addTarget(self, action: #selector(AlarmEditAddViewController.repeatSwitchTapped(_:)), for: UIControl.Event.touchUpInside)

                if repeatEnabled {
                   sw.setOn(true, animated: false)
                }

                cell!.accessoryView = sw
            }
        }
        else if indexPath.section == 1 {
            cell = UITableViewCell(
                style: UITableViewCell.CellStyle.default, reuseIdentifier: Id.settingIdentifier)
            cell!.selectedBackgroundView?.backgroundColor = .clear
                cell!.backgroundColor = .clear

                        cell!.textLabel!.text = "Delete Alarm"
                        cell!.textLabel!.text = ""

            cell!.textLabel!.textAlignment = .center
            cell!.textLabel!.textColor = UIColor.red
            cell?.isUserInteractionEnabled = false
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
            switch indexPath.row{
//            case 0:
//                performSegue(withIdentifier: Id.weekdaysSegueIdentifier, sender: self)
//                cell?.setSelected(true, animated: false)
//                cell?.setSelected(false, animated: false)
            case 0:
                
                if segueInfo.isEditMode {
                    let index = segueInfo.curCellIndex
                    if alarmModel.alarms[index].isDailyWake{
                        
                    }else{
                        performSegue(withIdentifier: Id.labelSegueIdentifier, sender: self)
                        cell?.setSelected(true, animated: false)
                        cell?.setSelected(false, animated: false)
                    }
                }
                else {
                    performSegue(withIdentifier: Id.labelSegueIdentifier, sender: self)
                    cell?.setSelected(true, animated: false)
                    cell?.setSelected(false, animated: false)
                }

            case 1:
                if segueInfo.isEditMode {
                    let index = segueInfo.curCellIndex
                    if alarmModel.alarms[index].isDailyWake{
                        
                    }else{
                        performSegue(withIdentifier: Id.selectSoundSegueIdentifier, sender: self)
                        cell?.setSelected(true, animated: false)
                        cell?.setSelected(false, animated: false)
                    }
                }
                else {
                    performSegue(withIdentifier: Id.selectSoundSegueIdentifier, sender: self)
                    cell?.setSelected(true, animated: false)
                    cell?.setSelected(false, animated: false)
                }

            default:
                break
            }
        }
        else if indexPath.section == 1 {
            alarmModel.alarms.remove(at: segueInfo.curCellIndex)
            performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
            NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)
        }
            
    }
    @IBOutlet weak var tapsave: UIButton!
    
    @IBOutlet weak var mainview: UIVisualEffectView!
    
    
    @IBAction func repeatSwitchTapped (_ sender: UISwitch) {
        
        
        repeatEnabled = sender.isOn
        segueInfo.repeatEnabled = sender.isOn
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    func createalarm(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "createalarm"), parameters: ["referrer" : referrer, "alarmname" : alarmname])
                                 }

    func tapsave(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "tapsave"), parameters: ["referrer" : referrer, "alarmname" : alarmname])
                                 }
    func turnoff(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "turnoff"), parameters: ["referrer" : referrer, "alarmname" : alarmname])
                                 }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Id.saveSegueIdentifier {
            let dist = segue.destination as! HomeViewController
            let cells = dist.tableView.visibleCells
            for cell in cells {
                if let cell = cell as? HomeItemTableViewCell {
                let sw = cell.itemSwitch!
                if sw.tag > segueInfo.curCellIndex
                {
                    
                    turnoff(referrer: referrer)
                    sw.tag -= 1
                }
            }
            alarmScheduler.reSchedule()
        }
        }
        else if segue.identifier == Id.selectSoundSegueIdentifier {
            //TODO
            let dist = segue.destination as! SelectSoundViewController
//            dist.mediaID = segueInfo.mediaID
            dist.segueInfo = segueInfo
            dist.date = datePicker.date
            let sound = allSounds.filter({$0.soundName == segueInfo.mediaLabel && $0.image == segueInfo.imageName && $0.category == segueInfo.category  }).first
            dist.selectedSound = Sounds(soundName: segueInfo.mediaLabel, title: segueInfo.imageName, image: segueInfo.imageName, category: segueInfo.category,popular: sound?.popular ?? 0)
        }
        else if segue.identifier == Id.labelSegueIdentifier {
            let dist = segue.destination as! TitleEditViewController
            dist.label = segueInfo.label
        }
        else if segue.identifier == Id.weekdaysSegueIdentifier {
            let dist = segue.destination as! SelectWeekdaysViewController
            dist.weekdays = segueInfo.repeatWeekdays
        }
    }
    
    @IBAction func unwindFromLabelEditView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! TitleEditViewController
        segueInfo.label = src.label
    }
    
    @IBAction func unwindFromWeekdaysView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! SelectWeekdaysViewController
        segueInfo.repeatWeekdays = src.weekdays
    }
    
    @IBAction func unwindFromMediaView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! SelectSoundViewController
        if let sound = src.selectedSound {
            segueInfo.mediaLabel = sound.soundName
            segueInfo.mediaID = ""
            segueInfo.imageName = sound.image
            segueInfo.category = sound.category
            
        }
        
    }
    
    
}


extension UIView {
   var allSubviews: [UIView] {
      return subviews.flatMap { [$0] + $0.allSubviews }
   }
}
extension UIColor {

    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
