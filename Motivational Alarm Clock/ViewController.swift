//
//  ViewController.swift
//  Motivational Alarm Clock
//
//  Created by Alek Matthiessen on 1/10/21.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import SwiftySound
import Foundation
import AudioToolbox
import AVFoundation
var player: AVAudioPlayer?


class ViewController: UIViewController {
    var audioPlayer : AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        playSound()
                //vibrate phone first
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                //set vibrate callback
                AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
                    nil,
                    { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    },
                    nil)
        let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
        dispatchQueue.async(execute: {

            if let data = NSData(contentsOfFile: self.audioFilePath())
            {
                do{
                    let session = AVAudioSession.sharedInstance()

                    try session.setCategory(AVAudioSession.Category.playback)
                    try session.setActive(true)

                    self.audioPlayer = try AVAudioPlayer(data: data as Data)
                    //self.audioPlayer.delegate = self
                    self.audioPlayer.prepareToPlay()
                    self.audioPlayer.play()
                }
                catch{
                    print("\(error)")
                }
            }
        });
        
    }

//    func playSound(fileName: String) {
//        let session = AVAudioSession.sharedInstance()
//
//        var setCategoryError: Error? = nil
//        do {
//            try session.setCategory(
//                .playback,
//                options: .mixWithOthers)
//        } catch let setCategoryError {
//            // handle error
//        }
//        var sound: SystemSoundID = 0
//        if let soundURL = Bundle.main.url(forAuxiliaryExecutable: "Rise & Grind.mp3") {
//            AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
//            AudioServicesPlaySystemSoundWithCompletion(sound, nil)
//            //vibrate phone first
//            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//            //set vibrate callback
//            AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
//                nil,
//                { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
//                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//                },
//                nil)
//        }
//    }
    

    func audioFilePath() -> String{

        let filePath = Bundle.main.path(forResource: "Rise & Grind", ofType: "mp3")!

        return filePath
    }
    func playSound() {
        guard let url = Bundle.main.url(forResource: "Rise & Grind", withExtension: "mp3") else {
            print("url not found")
            return
        }

        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            /// change fileTypeHint according to the type of your audio file (you can omit this)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            // no need for prepareToPlay because prepareToPlay is happen automatically when calling play()
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
}

