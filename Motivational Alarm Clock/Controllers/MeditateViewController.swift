//
//  MeditateViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 31/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import AVFoundation
import FBSDKCoreKit
class MeditateViewController: UIViewController ,AVAudioPlayerDelegate{
    var segueInfo: SegueInfo!
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    var date : Date?
    var filteredSounds:[Sounds] = []
    var selectedSound:Sounds?
//    var soundsCategories = ["Motivation","Prayers", "Meditation", "Fitness", "Money" ]
    
    var soundsCategories = ["Popular", "Sleep", "Anxiety", "Beginners", "Stress", "Work", "Self-Care","With Soundscapes","Inner Peace","Focus","Emotions","Relationships","Less Guidance","Personal Growth","Kids","By Guest Instructors","Relaxation"]

    func selectsound(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "selectsound"), parameters: ["referrer" : referrer])
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
    override func viewDidLoad() {
        allSounds.shuffle()
        let defaultSound = allSounds[0]
    segueInfo = SegueInfo(curCellIndex: alarmModel.count, isEditMode: false, label: defaultSound.title, mediaLabel: defaultSound.soundName, mediaID: "", repeatWeekdays: [], enabled: false, snoozeEnabled: false, imageName: defaultSound.image, category: defaultSound.category)
       let firstFilteredSounds = allSounds.filter({$0.category == selectedCategory})
        if firstFilteredSounds.count > 0  && !segueInfo.isEditMode{
            selectedSound = firstFilteredSounds[0]
        }
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
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        referrer = "SelectSoundTab"

    }
    
    @objc func appMovedToBackground() {
            // do whatever event you want
        audioPlayer?.stop()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        tagSelection(tag: selectedCategory, isFirst: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    func tagSelection(tag:String,isFirst:Bool){
        filteredSounds = allSounds.filter({$0.category == tag})
        if isFirst {
            if filteredSounds.count > 0 {
                let sound = filteredSounds[0]
                selectedSound = sound

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
    
    @IBAction func addAlarmActionButton(_ sender: Any) {
//        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc : AddNewAlarmViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "AddNewAlarmViewController") as! AddNewAlarmViewController
//        vc.selectedSound = self.selectedSound
//        vc.segueInfo = self.segueInfo
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
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
extension MeditateViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagsCollectionView {
            return soundsCategories.count
        }else{
//            return (!didpurchase && filteredSounds.count > 1) ? filteredSounds.count + 1 : filteredSounds.count
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
//            if indexPath.row == 2 && !didpurchase{
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalmUnlockCollectionViewCell", for: indexPath) as! CalmUnlockCollectionViewCell
//                return cell
//            }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SoundPickCollectionViewCell", for: indexPath) as! SoundPickCollectionViewCell
//                let sound = (indexPath.row == 0 || indexPath.row == 1 && !didpurchase) ? filteredSounds[indexPath.row] : filteredSounds[indexPath.row - 1]
            let sound = filteredSounds[indexPath.row]
            cell.playPauseButton.setImage(UIImage(named: "Bitmap"), for: .normal)
            cell.coverImageView.image = UIImage(named: sound.image) ?? UIImage(named: "Nature of The Universe")
            
            if let selected = selectedSound {
                if sound == selected{
                    cell.playPauseButton.isHidden = false
                    cell.topMainView.layer.borderColor = UIColor.white.cgColor
                    cell.topMainView.layer.borderWidth = 5.0
                    cell.selectCheckMarkButton.isHidden = false
                    let state = UIApplication.shared.applicationState
                    
                    if state == .background {
                        
                        // background
                    }
                    else if state == .active {
                        playSound(sound.soundName)
                        // foreground
                    }
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
//        }

    }
    
    func tapsave(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "tapsave"), parameters: ["referrer" : referrer])
                                 }
    
    func logsoundselected(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "soundselected"), parameters: ["referrer" : referrer])
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
           
//            if indexPath.row == 2 {
//                collectionView.alpha = 1
//
//                if didpurchase {
//
//                } else {
//                    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                    let vc : PaywallViewViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "PaywallViewViewController") as! PaywallViewViewController
//                    vc.modalPresentationStyle = .fullScreen
//                    self.present(vc, animated: true, completion: nil)
////                    self.performSegue(withIdentifier: "AlarmToPayWall", sender: self)
//                }
//            }else{
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                
//                let sound = (indexPath.row == 0 || indexPath.row == 1) ? filteredSounds[indexPath.row] : filteredSounds[indexPath.row - 1]
//                selectedSound = sound
            let sound = filteredSounds[indexPath.row]
            selectedSound = sound
                logcategorycollected(referrer: sound.soundName)

                segueInfo.mediaLabel = sound.soundName
                segueInfo.mediaID = sound.soundName
                segueInfo.category = sound.category
                segueInfo.imageName = sound.image
                segueInfo.label = sound.title
                playSound(selectedSound!.soundName)
                self.collectionView.reloadData()
            }

//        }
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
//            if indexPath.row == 2 && !didpurchase{
//                let bounds = UIScreen.main.bounds
//                let width = bounds.width
//                return CGSize(width: width, height: 70)
//            }else{
            let bounds = UIScreen.main.bounds
            let width = bounds.width
            return CGSize(width: width/2, height: 250)
//            }
        }

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let dist = segue.destination as! UINavigationController
        let addEditController = dist.topViewController as! AlarmEditAddViewController
        if segue.identifier == Id.addSegueIdentifier {
            addEditController.isFromSoundVc = true
            addEditController.navigationItem.title = "Add Alarm"
            addEditController.modalPresentationStyle = .fullScreen
            let defaultSound = selectedSound!
            addEditController.segueInfo = SegueInfo(curCellIndex: alarmModel.count, isEditMode: false, label: "Alarm", mediaLabel: defaultSound.soundName, mediaID: "", repeatWeekdays: [], enabled: false, snoozeEnabled: false, imageName: defaultSound.image, category: defaultSound.category)
        }
        else if segue.identifier == Id.editSegueIdentifier {
            addEditController.navigationItem.title = "Edit Alarm"
            addEditController.segueInfo = sender as? SegueInfo
        }
    }
    
}



