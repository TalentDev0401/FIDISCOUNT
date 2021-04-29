//
//  BenefitVC.swift
//  Fid
//
//  Created by CROCODILE on 10.03.2021.
//

import UIKit
import Freedom
import KeyboardLayoutGuide
import RealmSwift
import ProgressHUD

class BenefitVC: UIViewController {
    
    @IBOutlet weak var view_numberLbl: UILabel!
    @IBOutlet weak var likes_numberLbl: UILabel!
    @IBOutlet weak var likesImg: UIImageView!
    @IBOutlet weak var save_locallyBtn: UIButton!
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var shopView: UIView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var sendBtnImg: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tagging: Tagging! {
        didSet {
            tagging.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tagging.accessibilityIdentifier = "Tagging"
            tagging.textView.accessibilityIdentifier = "TaggingTextView"
            tagging.borderWidth = 1.0
//            tagging.cornerRadius = 5
            tagging.textInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
            tagging.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            tagging.defaultAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            tagging.symbolAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
            tagging.taggedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.underlineStyle: NSNumber(value: 1)]
            tagging.dataSource = self
            
            tagging.symbol = "@"
            
            switch traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    // light mode detected
                    break
                case .dark:
                    // dark mode detected
                    tagging.textView.textColor = .black
                    tagging.backgroundColor = .white
                    
                    break
                @unknown default:
                    break
            }
        }
    }
    
    let firebaseUpload = FirebaseUpload()
    let firebaseDownload = FirebaseDownload()
    
    @objc func handleSend() {
        
        if tagging.textView.text.count != 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM YYYY"
            let dateStr = dateFormatter.string(from: Date())
            
            let commentObject = ObjectComment()
            commentObject.id = UUID().uuidString
            commentObject.userId = AuthUser.userId()
            commentObject.userName = Persons.fullname()
            commentObject.comment = tagging.textView.text
            commentObject.postId = self.benefit.benefit_id
            commentObject.postTime = dateStr
            commentObject.likes = []
            commentObject.replies = []
            
            self.comments.append(commentObject)
            let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            tagging.textView.text = nil
            tagging.removeAllTaggedList()
            
            firebaseUpload.UpdateComment(commentObject, postId: self.benefit.benefit_id) { response in
                switch response {
                case .failure: return
                case .success:
                    print("Successfully commented")
                }
            }
            
            self.tagging.textView.resignFirstResponder()
        }
    }
    
    var comments: [ObjectComment] = [ObjectComment]()
    
    var benefit: SearchQueryProduct!
    var like_Num: Int = 0
    
    private var person: Person!
    private var initialTxt: String!
    private var userImg: UIImage!
    private var fullNameTxt: String!
    
    var searchquery: String = ""
    var searchcard: String = "I1I"
    var searchcategory: String = "0"
    var location_search: String = "0"
    var userName: String = "Not Registered"
    
    private var benefitRealm: Benefit?
    private var likeBenefitRealm: LikeBenefit?

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeView()
        configureView()
        configureCommentView()
                        
        if let username = defaults.string(forKey: "userName") {
            self.userName = username
        }
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        if (AuthUser.userId() == "") {
            let alert = UIAlertController(title: "Login required", message: "You should login or register for benefit with the other users.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { void in
                self.tabBarController?.selectedIndex = 0
            }))

            alert.addAction(UIAlertAction(title: "Register", style: .default, handler: { void in
                let register = self.storyboard?.instantiateViewController(identifier: "RegisterVC") as! RegisterVC
                self.navigationController?.popPushToVC(ofKind: RegisterVC.self, pushController: register)
            }))
                    
            self.present(alert, animated: true, completion: nil)
        }
        
        FidHelper.shared.chatsFromBenefit = false
        FidHelper.shared.benefit = nil
    }
    
    func initializeView() {
        
        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
        
        self.uploadView.layer.borderWidth = 1.0
        self.uploadView.layer.borderColor = UIColor.lightGray.cgColor
        self.uploadView.layer.masksToBounds = true
        self.saveView.layer.borderWidth = 1.0
        self.saveView.layer.borderColor = UIColor.lightGray.cgColor
        self.saveView.layer.masksToBounds = true
        self.shopView.layer.borderWidth = 1.0
        self.shopView.layer.borderColor = UIColor.lightGray.cgColor
        self.shopView.layer.masksToBounds = true
        self.chatView.layer.borderWidth = 1.0
        self.chatView.layer.borderColor = UIColor.lightGray.cgColor
        self.chatView.layer.masksToBounds = true
        self.mapView.layer.borderWidth = 1.0
        self.mapView.layer.borderColor = UIColor.lightGray.cgColor
        self.mapView.layer.masksToBounds = true
        self.shareView.layer.borderWidth = 1.0
        self.shareView.layer.borderColor = UIColor.lightGray.cgColor
        self.shareView.layer.masksToBounds = true
        
        self.like_Num = Int(self.benefit.likes_number)!
        
        // Benefit data from realm
        
        benefitRealm = realm.object(ofType: Benefit.self, forPrimaryKey: self.benefit.benefit_id)
        if benefitRealm != nil {
            self.save_locallyBtn.isSelected = true
        } else {
            self.save_locallyBtn.isSelected = false
        }
        
        likeBenefitRealm = realm.object(ofType: LikeBenefit.self, forPrimaryKey: self.benefit.benefit_id)
        if likeBenefitRealm != nil {
            self.likesImg.image = UIImage(named: "icon_benefit_likes")
        } else {
            self.likesImg.image = UIImage(named: "icon_benefit_unlikes")
        }
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                // light mode detected
                break
            case .dark:
                // dark mode detected
                let send = UIImage(named: "send_btn")
                sendBtnImg.image = send?.withRenderingMode(.alwaysTemplate)
                sendBtnImg.tintColor = UIColor(hexString: "#27bdb1")
                break
            @unknown default:
                break
        }
        
    }
    
    func configureView() {
        self.descLbl.text = self.benefit.title
        self.view_numberLbl.text = self.benefit.view_number
        self.likes_numberLbl.text = self.benefit.likes_number
    }
    
    func configureCommentView() {
//        bottomBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        sendBtn.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
                
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.downloadComments()
    }
                
    // MARK: - IBActions
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func BenefitLikeAction(_ sender: Any) {
                
        if likeBenefitRealm == nil {
            self.like_Num = self.like_Num + 1
            self.likes_numberLbl.text = "\(self.like_Num)"
            self.likesImg.image = UIImage(named: "icon_benefit_likes")
            self.sendLikeActionClick(operators: "increased")
            
            self.saveLikeBenefit()
        } else {
            self.like_Num = self.like_Num - 1
            self.likes_numberLbl.text = "\(self.like_Num)"
            self.likesImg.image = UIImage(named: "icon_benefit_unlikes")
            self.sendLikeActionClick(operators: "decreased")
            
            let realm = try! Realm()
            let deleteData = realm.object(ofType: LikeBenefit.self, forPrimaryKey: self.benefit.benefit_id)
            
            try! realm.safeWrite {
                realm.delete(deleteData!)
            }
                        
            self.likeBenefitRealm = nil
            print("deleted benefit from local")
        }
    }
    
    @IBAction func gotoShare(_ sender: Any) {
        self.shareAction()
    }
    
    @IBAction func gotoChat(_ sender: Any) {
//        self.navigationController?.popToRootViewController(animated: true)
//        NotificationCenter.default.post(name: NSNotification.Name("gotochat"), object: nil)
        FidHelper.shared.chatsFromBenefit = true
        FidHelper.shared.benefit = self.benefit
        self.performSegue(withIdentifier: "chats_benefit", sender: self)
        
    }
    
    @IBAction func saveBenefitLocally(_ sender: Any) {
        
        if benefitRealm == nil {
            self.save_locallyBtn.isSelected = true
            self.saveBenefit()
            print("Saved benefit locally")
        } else {
            let realm = try! Realm()
            let deleteData = realm.object(ofType: Benefit.self, forPrimaryKey: self.benefit.benefit_id)
            
            try! realm.safeWrite {
                realm.delete(deleteData!)
            }
            
            self.save_locallyBtn.isSelected = false
            
            self.benefitRealm = nil
            print("deleted benefit from local")
        }
    }
    
    @IBAction func gotoMap(_ sender: Any) {
        if self.benefit.locations.count != 0 {
            self.performSegue(withIdentifier: "benefit_map", sender: self)
        } else {
            let alert = UIAlertController(title: "", message: "There is no any location data for this benefit", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func openShopUrl(_ sender: Any) {
        UIApplication.shared.open(URL(string: self.benefit.search_url)!, options: [:], completionHandler: nil)
        self.sendSearchUrl()
    }
    
    @IBAction func uploadAttachment(_ sender: Any) {
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
    
    func saveBenefit() {
        
        let realm = try! Realm()
        try! realm.safeWrite {
            benefitRealm = Benefit()
            benefitRealm?.benefit_id = self.benefit.benefit_id
            benefitRealm?.title = self.benefit.title
            benefitRealm?.card_type = self.benefit.card_type
            benefitRealm?.search_url = self.benefit.search_url
            benefitRealm?.search_category = self.benefit.search_category
            benefitRealm?.card_image = self.benefit.card_image
            benefitRealm?.view_number = self.benefit.view_number
            benefitRealm?.likes_number = self.benefit.likes_number
            
            let locationss = List<LocationRealm>()
            for item in self.benefit.locations {
                let loc = LocationRealm()
                loc.lat = item.lat
                loc.lon = item.lon
                locationss.append(loc)
            }
            benefitRealm?.locations = locationss
            
            realm.add(benefitRealm!, update: .modified)
        }
    }
    
    func saveLikeBenefit() {
        let realm = try! Realm()
        try! realm.safeWrite {
            likeBenefitRealm = LikeBenefit()
            likeBenefitRealm?.benefit_id = self.benefit.benefit_id
            likeBenefitRealm?.title = self.benefit.title
            likeBenefitRealm?.card_type = self.benefit.card_type
            likeBenefitRealm?.search_url = self.benefit.search_url
            likeBenefitRealm?.search_category = self.benefit.search_category
            likeBenefitRealm?.card_image = self.benefit.card_image
            likeBenefitRealm?.view_number = self.benefit.view_number
            likeBenefitRealm?.likes_number = self.benefit.likes_number
            
            let locationss = List<LocationRealm>()
            for item in self.benefit.locations {
                let loc = LocationRealm()
                loc.lat = item.lat
                loc.lon = item.lon
                locationss.append(loc)
            }
            likeBenefitRealm?.locations = locationss
            
            realm.add(likeBenefitRealm!, update: .modified)
        }
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func uploadPicture(image: UIImage) {

        if let data = image.jpegData(compressionQuality: 0.6) {
            
            let pic_name = UUID().uuidString
            self.showLoadingView()
            
            MediaUpload.benefit(pic_name, data: data) { error in
                if (error == nil) {
                    self.uploadAttachment_Img(pic_name: pic_name)
                } else {
                    self.hideLoadingView()
                    ProgressHUD.showError("Picture upload error.")
                }
            }
        }
    }
    
    func uploadAttachment_Img(pic_name: String) {
        let param: [String: String] = ["username": self.userName, "benafit_id": self.benefit.benefit_id, "pic_name": pic_name]
        
        APIHandler.AFPostRequest_SendSearchUrl(url: ServerURL.upload_click, param: param) { error in
            self.hideLoadingView()
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            print("Success")
            ProgressHUD.showSuccess()
        }
    }
    
    func sendSearchUrl() {
        
        let param: [String: String] = ["texturl": self.benefit.search_url, "textsearch": searchquery, "textcard": searchcard, "username": userName, "cardquery": self.benefit.card_type, "titlequery": self.benefit.title, "benafit_id": self.benefit.benefit_id]
        
        print(param)
                
        APIHandler.AFPostRequest_SendSearchUrl(url: ServerURL.sendSearchUrl, param: param) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            print("Success")
        }
    }
    
    func sendLikeActionClick(operators: String) {
        
        let param : [String: String] = ["search_url": self.benefit.search_url, "benafit_id": self.benefit.benefit_id, "like_operator": operators, "username": userName, "card_displayname": self.benefit.card_type, "title_base": self.benefit.title]
        
        print(param)
        
        APIHandler.AFPostRequest_SendBenefitClick(url: ServerURL.like_insert, param: param) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            print("Success")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "benefit_map" {
            let destination = segue.destination as! BenefitMapVC
            destination.benefitList = self.benefit.locations
        } else if segue.identifier == "chats_benefit" {
            _ = segue.destination as! BenefitChatsView
        }
    }
    
    // MARK: - Private methods
    
    func shareAction() {
       
        let title = self.benefit.title!
        let url = URL(string: self.benefit.search_url)!
        let end = "shared by FID app"
        // Enable Debug Logs (disabled by default)
        Freedom.debugEnabled = true
        // Fetch activities for Safari and all third-party browsers supported by Freedom.
        let activities = Freedom.browsers()
        // Alternatively, one could select a specific browser (or browsers).
        // let activities = Freedom.browsers([.chrome])

        let activityViewController : UIActivityViewController = UIActivityViewController(
        activityItems: [title, url, end], applicationActivities: activities)
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
            UIActivity.ActivityType.postToWeibo,
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
    
    func downloadComments() {
        self.comments.removeAll()
//        self.showLoadingView()
        firebaseDownload.DownloadComments(postId: self.benefit.benefit_id) { comments, error in
//            self.hideLoadingView()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let comments = comments {
                
                let sortedComments = comments.sorted {
                    $0.timestamp < $1.timestamp
                }
                self.comments = sortedComments
                self.tableView.reloadData()
                self.tableView.scroll(to: .bottom, animated: true)
            }
        }
    }

}

extension BenefitVC: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return ""
    }
    
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "FID APP"
    }
}

// MARK: - TaggingDataSource

extension BenefitVC: TaggingDataSource {
            
    func tagging(_ tagging: Tagging, didChangedTaggedList taggedList: [TaggingModel]) {

    }
}


extension BenefitVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableCell", for: indexPath) as! CommentTableCell
        let comment = self.comments[indexPath.row]
        cell.configure(comment: comment)
        cell.delegate = self
                        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)        
    }
}

extension BenefitVC: UITextViewDelegate {
    
}

extension BenefitVC: CommentDelegate {
    func handleMention(username: String) {
        print("username is \(username)")
        
    }
    
    func handleHashTag(tagname: String) {
        print("clicked hashtag")
    }
    
    func handleURL(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func replyComment(username: String) {
                
        tagging.textView.text.append("@")
        tagging.updateTaggedList(allText: tagging.textView.text, tagText: username)
        tagging.textView.becomeFirstResponder()
    }
}

// MARK: - UIImagePickerControllerDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension BenefitVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if let image = info[.editedImage] as? UIImage {
            uploadPicture(image: image)            
        }
        picker.dismiss(animated: true)
    }
}
