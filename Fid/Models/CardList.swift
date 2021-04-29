//
//  CityNameList.swift
//  Fid
//
//  Created by CROCODILE on 14.01.2021.
//

import Foundation
import UIKit

class CardList {
    
    var card_id: String!
    var card_name: String!
    var card_image: String!
    
    init(card_id: String, name: String, image: String) {
        self.card_id = card_id
        self.card_name = name
        self.card_image = image
    }
}
