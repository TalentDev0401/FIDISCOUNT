//
//  LikeBenefit.swift
//  Fid
//
//  Created by CROCODILE on 28.04.2021.
//

import RealmSwift

class LikeBenefit: Object {
        
    @objc dynamic var neverSynced: Bool = true
    @objc dynamic var syncRequired: Bool = true

    @objc dynamic var createdAt: Int = Date().timestamp()
    @objc dynamic var updatedAt: Int = Date().timestamp()
    
    @objc dynamic var benefit_id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var card_type: String = ""
    @objc dynamic var search_url: String = ""
    @objc dynamic var search_category: String = ""
    @objc dynamic var card_image: String = ""
    @objc dynamic var view_number: String = ""
    @objc dynamic var likes_number: String = ""
    var locations = List<LocationRealm>()

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override static func primaryKey() -> String? {

        return "benefit_id"
    }

    // MARK: -
    //---------------------------------------------------------------------------------------------------------------------------------------------
    class func encryptedProperties() -> [String] {

        return []
    }
    
    // MARK: -
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func updateSynced() {

        if (syncRequired) || (neverSynced) {
            let realm = try! Realm()
            try! realm.safeWrite {
                neverSynced = false
                syncRequired = false
            }
        }
    }
}
