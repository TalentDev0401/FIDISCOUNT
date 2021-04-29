//
//  NewPostVC.swift
//  Fid
//
//  Created by CROCODILE on 18.03.2021.
//

import UIKit
import ProgressHUD

class NewPostVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLbl: UITextField!
    @IBOutlet weak var discountLbl: UITextField!
    @IBOutlet weak var cardLbl: UITextField!
    @IBOutlet weak var locationLbl: UITextField!
    @IBOutlet weak var descriptionLbl: UITextField!
    @IBOutlet weak var backImg: UIImageView!

    var isSelect = false
    var picImg: UIImage?
    var userName: String = "Not Registered"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let username = defaults.string(forKey: "userName") {
            self.userName = username
        }
        
        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
        
    }
    
    // MARK: - IBActions
    
    @IBAction func goback(_ sender: Any) {
        let navigationController : MainNavigationVC = self.sideBarController.contentViewController as! MainNavigationVC
        navigationController.showTabBarController()
    }
    
    @IBAction func postBenefit(_ sender: Any) {
                    
        var title = ""
        var discount = ""
        var card = ""
        var location = ""
        var descriptions = ""
        if (titleLbl.text?.count != 0)    { title = self.titleLbl.text! }
        if (discountLbl.text?.count != 0)    { discount = self.discountLbl.text! }
        if (cardLbl.text?.count != 0)        { card = self.cardLbl.text! }
        if (locationLbl.text?.count != 0)    { location = self.locationLbl.text! }
        if (descriptionLbl.text?.count != 0)        { descriptions = self.descriptionLbl.text! }
        
        if self.picImg == nil {
            self.showLoadingView()
            self.uploadAttachment_Img(pic_name: "", title: title, discount: discount, card: card, location: location, descriptions: descriptions)
        } else {
            self.uploadPicture(image: self.picImg!, title: title, discount: discount, card: card, location: location, descriptions: descriptions)
        }
    }
    
    @IBAction func picAttachment(_ sender: Any) {
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
    
    // MARK: - Private methods
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func uploadPicture(image: UIImage, title: String, discount: String, card: String, location: String, descriptions: String) {

        if let data = image.jpegData(compressionQuality: 0.6) {
            
            let pic_name = UUID().uuidString
            self.showLoadingView()
            
            MediaUpload.benefit(pic_name, data: data) { error in
                if (error == nil) {
                    self.uploadAttachment_Img(pic_name: pic_name, title: title, discount: discount, card: card, location: location, descriptions: descriptions)
                } else {
                    self.hideLoadingView()
                    ProgressHUD.showError("Attachment upload error.")
                }
            }
        }
    }
    
    func uploadAttachment_Img(pic_name: String, title: String, discount: String, card: String, location: String, descriptions: String) {
        let param: [String: String] = ["username": self.userName, "titlepost": title, "discountpost": discount, "cardpost": card, "discountlocation": location, "descriptionpost": descriptions, "pic_name": pic_name]
        
        APIHandler.AFPostRequest_SendSearchUrl(url: ServerURL.post_discount, param: param) { error in
            self.hideLoadingView()
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            print("Success")
            ProgressHUD.showSuccess()
            self.titleLbl.text = ""
            self.discountLbl.text = ""
            self.cardLbl.text = ""
            self.locationLbl.text = ""
            self.descriptionLbl.text = ""
            self.isSelect = false
            self.picImg = nil
        }
    }

}

// MARK: - UIImagePickerControllerDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension NewPostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if let image = info[.editedImage] as? UIImage {
            self.picImg = image
            self.isSelect = true
        }
        picker.dismiss(animated: true)
    }
}
