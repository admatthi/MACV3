//
//  SelectSoundViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 13/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import AVFoundation
import FBSDKCoreKit

var soundname = String()

class SelectSoundViewController: UIViewController ,AVAudioPlayerDelegate{
    var segueInfo: SegueInfo!
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    var date : Date?
    var filteredSounds:[Sounds] = []
    var selectedSound:Sounds?
//    var soundsCategories = ["Motivation","Prayers", "Meditation", "Fitness", "Money" ]
    
    var soundsCategories = ["Popular", "All", "Inspiration", "Affirmations", "Self Help", "Career", "Sounds"]
    func selectsound(referrer : String) {
        AppEvents.logEvent(AppEvents.Name(rawValue: "selectsound"), parameters: ["referrer" : referrer, "soundname" : soundname])
                                 }

//    var soundsCategories = ["Motivation","Faith","Self Help","Fitness", "Social", "Business", "Philosophy", "Spirituality" ]
    var selectedCategory = "Popular"
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    var mediaLabel: String!
    var mediaID: String!
    var image:String!
    var soundtitle:String!
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var tapback: UIButton!
    override func viewDidLoad() {
//        allSounds.shuffle()
        
//       let firstFilteredSounds = allSounds.filter({$0.category == selectedCategory})
//        if firstFilteredSounds.count > 0  && !segueInfo.isEditMode{
//            selectedSound = firstFilteredSounds[0]
//        }
        selectsound(referrer: referrer)
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

      
        if let category = selectedSound?.category{
            selectedCategory = category
        }
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
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        layout.itemSize = CGSize(width: 80, height: 90)
        collectionView.collectionViewLayout = layout
        
        tagSelection(tag: selectedCategory, isFirst: false)
        if selectedSound != nil{
            playSound(selectedSound!.soundName)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        referrer = "SelectSound"

//        if firstinstall {
//            tapback.alpha = 0
//            
//        } else {
//            
//            tapback.alpha = 1
//        }
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

                    
                    let date = Scheduler.correctSecondComponent(date: self.date ?? Date())
                    let index = segueInfo.curCellIndex
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
                    if segueInfo.isEditMode {
                        alarmModel.alarms[index] = tempAlarm
                    }
                    else {
                        alarmModel.alarms.append(tempAlarm)
                    }
                    alarmScheduler.reSchedule()
                    self.dismiss(animated: true, completion: nil)
//                    self.performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
                    NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)
        
        
                } else {
                    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc : PaywallViewViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "PaywallViewViewController") as! PaywallViewViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
//                    self.performSegue(withIdentifier: "AlarmToPayWall", sender: self)
                }
        
    }

    @objc func appMovedToBackground() {
            // do whatever event you want
        audioPlayer?.stop()
        }
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
//        self.navigationController?.navigationBar.backgroundColor = .clear
//        if #available(iOS 13.0, *) {
//            let statusbarView = UIView()
//            statusbarView.backgroundColor = .clear
//
//            navigationController?.navigationBar.addSubview(statusbarView)
//
//            statusbarView.translatesAutoresizingMaskIntoConstraints = false
//            statusbarView.heightAnchor.constraint(equalToConstant: UIApplication.shared.statusBarFrame.size.height).isActive = true
//            statusbarView.widthAnchor.constraint(equalTo: navigationController!.navigationBar.widthAnchor).isActive = true
//            statusbarView.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.topAnchor).isActive = true
//            statusbarView.centerXAnchor.constraint(equalTo: navigationController!.navigationBar.centerXAnchor).isActive = true
//        }
//        else {
//            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
//            statusBar?.backgroundColor = .clear
//        }
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
//        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
////        self.navigationController!.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.shadowImage = UIColor.clear.as1ptImage()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    performSegue(withIdentifier: Id.soundUnwindIdentifier, sender: self)
//        self.navigationController?.navigationBar.isHidden = false

        
    }
    func tagSelection(tag:String,isFirst:Bool){
        filteredSounds = allSounds.filter({$0.category == tag})
        if isFirst {
            if filteredSounds.count > 0 {
                let sound = filteredSounds[0]
                selectedSound = sound
                if selectedSound != nil{
                    playSound(selectedSound!.soundName)
                }
                segueInfo.mediaLabel = sound.soundName
                segueInfo.mediaID = sound.soundName
                segueInfo.category = sound.category
                segueInfo.imageName = sound.image
                segueInfo.label = sound.title
            }
        }
        self.tagsCollectionView.reloadData()
        self.collectionView.reloadData()
        let seconds = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if let index = self.filteredSounds.lastIndex(where: {$0.title == self.selectedSound?.title}){
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .top, animated: true)
            }
        }

    }
    //AVAudioPlayerDelegate protocol
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    func stopSound() {
        if audioPlayer != nil {
            if audioPlayer!.isPlaying {
                audioPlayer!.stop()
            }
        }

        
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
    
   @objc func playPauseAction(sender : UIButton){
    sender.setImage(UIImage(), for: .normal)
    sender.setImage(UIImage(), for: .selected)
        stopSound()
    }
}
extension SelectSoundViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagsCollectionView {
            return soundsCategories.count
        }else{
            return filteredSounds.count
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopSound()

        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.alpha = 1.0
        if collectionView == self.tagsCollectionView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            
            let tag = soundsCategories[indexPath.row]
            cell.titleButton.setTitle(tag, for: .normal)
            cell.titleButton.setTitle(tag, for: .selected)
            cell.titleButton.layer.cornerRadius = 15.0
            cell.titleButton.clipsToBounds = true
            if selectedCategory == tag {
                cell.titleButton.alpha = 1.0
            }else{
                cell.titleButton.alpha = 0.5
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SoundPickCollectionViewCell", for: indexPath) as! SoundPickCollectionViewCell
            let sound = filteredSounds[indexPath.row]
            cell.playPauseButton.setImage(UIImage(named: "Bitmap"), for: .normal)
            cell.coverImageView.image = UIImage(named: sound.image)
            
            if let selected = selectedSound {
                if sound == selected{
                    cell.playPauseButton.isHidden = false
                    cell.topMainView.layer.borderColor = UIColor.white.cgColor
                    cell.topMainView.layer.borderWidth = 5.0
                    cell.selectCheckMarkButton.isHidden = false
//                    playSound(sound.soundName)
                }else{
                    cell.playPauseButton.isHidden = true
                    cell.selectCheckMarkButton.isHidden = true
                    cell.topMainView.layer.borderColor = UIColor.white.cgColor
                    cell.topMainView.layer.borderWidth = 0.0
                }
            }
            cell.playPauseButton.tag = indexPath.row
            cell.playPauseButton.addTarget(self,
                                           action: #selector(self.playPauseAction(sender:)),
                    for: .touchUpInside)

            cell.titleLabel.text = sound.title
            cell.topMainView.layer.cornerRadius = 10
            cell.coverImageView.layer.cornerRadius = 10
            cell.topMainView.clipsToBounds = true


            return cell
        }

    }
    
    func tapsave(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "tapsave"), parameters: ["referrer" : referrer, "alarmname" : alarmname])
                                 }
    
    func logsoundselected(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "soundselected"), parameters: ["referrer" : referrer, "alarmname" : alarmname])
                                 }
    func logcategorycollected(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "categorycollected"), parameters: ["referrer" : referrer])
                                 }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.alpha = 0.0
        if collectionView == tagsCollectionView {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            selectedCategory = soundsCategories[indexPath.row]
            tagSelection(tag: selectedCategory, isFirst: true)
            
            logcategorycollected(referrer: selectedCategory)
            tagsCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            self.tagsCollectionView.reloadData()
        }else{
            let sound = filteredSounds[indexPath.row]
            selectedSound = sound
            logcategorycollected(referrer: sound.soundName)

            segueInfo.mediaLabel = sound.soundName
            segueInfo.mediaID = sound.soundName
            alarmname = sound.soundName
            segueInfo.category = sound.category
            segueInfo.imageName = sound.image
            segueInfo.label = sound.title
            playSound(selectedSound!.soundName)
            self.collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tagsCollectionView {
            return CGSize(width: 90, height: 30)
        }else{
            
            let bounds = UIScreen.main.bounds
            let width = bounds.width
            return CGSize(width: width/2, height: 250)
        }

    }
    
    
}



struct Sounds:Equatable {
    var soundName:String
    var title:String
    var image:String
    var category:String
    var popular:Int? = 0
    static func == (lhs: Sounds, rhs: Sounds) -> Bool {
        return lhs.category == rhs.category && lhs.title == rhs.title && lhs.image == rhs.image  && lhs.soundName == rhs.soundName && rhs.popular == lhs.popular
        }
}
