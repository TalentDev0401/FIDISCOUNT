//
//  ObjectComment.swift
//  RAP
//
//  Created by CROCODILE on 22.12.2020.
//  Copyright © 2020 Anton Sharov. All rights reserved.
//

import Foundation
import UIKit

class ObjectComment: FireCodable {
    
    var id = UUID().uuidString
    var userId: String?
    var userName: String?
    var comment: String?
    var postId: String?
    var postTime: String?
    var likes: [String]?
    var replies: [String]?
    var timestamp = Int(Date().timeIntervalSince1970)
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(userId, forKey: .userId)
    try container.encodeIfPresent(userName, forKey: .userName)
    try container.encodeIfPresent(comment, forKey: .comment)
    try container.encodeIfPresent(postId, forKey: .postId)
    try container.encodeIfPresent(postTime, forKey: .postTime)
    try container.encodeIfPresent(likes, forKey: .likes)
    try container.encodeIfPresent(replies, forKey: .replies)
    try container.encode(timestamp, forKey: .timestamp)
  }
  
  init() {}
  
  public required convenience init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    userId = try container.decodeIfPresent(String.self, forKey: .userId)
    userName = try container.decodeIfPresent(String.self, forKey: .userName)
    comment = try container.decodeIfPresent(String.self, forKey: .comment)
    postId = try container.decodeIfPresent(String.self, forKey: .postId)
    postTime = try container.decodeIfPresent(String.self, forKey: .postTime)
    likes = try container.decodeIfPresent([String].self, forKey: .likes)
    replies = try container.decodeIfPresent([String].self, forKey: .replies)
    timestamp = try container.decode(Int.self, forKey: .timestamp)
  }
}

extension ObjectComment {
  private enum CodingKeys: String, CodingKey {
    case id
    case userId    
    case userName
    case comment
    case postId
    case postTime
    case likes
    case replies    
    case timestamp
  }
}
