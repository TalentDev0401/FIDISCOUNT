//
//  CategoryList.swift
//  Fid
//
//  Created by CROCODILE on 04.02.2021.
//

import Foundation
import UIKit

class CategoryList {
    
    var search_word: String!
    var lower_card: String!
    var lower_price: String!
    var search_image: String!
    var view_num: String
    
    init(word: String, price: String, card: String, image: String, view_number: String) {
        self.search_word = word
        self.lower_price = price
        self.lower_card = card
        self.search_image = image
        self.view_num = view_number
    }
}
