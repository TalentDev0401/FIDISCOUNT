//
//  CategoryVC.swift
//  Fid
//
//  Created by CROCODILE on 19.01.2021.
//

import UIKit
import SearchTextField

class CategoryVC: UIViewController {

    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displayMessage: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    var name: String!
    var catId: Int!
    
    var search_words = [String]()
    var searchCard: String!
    var searchQuery: String!
    
    var my_cards_number_string: String!
    var userName: String = "Not Registered"
    
    var selectedCardTxt: String!
    var selectedCatId: Int!
    var categoryName: String = "Category"
    var categoryName_index: String = ""
    
    var categoryList: [CategoryList] = []
    
    var didSelect_table_row: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showLoadingView()
        let search_words_string = defaults.string(forKey: "search_words")
        self.search_words = search_words_string!.components(separatedBy: ",")
                
        self.searchView.backgroundColor = UIColor(hexString: "#e7eff1")
        self.searchView.layer.cornerRadius = self.searchView.frame.size.height / 2
        self.searchView.layer.masksToBounds = true
        
        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
        self.retryBtn.isHidden = true
        
        self.configureCustomSearchTextField()
                
        if self.name.count != 0 {
            self.categoryName = self.name
        }
        self.displayMessage.text = self.categoryName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchTextField.text = ""
        self.categotyindex()
        self.configureSettings()
        self.loadCategoryList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.didSelect_table_row = false
    }
    
    func categotyindex() {
        switch (categoryName) {

            case "???????????? ??????????????":
                categoryName_index = "1";
                break;
            case  "????????????????":
                categoryName_index = "1.1";
                break;
            case  "????????????":
                categoryName_index = "1.2";
                break;
            case ("????????????/\n??????????"):
                categoryName_index = "1.3";
                break;
            case ("?????? ????????????/\n???????????? ????????????"):
                categoryName_index = "1.4";
                break;

            case "????????????????":
                categoryName_index = "2";
                break;
            case "???????? ??????????":
                categoryName_index = "2.1";
                break;
            case "????????????":
                categoryName_index = "2.2";
                break;
            case "??????????\n??????????????":
                categoryName_index = "2.3";
                break;
            case "????????????????\n??????":
                categoryName_index = "2.4";
                break;
            case "??????????????":
                categoryName_index = "2.5";
                break;
            case "???????? ????????":
                categoryName_index = "2.6";
                break;
            case "??????????????/\n??????????????????":
                categoryName_index = "2.7";
                break;
            case "??????????\n????????????????":
                categoryName_index = "2.8";
                break;
            case "???????? ????????????":
                categoryName_index = "2.9";
                break;

            case "???????? ???????? ??????????????":
                categoryName_index = "3";
                break;
            case ("??????????/\n???????????? ????????????"):
                categoryName_index = "3.1";
                break;
            case ("??????????????????/\n??????????????"):
                categoryName_index = "3.2";
                break;
            case ("????????????" ):
                categoryName_index = "3.3";
                break;
            case ("?????? ??????"):
                categoryName_index = "3.4";
                break;
            case ("???????????? ??????????/\n???? ??????????????"):
                categoryName_index = "3.5";
                break;
            case ("???????????? ????????????????" ):
                categoryName_index = "3.6";
                break;
            case ("????????????/????????????/\n????????????"):
                categoryName_index = "3.7";
                break;
            case ("??????/????/??????" ):
                categoryName_index = "3.8";
                break;
            case ("?????????? ????????" ):
                categoryName_index = "3.9";
                break;

            case "????????":
                categoryName_index = "4";
                break;
            case "????????????":
                categoryName_index = "4.1";
                break;
            case "????????????":
                categoryName_index = "4.2";
                break;
            case "????????????":
                categoryName_index = "4.3";
                break;
            case "??????????":
                categoryName_index = "4.4";
                break;

            case "?????? ??????????":
                categoryName_index = "5";
                break;
            case "??????":
                categoryName_index = "5.1";
                break;
            case "??????????/\n?????????? ????????":
                categoryName_index = "5.2";
                break;
            case "????????????/\n??????????????":
                categoryName_index = "5.3";
                break;
            case "??????????/\n??????????????":
                categoryName_index = "5.4";
                break;
            case "??????????????/\n??????????????":
                categoryName_index = "5.5";
                break;
            case "????????????/\n????????????":
                categoryName_index = "5.6";
                break;

            case "?????????? ??????\"??":
                categoryName_index = "6";
                break;
            case "?????????? ?????? ????\"??":
                categoryName_index = "6.1";
                break;
            case "????????":
                categoryName_index = "6.2";
                break;
            case "??????????????":
                categoryName_index = "6.3";
                break;
            case "???????????? ????????????":
                categoryName_index = "6.4";
                break;

            case "????????????":
                categoryName_index = "7";
                break;
            case "???????? ????????\n????????????":
                categoryName_index = "7.1";
                break;
            case "??????????\n???????????? ????????":
                categoryName_index = "7.2";
                break;
            case "???????? ????????????":
                categoryName_index = "7.3";
                break;
            case "????????????":
                categoryName_index = "7.4";
                break;
            case "????????/??????????\n??????????????":
                categoryName_index = "7.5";
                break;
            case "??????????/????????????\n????????????????":
                categoryName_index = "7.6";
                break;
            case "?????? ??????????/????????????\n??????????????":
                categoryName_index = "7.7";
                break;
            case "??????????/??????????\n??????????":
                categoryName_index = "7.8";
                break;
            case "??????????????/??????????\n??????????":
                categoryName_index = "7.9";
                break;

            case "?????? ????????":
                categoryName_index = "8";
                break;
            case "?????????? ??????":
                categoryName_index = "8.1";
                break;
            case "?????????? ??????":
                categoryName_index = "8.2";
                break;
            case "?????????????? ????????":
                categoryName_index = "8.3";
                break;
            case "?????????????? ????????":
                categoryName_index = "8.4";
                break;

            case "???????????? ????????????":
                categoryName_index = "9";
                break;
            case "????????????/??????????/\n?????????? ????????????????":
                categoryName_index = "9.1";
                break;
            case "?????????? ?????????? ????????":
                categoryName_index = "9.2";
                break;
            case "?????????? ??????????":
                categoryName_index = "9.3";
                break;
            case "????????":
                categoryName_index = "9.4";
                break;
            case "??????????":
                categoryName_index = "9.5";
                break;
            case "??????????????/??????????????\n????????????":
                categoryName_index = "9.6";
                break;
            case "??????????????/\n?????????????? ????????????????????":
                categoryName_index = "9.7";
                break;
            case "????????/???????? ??????????\n?????????? ??????????":
                categoryName_index = "9.8";
                break;
            case "????????/??????????\n????????????":
                categoryName_index = "9.9";
                break;

            default:
                break
        }        
    }
    
    func configureSettings() {
        if let card = defaults.string(forKey: "selectedcarddef") {
            self.searchCard = card
        } else {
            self.searchCard = "I000I"
        }
        if let card_number = defaults.string(forKey: "my_cards_number") {
            self.my_cards_number_string = card_number
        } else {
            self.my_cards_number_string = "0"
        }
        
        if let username = defaults.string(forKey: "userName") {
            self.userName = username
        }
    }
    
    func loadCategoryList() {
        let param = ["searchcategory": categoryName_index, "username": userName]
        APIHandler.afPostRequest_CategoryList(url: ServerURL.categoryList, param: param) { list in
            
            self.hideLoadingView()
            if let list = list {
                self.categoryList = list
                self.retryBtn.isHidden = true
                self.displayMessage.isHidden = false
                self.tableView.isHidden = false
                self.tableView.reloadData()
            } else {
                self.retryBtn.isHidden = false
                self.displayMessage.isHidden = true
                self.tableView.isHidden = true
            }
        }
    }
    
    // 2 - Configure a custom search text view
    fileprivate func configureCustomSearchTextField() {
        
        self.searchTextField.placeholder = "?????? ????????"
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                // light mode detected
                break
            case .dark:
                // dark mode detected
                searchTextField.textColor = .black
                break
            @unknown default:
                break
        }

        // Modify current theme properties
        searchTextField.theme.font = UIFont.systemFont(ofSize: 14)
        searchTextField.theme.bgColor = .white
        searchTextField.theme.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        searchTextField.theme.separatorColor = UIColor.lightGray.withAlphaComponent(1.0)
        searchTextField.theme.cellHeight = 50
        searchTextField.theme.placeholderColor = UIColor.lightGray
        
        // Max number of results - Default: No limit
        searchTextField.maxNumberOfResults = 150
        
        // Max results list height - Default: No limit
        searchTextField.maxResultsListHeight = 200
        
        // Set specific comparision options - Default: .caseInsensitive
        searchTextField.comparisonOptions = [.caseInsensitive]

        // You can force the results list to support RTL languages - Default: false
        searchTextField.forceRightToLeft = false

        // Customize highlight attributes - Default: Bold
        searchTextField.highlightAttributes = [NSAttributedString.Key.backgroundColor: UIColor.yellow, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]
        
        // Handle item selection - Default behaviour: item title set to the text field
        searchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")
            
            // Do whatever you want with the picked item
            self.searchTextField.text = item.title
        }
        
        // Update data source when the user stops typing
        searchTextField.userStoppedTypingHandler = {
            if let criteria = self.searchTextField.text {
                if criteria.count > 1 {
                    
                    // Show loading indicator
                    self.searchTextField.showLoadingIndicator()
                    
                    let filtered_words = self.search_words.filter { $0.contains(criteria)}
                    
                    // Set new items to filter
                    self.searchTextField.filterStrings(filtered_words)
                    
                    // Stop loading indicator
                    self.searchTextField.stopLoadingIndicator()
                }
            }
        } as (() -> Void)
    }
    
    // MARK: - IBActions
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func retryAction(_ sender: Any) {
        self.retryBtn.isHidden = true
        self.loadCategoryList()
    }
    
    @IBAction func searchAction(_ sender: Any) {
        print("search Action")
        performSegue(withIdentifier: "search_from_category", sender: self)
    }
    
    @IBAction func selectCardAction(_ sender: Any) {
        print("select card action")
        performSegue(withIdentifier: "select_card_from_category", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search_from_category" {
            let destination = segue.destination as! ResultVC
            destination.searchcard = self.searchCard
            
            if self.didSelect_table_row {
                destination.searchquery = self.searchQuery
                destination.searchcategory = categoryName_index
            } else {
                destination.searchquery = self.searchTextField.text!
                destination.searchcategory = "0"
            }
            
        } else if segue.identifier == "select_card_from_category" {
//            let destination = segue.destination as! SelectCardVC
//            destination.delegate = self
        }
    }
}

extension CategoryVC: SelectCardVCProtocol {
    func sendSelectCard(card_number: String, selectedCardDef: String) {
        self.configureSettings()
    }
}

extension CategoryVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSegue(withIdentifier: "search_from_category", sender: self)
        return true
    }
}

extension CategoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableCell", for: indexPath) as! CategoryTableCell
        
        let product = self.categoryList[indexPath.row]
        cell.configure(categoryItem: product)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelect_table_row = true
        self.searchQuery = self.categoryList[indexPath.row].search_word
        performSegue(withIdentifier: "search_from_category", sender: self)
    }
}
