//
//  HomeViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 18/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    
     var alarmDelegate: AlarmApplicationDelegate = AppDelegate() as AlarmApplicationDelegate
     var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
     var alarmModel: Alarms = Alarms()
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        alarmScheduler.checkNotification()
        tableView.allowsSelectionDuringEditing = true
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        self.navigationController?.navigationBar.isHidden = true

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if alarmModel.alarms.count > 0 {
//            editButton.isHidden = false
//        }else{
//            editButton.isHidden = true
//        }
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = false
    }
    @IBAction func editDoneButtonAction(_ sender: UIButton) {
//        if self.tableView.isEditing{
//            editButton.setTitle("Edit", for: .normal)
//            editButton.setTitle("Edit", for: .selected)
//            isEditing = false
//            self.tableView.setEditing(false, animated: true)
//        }else{
//            editButton.setTitle("Done", for: .normal)
//            editButton.setTitle("Done", for: .selected)
//            isEditing = true
//            self.tableView.setEditing(true, animated: true)
//        }
        
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
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

     func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if alarmModel.count == 0 {
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
        else {
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
        return alarmModel.count
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            performSegue(withIdentifier: Id.editSegueIdentifier, sender: SegueInfo(curCellIndex: indexPath.row, isEditMode: true, label: alarmModel.alarms[indexPath.row].label, mediaLabel: alarmModel.alarms[indexPath.row].mediaLabel, mediaID: alarmModel.alarms[indexPath.row].mediaID, repeatWeekdays: alarmModel.alarms[indexPath.row].repeatWeekdays, enabled: alarmModel.alarms[indexPath.row].enabled, snoozeEnabled: alarmModel.alarms[indexPath.row].snoozeEnabled, imageName: alarmModel.alarms[indexPath.row].imageName, category: alarmModel.alarms[indexPath.row].category))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeItemTableViewCell") as! HomeItemTableViewCell
        //cell text
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        cell.mainView.layer.cornerRadius = 10
        cell.soundImageView.layer.cornerRadius = 10
//        cell.soundImageView.layer.borderWidth = 1
//        cell.soundImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
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
            alarmScheduler.setNotificationWithDate(alarmModel.alarms[index].date, onWeekdaysForNotify: alarmModel.alarms[index].repeatWeekdays, snoozeEnabled: alarmModel.alarms[index].snoozeEnabled, onSnooze: false, soundName: alarmModel.alarms[index].mediaLabel, index: index)
            tableView.reloadData()
        }
        else {
            print("switch off")
            alarmScheduler.reSchedule()
            tableView.reloadData()
        }
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
//            if alarmModel.alarms.count > 0 {
//                editButton.isHidden = false
//            }else{
//                editButton.isHidden = true
//            }
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
        self.tableView.setEditing(false, animated: true)
//        editButton.setTitle("Edit", for: .normal)
//        editButton.setTitle("Edit", for: .selected)
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
//                        homeCell.backgroundColor = UIColor.black
                        homeCell.textLabel?.alpha = 0.5
                        homeCell.detailTextLabel?.alpha = 0.5
                    }
                }

            }
        }
    }

}
