//
//  CommentTableCell.swift
//  RAP
//
//  Created by CROCODILE on 22.12.2020.
//  Copyright © 2020 Anton Sharov. All rights reserved.
//

import UIKit
import ActiveLabel

protocol CommentDelegate: class {
    func replyComment(username: String)
    func handleMention(username: String)
    func handleHashTag(tagname: String)
    func handleURL(url: URL)
}

class CommentTableCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameTxt: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var labelCommentText: ActiveLabel!
    @IBOutlet weak var commentTime: UILabel!
    @IBOutlet weak var likesBadge: UILabel!
    @IBOutlet weak var initialTxt: UILabel!
    @IBOutlet weak var replyBtn: UIButton!
    
    weak var delegate: CommentDelegate?
    
    var commentInfo: ObjectComment!
        
    let firebaseUpload = FirebaseUpload()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                // light mode detected
                break
            case .dark:
                // dark mode detected
                likesBadge.textColor = UIColor(hexString: "#FCA324")
                commentTime.textColor = UIColor(hexString: "#FCA324")
                usernameTxt.textColor = UIColor(hexString: "#FCA324")
                replyBtn.setTitleColor(UIColor(hexString: "#FCA324"), for: .normal)
                break
            @unknown default:
                break
        }
    }
    
    func configure(comment: ObjectComment) {
        self.commentInfo = comment
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 2
        self.userImageView.layer.borderWidth = 1.0
        self.userImageView.layer.borderColor = UIColor.gray.cgColor
        self.userImageView.layer.masksToBounds = true
        self.loadPerson(userId: comment.userId!)
        self.usernameTxt.text = comment.userName
        self.configureActiveLabel(comment: comment)
        self.commentTime.text = comment.postTime
        if let likes = comment.likes {
            self.likesBadge.text = "\(likes.count)"
            let me = likes.filter { $0 == AuthUser.userId() }
            if me.count != 0 {
                self.likeBtn.tag = 1
                self.likeBtn.setImage(UIImage(named: "icon_benefit_likes"), for: .normal)
            } else {
                self.likeBtn.tag = 0
                self.likeBtn.setImage(UIImage(named: "icon_benefit_unlikes"), for: .normal)
            }
        } else {
            self.likesBadge.text = "0"
        }
    }
    
    func configureActiveLabel(comment: ObjectComment) {
                
        labelCommentText.customize { label in
            label.text = comment.comment
            label.numberOfLines = 0
            label.lineSpacing = 4
            label.urlMaximumLength = 31
                        
            switch traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    // light mode detected
                    label.textColor = UIColor.black
                    break
                case .dark:
                    // dark mode detected
                    label.textColor = .white
                    break
                @unknown default:
                    break
            }            
            
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
            label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
            label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)

            label.handleMentionTap {
                self.delegate?.handleMention(username: $0)
                print("mention \($0)") }
            label.handleHashtagTap {
                self.delegate?.handleHashTag(tagname: $0)
                print("hashtag \($0)") }
            label.handleURLTap {
                self.delegate?.handleURL(url: $0)
                print("url \($0.absoluteString)") }

            //Custom types
            
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                atts[NSAttributedString.Key.font] = isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.boldSystemFont(ofSize: 14)
                
                return atts
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func favoriteAction(_ sender: Any) {
        if self.commentInfo.userId != AuthUser.userId() {
            if self.likeBtn.tag == 0 {
                self.likeBtn.tag = 1
                self.likeBtn.setImage(UIImage(named: "icon_benefit_likes"), for: .normal)
                self.commentInfo.likes?.append(AuthUser.userId())
                self.likesBadge.text = "\(self.commentInfo.likes!.count)"
                
                // - Update favorite badge
                firebaseUpload.updateCommentLikesInfo(postId: self.commentInfo.postId!, commentId: self.commentInfo.id, status: true)
                
            } else {
                self.likeBtn.tag = 0
                self.likeBtn.setImage(UIImage(named: "icon_benefit_unlikes"), for: .normal)
                self.commentInfo.likes = self.commentInfo.likes?.filter { $0 != AuthUser.userId() }
                self.likesBadge.text = "\(self.commentInfo.likes!.count)"
                firebaseUpload.updateCommentLikesInfo(postId: self.commentInfo.postId!, commentId: self.commentInfo.id, status: false)
            }
        }
    }
    
    @IBAction func replyActoin(_ sender: Any) {
        if self.commentInfo.userId != AuthUser.userId() {
            delegate?.replyComment(username: self.commentInfo.userName!)
        }
    }
    
    @objc func loadPerson(userId: String) {

        let person = realm.object(ofType: Person.self, forPrimaryKey: userId)

        self.initialTxt.text = person?.initials()
        MediaDownload.user(person!.objectId, pictureAt: person!.pictureAt) { image, error in
            if (error == nil) {
                self.userImageView.image = image
                self.initialTxt.isHidden = true
            }
        }

    }
}
