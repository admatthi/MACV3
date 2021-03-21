//
//  AppDelegate.swift
//  Motivational Alarm Clock
//
//  Created by Alek Matthiessen on 1/10/21.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//


import UIKit
import Foundation
import AudioToolbox
import AVFoundation
import Firebase
import Purchases
import FBSDKCoreKit
import MBProgressHUD
import AppsFlyerLib
import AVKit
import AVFoundation
import Kingfisher
import FirebaseDatabase

var db : Firestore!
var uid = String()
var firstinstall = Bool()
var audioGlobalPlayer: AVAudioPlayer!
var selectedSound : Alarm?
import BackgroundTasks
var isGlobalPlaying = false
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate, AlarmApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate{
    var soundId: SystemSoundID = 1
    var window: UIWindow?
    
    let alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
        uid = UIDevice.current.identifierForVendor!.uuidString
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.aatech.wakeSchedule", using: nil) { task in
            self.scheduleTaskForAudioPlaying()
            task.setTaskCompleted(success: true)
            self.scheduleAppRefresh()
        }
        AppEvents.activateApp()
        UIApplication.shared.isIdleTimerDisabled = true
        referrer = "LaunchAppDelegate"
        Settings.setAdvertiserTrackingEnabled(true)

        
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: "GwOgfMrQbjGSVMPqkiFSzUeRRXjCEWsd", appUserID: uid)
        
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        UserDefaults.standard.setValue(true, forKey: "newUserWithOutCreatingAlarm")
        let newUserCreatedAlarm = UserDefaults.standard.bool(forKey: "newUserWithOutCreatingAlarm")
//        if newUserCreatedAlarm  {
//            print("Not first launch.")
//            let vc : UITabBarController = mainStoryboardIpad.instantiateViewController(withIdentifier: "mainTabbarController") as! UITabBarController
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            self.window?.rootViewController = vc
//            self.window?.makeKeyAndVisible()
//        } else {
//            print("First launch, setting UserDefault.")
//            let vc : UINavigationController = mainStoryboardIpad.instantiateViewController(withIdentifier: "MotivationNavigationController") as! UINavigationController
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            self.window?.rootViewController = vc
//            self.window?.makeKeyAndVisible()
//        }
        print("Not first launch.")
        let vc : UITabBarController = mainStoryboardIpad.instantiateViewController(withIdentifier: "mainTabbarController") as! UITabBarController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        FirebaseApp.configure()
        ref = Database.database().reference()
        db = Firestore.firestore()
       
        queryforinfo()
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
            firstinstall = false
        } else {
            
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            firstinstall = true
        }

        uid = UIDevice.current.identifierForVendor?.uuidString ?? "x"
        var error: NSError?
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
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
        
    
        func asknotifications(referrer : String) {
                                         AppEvents.logEvent(AppEvents.Name(rawValue: "asknotifications"), parameters: ["referrer" : referrer])
                                     }
        
        
            func approvenotifications(referrer : String) {
                                             AppEvents.logEvent(AppEvents.Name(rawValue: "approvenotifications"), parameters: ["referrer" : referrer])
                                         }
        
        if UserDefaults.standard.bool(forKey: Id.isForOnboardingscreen){
            if #available(iOS 10.0, *) {
              // For iOS 10 display notification (sent via APNS)
              
                UNUserNotificationCenter.current().delegate = self
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound,]
              UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
                
                asknotifications(referrer: referrer)
    //
            } else {
              let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
              application.registerUserNotificationSettings(settings)
            }
            application.registerForRemoteNotifications()
        }

        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            
            approvenotifications(referrer: referrer)
             // User is registered for notification
        } else {
             // Show alert user is not registered for notification
        }

        
        Messaging.messaging().delegate = self
        setupForCallMethod()
        return true
    }
    func setupForCallMethod() {
      NotificationCenter.default.addObserver(self,selector: #selector(playerInterruption),name: AVAudioSession.interruptionNotification,object: AVAudioSession.sharedInstance())
    }
    
    @objc func playerInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
        }else if type == .ended {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.scheduleTaskForAudioPlaying()
            }
        }
    }
    func scheduleTaskForAudioPlaying(isFromNotification:Bool = false){
        
         let state = UIApplication.shared.applicationState

        if isGlobalPlaying {
            isGlobalPlaying = false
            if audioGlobalPlayer != nil{
                audioGlobalPlayer!.play()
            }
            else{
                scheduleTaskForAudioPlaying()
            }
        }else{
             let alarmmodel = Alarms()
            var alarms = alarmmodel.alarms.filter({$0.enabled == true})
             alarms.sort(by: { $0.date < $1.date })
             
             if alarms.count > 0 {
                 let greaterthencurretnTime  = alarms.filter({$0.date > Date()})
                 if greaterthencurretnTime.count > 0 {
             let session = AVAudioSession.sharedInstance()

             var setCategoryError: Error? = nil
             do {
                 try session.setCategory(
                     .playback,
                     options: .mixWithOthers)
             } catch let setCategoryError {
                 // handle error
             }
             let aurdioName = greaterthencurretnTime[0]
             let url = URL(fileURLWithPath: Bundle.main.path(forResource: aurdioName.mediaLabel, ofType: "mp3")!)
             
             var error: NSError?
             
             do {
                 audioGlobalPlayer = try AVAudioPlayer(contentsOf: url)
             } catch let error1 as NSError {
                 error = error1
                 audioGlobalPlayer = nil
             }
             
             if let err = error {
                 print("audioPlayer error \(err.localizedDescription)")
                 return
             } else {
                 audioGlobalPlayer!.delegate = self
                 audioGlobalPlayer!.prepareToPlay()
             }
             
             //negative number means loop infinity
//             audioGlobalPlayer!.numberOfLoops = -1
            audioGlobalPlayer.volume = 1.0
             audioGlobalPlayer!.isMeteringEnabled = true
             let currentAudioTime = audioGlobalPlayer!.deviceCurrentTime
             selectedSound = greaterthencurretnTime[0]
             isGlobalPlaying = false
             let delayTime: TimeInterval = greaterthencurretnTime[0].date.timeIntervalSinceNow // here as an example, we use 20 seconds delay
                    if isFromNotification {
                        audioGlobalPlayer!.play(atTime: currentAudioTime + delayTime)
                    }else{
                        audioGlobalPlayer!.play(atTime: currentAudioTime + delayTime)
                    }
                     
                 }

             }
        }
    }
    func scheduleAppRefresh() {
         let request = BGAppRefreshTaskRequest(identifier: "com.aatech.wakeSchedule")

         request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 75) // Refresh after 60 minutes.

         do {
             try BGTaskScheduler.shared.submit(request)
         } catch {
             print("Could not schedule app refresh task \(error.localizedDescription)")
         }
     }
//    func application(_ application: UIApplication,
//                     performFetchWithCompletionHandler completionHandler:
//                     @escaping (UIBackgroundFetchResult) -> Void) {
//       // Check for new data.
//        let state = UIApplication.shared.applicationState
//
//        if state == .background {
//            audioPlayer.stop()
//            let alarmmodel = Alarms()
//            var alarms = alarmmodel.alarms
//            alarms.sort(by: { $0.date < $1.date })
//
//            if alarms.count > 0 {
//                let greaterthencurretnTime  = alarms.filter({$0.date > Date()})
//                if greaterthencurretnTime.count > 0 {
//            let session = AVAudioSession.sharedInstance()
//
//            var setCategoryError: Error? = nil
//            do {
//                try session.setCategory(
//                    .playback,
//                    options: .duckOthers)
//            } catch let setCategoryError {
//                // handle error
//            }
//            let aurdioName = greaterthencurretnTime[0]
//            let url = URL(fileURLWithPath: Bundle.main.path(forResource: aurdioName.mediaLabel, ofType: "mp3")!)
//
//            var error: NSError?
//
//            do {
//                audioPlayer = try AVAudioPlayer(contentsOf: url)
//            } catch let error1 as NSError {
//                error = error1
//                audioPlayer = nil
//            }
//
//            if let err = error {
//                print("audioPlayer error \(err.localizedDescription)")
//                return
//            } else {
//                audioPlayer!.delegate = self
//                audioPlayer!.prepareToPlay()
//            }
//
//            //negative number means loop infinity
//            audioPlayer!.numberOfLoops = -1
//            let currentAudioTime = audioPlayer!.deviceCurrentTime
//
//            let delayTime: TimeInterval = greaterthencurretnTime[0].date.timeIntervalSinceNow // here as an example, we use 20 seconds delay
//                    audioPlayer!.play(atTime: currentAudioTime + delayTime)
//                }
//
//            }
//            completionHandler(.newData)
//        }
//    }
    func queryforinfo() {
            
            ref?.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                
                if let purchased = value?["Purchased"] as? String {
                    
                    if purchased == "True" {
                        
                        didpurchase = true
                        
                    } else {
                        
                        didpurchase = false
                        
                    }
                    
                } else {
                    
                    didpurchase = false
                }
                
            })
            
        }
    
    func getPrefrences(){
        db.collection("profile").whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, err) in
           
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let userName = data["userName"] as? String
                    {

                        
                    }
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   didReceive response: UNNotificationResponse,
                                   withCompletionHandler completionHandler: @escaping () -> Void) {
           let userInfo = response.notification.request.content.userInfo
           // Print full message.
           print("tap on on forground app",userInfo)
        //
        isGlobalPlaying = false
        if audioGlobalPlayer != nil {
            audioGlobalPlayer!.stop()
        }
        if selectedSound != nil{
            selectedSound = nil
        }
        alarmsounded(referrer: referrer)
        completionHandler()
       }
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // not triggred when we tap on "opps your killed wake app" notification only triggered for real alarm
        if notification.userInfo?.count ?? 0 > 0 {
            //
            isGlobalPlaying = false
            if audioGlobalPlayer != nil {
                audioGlobalPlayer!.stop()
            }
            if selectedSound != nil{
                selectedSound = nil
            }
            alarmsounded(referrer: referrer)
        }
        //show an alert window
//        var isSnooze: Bool = false
//        var soundName: String = ""
//        var index: Int = -1
//        if let userInfo = notification.userInfo {
//            isSnooze = userInfo["snooze"] as! Bool
//            soundName = userInfo["soundName"] as! String
//            index = userInfo["index"] as! Int
//        }
//        self.alarmModel = Alarms()
//        self.alarmModel.alarms[index].onSnooze = false
//        //change UI
//        var mainVC = self.window?.visibleViewController as? HomeViewController
//        if mainVC == nil {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            mainVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
//        }
//        mainVC!.changeSwitchButtonState(index: index)
//        playSound(soundName)
        //schedule notification for snooze
//        if isSnooze {
//            let snoozeOption = UIAlertAction(title: "Snooze", style: .default) {
//                (action:UIAlertAction)->Void in self.audioPlayer?.stop()
//                self.alarmScheduler.setNotificationForSnooze(snoozeMinute: 9, soundName: soundName, index: index)
//            }
//            storageController.addAction(snoozeOption)
//        }
//        let stopOption = UIAlertAction(title: "OK", style: .default) {
//            (action:UIAlertAction)->Void in self.audioPlayer?.stop()
//            AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
//
//        }
//
//        storageController.addAction(stopOption)
//        window?.visibleViewController?.navigationController?.present(storageController, animated: true, completion: nil)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification,
                                  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
          let userInfo = notification.request.content.userInfo
          print(userInfo) // the payload that is attached to the push notification
          // you can customize the notification presentation options. Below code will show notification banner as well as play a sound. If you want to add a badge too, add .badge in the array.
        var soundName = userInfo["soundName"] as? String ?? ""
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioGlobalPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioGlobalPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioGlobalPlayer!.delegate = self
            audioGlobalPlayer!.prepareToPlay()
        }
        
        //negative number means loop infinity
//        audioGlobalPlayer!.numberOfLoops = -1
        isGlobalPlaying = false
        audioGlobalPlayer!.isMeteringEnabled = true
        audioGlobalPlayer!.play()
        completionHandler([.alert,.sound])
      }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//            let alarmmodel = Alarms()
//            var alarms = alarmmodel.alarms
//            alarms.sort(by: { $0.date.compare($1.date) == .orderedDescending })
//            if alarms.count > 0 {
//                audioPlayer!.play()
//                playSound(fileName: "Rise & Grind.mp3")
//            }
//        let storageController = UIAlertController(title: "Alarm", message: nil, preferredStyle: .alert)
//        let stopOption = UIAlertAction(title: "OK", style: .default)
//        storageController.addAction(stopOption)
//        window?.visibleViewController?.navigationController?.present(storageController, animated: true, completion: nil)
        print("silent notification\(userInfo)")
        self.scheduleTaskForAudioPlaying(isFromNotification: true)
        completionHandler(UIBackgroundFetchResult.newData)

    }
    // Play the specified audio file with extension
    func playSound(fileName: String) {
        
        
        var setTo0 = 0
        AudioServicesSetProperty( kAudioServicesPropertyIsUISound,0,nil,
                                 4,&setTo0 )
        let session = AVAudioSession.sharedInstance()

        var setCategoryError: Error? = nil
        do {
            try session.setCategory(
                .playback,
                options: .duckOthers)
        } catch let setCategoryError {
            // handle error
        }
        var sound: SystemSoundID = 0
        if let soundURL = Bundle.main.url(forAuxiliaryExecutable: "Rise & Grind.mp3") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
            AudioServicesPlaySystemSoundWithCompletion(sound, nil)
            //vibrate phone first
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            //set vibrate callback
            AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
                nil,
                { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                },
                nil)
        }
    }
    //snooze notification handler when app in background
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        var index: Int = -1
        var soundName: String = ""
        var title:String = ""
        if let userInfo = notification.userInfo {
            soundName = userInfo["soundName"] as! String
            soundName = userInfo["title"] as! String
            index = userInfo["index"] as! Int
        }
        self.alarmModel = Alarms()
        self.alarmModel.alarms[index].onSnooze = false
        if identifier == Id.snoozeIdentifier {
            alarmScheduler.setNotificationForSnooze(snoozeMinute: 9, soundName: soundName, title: title, index: index)
            self.alarmModel.alarms[index].onSnooze = true
        }
        completionHandler()
        
        alarmsounded(referrer: referrer)
    }
    
    func alarmsounded(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "alarmsounded"), parameters: ["referrer" : referrer])
                                 }
    
    
    //print out all registed NSNotification for debug
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        print(notificationSettings.types.rawValue)
    }
    
    //AlarmApplicationDelegate protocol
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
            audioGlobalPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioGlobalPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioGlobalPlayer!.delegate = self
            audioGlobalPlayer!.prepareToPlay()
        }
        
        //negative number means loop infinity
        audioGlobalPlayer!.numberOfLoops = 0
        audioGlobalPlayer!.play()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
                 print("Firebase registration token: \(fcmToken)")
        if let token = fcmToken {
            db.collection("profile").whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if querySnapshot!.documents.count == 0{
                        var ref: DocumentReference? = nil
                        ref = db.collection("profile").addDocument(data: [
                            "token": fcmToken,
                            "uid":uid,
                            "created_at":Date()
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                self.getPrefrences()
                                print("Document added with ID: \(ref!.documentID)")
                            }
                        }
                    }else{
                        let updateReference = db.collection("profile").document(querySnapshot!.documents.first?.documentID ?? "")
                        updateReference.getDocument { (document, err) in
                            if let err = err {
                                print(err.localizedDescription)
                            }
                            else {
                                document?.reference.updateData([
                                    "token": fcmToken,
                                    "updated_at":Date()
                                    ])
                            }
                        }

                    }
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                }
            }
        }
    }
         // TODO: If necessary send token to application server.
         // Note: This callback is fired at each app startup and whenever a new token is generated.
    //AVAudioPlayerDelegate protocol
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print(flag)
        if !isGlobalPlaying{
            alarmsounded(referrer: referrer)
        }
        if audioGlobalPlayer != nil {
            isGlobalPlaying = true
            audioGlobalPlayer!.play()
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

        }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.scheduleTaskForAudioPlaying()
        }
    }
   
    //UIApplicationDelegate protocol
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//        audioPlayer?.pause()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.scheduleAppRefresh()

        let alarmmodel = Alarms()
        var alarms = alarmmodel.alarms.filter({$0.enabled == true})
        alarms.sort(by: { $0.date < $1.date })
        
        if alarms.count > 0 {
            let greaterthencurretnTime  = alarms.filter({$0.date > Date()})
            if greaterthencurretnTime.count > 0 {
        let session = AVAudioSession.sharedInstance()

        var setCategoryError: Error? = nil
        do {
            try session.setCategory(
                .playback,
                options: .mixWithOthers)
        } catch let setCategoryError {
            // handle error
        }
        let aurdioName = greaterthencurretnTime[0]
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: aurdioName.mediaLabel, ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioGlobalPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioGlobalPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioGlobalPlayer!.delegate = self
            audioGlobalPlayer!.prepareToPlay()
        }
        
        //negative number means loop infinity
//        audioGlobalPlayer!.numberOfLoops = -1
        audioGlobalPlayer.volume = 1.0
        audioGlobalPlayer!.isMeteringEnabled = true
        let currentAudioTime = audioGlobalPlayer!.deviceCurrentTime
        selectedSound = greaterthencurretnTime[0]
        isGlobalPlaying = false
        let delayTime: TimeInterval = greaterthencurretnTime[0].date.timeIntervalSinceNow // here as an example, we use 20 seconds delay
                audioGlobalPlayer!.play(atTime: currentAudioTime + delayTime)
            }

        }

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        audioPlayer?.play()
//        alarmScheduler.checkNotification()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let AlarmNotification: UILocalNotification = UILocalNotification()
        AlarmNotification.alertTitle = "Whoops! Your alarm won't sound"
        AlarmNotification.alertBody = "You closed Wake, so your alarm won't sound. Tap the Wake icon to open it and keep in the background, so you can wake up successfully"
        AlarmNotification.fireDate = Date().addingTimeInterval(1)
        UIApplication.shared.scheduleLocalNotification(AlarmNotification)
    }
    



}


extension Date {

    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }

}
