//
//  UITextView.swift
//  Fid
//
//  Created by CROCODILE on 27.04.2021.
//

import Foundation
import UIKit

extension UITextView {

    func hyperLink(originalText: String, hyperLink: String, urlString: String, textColor: UIColor) {

        let style = NSMutableParagraphStyle()
        style.alignment = .left

        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        let fullRange = NSMakeRange(0, attributedOriginalText.length)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: fullRange)

        self.linkTextAttributes = [
            kCTForegroundColorAttributeName: textColor,
            kCTUnderlineStyleAttributeName: NSUnderlineStyle.single.rawValue,
            ] as [NSAttributedString.Key : Any]

        self.attributedText = attributedOriginalText
    }
}
