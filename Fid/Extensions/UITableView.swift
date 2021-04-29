//
//  UITableView.swift
//  Fid
//
//  Created by CROCODILE on 11.03.2021.
//

import Foundation
import UIKit

extension UITableView {
  
  func scroll(to: Position, animated: Bool) {
    let sections = numberOfSections
    let rows = numberOfRows(inSection: numberOfSections - 1)
    switch to {
    case .top:
      if rows > 0 {
        let indexPath = IndexPath(row: 0, section: 0)
        self.scrollToRow(at: indexPath, at: .top, animated: animated)
      }
      break
    case .bottom:
      if rows > 0 {
        let indexPath = IndexPath(row: rows - 1, section: sections - 1)
        self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
      }
      break
    }
  }
  
  enum Position {
    case top
    case bottom
  }
}
