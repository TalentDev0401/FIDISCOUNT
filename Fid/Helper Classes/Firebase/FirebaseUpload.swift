//
//  FirebaseUpload.swift
//  RAP
//
//  Created by TalentDev0401 on 08.12.2020.
//  Copyright © 2020 Anton Sharov. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseStorage

class FirebaseUpload {
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
        
    func UpdateComment<T>(_ object: T, postId: String, completion: @escaping CompletionObject<FirestoreResponse>) where T: FireCodable {
        guard let data = object.values else { return }
        self.db.collection("Comments").document(postId).collection(postId).document(object.id).setData(data, merge: true) { (error) in
            guard let _ = error else { completion(.success); return }
            completion(.failure)
        }
    }
        
    func updateCommentLikesInfo(postId: String, commentId: String, status: Bool) {
        if status {
            self.db.collection("Comments").document(postId).collection(postId).document(commentId).updateData(["likes": FieldValue.arrayUnion([AuthUser.userId()])])
        } else {
            self.db.collection("Comments").document(postId).collection(postId).document(commentId).updateData(["likes": FieldValue.arrayRemove([AuthUser.userId()])])
        }
    }
}
