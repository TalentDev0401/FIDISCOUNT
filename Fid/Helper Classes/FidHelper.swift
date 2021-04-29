//
//  FidHelper.swift
//  Fid
//
//  Created by CROCODILE on 13.01.2021.
//

import Foundation
import UIKit
import Firebase

let defaults = UserDefaults.standard

class FidHelper {
    static let shared = FidHelper()
    
    let darkPrimary = UIColor(hexString: "#05191f")
    let lightPrimary = UIColor(hexString: "#0d2d38")
    
    var goBackRegister: Bool = false
    var benefit: SearchQueryProduct?
    var chatsFromBenefit: Bool = false
    
    func signedOut() {
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    func getMainData() -> [MainData] {
        
        var datas = [MainData]()
        
        datas.append(MainData(key: "cat1.png", value: "מופעים וקולנוע"))
        datas.append(MainData(key: "cat2.png", value: "אטרקציות"))
        datas.append(MainData(key: "cat3.png", value: "מזון מהיר ומסעדות"))
        datas.append(MainData(key: "cat4.png", value: "נופש"))
        datas.append(MainData(key: "cat5.png", value: "ספא ופנאי"))
        datas.append(MainData(key: "cat6.png", value: "לטסים לחו\"ל"))
        datas.append(MainData(key: "cat7.png", value: "צרכנות"))
        datas.append(MainData(key: "cat8.png", value: "דלק ורכב"))
        datas.append(MainData(key: "cat9.png", value: "מותגים ורשתות"))
        
        return datas
    }
    
    func getCat1Data() -> [MainData] {
        var datas = [MainData]()
        
        datas.append(MainData(key: "cat1_1.png", value: "מוזיקאים"))
        datas.append(MainData(key: "cat1_2.png", value: "סטנדאפ"))
        datas.append(MainData(key: "cat1_3.png", value: "מופעים/\nהצגות"))
        datas.append(MainData(key: "cat1_4.png", value: "בתי קולנוע/\nאולמות מופעים"))
        
        return datas
    }
    
    func getCat2Data() -> [MainData] {
        var datas = [MainData]()
        
        datas.append(MainData(key: "cat2_1.png", value: "חדרי בריחה"))
        datas.append(MainData(key: "cat2_2.png", value: "טיולים"))
        datas.append(MainData(key: "cat2.png", value: "פארקי\nשעשועים"))
        datas.append(MainData(key: "cat2_4.png", value: "אטרקציות\nמים"))
        datas.append(MainData(key: "cat2_5.png", value: "אקסטרים"))
        datas.append(MainData(key: "cat2_6.png", value: "בעלי חיים"))
        datas.append(MainData(key: "cat2_7.png", value: "תערוכות/\nמוזיאונים"))
        datas.append(MainData(key: "cat2_8.png", value: "מתחמי\nאטרקציות"))
        datas.append(MainData(key: "cat2_9.png", value: "חדרי קריוקי"))
        return datas
    }
    
    func getCat3Data() -> [MainData] {
        
        var array = [MainData]()
        
        array.append(MainData(key: "cat3.png", value: "פיצות/\nמסעדות חלביות"))
        array.append(MainData(key: "cat3_2.png", value: "המבורגרים/\nשווארמה"))
        array.append(MainData(key: "cat3_3.png", value: "אסייתי"))
        array.append(MainData(key: "cat3_4.png", value: "בתי קפה"))
        array.append(MainData(key: "cat3_5.png", value: "מסעדות בשרים/\nים תיכונית"))
        array.append(MainData(key: "cat3_6.png", value: "מסעדות איטלקיות"))
        array.append(MainData(key: "cat3_7.png", value: "גלידות/שייקים/\nמתוקים"))
        array.append(MainData(key: "cat3_8.png", value: "פאב/בר/יקב"))
        array.append(MainData(key: "cat3_9.png", value: "שוברי אוכל"))
        return array
    }
    
    func getCat4Data() -> [MainData] {
        var array = [MainData]()
        
        array.append(MainData(key: "cat4_1.png", value: "מלונות"))
        array.append(MainData(key: "cat4_2.png", value: "צימרים"))
        array.append(MainData(key: "cat4_3.png", value: "קמפינג"))
        array.append(MainData(key: "cat4_4.png", value: "וילות"))
        array.append(MainData(key: "cat6_4.png", value: "סוכנות נסיעות"))
        return array
    }
    
    func getCat5Data() -> [MainData] {
        var array = [MainData]()
        
        array.append(MainData(key: "cat5.png", value: "ספא"))
        array.append(MainData(key: "cat5_2.png", value: "ספורט/\nמכוני כושר"))
        array.append(MainData(key: "cat5_3.png", value: "בריכות/\nמרחצאות"))
        array.append(MainData(key: "cat5_4.png", value: "העשרה/\nמגזינים"))
        array.append(MainData(key: "cat5_5.png", value: "אסתטיקה/\nטיפולים"))
        array.append(MainData(key: "cat5_6.png", value: "סדנאות/\nקורסים"))
        return array
    }
    
    func getCat6Data() -> [MainData] {
        var array = [MainData]()
        
        array.append(MainData(key: "cat6_1.png", value: "השכרת רכב"))
        array.append(MainData(key: "cat6_2.png", value: "נתבג"))
        array.append(MainData(key: "cat6_3.png", value: "שירותים"))
        array.append(MainData(key: "cat6_4.png", value: "סוכנות נסיעות"))
        return array
    }
    
    func getCat7Data() -> [MainData] {
        var array = [MainData]()
        
        array.append(MainData(key: "cat7_1.png", value: "חשמל לבית\nולמטבח"))
        array.append(MainData(key: "cat7_2.png", value: "ריהוט\nועיצוב הבית"))
        array.append(MainData(key: "cat7_3.png", value: "מטבח ואירוח"))
        array.append(MainData(key: "cat7_4.png", value: "טקסטיל"))
        array.append(MainData(key: "cat7_5.png", value: "פארם/טיפוח\nובריאות"))
        array.append(MainData(key: "cat7_6.png", value: "מסכים/מחשבים\nוגיימינג"))
        array.append(MainData(key: "cat7_7.png", value: "כלי עבודה/טיולים\nוקמפינג"))
        array.append(MainData(key: "cat7_8.png", value: "ספורט/אופנה\nופנאי"))
        array.append(MainData(key: "cat7_9.png", value: "תינוקות/ילדים\nונוער"))
        return array
    }
    
    func getCat8Data() -> [MainData] {
        var array = [MainData]()
        
        array.append(MainData(key: "cat8.png", value: "השכרת רכב"))
        array.append(MainData(key: "cat8_2.png", value: "תחנות דלק"))
        array.append(MainData(key: "cat8_3.png", value: "שירותים לרכב"))
        array.append(MainData(key: "cat8_4.png", value: "אביזרים לרכב"))
        return array
    }
    
    func getCat9Data() -> [MainData] {
        var array = [MainData]()
        
        array.append(MainData(key: "cat9_1.png", value: "שוברים/מתנות/\nפרחים ואלבומים"))
        array.append(MainData(key: "cat9_2.png", value: "רשתות שיווק מזון"))
        array.append(MainData(key: "cat9_3.png", value: "אופנה ביגוד"))
        array.append(MainData(key: "cat9_4.png", value: "לבית"))
        array.append(MainData(key: "cat9_5.png", value: "הנעלה"))
        array.append(MainData(key: "cat9_6.png", value: "צעצועים/תינוקות\nוילדים"))
        array.append(MainData(key: "cat9_7.png", value: "תכשיטים/\nמשקפיים ואקססורייז"))
        array.append(MainData(key: "cat9_8.png", value: "חשמל/ציוד ספורט\nוציוד משרדי"))
        array.append(MainData(key: "cat9_9.png", value: "פארם/איפור\nוטיפוח"))
        return array
    }
}
