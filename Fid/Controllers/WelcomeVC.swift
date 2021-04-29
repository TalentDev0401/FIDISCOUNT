//
//  WelcomeVC.swift
//  Fid
//
//  Created by CROCODILE on 04.02.2021.
//

import UIKit

class WelcomeVC: UIViewController {
    
    @IBOutlet weak var skipBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        skipBtn.layer.cornerRadius = skipBtn.frame.size.height/2
        skipBtn.layer.borderWidth = 1
        skipBtn.layer.borderColor = UIColor.lightGray.cgColor
        skipBtn.layer.masksToBounds = true
    }
    
    @IBAction func gotoRegister(_ sender: Any) {
        performSegue(withIdentifier: "register", sender: self)
    }

}
