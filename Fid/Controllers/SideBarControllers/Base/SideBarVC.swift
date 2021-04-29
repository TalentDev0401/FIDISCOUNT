//
//  SideBarVC.swift
//  Fid
//
//  Created by CROCODILE on 16.01.2021.
//

import UIKit
import LMSideBarController

class SideBarVC: LMSideBarController, LMSideBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let sideBarDepthStyle = LMSideBarDepthStyle()
        sideBarDepthStyle.menuWidth = 220
        
        let rightMenuViewController = self.storyboard?.instantiateViewController(identifier: "RightBarVC") as! RightBarVC
        let navigationController = self.storyboard?.instantiateViewController(identifier: "MainNavigationVC") as! MainNavigationVC
        
        self.panGestureEnabled = true
        self.delegate = self
        
        self.setMenuView(rightMenuViewController, for: .right)
        self.setSideBarStyle(sideBarDepthStyle, for: .right)
        self.contentViewController = navigationController
        
    }

    // MARK: - LMSideBarController Delegate
    func sideBarController(_ sideBarController: LMSideBarController!, willShowMenuViewController menuViewController: UIViewController!) {
        
    }
    
    func sideBarController(_ sideBarController: LMSideBarController!, didShowMenuViewController menuViewController: UIViewController!) {
        
    }
    
    func sideBarController(_ sideBarController: LMSideBarController!, willHideMenuViewController menuViewController: UIViewController!) {
        
    }
    
    func sideBarController(_ sideBarController: LMSideBarController!, didHideMenuViewController menuViewController: UIViewController!) {
        
    }    

}
