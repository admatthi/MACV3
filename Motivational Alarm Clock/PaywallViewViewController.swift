//
//  PaywallViewViewController.swift
//  Motivational Alarm Clock
//
//  Created by Alek Matthiessen on 1/12/21.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import Firebase
import Purchases
import FBSDKCoreKit
import MBProgressHUD
import AppsFlyerLib
import AVKit
import AVFoundation
import Kingfisher
import FirebaseDatabase

var slimeybool = Bool()


@objc protocol SwiftPaywallDelegate {
    func purchaseCompleted(paywall: PaywallViewViewController, transaction: SKPaymentTransaction, purchaserInfo: Purchases.PurchaserInfo)
    @objc optional func purchaseFailed(paywall: PaywallViewViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error, userCancelled: Bool)
    @objc optional func purchaseRestored(paywall: PaywallViewViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error?)
}

var ref : DatabaseReference?

var referrer = String()
var didpurchase = Bool()

class PaywallViewViewController: UIViewController {
    
    var delegate : SwiftPaywallDelegate?

           private var offering : Purchases.Offering?
           
           private var offeringId : String?
           
           @IBOutlet weak var termstext: UILabel!
           @IBOutlet weak var disclaimertext: UIButton!
var purchases =         Purchases.configure(withAPIKey: "GwOgfMrQbjGSVMPqkiFSzUeRRXjCEWsd", appUserID: uid)

           
           @IBAction func tapRestore(_ sender: Any) {
               
               Purchases.shared.restoreTransactions { (purchaserInfo, error) in
                   //... check purchaserInfo to see if entitlement is now active
                   
                   if let error = error {
                       
                       
                   } else {
                       
                       //
                       ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                       
                       didpurchase = true
                    
                    self.dismiss(animated: true, completion: nil)
                       
               
                   }
                   
               }
           }
           @IBAction func tapBack(_ sender: Any) {
               
                   
        
                   
                   self.dismiss(animated: true, completion: nil)

               
           }
       
         
           func logNotificationsSettingsTrue(referrer : String) {
                                            AppEvents.logEvent(AppEvents.Name(rawValue: "notifications enabled"), parameters: ["value" : "true"])
                                        }
       
         
           func logNotificationsSettingsFalse(referrer : String) {
                                            AppEvents.logEvent(AppEvents.Name(rawValue: "notifications enabled"), parameters: ["value" : "false"])
                                        }
       
       
           @IBOutlet weak var backimage: UIImageView!
    
    
    func logTapSubscribeEvent(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "tapsubscribe"), parameters: ["referrer" : referrer])
                                 }
    
    func logPurchaseSuccessEvent(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "purchasefollowthrough"), parameters: ["referrer" : referrer])
                                 }
    
    
           @IBAction func tapContinue(_ sender: Any) {
               
               logTapSubscribeEvent(referrer : referrer)
               
               let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)

               
               guard let package = offering?.availablePackages[0] else {
                     print("No available package")
                   MBProgressHUD.hide(for: view, animated: true)

                     return
                 }
               
               
               Purchases.shared.purchasePackage(package) { (trans, info, error, cancelled) in
                         
                   MBProgressHUD.hide(for: self.view, animated: true)

                         if let error = error {
                             if let purchaseFailedHandler = self.delegate?.purchaseFailed {
                                 purchaseFailedHandler(self, info, error, cancelled)
                             } else {
                                 if !cancelled {
                                     
                                 }
                             }
                         } else  {
                             if let purchaseCompletedHandler = self.delegate?.purchaseCompleted {
                                 purchaseCompletedHandler(self, trans!, info!)
                                 
                                 self.logPurchaseSuccessEvent(referrer : referrer)
                                 //
                                 ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                                 
                                 didpurchase = true
                               
                               MBProgressHUD.hide(for: self.view, animated: true)
                                
                                self.dismiss(animated: true, completion: nil)


                                 
                             } else {
                                 
                                 self.logPurchaseSuccessEvent(referrer : referrer)
                                 //
                                 ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                                 
                               MBProgressHUD.hide(for: self.view, animated: true)

                                 didpurchase = true
                               
                                self.dismiss(animated: true, completion: nil)

                            
                                 
                             }
                         }
                     }
           }
           
           @IBAction func tapTerms(_ sender: Any) {
               
            
            didpurchase = true
            
               if let url = NSURL(string: "https://www.aktechnology.info/terms.html"
                   ) {
                   UIApplication.shared.openURL(url as URL)
               }
               
           }
           
           @IBOutlet weak var leadingtext: UILabel!
           
       @IBOutlet weak var headlinelabel: UILabel!
       @IBOutlet weak var tapcontinue: UIButton!
    
    func paywallview(referrer : String) {
                                     AppEvents.logEvent(AppEvents.Name(rawValue: "paywallview"), parameters: ["referrer" : referrer])
                                 }

//    Try 3 days free, then $19.99/year.
//    Cancel anytime.
    
    func queryforpaywall() {
        
        ref?.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            
            
            if let slimey = value?["Slimey"] as? String {
                
                slimeybool = true
                //
                
              
                self.tapcontinue.setTitle("Try for FREE", for: .normal)
        
                self.leadingtext.text = "Try 3 days free, then $19.99/year. Cancel anytime."
                
            } else {
                //
                slimeybool = false
                
        
                self.tapcontinue.setTitle("CONTINUE", for: .normal)
                
                self.leadingtext.text = "$19.99/year"

                
      
            }
            
            if let discountcode = value?["DiscountCode"] as? String {
                
                
            } else {
                
                
            }
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paywallview(referrer: referrer)
        ref = Database.database().reference()
                  
                  tapcontinue.layer.cornerRadius = 25.0
                  
                  tapcontinue.clipsToBounds = true
 
                
        Purchases.shared.offerings { (offerings, error) in
            
         
            if let offeringId = self.offeringId {
                self.offering = offerings?.offering(identifier: offeringId)
            } else {
                self.offering = offerings?.current
            }
            
       
            }
        
        queryforpaywall()
            
        }
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
          self.present(alert, animated: true, completion: nil)
      }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
   

}
