//
//  CreateProfileVC.swift
//  Fid
//
//  Created by CROCODILE on 03.03.2021.
//

import UIKit
import TextFieldEffects
import ProgressHUD
import RealmSwift
import Toaster

class CreateProfileVC: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var firstname: HoshiTextField!
    @IBOutlet weak var lastname: HoshiTextField!
    @IBOutlet weak var email: HoshiTextField!
    @IBOutlet weak var password: HoshiTextField!
    @IBOutlet weak var confirm_password: HoshiTextField!
    @IBOutlet weak var backImg: UIImageView!
    
    private var person: Person = Person()
    private var isPhoto = false
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialize()
        
    }
    
    func initialize() {
        firstname.placeholder = "First name"
        lastname.placeholder = "Last name"
        email.placeholder = "Email"
        password.placeholder = "Password"
        password.isSecureTextEntry = true
        confirm_password.placeholder = "Confirm Password"
        confirm_password.isSecureTextEntry = true
        
        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.height / 2
        self.profileImg.layer.masksToBounds = true
        
        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
    }
    
    // MARK: - Realm methods
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//    func loadPerson() {
//        if let saved_person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
//            person = saved_person
//        }
//
//    }
        
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        let firstnameTxt = firstname.text ?? ""
        let lastnameTxt = lastname.text ?? ""
        let emailTxt = email.text ?? ""
        let passwordTxt = password.text ?? ""
        let confirmPasswordTxt = confirm_password.text ?? ""
                
        if (firstnameTxt.count == 0)    { ProgressHUD.showError("Firstname must be set.");        return    }
        if (lastnameTxt.count == 0)    { ProgressHUD.showError("Lastname must be set.");        return    }
        if (emailTxt.count == 0)    { ProgressHUD.showError("Email must be set.");        return    }
        if (passwordTxt.count == 0)    { ProgressHUD.showError("Password must be set.");        return    }
        if (confirmPasswordTxt.count == 0)    { ProgressHUD.showError("Confirm password must be set.");  return    }
        if (passwordTxt != confirmPasswordTxt)    { ProgressHUD.showError("You must confirm password.");  return    }

        IJProgressView.shared.showProgressView()
        self.actionRegister(email: emailTxt, password: passwordTxt, firstname: firstnameTxt, lastname: lastnameTxt)
                
    }
    
    @IBAction func getProfilePicture(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Open Camera", style: .default) { action in
            ImagePicker.cameraPhoto(target: self, edit: true)
        })
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { action in
            ImagePicker.photoLibrary(target: self, edit: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionRegister(email: String, password: String, firstname: String, lastname: String) {

        AuthUser.signUp(email: email, password: password) { error in
            IJProgressView.shared.hideProgressView()
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
            } else {
                if self.isPhoto {
                    self.pictureUpload(email: email, firstname: firstname, lastname: lastname, password: password)
                } else {
                    self.createPerson(email: email, firstname: firstname, lastname: lastname, img: false)
                    self.updateUserInfoRegister(username: email, password: password)
                }
            }
        }
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    func pictureUpload(email: String, firstname: String, lastname: String, password: String) {
        if let data = self.profileImg.image!.jpegData(compressionQuality: 0.6) {
            if let encrypted = Cryptor.encrypt(data: data) {
                MediaUpload.user(AuthUser.userId(), data: encrypted) { error in
                    if (error == nil) {
                        Media.saveUser(AuthUser.userId(), data: data)
                        self.createPerson(email: email, firstname: firstname, lastname: lastname, img: true)
                        self.updateUserInfoRegister(username: email, password: password)
                    } else {
                        ProgressHUD.showError("Picture upload error.")
                    }
                }
            }
        }
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func createPerson(email: String, firstname: String, lastname: String, img: Bool) {

        let userId = AuthUser.userId()
        Persons.create(userId, email: email, firstname: firstname, lastname: lastname, img: img)
        
        Users.loggedIn()
    }
    
    func updateUserInfoRegister(username: String, password: String) {
        
        defaults.setValue("true", forKey: "firstStart")
        defaults.setValue(username, forKey: "userName")
        defaults.setValue(password, forKey: "password")
        Toast(text: "הרשמה בוצעה בהצלחה").show()
        defaults.setValue(false, forKey: "logout")
                
        self.loadUsername()
    }
    
    func loadUsername() {
        var username = "Not Registered"
        var password = ""
        if defaults.string(forKey: "userName") != nil {
            username = defaults.string(forKey: "userName")!
        }
        if defaults.string(forKey: "password") != nil {
            password = defaults.string(forKey: "password")!
        }
        
        let param = ["password": password, "username": username]
                
        APIHandler.AFPostRequest_LoadUserName(url: ServerURL.sever_url_insert, param: param)
        
        self.performSegue(withIdentifier: "card", sender: self)
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func savePerson(firstname: String, lastname: String) {
        
        let country = "Israel"
        let location = "Moscow"
        let phone = "123456789"

        let realm = try! Realm()
                        
        try! realm.safeWrite {
            person.firstname = firstname
            person.lastname    = lastname
            person.fullname    = "\(firstname) \(lastname)"
            person.country = country
            person.location    = location
            person.phone = phone
            person.syncRequired = true
            person.updatedAt = Date().timestamp()
            
            realm.add(person, update: .modified)
        }
    }
    
    // MARK: - Upload methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func uploadPicture(image: UIImage) {

        profileImg.image = image
    }
}

// MARK: - UIImagePickerControllerDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension CreateProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if let image = info[.editedImage] as? UIImage {
            uploadPicture(image: image)
            self.isPhoto = true
        }
        picker.dismiss(animated: true)
    }
}
