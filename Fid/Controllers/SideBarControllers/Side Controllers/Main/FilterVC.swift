//
//  FilterVC.swift
//  Fid
//
//  Created by CROCODILE on 21.01.2021.
//

import UIKit

protocol FilterVCProtocol {
    func sendSearchQueryFilter(searchquery: String, searchcard: String, searchcategory: String)
}

class FilterVC: UIViewController {
    
    @IBOutlet weak var displayMessage: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: FilterVCProtocol?
    
    var searchquery_input = ""
    var searchCard: String = ""
    var cardList: [CardData] = []
    var selectedCards: [String] = []
    var checkCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.retryBtn.isHidden = true
        self.filterBtn.isHidden = true
        
        tableView.register(UINib(nibName: "FilterCardHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "FilterCardHeaderView")
        
        defaults.setValue("", forKey: "myFilterChoices")
        
        self.loadFilterCard()
    }
    
    // MARK: - Private methods
    
    func loadFilterCard() {
        self.showLoadingView()
        APIHandler.AFGetRequestCardList(url: ServerURL.filterCardListUrl) { sections in
            self.hideLoadingView()
            
            if let sections = sections {
                
                self.cardList = sections
                
                self.getModel()
                
                self.tableView.reloadData()
                self.filterBtn.isHidden = false
                
            } else {
                self.retryBtn.isHidden = false
            }
        }
    }
    
    func getModel() {
               
        var myChoices = ""
        if let choice = defaults.string(forKey: "myChoices") {
            myChoices = choice
        }
        
        let myChoicesSplit = myChoices.components(separatedBy: ",")
        if myChoicesSplit.count != 0 {
            if myChoicesSplit.count == 1 {
                if myChoicesSplit.contains(self.cardList[0].rows[0].cardItem.card_id) {
                    checkCount = 0
                    self.cardList[0].rows[0].isChecked = true
                } else {
                    checkCount = 1
                    for i in 0..<self.cardList.count {
                        for j in 0..<self.cardList[i].rows.count {
                            if myChoicesSplit.contains(self.cardList[i].rows[j].cardItem.card_id) {
                                self.cardList[i].rows[j].isChecked = true
                            }
                        }
                    }
                }
            } else {
                checkCount = myChoicesSplit.count
                for i in 0..<self.cardList.count {
                    for j in 0..<self.cardList[i].rows.count {
                        if myChoicesSplit.contains(self.cardList[i].rows[j].cardItem.card_id) {
                            self.cardList[i].rows[j].isChecked = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func filterCardAction(_ sender: Any) {
                
        var x_i = ""
        for item in self.selectedCards {
            x_i = x_i + "I" + item + "I" + " "
        }
                        
        searchCard = x_i
                
        delegate?.sendSearchQueryFilter(searchquery: self.searchquery_input, searchcard: searchCard, searchcategory: "0")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func retryAction(_ sender: Any) {
        self.retryBtn.isHidden = true
        self.loadFilterCard()
    }
}

extension FilterVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.cardList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cardList[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableCell", for: indexPath) as! FilterTableCell
        
        let card = self.cardList[indexPath.section]
        let row = card.rows[indexPath.row]
        cell.configureCell(card: row, indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterCardHeaderView") as! FilterCardHeaderView
        headerView.sectionTitleLabel.text = self.cardList[section].section
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension FilterVC: FilterTableCellProtocol {
    func isCheckedItem(isOn: Bool, indexPath index: IndexPath) {
        if index.section == 0 && index.row == 0 {
            
            checkCount = 0
            self.selectedCards.removeAll()
            self.selectedCards.append(self.cardList[0].rows[0].cardItem.card_id)
            
            for i in 0..<self.cardList.count {
                for j in 0..<self.cardList[i].rows.count {
                    if i == 0 && j == 0 {
                        self.cardList[i].rows[j].isChecked = true
                    } else {
                        self.cardList[i].rows[j].isChecked = false
                    }
                    self.tableView.reloadData()
                }
            }
        } else {
            
            self.cardList[0].rows[0].isChecked = false
            
            if self.selectedCards.contains(self.cardList[0].rows[0].cardItem.card_id) {
                self.selectedCards.removeAll()
            }
            
            if !isOn && checkCount < 2 {
                checkCount = 1
                self.cardList[index.section].rows[index.row].isChecked = true
                
                self.selectedCards.removeAll()
                self.selectedCards.append(self.cardList[index.section].rows[index.row].cardItem.card_id)
                
            } else {
                self.cardList[index.section].rows[index.row].isChecked = isOn
                if isOn {
                    checkCount = checkCount + 1
                    
                    self.selectedCards.append(self.cardList[index.section].rows[index.row].cardItem.card_id)
                    
                } else {
                    checkCount = checkCount - 1
                    
                    if self.selectedCards.contains(self.cardList[index.section].rows[index.row].cardItem.card_id) {
                        let filteredCards = self.selectedCards.filter { $0 != self.cardList[index.section].rows[index.row].cardItem.card_id }
                        self.selectedCards = filteredCards
                    }
                    
                }
            }
            
            self.tableView.reloadData()
        }
    }
}
