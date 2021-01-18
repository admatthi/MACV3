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

@objc protocol SwiftPaywallDelegate {
    func purchaseCompleted(paywall: PaywallViewViewController, transaction: SKPaymentTransaction, purchaserInfo: Purchases.PurchaserInfo)
    @objc optional func purchaseFailed(paywall: PaywallViewViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error, userCancelled: Bool)
    @objc optional func purchaseRestored(paywall: PaywallViewViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error?)
}

var ref : DatabaseReference?

var uid = String()
var referrer = String()
var didpurchase = Bool()

class PaywallViewViewController: UIViewController {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    var purchases = Purchases.configure(withAPIKey: "slBUTCfxpPxhDhmESLETLyjJtFpYzjCj", appUserID: nil)
    
    var delegate : SwiftPaywallDelegate?
    
    private var offering : Purchases.Offering?
    
    private var offeringId : String?
    
    @IBAction func tapRestore(_ sender: Any) {
        
        ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
             
             didpurchase = true
             
             
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
    @IBAction func tapTerms(_ sender: Any) {
          
          if let url = NSURL(string: "https://www.aktechnology.info/terms.html"
              ) {
              UIApplication.shared.openURL(url as URL)
          }
          
      }

    @IBAction func tapPay(_ sender: Any) {
        
        guard let package = offering?.availablePackages[0] else {
                    print("No available package")
                    MBProgressHUD.hide(for: view, animated: true)
                    
                    return
                }
        
        Purchases.shared.purchasePackage(package) { (trans, info, error, cancelled) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let purchaseFailedHandler = self.delegate?.purchaseFailed {
                    purchaseFailedHandler(self, info, error, cancelled)
                } else {
                    if !cancelled {
                        
                    }
                }
            } else  {
                if let purchaseCompletedHandler = self.delegate?.purchaseCompleted {
                    purchaseCompletedHandler(self, trans!, info!)
                    
//                    self.logPurchaseSuccessEvent(referrer : referrer)
                    //
                    ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                    
                    didpurchase = true
                    
                    AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: [AFEventParam1 : referrer])
                    
//                                            AppsFlyerTracker.shared().trackEvent(AFEventStartTrial, withValues: [
//                                                AFEventParamContentId: referrer,
//
//                                            ]);
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    
                    referrer = "Paywall"
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                    
                } else {
                    
//                    self.logPurchaseSuccessEvent(referrer : referrer)
                    //
                    ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    
                    //                        AppsFlyerTracker.shared().trackEvent(AFEventStartTrial, withValues: [
                    //                            AFEventParamContentId: referrer,
                    //
                    //                        ]);
                    didpurchase = true
                    
                    referrer = "Paywall"
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                    
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissButton.layer.cornerRadius = 12.5
        payButton.layer.cornerRadius = 20
        
        ref = Database.database().reference()

        Purchases.shared.offerings { (offerings, error) in
                  
                  if error != nil {
                  }
                  if let offeringId = self.offeringId {
                      
                      self.offering = offerings?.offering(identifier: "weekly")
                  } else {
                      self.offering = offerings?.current
                  }
                  
              }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
