//
//  ProfileVC.swift
//  Fid
//
//  Created by CROCODILE on 17.03.2021.
//

import UIKit

class ProfileVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profileInitialLbl: UILabel!
    @IBOutlet weak var editprofiletitle: UILabel!
    @IBOutlet weak var favoriteTitle: UILabel!
    @IBOutlet weak var cardTitle: UILabel!

    private var person: Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userImg.layer.cornerRadius = self.userImg.frame.size.height / 2
        self.userImg.layer.masksToBounds = true
        self.profileInitialLbl.layer.cornerRadius = self.profileInitialLbl.frame.size.height / 2
        self.profileInitialLbl.layer.borderWidth = 1.0
        self.profileInitialLbl.layer.borderColor = UIColor.lightGray.cgColor
        self.profileInitialLbl.layer.masksToBounds = true
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        if (AuthUser.userId() == "") {
            let alert = UIAlertController(title: "Login required", message: "You should login or register for chat with the other users.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { void in
                self.tabBarController?.selectedIndex = 0
            }))

            alert.addAction(UIAlertAction(title: "Register", style: .default, handler: { void in
                let register = self.storyboard?.instantiateViewController(identifier: "RegisterVC") as! RegisterVC
                self.navigationController?.popPushToVC(ofKind: RegisterVC.self, pushController: register)
            }))
                    
            self.present(alert, animated: true, completion: nil)
        } else {
            self.loadPerson()
        }
    }
    
    func loadPerson() {

        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())

        self.profileInitialLbl.text = person.initials()
        MediaDownload.user(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profileInitialLbl.isHidden = true
                self.userImg.isHidden = false
                self.userImg.image = image
            } else {
                self.profileInitialLbl.isHidden = false
                self.userImg.isHidden = true
            }
        }

        self.username.text = person.fullname
    }
    
    @IBAction func editProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "edit_profile", sender: self)
    }
    
    @IBAction func editCard(_ sender: Any) {
        self.performSegue(withIdentifier: "edit_cards", sender: self)
    }
    
    @IBAction func showFavorite(_ sender: Any) {
        self.performSegue(withIdentifier: "edit_favorites", sender: self)
    }
    
    @IBAction func showLikes(_ sender: Any) {
        self.performSegue(withIdentifier: "edit_likes", sender: self)
    }

}
