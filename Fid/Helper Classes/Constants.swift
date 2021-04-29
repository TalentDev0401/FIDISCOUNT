//
//  Constants.swift
//  Fid
//
//  Created by CROCODILE on 14.01.2021.
//

import Foundation
import UIKit

struct SearchURL {
    
    static let search_word = "https://fid.ninja/wordslist.php"
    static let search_city = "https://fid.ninja/citylist.php"
}

struct ServerURL {
    static let sever_url_insert =  "https://fid.ninja/GP//registration.php"
    static let querySearch =       "https://fid.ninja/GP//querySearch.php"
    static let querySearch3 =      "https://fid.ninja//GP//querySearchv3.php"
    static let sendSearchUrl =     "https://fid.ninja/GP//url_click.php"
    static let filterCardListUrl = "https://fid.ninja/GP/cardslistcategory.php"
    static let cardListUrl =       "https://fid.ninja/GP/cardslistcategory.php"
    static let categoryList =      "https://fid.ninja/GP//categorylist.php"
    static let benefitList =       "https://fid.ninja/GP/maplist.php"
    static let benafite_click =    "https://fid.ninja/GP/benafit_click.php"
    static let like_insert =       "https://fid.ninja//GP//likes.php"
    static let upload_click =      "https://fid.ninja/GP/upload_click.php"
    static let post_discount =     "https://fid.ninja//GP//post_discount.php"
    
}

struct GoogleMapKey {
    static let mapKey = "AIzaSyBNW1LC8nm-MgQGv1YdjU5N1HF1Ggd8ZT0"
    static let directionKey = "AIzaSyCMF7ITal3QWN_iyjYZ5DaYPmaQoHvqukQ"
}
