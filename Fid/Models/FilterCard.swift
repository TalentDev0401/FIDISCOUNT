//
//  FilterCard.swift
//  Fid
//
//  Created by CROCODILE on 21.01.2021.
//

import Foundation
import UIKit

class FilterCard {
    
    var isChecked = false
    var cardItem: CardList!
    
    init(checked: Bool, item: CardList) {        
        self.isChecked = checked
        self.cardItem = item
    }
}
