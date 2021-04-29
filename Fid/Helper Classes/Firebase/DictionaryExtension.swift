//
//  DictionaryExtension.swift
//  Fid
//
//  Created by CROCODILE on 11.03.2021.
//

import Foundation

extension Dictionary {
  
  var data: Data? {
    return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
  }
}
