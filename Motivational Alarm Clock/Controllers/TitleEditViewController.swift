//
//  TitleEditViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 12/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit

class TitleEditViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var tapback: UIButton!
    @IBOutlet weak var labelTextField: UITextField!
    var label: String!
    
    override func viewDidAppear(_ animated: Bool) {
        
        referrer = "TitleEdit"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        labelTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
        self.labelTextField.delegate = self
        
        labelTextField.text = label
        
        //defined in UITextInputTraits protocol
        labelTextField.returnKeyType = UIReturnKeyType.done
        labelTextField.enablesReturnKeyAutomatically = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        label = textField.text!
        performSegue(withIdentifier: Id.labelUnwindIdentifier, sender: self)
        //This method can be used when no state passing is needed
        //navigationController?.popViewController(animated: true)
        return false
    }

    @IBAction func tapbackButtonAction(_ sender: Any) {
        label = labelTextField.text
        performSegue(withIdentifier: Id.labelUnwindIdentifier, sender: self)
    }
}

