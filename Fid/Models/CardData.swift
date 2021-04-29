//
//  CardData.swift
//  Fid
//
//  Created by CROCODILE on 24.03.2021.
//

import Foundation
import UIKit

class CardData {
    
    var section: String!
    var rows: [FilterCard] = []
    
    init(section_name: String, rows_data: [FilterCard]) {
        self.section = section_name
        self.rows = rows_data
    }
}
