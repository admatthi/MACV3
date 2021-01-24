//
//  HomeTableViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 12/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class HomeTableViewController: UITableViewController{
   
    var alarmDelegate: AlarmApplicationDelegate = AppDelegate() as AlarmApplicationDelegate
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmScheduler.checkNotification()
        tableView.allowsSelectionDuringEditing = true
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarmModel = Alarms()
        tableView.reloadData()
        tableView.separatorStyle = .none
        
        //dynamically append the edit button
        if alarmModel.count != 0 {
            self.navigationItem.leftBarButtonItem = editButtonItem
        }
        else {
            self.navigationItem.leftBarButtonItem = nil
        }
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            let statusbarView = UIView()
            statusbarView.backgroundColor = #colorLiteral(red: 0.007841204293, green: 0.007844249718, blue: 0.007841013372, alpha: 1)
            
            navigationController?.navigationBar.addSubview(statusbarView)
            
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor.constraint(equalToConstant: UIApplication.shared.statusBarFrame.size.height).isActive = true
            statusbarView.widthAnchor.constraint(equalTo: navigationController!.navigationBar.widthAnchor).isActive = true
            statusbarView.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.topAnchor).isActive = true
            statusbarView.centerXAnchor.constraint(equalTo: navigationController!.navigationBar.centerXAnchor).isActive = true
        }
        else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = #colorLiteral(red: 0.007841204293, green: 0.007844249718, blue: 0.007841013372, alpha: 1)
        }
        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
        self.navigationController!.navigationBar.setBackgroundImage(UIColor.black.as1ptImage(), for: .default)
//        self.navigationController!.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.shadowImage = UIColor.clear.as1ptImage()
    }
    @objc func onDidReceiveData(_ notification: Notification)
    {
        alarmModel = Alarms()
        tableView.reloadData()
        //dynamically append the edit button
        if alarmModel.count != 0 {
            self.navigationItem.leftBarButtonItem = editButtonItem
        }
        else {
            self.navigationItem.leftBarButtonItem = nil
        }
        alarmScheduler.reSchedule()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if alarmModel.count == 0 {
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
        else {
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
        return alarmModel.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            performSegue(withIdentifier: Id.editSegueIdentifier, sender: SegueInfo(curCellIndex: indexPath.row, isEditMode: true, label: alarmModel.alarms[indexPath.row].label, mediaLabel: alarmModel.alarms[indexPath.row].mediaLabel, mediaID: alarmModel.alarms[indexPath.row].mediaID, repeatWeekdays: alarmModel.alarms[indexPath.row].repeatWeekdays, enabled: alarmModel.alarms[indexPath.row].enabled, snoozeEnabled: alarmModel.alarms[indexPath.row].snoozeEnabled, imageName: alarmModel.alarms[indexPath.row].imageName, category: alarmModel.alarms[indexPath.row].category))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeItemTableViewCell") as! HomeItemTableViewCell
        //cell text
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        cell.mainView.layer.cornerRadius = 10
        cell.soundImageView.layer.cornerRadius = 10
        cell.soundImageView.layer.borderWidth = 1
        cell.soundImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let alarm: Alarm = alarmModel.alarms[indexPath.row]
        cell.soundImageView.image = UIImage(named: alarm.imageName)
//        let amAttr: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont.systemFont(ofSize: 20.0)]
//        let str = NSMutableAttributedString(string: alarm.formattedTime, attributes: amAttr)
//        let timeAttr: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont.systemFont(ofSize: 45.0)]
//        str.addAttributes(timeAttr, range: NSMakeRange(0, str.length-2))
//        cell!.textLabel?.attributedText = str
//        cell!.textLabel?.textColor = .white
//        cell!.detailTextLabel?.textColor = .white
        cell.titleLable.text = alarm.label
        cell.timeLabel.text = alarm.formattedTime.lowercased()
        //append switch button
//        let sw = UISwitch(frame: CGRect())
//        sw.transform = CGAffineTransform(scaleX: 0.9, y: 0.9);
//
//        //tag is used to indicate which row had been touched
//        sw.tag = indexPath.row
        cell.itemSwitch.tag = indexPath.row
        cell.itemSwitch.addTarget(self, action: #selector(self.switchTapped(_:)), for: UIControl.Event.valueChanged)
        if alarm.enabled {
            cell.mainView.backgroundColor = UIColor(red: 0.917, green: 0.917, blue: 0.917, alpha: 0.8)
            cell.titleLable?.alpha = 1.0
            cell.timeLabel.alpha = 1.0
            cell.itemSwitch.setOn(true, animated: false)
        } else {
            cell.mainView.backgroundColor = UIColor(red: 0.917, green: 0.917, blue: 0.917, alpha: 0.8)
            cell.titleLable.alpha = 1
            cell.timeLabel.alpha = 1
            cell.itemSwitch.setOn(false, animated: false)
        }
        
        //delete empty seperator line
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return cell
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        let index = sender.tag
        alarmModel.alarms[index].enabled = sender.isOn
        if sender.isOn {
            print("switch on")
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            alarmScheduler.setNotificationWithDate(alarmModel.alarms[index].date, onWeekdaysForNotify: alarmModel.alarms[index].repeatWeekdays, snoozeEnabled: alarmModel.alarms[index].snoozeEnabled, onSnooze: false, soundName: alarmModel.alarms[index].mediaLabel, index: index)
            tableView.reloadData()
        }
        else {
            print("switch off")
            
            turnoff(referrer: referrer)
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            alarmScheduler.reSchedule()
            tableView.reloadData()
        }
    }
    
    func turnoff(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "turnoff"), parameters: ["referrer" : referrer])
                                 }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.row
            alarmModel.alarms.remove(at: index)
            let cells = tableView.visibleCells
            for cell in cells {
                if let cell = cell as? HomeItemTableViewCell {
                    let sw = cell.itemSwitch!
                    //adjust saved index when row deleted
                    if sw.tag > index {
                        sw.tag -= 1
                    }
                }

            }
            if alarmModel.count == 0 {
                self.navigationItem.leftBarButtonItem = nil
            }
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            alarmScheduler.reSchedule()
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let dist = segue.destination as! UINavigationController
        let addEditController = dist.topViewController as! AlarmEditAddViewController
        if segue.identifier == Id.addSegueIdentifier {
            addEditController.navigationItem.title = "Add Alarm"
            addEditController.modalPresentationStyle = .fullScreen
            let defaultSound = allSounds[0]
            addEditController.segueInfo = SegueInfo(curCellIndex: alarmModel.count, isEditMode: false, label: defaultSound.title, mediaLabel: defaultSound.soundName, mediaID: "", repeatWeekdays: [], enabled: false, snoozeEnabled: false, imageName: defaultSound.image, category: defaultSound.category)
        }
        else if segue.identifier == Id.editSegueIdentifier {
            addEditController.navigationItem.title = "Edit Alarm"
            addEditController.segueInfo = sender as? SegueInfo
        }
    }
    
    @IBAction func unwindFromAddEditAlarmView(_ segue: UIStoryboardSegue) {
        isEditing = false
    }
    
    public func changeSwitchButtonState(index: Int) {
        //let info = notification.userInfo as! [String: AnyObject]
        //let index: Int = info["index"] as! Int
        alarmModel = Alarms()
        if alarmModel.alarms[index].repeatWeekdays.isEmpty {
            alarmModel.alarms[index].enabled = false
        }
        let cells = tableView.visibleCells
        for cell in cells {
            if cell.tag == index {
               if let homeCell = cell as? HomeItemTableViewCell {
                    let sw = homeCell.itemSwitch
                    if alarmModel.alarms[index].repeatWeekdays.isEmpty {
                        sw?.setOn(false, animated: false)
                        homeCell.backgroundColor = UIColor.black
                        homeCell.textLabel?.alpha = 0.5
                        homeCell.detailTextLabel?.alpha = 0.5
                    }
                }

            }
        }
    }

}


extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}
extension UIDatePicker {

     var textColor: UIColor? {
         set {
              setValue(newValue, forKeyPath: "textColor")
             }
         get {
              return value(forKeyPath: "textColor") as? UIColor
             }
     }

     var highlightsToday : Bool? {
         set {
              setValue(newValue, forKeyPath: "highlightsToday")
             }
         get {
              return value(forKey: "highlightsToday") as? Bool
             }
     }
 }
