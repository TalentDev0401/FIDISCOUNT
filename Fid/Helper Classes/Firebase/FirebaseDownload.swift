//
//  FirebaseDownload.swift
//  RAP
//
//  Created by TalentDev0401 on 08.12.2020.
//  Copyright © 2020 Anton Sharov. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore

class FirebaseDownload {
    
    let db = Firestore.firestore()
    
    func DownloadComments(postId: String, results: @escaping (_ comments: [ObjectComment]?, _ error: Error?) -> ()) {
        db.collection("Comments").document(postId).collection(postId).getDocuments() { querySnapshot, error in
            
            if let err = error {
                print(err.localizedDescription)
                results(nil, err)
                return
            }
                        
            var comments: [ObjectComment] = [ObjectComment]()
            for document in querySnapshot!.documents {
                if let objectData = document.data().data, let object = try? JSONDecoder().decode(ObjectComment.self, from: objectData) {
                    comments.append(object)
                }
            }
            results(comments, nil)
        }
    }
}
