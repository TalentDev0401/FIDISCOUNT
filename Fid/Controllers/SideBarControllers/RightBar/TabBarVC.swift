//
//  TabBarVC.swift
//  Fid
//
//  Created by CROCODILE on 28.02.2021.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(chatTab), name: NSNotification.Name("gotochat"), object: nil)
    }
    
    @objc func chatTab() {
        self.selectedIndex = 2
    }
}
