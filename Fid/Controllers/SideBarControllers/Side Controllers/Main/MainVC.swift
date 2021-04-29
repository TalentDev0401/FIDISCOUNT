//
//  MainVC.swift
//  Fid
//
//  Created by CROCODILE on 16.01.2021.
//

import UIKit
import SearchTextField

class MainVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var search_words = [String]()
    
    var searchCard: String!
    var my_cards_number_string: String!
    
    var selectedCardTxt: String!
    var selectedCatId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Users.loggedIn()
        
        let search_words_string = defaults.string(forKey: "search_words")
        self.search_words = search_words_string!.components(separatedBy: ",")
        
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
        
        self.searchView.backgroundColor = UIColor(hexString: "#e7eff1")
        self.searchView.layer.cornerRadius = self.searchView.frame.size.height / 2
        self.searchView.layer.masksToBounds = true
        
        self.configureCustomSearchTextField()
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectCardSetting(_:)), name: NSNotification.Name("selectCard"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(chatTab), name: NSNotification.Name("gotochat"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchTextField.text = ""
        self.configureSettings()
    }
    
    // MARK: - Private methods
    
    @objc func viewEndEditing() {
        self.view.endEditing(true)
    }
    
    @objc func chatTab() {
        self.tabBarController?.selectedIndex = 2
    }
    
    @objc func selectCardSetting(_ notification: Notification) {
        self.configureSettings()
    }
    
    func configureSettings() {
        if let card = defaults.string(forKey: "selectedcarddef") {
            self.searchCard = card
        } else {
            self.searchCard = "I000I"
        }
    }
    
    // 2 - Configure a custom search text view
    fileprivate func configureCustomSearchTextField() {
        
        self.searchTextField.placeholder = "חפש הטבה"
        
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
    
    @IBAction func searchAction(_ sender: Any) {
        print("search Action")
        performSegue(withIdentifier: "search", sender: self)
    }
    
    @IBAction func selectCardAction(_ sender: Any) {
        print("select card action")
        performSegue(withIdentifier: "select_card", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search" {
            let destination = segue.destination as! ResultVC
            destination.searchquery = self.searchTextField.text!
            destination.searchcard = self.searchCard
            destination.searchcategory = "0"
            
        } else if segue.identifier == "select_card" {
            let destination = segue.destination as! SelectCardVC
            destination.delegate = self
        } else if segue.identifier == "sub_cat" {
            let destination = segue.destination as! SubCatVC
            destination.name = self.selectedCardTxt
            destination.catId = self.selectedCatId
        }
    }
}

extension MainVC: SelectCardVCProtocol {
    func sendSelectCard(card_number: String, selectedCardDef: String) {
        self.configureSettings()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDatasource, UICollectionViewDelegateFlowLayout methods

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FidHelper.shared.getMainData().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewCollectionCell", for: indexPath) as! MainViewCollectionCell
        cell.image.image = UIImage(named: FidHelper.shared.getMainData()[indexPath.row].key!)
        cell.title.text = FidHelper.shared.getMainData()[indexPath.row].value
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedCardTxt = FidHelper.shared.getMainData()[indexPath.row].value
        self.selectedCatId = indexPath.row
        
        performSegue(withIdentifier: "sub_cat", sender: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 30)) / 3
        return CGSize(width: itemSize, height: itemSize*1.3)
    }
    
}

extension MainVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSegue(withIdentifier: "search", sender: self)
        return true
    }
}
