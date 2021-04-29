//
//  FilterTableCell.swift
//  Fid
//
//  Created by CROCODILE on 21.01.2021.
//

import UIKit
import SDWebImage

protocol FilterTableCellProtocol {
    func isCheckedItem(isOn: Bool, indexPath: IndexPath)
}

class FilterTableCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: Checkbox!
    @IBOutlet weak var filter_card_type: UILabel!
    @IBOutlet weak var card_image: UIImageView!
    @IBOutlet weak var contents: UIView!
    
    var delegate: FilterTableCellProtocol?
    
    var itemIndex: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
                
        self.contents.layer.cornerRadius = 9
        contents.layer.shadowRadius = 5
        contents.layer.shadowColor = UIColor.lightGray.cgColor
        contents.layer.shadowOffset = .zero
        contents.layer.shadowOpacity = 1
        
        self.checkBox.isChecked = false
        checkBox.valueChanged = { (value) in
            self.delegate?.isCheckedItem(isOn: value, indexPath: self.itemIndex)
        }
    }
    
    func configureCell(card: FilterCard, indexPath: IndexPath) {
        self.checkBox.isChecked = card.isChecked
        self.filter_card_type.text = card.cardItem.card_name
        self.card_image.sd_setImage(with: URL(string: card.cardItem.card_image)!)
        self.itemIndex = indexPath
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
