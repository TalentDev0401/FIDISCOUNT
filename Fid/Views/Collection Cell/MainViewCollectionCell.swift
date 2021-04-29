//
//  MainViewCollectionCell.swift
//  Fid
//
//  Created by CROCODILE on 18.01.2021.
//

import UIKit

class MainViewCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
      super.awakeFromNib()
      
        self.image.layer.cornerRadius = self.image.frame.size.height / 2
        self.image.layer.masksToBounds = true
    }
    
}
