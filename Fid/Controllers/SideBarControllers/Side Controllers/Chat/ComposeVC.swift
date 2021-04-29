//
//  ComposeVC.swift
//  Fid
//
//  Created by CROCODILE on 01.03.2021.
//

import UIKit

class ComposeVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var tabsView: TabsView!
    var pageController: UIPageViewController!
    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
        
        self.setupTabs()
        self.setupPageViewController()
    }
    

    // MARK: - IBActions
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addUserAndGroup(_ sender: Any) {
        if currentIndex == 0 {
            actionAddFriends()
        } else {
            actionNewGroup()
        }
    }
    
    @objc func actionAddFriends() {

        let addFriendsView = AddFriendsView()
        let navController = NavigationController(rootViewController: addFriendsView)
        present(navController, animated: true)
    }
    
    @objc func actionNewGroup() {

        let groupCreateView = GroupCreateView()
        let navController = NavigationController(rootViewController: groupCreateView)
        present(navController, animated: true)
    }

}
