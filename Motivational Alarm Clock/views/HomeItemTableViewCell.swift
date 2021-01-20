//
//  HomeItemTableViewCell.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 13/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit

class HomeItemTableViewCell: UITableViewCell {

    @IBOutlet weak var sound2: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var soundImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var itemSwitch: UISwitch!
    @IBOutlet weak var playPauseButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
