//
//  CategoryTableCell.swift
//  Fid
//
//  Created by CROCODILE on 21.01.2021.
//

import UIKit
import SDWebImage

class CategoryTableCell: UITableViewCell {
    
    @IBOutlet weak var lower_price: UILabel!
    @IBOutlet weak var lower_card: UILabel!
    @IBOutlet weak var search_word: UILabel!
    @IBOutlet weak var search_image: UIImageView!
    @IBOutlet weak var contents: UIView!
    @IBOutlet weak var subContents: UIView!
    @IBOutlet weak var icon_arrow: UIImageView!
    @IBOutlet weak var view_num: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.subContents.layer.cornerRadius = 10
        self.subContents.layer.masksToBounds = true
        
        let arrow = UIImage(named: "arrow")
        icon_arrow.image = arrow?.withRenderingMode(.alwaysTemplate)
        icon_arrow.tintColor = UIColor(hexString: "#092D37")
        
        self.search_image.layer.cornerRadius = self.search_image.frame.size.height / 2
        self.search_image.layer.masksToBounds = true
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                // light mode detected
                break
            case .dark:
                // dark mode detected
//                search_word.textColor = .black
                break
            @unknown default:
                break
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(categoryItem: CategoryList) {
        self.lower_price.text = categoryItem.lower_price
        self.search_word.text = categoryItem.search_word
        self.lower_card.text = categoryItem.lower_card
        self.view_num.text = categoryItem.view_num
        self.search_image.sd_setImage(with: URL(string: categoryItem.search_image)!)
        
        self.contents.layer.cornerRadius = 10        
        contents.layer.shadowRadius = 5
        contents.layer.shadowColor = UIColor.lightGray.cgColor
        contents.layer.shadowOffset = .zero
        contents.layer.shadowOpacity = 1
    }

}
