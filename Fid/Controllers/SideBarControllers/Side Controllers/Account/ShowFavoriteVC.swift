//
//  ShowFavoriteVC.swift
//  Fid
//
//  Created by CROCODILE on 17.03.2021.
//

import UIKit
import Toaster
import SDWebImage
import Freedom
import RealmSwift

class ShowFavoriteVC: UIViewController {

    //MARK: - IBOutlets
    
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
        
        self.location_search = "0"
    }
    
    // MARK: - Private methods
    
    func loadProducts() {
        self.products.removeAll()
        let realm = try! Realm()
        let object = realm.objects(Benefit.self)
        for item in object {
            
            let Realm_Locations = item.locations
            var locations = [Location]()
            for item1 in Realm_Locations {
                locations.append(Location(lat: item1.lat, lon: item1.lon))
            }
            let product = SearchQueryProduct(title: item.title, cardType: item.card_type, searchUrl: item.search_url, searchCategory: item.search_category, cardImage: item.card_image, view_number: item.view_number, likes_number: item.likes_number, benefit_id: item.benefit_id, locations: locations)
            
            self.products.append(product)
        }
        
        self.tableView.reloadData()
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
    
    func actionDelete(at indexPath: IndexPath) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in
            let product = self.products[indexPath.row]
            self.products.remove(at: indexPath.row)
            
            let realm = try! Realm()
            let deleteData = realm.object(ofType: Benefit.self, forPrimaryKey: product.benefit_id)
            
            try! realm.safeWrite {
                realm.delete(deleteData!)
            }
            
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    // MARK: - IBOutActions
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit_benefit" {
            let destination = segue.destination as! BenefitVC
            destination.benefit = self.product
            destination.searchquery = self.searchquery
            destination.searchcard = self.searchcard
            destination.searchcategory = self.searchcategory
            destination.location_search = self.location_search
        }
    }
}

extension ShowFavoriteVC: FilterVCProtocol {
    func sendSearchQueryFilter(searchquery: String, searchcard: String, searchcategory: String) {
        self.searchquery = searchquery
        self.searchcard = searchcard
        self.searchcategory = searchcategory
        
        self.loadProducts()
    }
}

extension ShowFavoriteVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "show_result", for: indexPath) as! SearchResultCell
        
        let product = self.products[indexPath.row]
        cell.configureCell(product: product)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let product = self.products[indexPath.row]
        self.product = product
        self.performSegue(withIdentifier: "edit_benefit", sender: self)
        self.sendBenefitClick()
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let actionDelete = UIContextualAction(style: .destructive, title: "Delete") {  action, sourceView, completionHandler in
            self.actionDelete(at: indexPath)
            completionHandler(false)
        }

        actionDelete.image = UIImage(systemName: "trash")
        

        return UISwipeActionsConfiguration(actions: [actionDelete])
    }
    
}

extension ShowFavoriteVC: ShareProtocol {
    func shareWithUrl(product: SearchQueryProduct) {
        self.shareAction(benefit: product)
    }
}

extension ShowFavoriteVC: CustomDialogProtocl {
    
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
