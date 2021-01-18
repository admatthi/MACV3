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
class SelectSoundViewController: UIViewController ,AVAudioPlayerDelegate{

    var filteredSounds:[Sounds] = []
    var selectedSound:Sounds?
    var soundsCategories = ["Motivation","Self Help","Fitness","Faith", "Social", "Business", "Philosophy", "Spirituality" ]
    var selectedCategory = "Motivation"
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    var mediaLabel: String!
    var mediaID: String!
    var image:String!
    var soundtitle:String!
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
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
                selectedSound = filteredSounds[0]
            }
        }
        self.tagsCollectionView.reloadData()
        self.collectionView.reloadData()
    }
    //AVAudioPlayerDelegate protocol
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    func stopSound() {
        if audioPlayer!.isPlaying {
            audioPlayer!.stop()
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
                    playSound(sound.soundName)
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
            cell.mainView.layer.cornerRadius = 10
            cell.mainView.clipsToBounds = true

            return cell
        }

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.alpha = 0.0
        if collectionView == tagsCollectionView {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            selectedCategory = soundsCategories[indexPath.row]
            tagSelection(tag: selectedCategory, isFirst: true)
            tagsCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            self.tagsCollectionView.reloadData()
        }else{
            let sound = filteredSounds[indexPath.row]
            selectedSound = sound
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
    static func == (lhs: Sounds, rhs: Sounds) -> Bool {
            return lhs.category == rhs.category && lhs.title == rhs.title && lhs.image == rhs.image  && lhs.soundName == rhs.soundName
        }
}
