//
//  CalmUnlockCollectionViewCell.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 17/02/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit

var color1 = UIColor(red: 0.97, green: 0.52, blue: 0.18, alpha: 1.00)

var color2 = UIColor(red: 0.99, green: 0.42, blue: 0.20, alpha: 1.00)



class CalmUnlockCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
        
            self.titleLabel.text = "Unlock Wake Premium"
            self.mainView.addGradientBackground(firstColor: color1, secondColor: color2)
            self.mainView.layer.cornerRadius = 10
            self.mainView.layer.masksToBounds = true
        }
    }
}
extension UIView {

func addGradiant() {
    let GradientLayerName = "gradientLayer"

    if let oldlayer = self.layer.sublayers?.filter({$0.name == GradientLayerName}).first {
        oldlayer.removeFromSuperlayer()
    }

    let gradientLayer = CAGradientLayer()
    let color1 = #colorLiteral(red: 0.5191865563, green: 0.6777381301, blue: 0.9185937047, alpha: 1)
    let color2 = #colorLiteral(red: 0.6489231586, green: 0.4896077514, blue: 0.9127531052, alpha: 1)
    gradientLayer.colors = [color1.cgColor, color2.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
    gradientLayer.frame = self.bounds
    gradientLayer.name = GradientLayerName

    self.layer.insertSublayer(gradientLayer, at: 0)
}
    

}
extension UIView{
        func addGradientBackground(firstColor: UIColor, secondColor: UIColor){
            clipsToBounds = true
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
            gradientLayer.frame = self.bounds
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            print(gradientLayer.frame)
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
