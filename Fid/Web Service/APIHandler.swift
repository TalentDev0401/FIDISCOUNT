//
//  APIHandler.swift
//  Fid
//
//  Created by CROCODILE on 14.01.2021.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIHandler: NSObject {
    class func AFGetRequest(url: String, search_param: String, completion: @escaping ([String]?) -> Void) {
        
        AF.request(url, encoding: JSONEncoding.default).responseJSON { response in

            var array: [String] = []
            switch response.result {
                case .success(let value):
                    print("*************")
                    print(JSON(value))
                    for item in JSON(value).arrayValue {
                        array.append(item[search_param].stringValue)
                    }
                    
                    completion(array)
                case .failure(let error):
                    print(error)
                    completion(nil)
            }
        }
    }
    
    class func AFGetRequestCardList(url: String, completion: @escaping ([CardData]?) -> Void) {
        
        AF.request(url, encoding: JSONEncoding.default).responseJSON { response in

            var array: [CardData] = []
            switch response.result {
                case .success(let value):
                    print("*************")
                    print(JSON(value))
                    for item in JSON(value).arrayValue {
                        let card_section = item["section"].stringValue
                        let card_rows = item["rows"].arrayValue
                        var rows: [FilterCard] = []
                        for item1 in card_rows {
                            let card_id = item1["card_id"].stringValue
                            let card_name = item1["card_name"].stringValue
                            let card_image = item1["card_image"].stringValue
                            let card = CardList(card_id: card_id, name: card_name, image: card_image)
                            let filter = FilterCard(checked: false, item: card)
                            rows.append(filter)
                        }
                        
                        let cardItem = CardData(section_name: card_section, rows_data: rows)
                        array.append(cardItem)
                    }
                    
                    completion(array)
                case .failure(let error):
                    print(error)
                    completion(nil)
            }
        }
    }
        
    class func AFPostRequest_LoadUserName(url: String, param: [String: String]) {
        
//        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        
        AF.request(url, method: .post, parameters: param, headers: nil).responseString { response in
            switch response.result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    class func AFPostRequest_QuerySearch(url: String, param: [String: String], completion: @escaping (_ products: [SearchQueryProduct]?, _ error: Error?) -> Void) {
        AF.request(url, method: .post, parameters: param, headers: nil).responseJSON { response in
            
            var products: [SearchQueryProduct] = []
            switch response.result {
                case .success(let value):
                    let items = JSON(value)
                    print("result is \(items)")
                    for item in items.arrayValue {
                        let title = item["title"].stringValue
                        let card_type = item["card_type"].stringValue
                        let search_url = item["search_url"].stringValue
                        let search_category = item["search_category"].stringValue
                        let card_image = item["card_image"].stringValue
                        let view_number = item["view_number"].stringValue
                        let likes_number = item["likes_number"].stringValue
                        let benefit_id = item["benafit_id"].stringValue
                        
                        var benefit_locations: [Location] = []
                        for item in item["Benafit_Location"].arrayValue {
                            let benefit = Location(lat: Double(item["lat"].stringValue)!, lon: Double(item["lon"].stringValue)!)
                            benefit_locations.append(benefit)
                        }
                        
                        let product = SearchQueryProduct(title: title, cardType: card_type, searchUrl: search_url, searchCategory: search_category, cardImage: card_image, view_number: view_number, likes_number: likes_number, benefit_id: benefit_id, locations: benefit_locations)
                        products.append(product)
                    }
                    
                    completion(products, nil)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil, error)
            }
        }
    }
    
    class func AFPostRequest_SendSearchUrl(url: String, param: [String: String], completion: @escaping (_ error: Error?) -> Void) {
        AF.request(url, method: .post, parameters: param, headers: nil).responseString { response in
            
            switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    class func AFPostRequest_SendBenefitClick(url: String, param: [String: String], completion: @escaping (_ error: Error?) -> Void) {
        AF.request(url, method: .post, parameters: param, headers: nil).responseString { response in
            
            switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    class func afPostRequest_CategoryList(url: String, param: [String: String], completion: @escaping (_ list: [CategoryList]?) -> Void) {
        AF.request(url, method: .post, parameters: param, headers: nil).responseJSON { response in
            
            var array: [CategoryList] = []
            switch response.result {
                case .success(let value):
                    
                    let items = JSON(value)
                    print(items)
                    for item in JSON(value).arrayValue {
                        let search_word = item["search_word"].stringValue
                        let lower_price = item["lower_price"].stringValue
                        let lower_card = item["lower_card"].stringValue
                        let search_image = item["search_image"].stringValue
                        let view_number = item["view_number"].stringValue
                        let catItem = CategoryList(word: search_word, price: lower_price, card: lower_card, image: search_image, view_number: view_number)
                        array.append(catItem)
                    }
                    completion(array)
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                    break
            }
        }
    }
    
    class func afPostRequest_BenefitList(url: String, param: [String: String], completion: @escaping (_ list: [Place]?) -> Void) {
        AF.request(url, method: .post, parameters: param, headers: nil).responseJSON { response in
            
            var array: [Place] = []
            switch response.result {
                case .success(let value):
                    
                    let items = JSON(value)
                    print(items)
                    for item in JSON(value).arrayValue {
                        let longitude = item["longitude"].stringValue
                        let latitude = item["latitude"].stringValue
                        let benefit_name = item["benefit_name"].stringValue
                        if latitude.contains(", ") {
                            continue
                        }
                        let placeItem = Place(lat: Double(latitude)!, lon: Double(longitude)!, name: benefit_name)
                        array.append(placeItem)
                    }
                    completion(array)
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                    break
            }
        }
    }
}
