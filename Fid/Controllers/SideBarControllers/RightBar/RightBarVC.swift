//
//  RightBarVC.swift
//  Fid
//
//  Created by CROCODILE on 16.01.2021.
//

import UIKit
import Freedom
import MessageUI
import Toaster

class RightBarVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
  
    var array = [MainData]()
           
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureMenuData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func configureMenuData() {
        array.append(MainData(key: "home.png", value: "דף הבית"))
        array.append(MainData(key: "name.png", value: "הירשם"))
        array.append(MainData(key: "share.png", value: "שתף"))
        array.append(MainData(key: "attachment.png", value: "דווח הטבה"))
        array.append(MainData(key: "security.png", value: "תנאי שימוש"))
        array.append(MainData(key: "privacy.png", value: "מדיניות פרטיות"))
        array.append(MainData(key: "subscription.png", value: "צור קשר"))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightMenuCell", for: indexPath) as! RightMenuCell
                
        cell.title.text = self.array[indexPath.row].value
        cell.img.image = UIImage(named: self.array[indexPath.row].key)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let navigationController : MainNavigationVC = self.sideBarController.contentViewController as! MainNavigationVC
        switch indexPath.row {
        case 0:
            self.sideBarController.hideMenuViewController(true)
            navigationController.showTabBarController()
            break
        case 1:
            
            AuthUser.logOut()
            
            defaults.setValue(true, forKey: "logout")
            defaults.setValue("false", forKey: "firstStart")
            
            FidHelper.shared.goBackRegister = true
            self.sideBarController.hideMenuViewController(true)
            let register = self.storyboard?.instantiateViewController(identifier: "RegisterVC") as! RegisterVC
            self.navigationController?.popPushToVC(ofKind: RegisterVC.self, pushController: register)
            
        case 2:
            self.sideBarController.hideMenuViewController(true)
            self.shareAction()
            break
        case 3:
            self.sideBarController.hideMenuViewController(true)
            navigationController.showPostController()
            break
        case 4:
            self.sideBarController.hideMenuViewController(true)
            navigationController.showSecurityController()
            break
        case 5:
            self.sideBarController.hideMenuViewController(true)
            navigationController.showPolicyController()
            break
        case 6:
            self.sideBarController.hideMenuViewController(true)
            self.sendEmail()
            break
        default:
            break
        }
    }
    
    // MARK: - Private methods
    
    func shareAction() {
       
        let url = URL(string: "https://apps.apple.com/us/app/fid/id1550732583")!
//        // Enable Debug Logs (disabled by default)
        Freedom.debugEnabled = true
        // Fetch activities for Safari and all third-party browsers supported by Freedom.
        let activities = Freedom.browsers()
        // Alternatively, one could select a specific browser (or browsers).
        // let activities = Freedom.browsers([.chrome])

        let activityViewController : UIActivityViewController = UIActivityViewController(
        activityItems: [url], applicationActivities: activities)
        activityViewController.isModalInPresentation = true
        activityViewController.popoverPresentationController?.sourceView = self.view



        // This lines is for the popover you need to show in iPad
        //           activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)

        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading

        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]

        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["fidiscountcard@gmail.com"])
            mail.title = "צור קשר עם FID"
            mail.setMessageBody("Message from App", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
            print("can't test in simulator")
            Toast(text: "ההודעה נכשלה: Your device could not send e-mail.  Please check e-mail configuration and try again.").show()
        }
    }
    
    // MARK: - MFMailComposeViewController
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        Toast(text: "ההודעה נשלחה בהצלחה").show()
        controller.dismiss(animated: true)
    }
}


