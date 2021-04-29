//
//  RightMenuCell.swift
//  Fid
//
//  Created by CROCODILE on 16.01.2021.
//

import UIKit

class RightMenuCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                // light mode detected
                break
            case .dark:
                // dark mode detected
                title.textColor = .black
                break
            @unknown default:
                break
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
