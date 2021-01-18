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


class AlarmEditAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    var segueInfo: SegueInfo!
    var snoozeEnabled: Bool = false
    var enabled: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        alarmModel=Alarms()
        self.navigationController?.navigationBar.isHidden = true
        tableView.reloadData()
        snoozeEnabled = segueInfo.snoozeEnabled
        
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
        let date = Scheduler.correctSecondComponent(date: datePicker.date)
        let index = segueInfo.curCellIndex
        var tempAlarm = Alarm()
        tempAlarm.date = date
        tempAlarm.label = segueInfo.label
        tempAlarm.enabled = true
        tempAlarm.mediaLabel = segueInfo.mediaLabel
        tempAlarm.mediaID = segueInfo.mediaID
        tempAlarm.snoozeEnabled = snoozeEnabled
        tempAlarm.imageName = segueInfo.imageName
        tempAlarm.category = segueInfo.category
        tempAlarm.repeatWeekdays = segueInfo.repeatWeekdays
        tempAlarm.uuid = UUID().uuidString
        tempAlarm.onSnooze = false
        if segueInfo.isEditMode {
            alarmModel.alarms[index] = tempAlarm
        }
        else {
            alarmModel.alarms.append(tempAlarm)
        }
        self.performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
        NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)
        

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
            return 2
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
        cell!.backgroundColor = .clear
        cell!.selectedBackgroundView?.backgroundColor = .clear
        let image = UIImage(systemName: "chevron.right")
        let accessory  = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width)!, height:(image?.size.height)!))
        accessory.image = image

        // set the color here
        accessory.tintColor = UIColor.white
        cell?.selectionStyle = .none
        cell!.accessoryView = accessory
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                cell?.tintColor = .white
                cell!.textLabel!.text = "Repeat"
                cell!.textLabel?.textColor = .white
                cell!.detailTextLabel?.textColor = .white
                cell!.detailTextLabel!.text = WeekdaysViewController.repeatText(weekdays: segueInfo.repeatWeekdays)
                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
//            else if indexPath.row == 1 {
//                cell!.textLabel?.textColor = .white
//                cell!.detailTextLabel?.textColor = .gray
//                cell!.textLabel!.text = "Label"
//                cell!.detailTextLabel!.text = segueInfo.label
//                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
//            }
            else if indexPath.row == 1 {
                cell!.textLabel?.textColor = .white
                cell!.detailTextLabel?.textColor = .white
                cell!.textLabel!.text = "Sound"
                cell!.detailTextLabel!.text = segueInfo.mediaLabel
                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
//            else if indexPath.row == 3 {
//                cell!.textLabel?.textColor = .white
//                cell!.detailTextLabel?.textColor = .gray
//
//                cell!.textLabel!.text = "Snooze"
//                let sw = UISwitch(frame: CGRect())
//                sw.addTarget(self, action: #selector(AlarmEditAddViewController.snoozeSwitchTapped(_:)), for: UIControl.Event.touchUpInside)
//
//                if snoozeEnabled {
//                   sw.setOn(true, animated: false)
//                }
//
//                cell!.accessoryView = sw
//            }
        }
        else if indexPath.section == 1 {
            cell = UITableViewCell(
                style: UITableViewCell.CellStyle.default, reuseIdentifier: Id.settingIdentifier)
            cell!.selectedBackgroundView?.backgroundColor = .clear
                cell!.backgroundColor = .clear
            cell!.textLabel!.text = "Delete Alarm"
            cell!.textLabel!.textAlignment = .center
            cell!.textLabel!.textColor = UIColor.red
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
            switch indexPath.row{
            case 0:
                performSegue(withIdentifier: Id.weekdaysSegueIdentifier, sender: self)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            case 1:
                performSegue(withIdentifier: Id.selectSoundSegueIdentifier, sender: self)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
//            case 2:
//                performSegue(withIdentifier: Id.selectSoundSegueIdentifier, sender: self)
//                cell?.setSelected(true, animated: false)
//                cell?.setSelected(false, animated: false)
            default:
                break
            }
        }
        else if indexPath.section == 1 {
            //delete alarm
            alarmModel.alarms.remove(at: segueInfo.curCellIndex)
            performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
            NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)
        }
            
    }
   
    @IBAction func snoozeSwitchTapped (_ sender: UISwitch) {
        snoozeEnabled = sender.isOn
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
//            dist.mediaLabel = segueInfo.mediaLabel
            dist.selectedSound = Sounds(soundName: segueInfo.mediaLabel, title: segueInfo.label, image: segueInfo.imageName, category: segueInfo.category)
        }
        else if segue.identifier == Id.labelSegueIdentifier {
            let dist = segue.destination as! TitleEditViewController
            dist.label = segueInfo.label
        }
        else if segue.identifier == Id.weekdaysSegueIdentifier {
            let dist = segue.destination as! WeekdaysViewController
            dist.weekdays = segueInfo.repeatWeekdays
        }
    }
    
    @IBAction func unwindFromLabelEditView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! TitleEditViewController
        segueInfo.label = src.label
    }
    
    @IBAction func unwindFromWeekdaysView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! WeekdaysViewController
        segueInfo.repeatWeekdays = src.weekdays
    }
    
    @IBAction func unwindFromMediaView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! SelectSoundViewController
        if let sound = src.selectedSound {
            segueInfo.mediaLabel = sound.soundName
            segueInfo.label = sound.title
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
