//
//  ViewController.swift
//  Fid
//
//  Created by CROCODILE on 13.01.2021.
//

import UIKit

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                        
        self.downloadSearchValues(url: SearchURL.search_word, searchParam: "search_word")
        self.downloadSearchValues(url: SearchURL.search_city, searchParam: "city_name")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
                
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcome" {
            _ = segue.destination as! WelcomeVC
        } else if segue.identifier == "main_from_register" {
            let _ = segue.destination as! SideBarVC
        }
    }
    
    func downloadSearchValues(url: String, searchParam: String) {
        APIHandler.AFGetRequest(url: url, search_param: searchParam) { response in
            print("ssss")
            var myWord = ""
            if let values = response {
                for i in 0..<values.count {
                    if i != values.count - 1 {
                        myWord = myWord + values[i] + ","
                    } else {
                        myWord = myWord + values[i]
                    }
                }
                
                if searchParam == "search_word" {
                    defaults.set(myWord, forKey: "search_words")
                } else if searchParam == "city_name" {
                    defaults.set(myWord, forKey: "search_city")
                    
                    let logout = defaults.bool(forKey: "logout")
                    if let _ = defaults.string(forKey: "firstStart") {
                        if !logout {
                            self.performSegue(withIdentifier: "main_from_register", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "welcome", sender: self)
                        }
                    } else {
                        self.performSegue(withIdentifier: "welcome", sender: self)
                    }
                }
            }
        }
    }
    
    public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + seconds
        dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
    }

    public enum DispatchLevel {
        case main, userInteractive, userInitiated, utility, background
        var dispatchQueue: DispatchQueue {
            switch self {
            case .main:                 return DispatchQueue.main
            case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
            case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
            case .utility:              return DispatchQueue.global(qos: .utility)
            case .background:           return DispatchQueue.global(qos: .background)
            }
        }
    }
}

