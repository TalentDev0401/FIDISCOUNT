//
//  BaseVC.swift
//  Fid
//
//  Created by CROCODILE on 16.01.2021.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func rightMenuButtonTapped(_ sender: Any) {
        self.sideBarController.showMenuViewController(in: .right)
    }

}
