//
//  SearchResultCell.swift
//  Fid
//
//  Created by CROCODILE on 20.01.2021.
//

import UIKit

protocol ShareProtocol {
    func shareWithUrl(product: SearchQueryProduct)
}

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var cardType: UILabel!
    @IBOutlet weak var contents: UIView!
    @IBOutlet weak var subContents: UIView!
    @IBOutlet weak var card_image: UIImageView!
    @IBOutlet weak var icon_arrow: UIImageView!
    @IBOutlet weak var view_number: UILabel!
    @IBOutlet weak var likes_number: UILabel!
    
    var delegate: ShareProtocol?
    var product: SearchQueryProduct!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.subContents.layer.cornerRadius = 10
        self.subContents.layer.masksToBounds = true
        
        let arrow = UIImage(named: "arrow")
        icon_arrow.image = arrow?.withRenderingMode(.alwaysTemplate)
        icon_arrow.tintColor = UIColor(hexString: "#092D37")
        card_image.layer.cornerRadius = card_image.frame.size.height / 2
        card_image.layer.masksToBounds = true
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                // light mode detected
                break
            case .dark:
                // dark mode detected
                cardTitle.textColor = .black
                break
            @unknown default:
                break
        }
    }
    
    func configureCell(product: SearchQueryProduct) {
        self.product = product        
        self.cardTitle.text = product.title
        self.cardType.text = product.card_type
        self.view_number.text = product.view_number
        self.likes_number.text = product.likes_number
        self.card_image.sd_setImage(with: URL(string: product.card_image)!)
        
        // Initialization code
        self.contents.layer.cornerRadius = 10
        contents.layer.shadowRadius = 5
        contents.layer.shadowColor = UIColor.lightGray.cgColor
        contents.layer.shadowOffset = .zero
        contents.layer.shadowOpacity = 1
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func shareAction(_ sender: Any) {
        delegate?.shareWithUrl(product: self.product)
    }

}
