//
//  EncodableExtension.swift
//  Fid
//
//  Created by CROCODILE on 11.03.2021.
//

import Foundation

extension Encodable {
  var values: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
