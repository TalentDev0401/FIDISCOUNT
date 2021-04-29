//
//  TestViewController.swift
//  LSDialogViewController
//
//  Created by Daisuke Hasegawa on 2016/05/17.
//  Copyright © 2016年 Libra Studio, Inc. All rights reserved.
//

import UIKit
import SearchTextField

protocol CustomDialogProtocl {
    func dismissDialog()
    func searchCity(cityname: String)
}

class CustomDialogViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cityname: SearchTextField!
    
    var delegate: CustomDialogProtocl?
    var search_cities = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let search_cities_string = defaults.string(forKey: "search_city")
        self.search_cities = search_cities_string!.components(separatedBy: ",")
        print(search_cities)
        
        self.configureCustomSearchTextField()
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                // light mode detected
                break
            case .dark:
                // dark mode detected
                cityname.textColor = .black
                break
            @unknown default:
                break
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        self.view.frame.origin.y = 100
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 300
    }
    
    // 2 - Configure a custom search text view
    fileprivate func configureCustomSearchTextField() {
                
        // Modify current theme properties
        cityname.theme.font = UIFont.systemFont(ofSize: 14)
        cityname.theme.bgColor = .white
        cityname.theme.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        cityname.theme.separatorColor = UIColor.lightGray.withAlphaComponent(1.0)
        cityname.theme.cellHeight = 50
        cityname.theme.placeholderColor = UIColor.lightGray
        
        // Max number of results - Default: No limit
        cityname.maxNumberOfResults = 150
        
        // Max results list height - Default: No limit
        cityname.maxResultsListHeight = 200
        
        // Set specific comparision options - Default: .caseInsensitive
        cityname.comparisonOptions = [.caseInsensitive]

        // You can force the results list to support RTL languages - Default: false
        cityname.forceRightToLeft = false

        // Customize highlight attributes - Default: Bold
        cityname.highlightAttributes = [NSAttributedString.Key.backgroundColor: UIColor.yellow, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]
        
        // Handle item selection - Default behaviour: item title set to the text field
        cityname.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            // Do whatever you want with the picked item
            self.cityname.text = item.title
            self.view.endEditing(true)
        }
        
        // Update data source when the user stops typing
        cityname.userStoppedTypingHandler = {
            if let criteria = self.cityname.text {
                if criteria.count > 1 {
                    
                    // Show loading indicator
                    self.cityname.showLoadingIndicator()
                    
                    let filtered_words = self.search_cities.filter { $0.contains(criteria)}
                    
                    // Set new items to filter
                    self.cityname.filterStrings(filtered_words)
                    
                    // Stop loading indicator
                    self.cityname.stopLoadingIndicator()
                    
                }
            }
        } as (() -> Void)
    }
    
    // close dialogView
    @IBAction func closeButton(_ sender: Any) {
        delegate?.dismissDialog()
    }
    
    @IBAction func searchCity(_ sender: Any) {
        delegate?.searchCity(cityname: self.cityname.text!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
