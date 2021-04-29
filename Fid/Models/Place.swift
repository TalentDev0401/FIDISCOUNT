//
//  Place.swift
//  Fid
//
//  Created by CROCODILE on 09.03.2021.
//

import Foundation
import UIKit
import CoreLocation

class Place {
    
    var lat: CLLocationDegrees!
    var lon: CLLocationDegrees!
    var name: String!
    
    init(lat: Double, lon: Double, name: String) {
        self.lat = lat
        self.lon = lon
        self.name = name
    }
}
