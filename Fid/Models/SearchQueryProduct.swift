//
//  SearchQueryProduct.swift
//  Fid
//
//  Created by CROCODILE on 20.01.2021.
//

import Foundation
import UIKit

class SearchQueryProduct {
    
    var benefit_id: String!
    var title: String!
    var card_type: String!
    var search_url: String!
    var search_category: String!
    var card_image: String!
    var view_number: String!
    var likes_number: String!
    var locations: [Location] = []
    
    init(title: String, cardType: String, searchUrl: String, searchCategory: String, cardImage: String, view_number: String, likes_number: String, benefit_id: String, locations: [Location]) {
        self.benefit_id = benefit_id
        self.title = title
        self.card_type = cardType
        self.search_url = searchUrl
        self.search_category = searchCategory
        self.card_image = cardImage
        self.view_number = view_number
        self.likes_number = likes_number
        self.locations = locations
    }
}
