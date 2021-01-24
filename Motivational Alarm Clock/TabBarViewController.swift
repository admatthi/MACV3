//
//  TabBarViewController.swift
//  Motivational Alarm Clock
//
//  Created by Alek Matthiessen on 1/24/21.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tabBarController!.tabBar.backgroundColor = UIColor.clear
//        self.tabBarController!.tabBar.isTranslucent = true

        // Do any additional setup after loading the view.
        
        
    //
    //        self.tabBar.frame = CGRect(origin: CGPoint(x: 0,y :40), size: CGSize(width: view.frame.width, height: 50))
            
//            self.tabBar.frame = CGRect(origin: CGPoint(x: 0,y :30), size: CGSize(width: view.frame.width, height: 50))
//            self.tabBar.layer.borderWidth = 0.0
//            self.tabBar.clipsToBounds = true
//
//    //
        
            tabBar.isTranslucent = true
                tabBar.backgroundImage = UIImage()
                tabBar.shadowImage = UIImage() // add this if you want remove tabBar separator
                tabBar.barTintColor = .clear
                tabBar.backgroundColor = .black // here is your tabBar color
                tabBar.layer.backgroundColor = UIColor.clear.cgColor
//
//
//
//
//    //        self.tabBar.layer.borderColor = UIColor.white.cgColor
//            self.tabBar.itemPositioning = .centered
//
//            self.tabBar.layer.borderWidth = 0.0
//            self.tabBar.layer.borderColor = UIColor.clear.cgColor
//            self.tabBar.itemSpacing = UIScreen.main.bounds.width/10
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
