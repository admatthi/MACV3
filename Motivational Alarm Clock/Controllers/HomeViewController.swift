//
//  HomeViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 18/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox
import AVFoundation
import FBSDKCoreKit
import StoreKit

var alarmname = String()

class HomeViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate{
    var selectedAlarm:Alarm?
     var alarmDelegate: AlarmApplicationDelegate = AppDelegate() as AlarmApplicationDelegate
     var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
     var alarmModel: Alarms = Alarms()
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var audioPlayer: AVAudioPlayer?
    var ifAlreadyPresented = false
    var soundsCategories = ["Popular", "All", "Inspiration", "Affirmations", "Self Help", "Career", "Sounds"]
    var selectedCategory = "Popular"
    override func viewDidAppear(_ animated: Bool) {
        
        referrer = "HomeAlarm"
        allSounds = allSounds.filter({$0.category == "Popular" || $0.category == "All" || $0.category == "Inspiration" || $0.category == "Affirmations" || $0.category == "Self Help" || $0.category == "Career" || $0.category == "Dating" || $0.category == "Sounds" } )
        if didpurchase {
            
            
        } else {
            
            if !ifAlreadyPresented{
                
                ifAlreadyPresented = true
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : PaywallViewViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "PaywallViewViewController") as! PaywallViewViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }

            
//            self.performSegue(withIdentifier: "HomeToPaywall", sender: self)
        }
    }
    
    func queryforinfo() {
            
            ref?.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                
                if let purchased = value?["Purchased"] as? String {
                    
                    if purchased == "True" {
                        
                        didpurchase = true
                        
                    } else {
                        
                        didpurchase = false
                        
                     
                        if !self.ifAlreadyPresented{
                                
                                self.ifAlreadyPresented = true
                                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc : PaywallViewViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "PaywallViewViewController") as! PaywallViewViewController
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }

                            
                //            self.performSegue(withIdentifier: "HomeToPaywall", sender: self)
                    
                        
                    }
                    
                } else {
                    
                    didpurchase = false
                    
                    
                    if !self.ifAlreadyPresented{
                               
                        self.ifAlreadyPresented = true
                               let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                               let vc : PaywallViewViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "PaywallViewViewController") as! PaywallViewViewController
                               vc.modalPresentationStyle = .fullScreen
                               self.present(vc, animated: true, completion: nil)
                           }
                }
                
            })
            
        }
    
    func homeview(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "homeview"), parameters: ["referrer" : referrer])
                                 }
    override func viewDidLoad() {
        setupTodayorFutureDate()
        ref = Database.database().reference()

        homeview(referrer: referrer)
        super.viewDidLoad()
        editButton.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.separatorStyle = .none
        alarmScheduler.checkNotification()
        tableView.allowsSelectionDuringEditing = true
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.navigationController?.navigationBar.isHidden = true
        var error: NSError?
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch let error1 as NSError{
            error = error1
            print("could not set session. err:\(error!.localizedDescription)")
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error1 as NSError{
            error = error1
            print("could not active session. err:\(error!.localizedDescription)")
        }
        
        queryforinfo()
        
//        if didpurchase {
//
//
//        } else {
//
//            self.performSegue(withIdentifier: "HomeToPaywall", sender: self)
//        }
        

    }
    @objc func appMovedToBackground() {
            // do whatever event you want
        self.selectedAlarm = nil
        self.tableView.reloadData()
        stopSound()
        }
    @objc func appMovedToForeground() {
            // do whatever event you want
        setupTodayorFutureDate()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedAlarm = nil
        allSounds.shuffle()
        allSounds = allSounds.sorted { $0.popular ?? 0 > $1.popular ?? 0 }
        alarmModel = Alarms()
        addAlarmForNewUsers()
        self.tableView.reloadData()
//        if alarmModel.alarms.count > 0 {
//            editButton.isHidden = false
//        }else{
//            editButton.isHidden = true
//        }
        alarmScheduler.reSchedule()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSound()
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
        if alarmModel.alarms.count == 0 {
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
        else {
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
        return alarmModel.alarms.count
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: Id.editSegueIdentifier, sender: SegueInfo(curCellIndex: indexPath.row, isEditMode: true, label: alarmModel.alarms[indexPath.row].label, mediaLabel: alarmModel.alarms[indexPath.row].mediaLabel, mediaID: alarmModel.alarms[indexPath.row].mediaID, repeatWeekdays: alarmModel.alarms[indexPath.row].repeatWeekdays, enabled: alarmModel.alarms[indexPath.row].enabled, snoozeEnabled: alarmModel.alarms[indexPath.row].snoozeEnabled, imageName: alarmModel.alarms[indexPath.row].imageName, category: alarmModel.alarms[indexPath.row].category, repeatEnabled: alarmModel.alarms[indexPath.row].repeatEnabled))
    }
    @objc func playPauseAction(sender : UIButton){
        if audioGlobalPlayer != nil {
            audioGlobalPlayer!.stop()
        }
        let alarm: Alarm = alarmModel.alarms[sender.tag]
        if selectedAlarm?.uuid == alarm.uuid {
            stopSound()
            selectedAlarm = nil
        }else{
            playSound(alarm.mediaLabel)
            selectedAlarm =  alarm
        }
        self.tableView.reloadData()
        
     }
    func playSound(_ soundName: String) {
        
//        //vibrate phone first
//        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//        //set vibrate callback
//        AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
//            nil,
//            { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
//                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//            },
//            nil)
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
        }
        
        //negative number means loop infinity
        audioPlayer!.numberOfLoops = -1
        audioPlayer!.play()
    }
    func stopSound() {
        if audioPlayer != nil {
            if audioPlayer!.isPlaying {
                audioPlayer!.stop()
            }
        }

        
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if alarmModel.alarms[indexPath.row].isDailyWake == true {
            return .none
        }else{
            return .delete
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeItemTableViewCell") as! HomeItemTableViewCell
        //cell text
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        cell.mainView.layer.cornerRadius = 10
        cell.mainView.clipsToBounds = true
        
//        cell.soundImageView.layer.borderWidth = 1
//        cell.soundImageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let alarm: Alarm = alarmModel.alarms[indexPath.row]
//        cell.soundImageView.image = UIImage(named: alarm.imageName)
        cell.sound2.image = UIImage(named: alarm.imageName)
        
//        cell.soundImageView.layer.cornerRadius = cell.soundImageView.frame.width/2
//        cell.soundImageView.clipsToBounds = true

//        let amAttr: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont.systemFont(ofSize: 20.0)]
//        let str = NSMutableAttributedString(string: alarm.formattedTime, attributes: amAttr)
//        let timeAttr: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : UIFont.systemFont(ofSize: 45.0)]
//        str.addAttributes(timeAttr, range: NSMakeRange(0, str.length-2))
//        cell!.textLabel?.attributedText = str
//        cell!.textLabel?.textColor = .white
//        cell!.detailTextLabel?.textColor = .white
        cell.titleLable.text = alarm.label
        cell.timeLabel.text = alarm.formattedTime.lowercased().replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        cell.playPauseButton.setImage(nil, for: .normal)
        cell.playPauseButton.setImage(nil, for: .selected)
        cell.playPauseButton.tag = indexPath.row
        cell.playPauseButton.addTarget(self,
                                       action: #selector(self.playPauseAction(sender:)),
                for: .touchUpInside)
        if selectedAlarm?.uuid == alarmModel.alarms[indexPath.row].uuid {
            cell.playPauseButton.setImage(UIImage(named: "Bitmap"), for: .normal)
            cell.playPauseButton.setImage(UIImage(named: "Bitmap"), for: .selected)
        }else{
            cell.playPauseButton.setImage(UIImage(named: "playButton"), for: .normal)
            cell.playPauseButton.setImage(UIImage(named: "playButton"), for: .selected)
            
        }

        //append switch button
//        let sw = UISwitch(frame: CGRect())
//        sw.transform = CGAffineTransform(scaleX: 0.9, y: 0.9);
//
//        //tag is used to indicate which row had been touched
//        sw.tag = indexPath.row
        cell.itemSwitch.tag = indexPath.row
        cell.itemSwitch.addTarget(self, action: #selector(self.switchTapped(_:)), for: UIControl.Event.valueChanged)
        
        cell.sound2.layer.cornerRadius = cell.sound2.frame.width/2
        cell.sound2.clipsToBounds = true
        
        
        if alarm.enabled {
//            cell.mainView.backgroundColor = UIColor(red: 0.917, green: 0.917, blue: 0.917, alpha: 0.8)
            cell.timeLabel.alpha = 1.0
            cell.titleLable.alpha = 1.0
//            cell.soundImageView.alpha = 0.5
            cell.sound2.alpha = 1.0
//            cell.mainView.alpha = 1.0
            cell.playPauseButton.alpha = 1.0
            cell.itemSwitch.setOn(true, animated: false)
        } else {
//            cell.mainView.backgroundColor = UIColor(red: 0.917, green: 0.917, blue: 0.917, alpha: 0.8)
            cell.timeLabel.alpha = 0.8
            cell.titleLable.alpha = 0.8
//            cell.soundImageView.alpha = 0.5
            cell.sound2.alpha = 0.8
//            cell.mainView.alpha = 0.8
            cell.playPauseButton.alpha = 0.8
            cell.itemSwitch.setOn(false, animated: false)
        }
        
        if indexPath.row > 1 {
            
            SKStoreReviewController.requestReview()
        }
        
        //delete empty seperator line
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return cell
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        if audioGlobalPlayer != nil {
            audioGlobalPlayer!.stop()
        }
        let index = sender.tag
        alarmModel.alarms[index].enabled = sender.isOn
        if sender.isOn {
            let date = alarmModel.alarms[index].date
            if (date.timeIntervalSinceNow.sign == .minus) {
                // date is in past
                let calendar = Calendar.current
                let time=calendar.dateComponents([.hour,.minute,.second], from: alarmModel.alarms[index].date)
                let newDate = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
                alarmModel.alarms[index].date = newDate
                if (newDate.timeIntervalSinceNow.sign == .minus) {
                    let calendar = Calendar.current
                    let time=calendar.dateComponents([.hour,.minute,.second], from: alarmModel.alarms[index].date)
                    let againNewDate = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
                    let today = againNewDate
                    if  let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today){
                        alarmModel.alarms[index].date = tomorrow
                    }
                   
                }
                
            }else if (date.timeIntervalSinceNow.sign == .plus) {
                // date is in future
            }
            

            print("switch on")
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            alarmScheduler.reSchedule()
            tableView.reloadData()
        }
        else {
            print("switch off")
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            turnoff(referrer: referrer)
            alarmScheduler.reSchedule()
            tableView.reloadData()
        }
    }
    func setupTodayorFutureDate(){
        for (index,alarm) in alarmModel.alarms.enumerated(){
//            if alarm.isDailyWake {
//                var filteredSounds = allSounds.filter({$0.category == selectedCategory})
//                filteredSounds.shuffle()
//                let firstSound = filteredSounds[0]
//                alarmModel.alarms[index].mediaLabel = firstSound.soundName
//                alarmModel.alarms[index].mediaID = firstSound.soundName
//                alarmModel.alarms[index].imageName = firstSound.image
//                alarmModel.alarms[index].category = firstSound.category
//            }
            let date = alarmModel.alarms[index].date
            if (date.timeIntervalSinceNow.sign == .minus) {
                if alarm.repeatEnabled {
                    // date is in past
                    if alarm.isDailyWake {
                        var filteredSounds = allSounds.filter({$0.category == selectedCategory})
                        filteredSounds.shuffle()
                        let firstSound = filteredSounds[0]
                        alarmModel.alarms[index].mediaLabel = firstSound.soundName
                        alarmModel.alarms[index].mediaID = firstSound.soundName
                        alarmModel.alarms[index].imageName = firstSound.image
                        alarmModel.alarms[index].category = firstSound.category
                    }
                    let calendar = Calendar.current
                    let time=calendar.dateComponents([.hour,.minute,.second], from: alarmModel.alarms[index].date)
                    let newDate = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
                    alarmModel.alarms[index].date = newDate
                    if (newDate.timeIntervalSinceNow.sign == .minus) {
                        let calendar = Calendar.current
                        let time=calendar.dateComponents([.hour,.minute,.second], from: alarmModel.alarms[index].date)
                        let againNewDate = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
                        let today = againNewDate
                        if  let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today){
                            alarmModel.alarms[index].date = tomorrow
                        }
                       
                    }
                }else{
                    alarmModel.alarms[index].enabled = false
                }

                
            }else if (date.timeIntervalSinceNow.sign == .plus) {
                // date is in future
            }
            
            
        }
        alarmScheduler.reSchedule()
        self.tableView.reloadData()
    }
    func turnoff(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "turnoff"), parameters: ["referrer" : referrer])
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
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            if alarmModel.alarms.count > 0 {
                if index == alarmModel.alarms.count {
                    
                }else{
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
               
            }
            

//            if alarmModel.alarms.count > 0 {
//                editButton.isHidden = false
//            }else{
//                editButton.isHidden = true
//            }
            alarmScheduler.reSchedule()
        }
    }
    func addAlarmForNewUsers()
    {
       let isInitialAlrmCreatedForDaily = UserDefaults.standard.bool(forKey: "isInitialAlrmCreatedForDaily")
        if !isInitialAlrmCreatedForDaily{
            allSounds = allSounds.sorted { $0.popular ?? 0 > $1.popular ?? 0 }
            let filteredSounds = allSounds.filter({$0.category == selectedCategory && $0.soundName == "CT Fletcher"})
            let firstSound = filteredSounds[0]
            var firstDate = Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date())!
            if (firstDate.timeIntervalSinceNow.sign == .minus) {
                // date is in past
                let calendar = Calendar.current
                let time=calendar.dateComponents([.hour,.minute,.second], from: firstDate)
                let newDate = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
                firstDate = newDate
                if (newDate.timeIntervalSinceNow.sign == .minus) {
                    let calendar = Calendar.current
                    let time=calendar.dateComponents([.hour,.minute,.second], from: firstDate)
                    let againNewDate = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
                    let today = againNewDate
                    if  let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today){
                        firstDate = tomorrow
                    }

                }

            }else if (firstDate.timeIntervalSinceNow.sign == .plus) {
                // date is in future
            }
            
            var secondDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
            if (secondDate.timeIntervalSinceNow.sign == .minus) {
                // date is in past
                let calendar = Calendar.current
                let time=calendar.dateComponents([.hour,.minute,.second], from: secondDate)
                let newDate = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
                secondDate = newDate
                if (newDate.timeIntervalSinceNow.sign == .minus) {
                    let calendar = Calendar.current
                    let time=calendar.dateComponents([.hour,.minute,.second], from: secondDate)
                    let againNewDate = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of: Date())!
                    let today = againNewDate
                    if  let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today){
                        secondDate = tomorrow
                    }

                }

            }else if (firstDate.timeIntervalSinceNow.sign == .plus) {
                // date is in future
            }
            var tempAlarm = Alarm()
            tempAlarm.date = firstDate
            tempAlarm.label = "Daily Wake"
            tempAlarm.enabled = true
            tempAlarm.mediaLabel = firstSound.soundName
            tempAlarm.mediaID = firstSound.soundName
            tempAlarm.snoozeEnabled = false
            tempAlarm.imageName = firstSound.image
            tempAlarm.category = firstSound.category
            tempAlarm.repeatWeekdays = []
            tempAlarm.uuid = UUID().uuidString
            tempAlarm.onSnooze = false
            tempAlarm.enabled = false
            tempAlarm.repeatEnabled = true
            tempAlarm.isDailyWake = true
            alarmModel.alarms.append(tempAlarm)
            alarmScheduler.reSchedule()
            NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)
            UserDefaults.standard.setValue(true, forKey: "isInitialAlrmCreatedForDaily")
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
            
            // pin default logic for sound
//            allSounds = allSounds.sorted { $0.popular ?? 0 > $1.popular ?? 0 }

            let firstFilteredSounds = allSounds.filter({$0.category == selectedCategory})
            let defaultSound = firstFilteredSounds[0]
            addEditController.segueInfo = SegueInfo(curCellIndex: alarmModel.count, isEditMode: false, label: "Alarm", mediaLabel: defaultSound.soundName, mediaID: "", repeatWeekdays: [], enabled: false, snoozeEnabled: false, imageName: defaultSound.image, category: defaultSound.category, repeatEnabled: true)
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
                        homeCell.timeLabel.alpha = 0.5
                    }
                }

            }
        }
    }

}

