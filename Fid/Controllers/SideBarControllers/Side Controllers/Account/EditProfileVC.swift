//
//  EditProfileVC.swift
//  Fid
//
//  Created by CROCODILE on 17.03.2021.
//

import UIKit
import TextFieldEffects
import ProgressHUD
import RealmSwift

class EditProfileVC: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileInitialLbl: UILabel!
    @IBOutlet weak var firstname: HoshiTextField!
    @IBOutlet weak var lastname: HoshiTextField!
    @IBOutlet weak var backImg: UIImageView!
    
    private var person: Person!
    private var isPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialize()
        self.loadPerson()
    }
    
    func initialize() {
        firstname.placeholder = "First name"
        lastname.placeholder = "Last name"
                        
        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.height / 2
        self.profileImg.layer.masksToBounds = true
        self.profileInitialLbl.layer.cornerRadius = self.profileInitialLbl.frame.size.height / 2
        self.profileInitialLbl.layer.borderWidth = 1.0
        self.profileInitialLbl.layer.borderColor = UIColor.lightGray.cgColor
        self.profileInitialLbl.layer.masksToBounds = true
        
        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
    }
    
    // MARK: - Realm methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadPerson() {

        person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())

        self.profileInitialLbl.text = person.initials()
        MediaDownload.user(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profileInitialLbl.isHidden = true
                self.profileImg.isHidden = false
                self.profileImg.image = image
            } else {
                self.profileInitialLbl.isHidden = false
                self.profileImg.isHidden = true
            }
        }

        firstname.text = person.firstname
        lastname.text = person.lastname
    }
        
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        let firstnameTxt = firstname.text ?? ""
        let lastnameTxt = lastname.text ?? ""
        let country = "Israel"
        let location = "Moscow"
        let phone = "123456789"

        if (firstnameTxt.count == 0)    { ProgressHUD.showError("Firstname must be set.");        return    }
        if (lastnameTxt.count == 0)    { ProgressHUD.showError("Lastname must be set.");        return    }

        savePerson(firstname: firstnameTxt, lastname: lastnameTxt, country: country, location: location, phone: phone)

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func getProfilePicture(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Open Camera", style: .default) { action in
            ImagePicker.cameraPhoto(target: self, edit: true)
        })
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { action in
            ImagePicker.photoLibrary(target: self, edit: true)
        })
        
        alert.addAction(UIAlertAction(title: "Remove Photo", style: .default) { action in
            self.deletePhoto()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    func deletePhoto() {
        person.update(pictureAt: 0)
        profileImg.image = UIImage(named: "userPic")
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func savePerson(firstname: String, lastname: String, country: String, location: String, phone: String) {

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
        }
    }
    
    // MARK: - Upload methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func uploadPicture(image: UIImage) {

        if let data = image.jpegData(compressionQuality: 0.6) {
            if let encrypted = Cryptor.encrypt(data: data) {
                MediaUpload.user(AuthUser.userId(), data: encrypted) { error in
                    if (error == nil) {
                        self.pictureUploaded(image: image, data: data)
                    } else {
                        ProgressHUD.showError("Picture upload error.")
                    }
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func pictureUploaded(image: UIImage, data: Data) {

        person.update(pictureAt: Date().timestamp())

        Media.saveUser(AuthUser.userId(), data: data)

        profileImg.image = image
    }

}

// MARK: - UIImagePickerControllerDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if let image = info[.editedImage] as? UIImage {
            uploadPicture(image: image)
            self.isPhoto = true
        }
        picker.dismiss(animated: true)
    }
}
