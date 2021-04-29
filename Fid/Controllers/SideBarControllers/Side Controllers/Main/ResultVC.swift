//
//  ResultVC.swift
//  Fid
//
//  Created by CROCODILE on 19.01.2021.
//

import UIKit
import Toaster
import SDWebImage
import Freedom

class ResultVC: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var filterCardBtn: UIButton!
    @IBOutlet weak var filterLocationBtn: UIButton!
    @IBOutlet weak var displayMessage: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backImg: UIImageView!
    
    // MARK: - Properties
    
    var searchquery: String = ""
    var searchcard: String = "I1I"
    var searchcategory: String = "0"
    var location_search: String = "0"
    var userName: String = "Not Registered"
    
    var products: [SearchQueryProduct] = [SearchQueryProduct]()
    var product: SearchQueryProduct!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.retryBtn.isHidden = true
        self.displayMessage.isHidden = true
        
        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
        
        if let username = defaults.string(forKey: "userName") {
            self.userName = username
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadProducts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        self.location_search = "0"
    }
    
    // MARK: - Private methods
    
    func loadProducts() {
        
        // show loading view
        self.showLoadingView()
        self.filterLocationBtn.isHidden = true
        self.filterCardBtn.isHidden = true
        self.retryBtn.isHidden = true
        self.displayMessage.isHidden = true
        
        let param = ["textsearch": searchquery, "textcard": searchcard, "username": userName, "searchcategory": searchcategory, "searchlocation": location_search]
        
        APIHandler.AFPostRequest_QuerySearch(url: ServerURL.querySearch3, param: param) { (products, error) in
            
            self.hideLoadingView()
            
            if let error = error {
                print(error.localizedDescription)
                self.filterCardBtn.isHidden = true
                self.filterLocationBtn.isHidden = true
                self.displayMessage.isHidden = true
                self.retryBtn.isHidden = false
                return
            }
                                                
            if let products = products {
                if products.count == 0 {
                    
                    self.filterLocationBtn.isHidden = false
                    self.filterCardBtn.isHidden = false
                    self.displayMessage.isHidden = false
                    self.retryBtn.isHidden = true
                } else {
                    self.filterLocationBtn.isHidden = false
                    self.filterCardBtn.isHidden = false
                    self.displayMessage.isHidden = false
                    self.retryBtn.isHidden = true
                    
                    self.products = products
                }
            }
            
            self.setTitlewithProducts()
            self.tableView.reloadData()
        }
    }
    
    func setTitlewithProducts() {
        if self.products.count > 0 {
            let benefit_Title = self.products[0].title//productList.get(0).getTitle();
            if benefit_Title == "None" {
                let benefit_cards = self.products[0].card_type
                self.displayMessage.text = " נמצאו 0 הטבות עבור " + self.searchquery + "\n" + "הטבה קיימת בכרטיסים : " + benefit_cards!
                self.products.removeAll()

            } else {
                self.displayMessage.text = " נמצאו " + "\(self.products.count)" + " הטבות עבור " + self.searchquery
            }
        }else{
            self.displayMessage.text = " נמצאו 0 הטבות עבור " + self.searchquery
            
        }
    }
    
    func shareAction(benefit: SearchQueryProduct) {
       
        let title = benefit.title!
        let url = URL(string: benefit.search_url)!
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
    
    func sendBenefitClick() {
        
        let param : [String: String] = ["texturl": self.product.search_url, "textsearch": searchquery, "textcard": searchcard, "username": userName, "cardquery": self.product.card_type, "titlequery": self.product.title, "benafit_id": self.product.benefit_id]
        
        print(param)
                        
        APIHandler.AFPostRequest_SendBenefitClick(url: ServerURL.benafite_click, param: param) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            print("Success")
        }
    }

    // MARK: - IBOutActions
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterCardAction(_ sender: Any) {
        performSegue(withIdentifier: "filter_card", sender: self)
    }
    
    @IBAction func filterLocationAction(_ sender: Any) {
        showDialog(.fadeInOut)
    }
    
    @IBAction func retryLoadData(_ sender: Any) {
        self.retryBtn.isHidden = true
        self.loadProducts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter_card" {
            let destination = segue.destination as! FilterVC
            destination.delegate = self
            destination.searchquery_input = self.searchquery
            destination.searchCard = self.searchcard
        } else if segue.identifier == "benefit" {
            let destination = segue.destination as! BenefitVC
            destination.benefit = self.product
            destination.searchquery = self.searchquery
            destination.searchcard = self.searchcard
            destination.searchcategory = self.searchcategory
            destination.location_search = self.location_search
        }
    }
}

extension ResultVC: FilterVCProtocol {
    func sendSearchQueryFilter(searchquery: String, searchcard: String, searchcategory: String) {
        self.searchquery = searchquery
        self.searchcard = searchcard
        self.searchcategory = searchcategory
        
        self.products.removeAll()
        self.tableView.reloadData()
        
        self.loadProducts()
    }
}

extension ResultVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        
        let product = self.products[indexPath.row]
        cell.configureCell(product: product)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let product = self.products[indexPath.row]
        self.product = product
        self.performSegue(withIdentifier: "benefit", sender: self)
        self.sendBenefitClick()
    }
    
    func showAlert(product: SearchQueryProduct) {
        let alertController = UIAlertController(title: "", message: "לצפייה בהטבה באתר המועדון", preferredStyle: .alert)

        // Create the actions
        let okAction = UIAlertAction(title: "אישור", style: UIAlertAction.Style.default) {
                    UIAlertAction in
            
            if let url = product.search_url {
//                self.sendSearchUrl(url: url)
                UIApplication.shared.open(URL(string: url)!, options: [:])
            }
        }
        let cancelAction = UIAlertAction(title: "ביטול", style: UIAlertAction.Style.cancel) {
                    UIAlertAction in
            NSLog("Cancel Pressed")
        }

        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ResultVC: ShareProtocol {
    func shareWithUrl(product: SearchQueryProduct) {
        self.shareAction(benefit: product)
    }
}

extension ResultVC: CustomDialogProtocl {
    
    fileprivate func showDialog(_ animationPattern: LSAnimationPattern) {
        let dialogViewController = CustomDialogViewController(nibName: "CustomDialog", bundle: nil)
        dialogViewController.delegate = self
        
        presentDialogViewController(dialogViewController, animationPattern: animationPattern)
    }
    
    func dismissDialog() {
        dismissDialogViewController(LSAnimationPattern.fadeInOut)
    }
    
    func searchCity(cityname: String) {
        dismissDialogViewController(LSAnimationPattern.fadeInOut)
        
        Toast(text: cityname).show()
        
        self.location_search = cityname
        self.loadProducts()
    }
}
