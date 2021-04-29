//
//  MainNavigationVC.swift
//  Fid
//
//  Created by CROCODILE on 16.01.2021.
//

import UIKit

class MainNavigationVC: UINavigationController {

    var homeViewController = MainVC()
    var postViewController = NewPostVC()
    var policyViewController = PolicyHelpVC()
    var securityViewController = SecurityHelpVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Properties
    
    func tabController() -> TabBarVC {

        let tabBarVC = (self.storyboard?.instantiateViewController(identifier: "TabBarVC") as? TabBarVC)!

        return tabBarVC
    }
    
    func homeController() -> MainVC {
        homeViewController = (self.storyboard?.instantiateViewController(identifier: "MainVC") as? MainVC)!
        return homeViewController
    }
    
    func postController() -> NewPostVC {
        postViewController = (self.storyboard?.instantiateViewController(identifier: "NewPostVC") as? NewPostVC)!
        return postViewController
    }
    
    func policyController() -> PolicyHelpVC {
        
        policyViewController = (self.storyboard?.instantiateViewController(identifier: "PolicyHelpVC") as? PolicyHelpVC)!
        return policyViewController
    }
    
    func securityController() -> SecurityHelpVC {
        
        securityViewController = (self.storyboard?.instantiateViewController(identifier: "SecurityHelpVC") as? SecurityHelpVC)!
        return securityViewController
    }
    
    // MARK: - Show ViewController
    
    func showTabBarController() {
        self.setViewControllers([self.tabController()], animated: true)
    }
    
    func showHomeController() {
        self.setViewControllers([self.homeController()], animated: true)
    }
    
    func showPolicyController() {
        self.setViewControllers([self.policyController()], animated: true)
    }
    
    func showSecurityController() {
        self.setViewControllers([self.securityController()], animated: true)
    }
    
    func showPostController() {
        self.setViewControllers([self.postController()], animated: true)
    }

}
